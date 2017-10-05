From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 0/5] bpf: get rid of global verifier state and reuse instruction printer
Date: Thu,  5 Oct 2017 08:34:17 -0700
Message-ID: <20171005153422.8947-1-jakub.kicinski@netronome.com>
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:45230 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751330AbdJEPee (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 11:34:34 -0400
Received: by mail-pg0-f46.google.com with SMTP id b192so5350397pga.2
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 08:34:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This set started off as simple extraction of eBPF verifier's instruction
printer into a separate file but evolved into removal of global state...
The purpose of moving instruction printing code is to be able to reuse it
from the bpftool.

As far as the global verifier lock goes, this set removes the global
variables relating to the log buffer, makes the one-time init done
by bpf_get_skb_set_tunnel_proto() not depend on any external locking,
and performs verifier log writeback as data is produced removing the need
for allocating a potentially large temporary buffer.

The final step of actually removing the verifier lock is left to someone
more competent and self-confident :)


Jakub Kicinski (5):
  bpf: remove global verifier log
  bpf: move instruction printing into a separate file
  tools: bpftool: use the kernel's instruction printer
  bpf: don't rely on the verifier lock for metadata_dst allocation
  bpf: write back the verifier log buffer as it gets filled

 include/linux/bpf_verifier.h                     |   8 +
 include/net/dst_metadata.h                       |   1 +
 kernel/bpf/Makefile                              |   1 +
 kernel/bpf/disasm.c                              | 214 +++++++
 kernel/bpf/disasm.h                              |  32 +
 kernel/bpf/verifier.c                            | 710 +++++++++--------------
 net/core/dst.c                                   |  16 +
 net/core/filter.c                                |  16 +-
 tools/bpf/bpftool/Documentation/bpftool-prog.rst |  11 +-
 tools/bpf/bpftool/Makefile                       |   7 +-
 tools/bpf/bpftool/main.h                         |  10 +-
 tools/bpf/bpftool/prog.c                         |  44 +-
 12 files changed, 618 insertions(+), 452 deletions(-)
 create mode 100644 kernel/bpf/disasm.c
 create mode 100644 kernel/bpf/disasm.h

-- 
2.14.1
