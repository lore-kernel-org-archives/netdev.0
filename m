From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 0/5] BPF updates
Date: Thu, 29 Oct 2015 14:58:05 +0100
Message-ID: <cover.1446126105.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, hannes@stressinduktion.org, tgraf@suug.ch,
	viro@ZenIV.linux.org.uk, ebiederm@xmission.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This set adds support for persistent maps/progs. Please see
individual patches for further details. A man-page update
to bpf(2) will be sent later on, also a iproute2 patch for
support in tc.

Thanks!

v1 -> v2:
  - Reworked most of patch 4 and 5
  - Rebased to latest net-next

Daniel Borkmann (5):
  bpf: abstract anon_inode_getfd invocations
  bpf: align and clean bpf_{map,prog}_get helpers
  bpf: consolidate bpf_prog_put{,_rcu} dismantle paths
  bpf: add support for persistent maps/progs
  bpf: add sample usages for persistent maps/progs

 include/linux/bpf.h        |   9 +-
 include/uapi/linux/bpf.h   |  45 +-----
 include/uapi/linux/magic.h |   1 +
 kernel/bpf/Makefile        |   4 +-
 kernel/bpf/core.c          |   3 +-
 kernel/bpf/inode.c         | 387 +++++++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/syscall.c       |  95 +++++++----
 kernel/bpf/verifier.c      |   3 +-
 samples/bpf/Makefile       |   3 +
 samples/bpf/fds_example.c  | 183 +++++++++++++++++++++
 samples/bpf/libbpf.c       |  19 +++
 samples/bpf/libbpf.h       |   3 +
 12 files changed, 683 insertions(+), 72 deletions(-)
 create mode 100644 kernel/bpf/inode.c
 create mode 100644 samples/bpf/fds_example.c

-- 
1.9.3
