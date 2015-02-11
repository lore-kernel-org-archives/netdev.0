From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [RFC PATCH net-next 0/7] eBPF support for cls_bpf
Date: Wed, 11 Feb 2015 01:15:11 +0100
Message-ID: <cover.1423610452.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56160 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbbBKAP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 19:15:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm sending this out only as RFC as the merge window is open
anyway and Dave's pull request pending.

My plan would be to get this work fully refined and remove
some rough edges until net-next opens up again, submitting
it as non-RFC.

So for the time being similarly as the recent OVS eBPF action
patchset this may serve as a discussion ground, also wrt to
the BPF tutorial at netdev01 [1].

I presume on top of this e.g. Jiri might want to follow-up
with act_bpf, I'm also open/happy to contribute to it.

The series starts with a couple of cleanups and making the
prog type infrastructure pluggable in eBPF. Most interesting
is probably the last patch that adds actual support and the
iproute2 bits from the link below.

With regards to accessing fields from the context (here: skb),
I leave that for future work just as we currently do in socket
filters, also with regard to the currently ongoing ABI discussion
from tracing side. Nevertheless, the state with these patches
still allows for interesting functionality to be implemented as
complex classifiers, e.g. such as a fully fledged C-like flow
dissector as shown in bpf samples directory and the like.

iproute2 part:

   http://git.breakpoint.cc/cgit/dborkman/iproute2.git/log/?h=ebpf

I have configured and built LLVM with: --enable-experimental-targets=BPF

  [1] https://www.netdev01.org/sessions/15

Thanks !

Daniel Borkmann (7):
  ebpf: remove kernel test stubs
  ebpf: constify various function pointer structs
  ebpf: check first for MAXINSNS in bpf_prog_load
  ebpf: extend program type/subsystem registration
  ebpf: export BPF_PSEUDO_MAP_FD to uapi
  ebpf: remove CONFIG_BPF_SYSCALL ifdefs in socket filter code
  cls_bpf: add initial eBPF support for programmable classifiers

 include/linux/bpf.h          |  46 +++++++---
 include/linux/filter.h       |   2 -
 include/uapi/linux/bpf.h     |   3 +
 include/uapi/linux/pkt_cls.h |   1 +
 kernel/bpf/Makefile          |   3 -
 kernel/bpf/arraymap.c        |   6 +-
 kernel/bpf/hashtab.c         |   6 +-
 kernel/bpf/helpers.c         |   9 +-
 kernel/bpf/syscall.c         |  96 +++++++++++++++------
 kernel/bpf/test_stub.c       |  78 -----------------
 kernel/bpf/verifier.c        |  28 ++++--
 net/core/filter.c            | 169 +++++++++++++++++-------------------
 net/sched/cls_bpf.c          | 200 ++++++++++++++++++++++++++++++++-----------
 samples/bpf/libbpf.h         |   4 +-
 samples/bpf/test_verifier.c  |   5 +-
 15 files changed, 374 insertions(+), 282 deletions(-)
 delete mode 100644 kernel/bpf/test_stub.c

-- 
1.9.3
