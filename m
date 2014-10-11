From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 11 Oct 2014 17:59:49 -0400 (EDT)
Message-ID: <20141011.175949.1280849585247431047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40003 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147AbaJKV7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2014 17:59:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This set fixes a bunch of fallout from the changes that went in
during this merge window, particularly:

1) Fix fsl_pq_mdio (Claudiu Manoil) and fm10k (Pranith Kumar) build
   failures.

2) Several networking drivers do atomic_set() on page counts where
   that's not exactly legal.  From Eric Dumazet.

3) Make __skb_flow_get_ports() work cleanly with unaligned data,
   from Alexander Duyck.

4) Fix some kernel-doc buglets in rfkill and netlabel, from Fabian
   Frederick.

5) Unbalanced enable_irq_wake usage in bcmgenet and systemport
   drivers, from Florian Fainelli.

6) pxa168_eth needs to depend on HAS_DMA, from Geert Uytterhoeven.

7) Multi-dequeue in the qdisc layer severely bypasses the fairness
   limits the previous code used to enforce, reintroduce in a way that
   at the same time doesn't compromise bulk dequeue opportunities.
   From Jesper Dangaard Brouer.

8) macvlan receive path unnecessarily hops through a softirq by
   using netif_rx() instead of netif_receive_skb().  From Jason
   Baron.

Please pull, thanks a lot!

