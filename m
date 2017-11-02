From: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>
Subject: [PATCH net-next V2 0/3] tools: bpftool: show filenames of pinned objects
Date: Thu,  2 Nov 2017 16:59:14 +0900
Message-ID: <20171102075917.2780-1-bhole_prashant_q7@lab.ntt.co.jp>
Cc: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>,
        netdev@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Quentin Monnet <quentin.monnet@netronome.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:43401 "EHLO
        tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755561AbdKBIAv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 04:00:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds support to show pinned objects in object details.

Patch1 adds a funtionality to open a path in bpf-fs regardless of its object
type.

Patch2 adds actual functionality by scanning the bpf-fs once and adding
object information in hash table, with object id as a key. One object may be
associated with multiple paths because an object can be pinned multiple times

Patch3 adds command line option to enable this functionality. Making it optional
because scanning bpf-fs can be costly.

v1->v2:
 - Dynamically identify bpf-fs moutpoint
 - Close files descriptors before returning on error
 - Change command line option from {-l|--pinned} to {-f|--bpffs}
 - Updated documentation
 - Fixed line break for proper output formatting
 - Code style: wrapped lines > 80, used reverse christmastree style

Prashant Bhole (3):
  tools: bpftool: open pinned object without type check
  tools: bpftool: show filenames of pinned objects
  tools: bpftool: optionally show filenames of pinned objects

 tools/bpf/bpftool/Documentation/bpftool-map.rst  |   5 +-
 tools/bpf/bpftool/Documentation/bpftool-prog.rst |   5 +-
 tools/bpf/bpftool/common.c                       | 108 ++++++++++++++++++++++-
 tools/bpf/bpftool/main.c                         |  18 +++-
 tools/bpf/bpftool/main.h                         |  21 ++++-
 tools/bpf/bpftool/map.c                          |  22 +++++
 tools/bpf/bpftool/prog.c                         |  25 ++++++
 7 files changed, 198 insertions(+), 6 deletions(-)

-- 
2.13.6
