From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/5] Misc BPF updates
Date: Thu, 27 Apr 2017 01:39:30 +0200
Message-ID: <cover.1493249192.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57399 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754575AbdDZXk4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 19:40:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set cleans up ldimm64 leftovers from early eBPF days and
adds couple of test cases related to this to the verifier test
suite. It also cleans up the kallsyms spinlock (had same patch
also in queue) by relaxing it through switching to _bh variant.
It fixes up test_progs in relation to htons/ntohs and adds
accessor macros for the percpu tests in test_maps.

Thanks!

Daniel Borkmann (4):
  bpf, x86_64/arm64: remove old ldimm64 artifacts from jits
  bpf: add various test cases to verifier selftests
  bpf: fix _htons occurences in test_progs
  bpf: provide a generic macro for percpu values for selftests

Hannes Frederic Sowa (1):
  bpf: bpf_lock on kallsysms doesn't need to be irqsave

 arch/arm64/net/bpf_jit_comp.c                 |   9 --
 arch/x86/net/bpf_jit_comp.c                   |   7 --
 kernel/bpf/core.c                             |  12 +--
 tools/testing/selftests/bpf/bpf_util.h        |  26 +++++
 tools/testing/selftests/bpf/test_l4lb.c       |  11 +--
 tools/testing/selftests/bpf/test_maps.c       |  37 +++----
 tools/testing/selftests/bpf/test_pkt_access.c |   6 +-
 tools/testing/selftests/bpf/test_progs.c      |  10 +-
 tools/testing/selftests/bpf/test_verifier.c   | 137 ++++++++++++++++++++++++++
 9 files changed, 199 insertions(+), 56 deletions(-)

-- 
1.9.3
