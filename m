From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 17 Apr 2015 16:13:57 -0400 (EDT)
Message-ID: <20150417.161357.840055440924361246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix verifier memory corruption and other bugs in BPF layer, from
   Alexei Starovoitov.

2) Add a conservative fix for doing BPF properly in the BPF classifier
   of the packet scheduler on ingress.  Also from Alexei.

3) The SKB scrubber should not clear out the packet MARK and security
   label, from Herbert Xu.

4) Fix oops on rmmod in stmmac driver, from Bryan O'Donoghue.

5) Pause handling is not correct in the stmmac driver because it doesn't
   take into consideration the RX and TX fifo sizes.  From Vince
   Bridgers.

6) Failure path missing unlock in FOU driver, from Wang Cong.

Please pull, thanks a lot!

The following changes since commit c841e12add6926d64aa608687893465330b5a03e:

  Merge branch 'kconfig' of git://git.kernel.org/pub/scm/linux/kernel/git/mmarek/kbuild (2015-04-15 11:24:41 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to e3122b7fae7b4e3d1d49fa84f6515bcbe6cbc6fc:

  net: dsa: use DEVICE_ATTR_RW to declare temp1_max (2015-04-17 15:58:37 -0400)

----------------------------------------------------------------
Alexei Starovoitov (3):
      bpf: fix verifier memory corruption
      bpf: fix bpf helpers to use skb->mac_header relative offsets
      bpf: fix two bugs in verification logic when accessing 'ctx' pointer

Andreas Oetken (1):
      altera tse: Fix network-delays and -retransmissions after high throughput.

Anjali Singhai Jain (2):
      i40e: Add support to program FDir SB rules for VF from PF through ethtool
      i40e: For VF reset (VFR and VFLR) add some more delay

Bryan O'Donoghue (1):
      stmmac: fix oops on rmmod after assigning ip addr

Catherine Sullivan (1):
      i40e: Bump version to 1.3.2

David S. Miller (3):
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/next-queue
      Merge branch 'stmmac-flow-control'
      sfc: Fix memcpy() with const destination compiler warning.

Denys Vlasenko (1):
      netns: remove BUG_ONs from net_generic()

Erez Shitrit (1):
      IB/ipoib: Fix ndo_get_iflink

Eric Dumazet (3):
      bnx2x: Fix busy_poll vs netpoll
      tcp: tcp_get_info() should fetch socket fields once
      inet_diag: fix access to tcp cc information

Geert Uytterhoeven (1):
      net: dsa: mv88e6xxx: Add missing initialization in mv88e6xxx_set_port_state()

Greg Rose (1):
      i40e: Use new 40G speeds

Guenter Roeck (2):
      dsa: mv88e6xxx: Fix error handling in mv88e6xxx_set_port_state
      dsa: mv88e6xxx: Drop duplicate declaration of 'ret' variable

Herbert Xu (3):
      Revert "net: Reset secmark when scrubbing packet"
      skbuff: Do not scrub skb mark within the same name space
      act_mirred: Fix bogus header when redirecting from VLAN

Jesse Brandeburg (3):
      i40e: enable user dump of internal hardware state
      i40e: handle possible memory allocation failure
      i40e: get rid of unused locals

Johannes Berg (1):
      net: remove unused 'dev' argument from netif_needs_gso()

Kevin Scott (1):
      i40e/i40evf: Save WR_CSR_PROT field from DEV/FUNC capabilities

Michal Hocko (1):
      cxgb4: drop __GFP_NOFAIL allocation

Mitch Williams (5):
      i40e: stop VF rings
      i40evf: fix bad indentation
      i40evf: remove aq_pending
      i40e: notify VFs of link state
      i40e: move VF notification routines up

Thomas Gleixner (1):
      net: hip04: Make tx coalesce timer actually work

Vasu Dev (1):
      i40e: print FCoE capability reported by the device function

Vince Bridgers (5):
      stmmac: Add properties for transmit and receive fifo sizes
      stmmac: Add defines and documentation for enabling flow control
      stmmac: Read tx-fifo-depth and rx-fifo-depth from the devicetree
      stmmac: Enable unicast pause frame detect in GMAC Register 6
      stmmac: Configure Flow Control to work correctly based on rxfifo size