The following changes since commit 35a9ad8af0bb0fa3525e6d0d20e32551d226f38e:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next (2014-10-08 21:40:54 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 01d2d484e49e9bc0ed9b5fdaf345a0e2bf35ffed:

  Merge branch 'bcmgenet_systemport' (2014-10-10 15:39:22 -0400)

----------------------------------------------------------------

Alexander Duyck (1):
      flow-dissector: Fix alignment issue in __skb_flow_get_ports

Alexei Starovoitov (1):
      net: bpf: fix bpf syscall dependence on anon_inodes

Andrea Merello (1):
      rtl818x_pci: fix response rate may be incorrect.

Claudiu Manoil (8):
      net/fsl_pq_mdio: Fix asm/ucc.h compile error for ARM
      net/fsl_pq_mdio: Use ioread/iowrite32be() portable accessors
      net/fsl_pq_mdio: Replace spin_event_timeout() with arch independent
      gianfar: Include missing headers for ARM builds
      gianfar: Exclude PPC specific errata handling from ARM builds
      gianfar: Make MAC addr setup endian safe, cleanup
      gianfar: Replace spin_event_timeout() with arch independent
      gianfar: Replace eieio with wmb for non-PPC archs

David S. Miller (9):
      Merge branch 'gianfar'
      Merge branch 'cxgb4'
      Merge branch 'r8152'
      Merge tag 'master-2014-10-08' of git://git.kernel.org/.../linville/wireless-next
      Merge git://git.kernel.org/.../pablo/nf-next
      Merge branch 'xgene'
      Merge branch 'macvlan'
      Merge branch 'net-drivers-pgcnt'
      Merge branch 'bcmgenet_systemport'

Eric Dumazet (5):
      fm10k: fix race accessing page->_count
      igb: fix race accessing page->_count
      ixgbe: fix race accessing page->_count
      mlx4: fix race accessing page->_count
      net: fix races in page->_count manipulation

Fabian Frederick (2):
      net: rfkill: kernel-doc warning fixes
      netlabel: kernel-doc warning fix

Florian Fainelli (3):
      net: bcmgenet: fix off-by-one in incrementing read pointer
      net: bcmgenet: avoid unbalanced enable_irq_wake calls
      net: systemport: avoid unbalanced enable_irq_wake calls

Geert Uytterhoeven (1):
      net: pxa168_eth: PXA168_ETH should depend on HAS_DMA

Hariprasad Shenai (3):
      cxgb4/cxgb4vf: Updated the LSO transfer length in CPL_TX_PKT_LSO for T5
      cxgb4vf: Add 40G support for cxgb4vf driver
      cxgb4: Wait for device to get ready before reading any register

Iyappan Subramanian (6):
      MAINTAINERS: Update APM X-Gene section
      Documentation: dts: Update section header for APM X-Gene
      dtb: Add 10GbE node to APM X-Gene SoC device tree
      drivers: net: xgene: Preparing for adding 10GbE support
      drivers: net: xgene: Add 10GbE support
      drivers: net: xgene: Add 10GbE ethtool support

Jesper Dangaard Brouer (1):
      net_sched: restore qdisc quota fairness limits after bulk dequeue

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless

LEROY Christophe (1):
      net: fs_enet: error: 'SCCE_ENET_TXF' undeclared

Larry Finger (1):
      rtlwifi: Fix possible unaligned array in ether_addr_copy()

Li RongQing (2):
      Documentation: replace __sk_run_filter with __bpf_prog_run
      net: filter: fix the comments

Marek Puzyniak (1):
      ath9k_htc: avoid kernel panic in ath9k_hw_reset

Masanari Iida (1):
      net: Missing @ before descriptions cause make xmldocs warning

Pablo Neira Ayuso (2):
      netfilter: kill nf_send_reset6() from include/net/netfilter/ipv6/nf_reject.h
      netfilter: fix wrong arithmetics regarding NFT_REJECT_ICMPX_MAX

Pranith Kumar (1):
      networking: fm10k: Fix build failure

Sascha Hauer (1):
      net/phy: micrel: Add clock support for KSZ8021/KSZ8031

Sujith Manoharan (3):
      ath: Fix smatch warning
      ath9k: Fix crash in MCC mode
      ath9k: Fix sequence number assignment

Vince Bridgers (1):
      stmmac: correct mc_filter local variable in set_filter and set_mac_addr call

hayeswang (3):
      r8152: autoresume before setting feature
      r8152: adjust usb_autopm_xxx
      r8152: add mutex for hw settings

jbaron@akamai.com (2):
      macvlan: pass 'bool' type to macvlan_count_rx()
      macvlan: optimize the receive path

 Documentation/devicetree/bindings/net/apm-xgene-enet.txt |   4 +-
 Documentation/devicetree/bindings/net/micrel.txt         |   6 +
 Documentation/networking/filter.txt                      |   4 +-
 MAINTAINERS                                              |   1 -
 arch/arm64/boot/dts/apm-mustang.dts                      |   4 +
 arch/arm64/boot/dts/apm-storm.dtsi                       |  29 ++++-
 drivers/net/ethernet/apm/xgene/Makefile                  |   3 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c      |  28 ++++-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c           |  44 ++++---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h           |  30 ++---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c         |  86 ++++++++++----
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h         |  24 +++-
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c        | 331 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h        |  57 +++++++++
 drivers/net/ethernet/broadcom/bcmsysport.c               |   3 +-
 drivers/net/ethernet/broadcom/genet/bcmgenet.c           |   9 +-
 drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c       |   4 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h               |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c          |   6 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c                 |   5 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c               |  17 +--
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h              |   1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h             |   5 +-
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c      |  12 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c               |   5 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h       |   6 +
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c           |  10 +-
 drivers/net/ethernet/freescale/fs_enet/mac-fcc.c         |   2 +-
 drivers/net/ethernet/freescale/fs_enet/mac-scc.c         |   2 +-
 drivers/net/ethernet/freescale/fsl_pq_mdio.c             |  56 +++++----
 drivers/net/ethernet/freescale/gianfar.c                 |  68 ++++++-----
 drivers/net/ethernet/freescale/gianfar.h                 |  31 +++++
 drivers/net/ethernet/intel/Kconfig                       |   1 +
 drivers/net/ethernet/intel/fm10k/fm10k_main.c            |   7 +-
 drivers/net/ethernet/intel/igb/igb_main.c                |   7 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c            |   8 +-
 drivers/net/ethernet/marvell/Kconfig                     |   3 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c               |   6 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c     |   4 +-
 drivers/net/macvlan.c                                    |  21 ++--
 drivers/net/phy/micrel.c                                 |  31 ++++-
 drivers/net/usb/r8152.c                                  |  98 +++++++++++++---
 drivers/net/wireless/ath/ath9k/ath9k.h                   |   4 +-
 drivers/net/wireless/ath/ath9k/beacon.c                  |  12 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c            |   1 +
 drivers/net/wireless/ath/ath9k/main.c                    |   2 +-
 drivers/net/wireless/ath/ath9k/tx99.c                    |   8 +-
 drivers/net/wireless/ath/ath9k/xmit.c                    |  34 ++++--
 drivers/net/wireless/ath/main.c                          |   8 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c               |  36 ++++--
 drivers/net/wireless/rtlwifi/wifi.h                      |   2 +-
 include/linux/micrel_phy.h                               |   1 +
 include/net/netfilter/ipv6/nf_reject.h                   | 157 +------------------------
 include/uapi/linux/netfilter/nf_tables.h                 |   2 +-
 net/Kconfig                                              |   1 +
 net/core/filter.c                                        |   9 +-
 net/core/flow_dissector.c                                |  36 +++---
 net/core/skbuff.c                                        |  35 ++++--
 net/netfilter/nft_reject.c                               |  10 +-
 net/netlabel/netlabel_kapi.c                             |   1 -
 net/rfkill/core.c                                        |   4 +-
 net/sched/sch_generic.c                                  |  20 ++--
 62 files changed, 1017 insertions(+), 447 deletions(-)
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
