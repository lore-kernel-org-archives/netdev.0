From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 00/12] tools: bpftool: Add JSON output to bpftool
Date: Mon, 23 Oct 2017 09:24:04 -0700
Message-ID: <20171023162416.32753-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:51684 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751277AbdJWQYz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 12:24:55 -0400
Received: by mail-pg0-f66.google.com with SMTP id p9so12156221pgc.8
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 09:24:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quentin says:

This series introduces support for JSON output to all bpftool commands. It
adds option parsing, and several options are created:

  * -j, --json     Switch to JSON output.
  * -p, --pretty   Switch to JSON and print it in a human-friendly fashion.
  * -h, --help     Print generic help message.
  * -V, --version  Print version number.

This code uses a "json_writer", which is a copy of the one written by
Stephen Hemminger in iproute2.
---
I don't know if there is an easy way to share the code for json_write
without copying the file, so I am very open to suggestions on this matter.


Quentin Monnet (12):
  tools: bpftool: copy JSON writer from iproute2 repository
  tools: bpftool: add option parsing to bpftool, --help and --version
  tools: bpftool: introduce --json and --pretty options
  tools: bpftool: add JSON output for `bpftool prog show *` command
  tools: bpftool: add JSON output for `bpftool prog dump jited *`
    command
  tools: bpftool: add JSON output for `bpftool prog dump xlated *`
    command
  tools: bpftool: add JSON output for `bpftool map *` commands
  tools: bpftool: add JSON output for `bpftool batch file FILE` command
  tools: bpftool: turn err() and info() macros into functions
  tools: bpftool: provide JSON output for all possible commands
  tools: bpftool: add cosmetic changes for the manual pages
  tools: bpftool: update documentation for --json and --pretty usage

 tools/bpf/bpftool/Documentation/bpftool-map.rst  |  44 ++-
 tools/bpf/bpftool/Documentation/bpftool-prog.rst |  81 +++++-
 tools/bpf/bpftool/Documentation/bpftool.rst      |  30 +-
 tools/bpf/bpftool/common.c                       |  36 ++-
 tools/bpf/bpftool/jit_disasm.c                   |  86 +++++-
 tools/bpf/bpftool/json_writer.c                  | 356 +++++++++++++++++++++++
 tools/bpf/bpftool/json_writer.h                  |  72 +++++
 tools/bpf/bpftool/main.c                         | 121 +++++++-
 tools/bpf/bpftool/main.h                         |  43 ++-
 tools/bpf/bpftool/map.c                          | 253 ++++++++++++----
 tools/bpf/bpftool/prog.c                         | 271 +++++++++++++----
 11 files changed, 1209 insertions(+), 184 deletions(-)
 create mode 100644 tools/bpf/bpftool/json_writer.c
 create mode 100644 tools/bpf/bpftool/json_writer.h

-- 
2.14.1
