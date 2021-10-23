#!/bin/bash

# 第一引数に渡したディレクトリ配下から
# *.zipファイルのパスを取得する。
# *.zipと同一階層にある
# 被圧縮ファイル・フォルダまたは
# *.zipと同一名称のフォルダを削除する。
# ただし、ファイルとフォルダの同一性は保障しない。

RemoveExtractedDirectoryEntries() {

  while IFS= read -r z; do

    # 存在しないファイル数
    count=0

    # *.zipの存在するディレクトリ
    basePath=$(dirname "$z")

    # 「{*.zip}に解凍」とした場合のパス
    unzippedPath=${basePath:?}/$(basename -s .zip "$z")

    # ディレクトリを削除する。
    if [ -d "${unzippedPath:?}" ]; then
      rm -rfv "${unzippedPath}"
      # 以降の処理をスキップする。
      continue
    fi

    # *.zipの第1階層に位置するディレクトリのパスを格納する。
    # 初期値はLinuxおよびWindowsでディレクトリの名前に非推奨の文字列
    regexPath=//

    # 区切り文字の指定
    IFS=$'\n'

    # *.zipの圧縮ファイルごとに処理を実施する
    for e in $(zipinfo -1 "$z"); do

      unzippedPath=${basePath:?}/${e:?}
      # ディレクトリ配下のエントリに対する処理をスキップする。
      if [[ $unzippedPath =~ ^$regexPath.* ]]; then
        continue
      fi

      # ディレクトリを削除する。
      if [ -d "${unzippedPath:?}" ]; then
        # パスを格納する。
        regexPath="${unzippedPath}"
        rm -rfv "${regexPath}"
        # 以降の処理をスキップする。
        continue
      fi

      unzippedPath=${basePath:?}/$(basename "${e:?}")
      # ファイルを削除する。
      if [ -f "${unzippedPath:?}" ]; then
        rm -fv "${unzippedPath}"
        continue
      fi

      ((count++))

      # 削除対象が存在しない(未解凍)場合は処理をループを抜ける
      if [ "$count" == 3 ]; then
        break
      fi

    done

  done < <(find "$1" -maxdepth "$2" -name \*.zip)
}

# バックスラッシュをスラッシュに変換する
# ただし、バックスラッシュはエスケープとして扱われるため
# 事前にシングルクォートで囲むあるいは
# バックスラッシュをエスケープして渡す必要がある
# バックスラッシュ全てを手動で置換するよりは幾分楽であるはず。
BackSlashToSlash() {
  str="$1"
  echo "${str//\\//}"
}

RemoveExtractedDirectoryEntries "$(BackSlashToSlash "$1")" "$2"
