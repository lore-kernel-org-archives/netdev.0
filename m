From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 06 Jan 2016 17:09:51 -0500 (EST)
Message-ID: <20160106.170951.2079594647063843612.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


As usual, there are a couple straggler bug fixes:

1) qlcnic_alloc_mbx_args() error returns are not checked in qlcnic driver.
   Fix from Insu Yun.

2) SKB refcounting bug in connector, from Florian Westphal.

3) vrf_get_saddr() has to propagate fib_lookup() errors to it's callers,
   from David Ahern.

4) Fix AF_UNIX splice/bind deadlock, from Rainer Weikusat.

5) qdisc_rcu_free() fails to free the per-cpu qstats.  Fix from John
   Fastabend.

6) vmxnet3 driver passes wrong page to dma_map_page(), fix from
   Shrikrishna Khare.

7) Don't allow zero cwnd in tcp_cwnd_reduction(), from Yuchung Cheng.

Please pull, thanks a lot!

The following changes since commit 9c982e86dbdbaa3fb248dfc776dddda32cbc8927:

  Merge tag 'pci-v4.4-fixes-3' of git://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci (2015-12-31 14:59:21 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 8b8a321ff72c785ed5e8b4cf6eda20b35d427390:

  tcp: fix zero cwnd in tcp_cwnd_reduction (2016-01-06 16:39:56 -0500)

----------------------------------------------------------------
Alan (1):
      mkiss: fix scribble on freed memory

David Ahern (1):
      net: Propagate lookup failure in l3mdev_get_saddr to caller

Florian Westphal (1):
      connector: bump skb->users before callback invocation

Francesco Ruggeri (1):
      net: possible use after free in dst_release

Hannes Frederic Sowa (1):
      bridge: Only call /sbin/bridge-stp for the initial network namespace

Insu Yun (2):
      qlcnic: correctly handle qlcnic_alloc_mbx_args
      cxgb4: correctly handling failed allocation

John Fastabend (1):
      net: sched: fix missing free per cpu on qstats

Kristian Evensen (1):
      net: qmi_wwan: Add WeTelecom-WPD600N

One Thousand Gnomes (1):
      6pack: fix free memory scribbles

Rabin Vincent (2):
      net: filter: make JITs zero A for SKF_AD_ALU_XOR_X
      ARM: net: bpf: fix zero right shift

Rainer Weikusat (1):
      af_unix: Fix splice-bind deadlock

Shrikrishna Khare (1):
      Driver: Vmxnet3: Fix regression caused by 5738a09

Yuchung Cheng (1):
      tcp: fix zero cwnd in tcp_cwnd_reduction

hayeswang (1):
      r8152: add reset_resume function

 arch/arm/net/bpf_jit_32.c                       | 19 +++----------------
 arch/mips/net/bpf_jit.c                         | 16 +---------------
 arch/powerpc/net/bpf_jit_comp.c                 | 13 ++-----------
 arch/sparc/net/bpf_jit_comp.c                   | 17 ++---------------
 drivers/connector/connector.c                   | 11 +++--------
 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c   |  4 ++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c |  6 ++++--
 drivers/net/hamradio/6pack.c                    |  6 ++++++
 drivers/net/hamradio/mkiss.c                    |  5 +++++
 drivers/net/usb/qmi_wwan.c                      |  1 +
 drivers/net/usb/r8152.c                         | 10 +++++++++-
 drivers/net/vmxnet3/vmxnet3_drv.c               |  8 ++++----
 drivers/net/vmxnet3/vmxnet3_int.h               |  4 ++--
 drivers/net/vrf.c                               | 10 +++++++---
 include/linux/filter.h                          | 19 +++++++++++++++++++
 include/net/l3mdev.h                            | 16 ++++++++++------
 include/net/route.h                             |  7 ++++++-
 net/bridge/br_stp_if.c                          |  5 ++++-
 net/core/dst.c                                  |  3 ++-
 net/ipv4/raw.c                                  |  7 +++++--
 net/ipv4/tcp_input.c                            |  3 +++
 net/ipv4/udp.c                                  |  7 +++++--
 net/sched/sch_generic.c                         |  4 +++-
 net/unix/af_unix.c                              | 66 ++++++++++++++++++++++++++++++++++++++++--------------------------
 24 files changed, 150 insertions(+), 117 deletions(-)
