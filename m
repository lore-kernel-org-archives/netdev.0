From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 0/8] eBPF support for cls_bpf
Date: Sun,  1 Mar 2015 12:31:40 +0100
Message-ID: <cover.1425208501.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52007 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034AbbCALcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 06:32:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the non-RFC version of my patchset posted before netdev01 [1]
conference. It contains a couple of eBPF cleanups and preparation
patches to get eBPF support into cls_bpf. The last patch adds the
actual support. I'll post the iproute2 parts after the kernel bits
are merged, an initial preview link to the code is mentioned in the
last patch.

Patch 4 and 5 were originally one patch, but I've split them into
two parts upon request as patch 4 only is also needed for Alexei's
tracing patches that go via tip tree.

Tested with tc and all in-kernel available BPF test suites.

I have configured and built LLVM with --enable-experimental-targets=BPF
but as Alexei put it, the plan is to get rid of the experimental
status in future [2].

Thanks a lot!

v1 -> v2:
 - Removed arch patches from this series
  - x86 is already queued in tip tree, under x86/mm
  - arm64 just reposted directly to arm folks
 - Rest is unchanged

  [1] http://thread.gmane.org/gmane.linux.network/350191
  [2] http://article.gmane.org/gmane.linux.kernel/1874969

Daniel Borkmann (8):
  ebpf: remove kernel test stubs
  ebpf: constify various function pointer structs
  ebpf: export BPF_PSEUDO_MAP_FD to uapi
  ebpf: make internal bpf API independent of CONFIG_BPF_SYSCALL ifdefs
  ebpf: remove CONFIG_BPF_SYSCALL ifdefs in socket filter code
  ebpf: add sched_cls_type and map it to sk_filter's verifier ops
  ebpf: move read-only fields to bpf_prog and shrink bpf_prog_aux
  cls_bpf: add initial eBPF support for programmable classifiers

 include/linux/bpf.h          |  38 +++++---
 include/linux/filter.h       |   6 +-
 include/uapi/linux/bpf.h     |   3 +
 include/uapi/linux/pkt_cls.h |   2 +
 kernel/bpf/Makefile          |   3 -
 kernel/bpf/arraymap.c        |   6 +-
 kernel/bpf/hashtab.c         |   6 +-
 kernel/bpf/helpers.c         |   6 +-
 kernel/bpf/syscall.c         |   9 +-
 kernel/bpf/test_stub.c       |  78 ----------------
 kernel/bpf/verifier.c        |  17 +++-
 net/core/filter.c            |  47 +++++-----
 net/sched/cls_bpf.c          | 206 ++++++++++++++++++++++++++++++++-----------
 samples/bpf/libbpf.h         |   4 +-
 samples/bpf/test_verifier.c  |   5 +-
 15 files changed, 243 insertions(+), 193 deletions(-)
 delete mode 100644 kernel/bpf/test_stub.c

-- 
1.9.3
