From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 00/10] BPF updates
Date: Fri, 13 May 2016 19:08:25 +0200
Message-ID: <cover.1463158442.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, elena.reshetova@intel.com,
	zlim.lnx@gmail.com, yang.shi@linaro.org,
	holzheu@linux.vnet.ibm.com, tgraf@suug.ch, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41856 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129AbcEMRJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 13:09:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set implements constant blinding for BPF, first couple of
patches are some preparatory cleanups, followed by the blinding.
Please see individual patches for details.

Thanks a lot!

Daniel Borkmann (10):
  bpf: minor cleanups in ebpf code
  bpf: move bpf_jit_enable declaration
  bpf: split HAVE_BPF_JIT into cBPF and eBPF variant
  bpf, x86/arm64: remove useless checks on prog
  bpf: add bpf_patch_insn_single helper
  bpf: prepare bpf_int_jit_compile/bpf_prog_select_runtime apis
  bpf: add generic constant blinding for use in jits
  bpf, x86: add support for constant blinding
  bpf, arm64: add support for constant blinding
  bpf, s390: add support for constant blinding

 Documentation/sysctl/net.txt  |  11 ++
 arch/arm/Kconfig              |   2 +-
 arch/arm64/Kconfig            |   2 +-
 arch/arm64/net/bpf_jit_comp.c |  56 +++++---
 arch/mips/Kconfig             |   2 +-
 arch/powerpc/Kconfig          |   2 +-
 arch/s390/Kconfig             |   2 +-
 arch/s390/net/bpf_jit_comp.c  |  77 ++++++++---
 arch/sparc/Kconfig            |   2 +-
 arch/x86/Kconfig              |   2 +-
 arch/x86/net/bpf_jit_comp.c   |  70 +++++++---
 include/linux/filter.h        |  52 +++++++-
 include/linux/netdevice.h     |   1 -
 kernel/bpf/core.c             | 294 +++++++++++++++++++++++++++++++++++++++++-
 kernel/bpf/syscall.c          |   2 +-
 kernel/bpf/verifier.c         |  53 ++------
 lib/test_bpf.c                |   5 +-
 net/Kconfig                   |  21 ++-
 net/core/filter.c             |  40 +++---
 net/core/sysctl_net_core.c    |   9 ++
 20 files changed, 569 insertions(+), 136 deletions(-)

-- 
1.9.3