Vivien Didelot (1):
      net: dsa: use DEVICE_ATTR_RW to declare temp1_max

WANG Cong (1):
      fou: avoid missing unlock in failure path

Wei Yongjun (3):
      rocker: fix error return code in rocker_probe()
      ethernet: remove unused including <linux/version.h>
      netns: remove duplicated include from net_namespace.c

 Documentation/devicetree/bindings/net/ethernet.txt    |   6 +++
 Documentation/devicetree/bindings/net/stmmac.txt      |   4 ++
 drivers/infiniband/hw/cxgb4/mem.c                     |   2 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c             |   5 ++
 drivers/infiniband/ulp/ipoib/ipoib_vlan.c             |   3 +-
 drivers/net/dsa/mv88e6xxx.c                           |   8 ++--
 drivers/net/ethernet/altera/altera_tse_main.c         |   9 +++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h           | 137 ++++++++++++++++++++---------------------------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c       |   9 ++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c       |  15 ++++--
 drivers/net/ethernet/hisilicon/hip04_eth.c            |  18 ++++---
 drivers/net/ethernet/intel/i40e/i40e_common.c         |  65 +++++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_dcb.c            |   6 +--
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c        |  45 ++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c        |  29 +++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_main.c           |  16 +++++--
 drivers/net/ethernet/intel/i40e/i40e_nvm.c            |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h      |   5 ++
 drivers/net/ethernet/intel/i40e/i40e_type.h           |   1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c    | 244 +++++++++++++++++++++++++++++++++++++++++++++++++++-------------------------------------------
 drivers/net/ethernet/intel/i40evf/i40e_type.h         |   1 +
 drivers/net/ethernet/intel/i40evf/i40evf.h            |   1 -
 drivers/net/ethernet/intel/i40evf/i40evf_main.c       |   9 +---
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c   |  42 +++++------------
 drivers/net/ethernet/qualcomm/qca_spi.c               |   1 -
 drivers/net/ethernet/rocker/rocker.c                  |   1 +
 drivers/net/ethernet/sfc/selftest.c                   |   2 +-
 drivers/net/ethernet/stmicro/stmmac/common.h          |   5 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h       |  51 ++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c  |   5 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c   |  26 +++++++++-
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c    |   2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     |  22 +++++----
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |   4 ++
 drivers/net/ifb.c                                     |   2 +-
 drivers/net/macvtap.c                                 |   2 +-
 drivers/net/xen-netfront.c                            |   2 +-
 include/linux/netdevice.h                             |   2 +-
 include/linux/stmmac.h                                |   2 +
 include/net/netns/generic.h                           |   2 -
 include/net/tcp.h                                     |   2 +-
 include/uapi/linux/bpf.h                              |   2 +-
 include/uapi/linux/filter.h                           |   7 ++-
 kernel/bpf/verifier.c                                 |  12 +++--
 net/core/dev.c                                        |   2 +-
 net/core/filter.c                                     |  41 ++++++++++++----
 net/core/net_namespace.c                              |   1 -
 net/core/skbuff.c                                     |  10 ++--
 net/dsa/dsa.c                                         |   6 +--
 net/ipv4/fou.c                                        |   3 +-
 net/ipv4/inet_diag.c                                  |  28 ++++++++---
 net/ipv4/tcp.c                                        |  10 ++--
 net/ipv4/tcp_dctcp.c                                  |   5 +-
 net/ipv4/tcp_illinois.c                               |   6 +--
 net/ipv4/tcp_vegas.c                                  |   5 +-
 net/ipv4/tcp_vegas.h                                  |   2 +-
 net/ipv4/tcp_westwood.c                               |   6 +--
 net/sched/act_bpf.c                                   |   3 ++
 net/sched/act_mirred.c                                |   2 +-
 net/sched/cls_bpf.c                                   |   3 ++
 samples/bpf/tcbpf1_kern.c                             |  16 +++----
 samples/bpf/test_verifier.c                           |  22 +++++++++
 62 files changed, 656 insertions(+), 352 deletions(-)
