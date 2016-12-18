From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net v2 0/3] Couple of BPF fixes
Date: Sun, 18 Dec 2016 01:52:56 +0100
Message-ID: <cover.1482019225.git.daniel@iogearbox.net>
Cc: ast@fb.com, kafai@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60742 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753624AbcLRAxQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 19:53:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set contains three BPF fixes for net, one that addresses the
complaint from Geert wrt static allocations, and the other is a fix
wrt mem accounting that I found recently during testing and there's
still one more fix on the map value marking.

Thanks!

v1 -> v2:
  - Patch 1 as is.
  - Fixed kbuild bot issue by letting charging helpers stay in the
    syscall.c, since there locked_vm is valid and only export the
    ones needed by bpf_prog_realloc(). Add empty stubs in case the
    bpf syscall is not enabled.
  - Added patch 3 that addresses one more issue in map val marking.

Daniel Borkmann (3):
  bpf: dynamically allocate digest scratch buffer
  bpf: fix overflow in prog accounting
  bpf: fix mark_reg_unknown_value for spilled regs on map value marking

 include/linux/bpf.h    | 13 ++++++++++++-
 include/linux/filter.h | 14 +++++++++++---
 kernel/bpf/core.c      | 43 +++++++++++++++++++++++++++++--------------
 kernel/bpf/syscall.c   | 38 +++++++++++++++++++++++++++++---------
 kernel/bpf/verifier.c  | 17 ++++++++++++-----
 5 files changed, 93 insertions(+), 32 deletions(-)

-- 
1.9.3
