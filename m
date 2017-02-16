From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/3] Misc BPF improvements
Date: Thu, 16 Feb 2017 22:24:47 +0100
Message-ID: <cover.1487279499.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, ast@kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40162 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933553AbdBPVZh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 16:25:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This last series for this window adds various misc
improvements to BPF, one is to mark registered map and
prog types as __ro_after_init, another one for removing
cBPF stubs in eBPF JITs and moving the stub to the core
and last also improving JITs is to make generated images
visible to the kernel and kallsyms, so they can be
seen in traces. For details, please have a look at the
individual patches.

Thanks a lot!

Daniel Borkmann (3):
  bpf: mark all registered map/prog types as __ro_after_init
  bpf: remove stubs for cBPF from arch code
  bpf: make jited programs visible in traces

 Documentation/sysctl/net.txt      |  12 ++
 arch/arm64/net/bpf_jit_comp.c     |  20 ----
 arch/powerpc/net/bpf_jit_comp64.c |   3 +-
 arch/s390/net/bpf_jit_comp.c      |  26 -----
 arch/x86/net/bpf_jit_comp.c       |  23 +---
 include/linux/bpf.h               |   4 +
 include/linux/filter.h            | 112 +++++++++++++++++-
 kernel/bpf/arraymap.c             |  10 +-
 kernel/bpf/core.c                 | 235 +++++++++++++++++++++++++++++++++++++-
 kernel/bpf/hashtab.c              |   8 +-
 kernel/bpf/lpm_trie.c             |   2 +-
 kernel/bpf/stackmap.c             |   2 +-
 kernel/bpf/syscall.c              |   2 +
 kernel/extable.c                  |   9 +-
 kernel/kallsyms.c                 |  61 ++++++++--
 kernel/trace/bpf_trace.c          |   6 +-
 net/Kconfig                       |   3 +-
 net/core/filter.c                 |  18 +--
 net/core/sysctl_net_core.c        |   7 ++
 19 files changed, 453 insertions(+), 110 deletions(-)

-- 
1.9.3
