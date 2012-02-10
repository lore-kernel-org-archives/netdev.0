From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 10 Feb 2012 16:00:44 -0500 (EST)
Message-ID: <20120210.160044.887345417822322200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I'll keep an eye out to make sure that bluetooth inline fix needed for
bleeding edge GCC's gets integrated soon.

1) GRO MAC header comparisons were ethernet specific, breaking other
   link types.  This required a multi-faceted fix to cure the
   originally noted case (Infiniband), because IPoIB was lying about
   it's actual hard header length.  Thanks to Eric Dumazet, Roland
   Dreier, and others.

2) Fix build failure when INET_UDP_DIAG is built in and ipv6 is modular.
   From Anisse Astier.

3) Off by ones and other bug fixes in netprio_cgroup from Neil Horman.

4) ipv4 TCP reset generation needs to respect any network interface
   binding from the socket, otherwise route lookups might give a
   different result than all the other segments received.  From Shawn
   Lu.

5) Fix unintended regression in ipv4 proxy ARP responses, from Thomas
   Graf.

6) Fix SKB under-allocation bug in sh_eth, from Yoshihiro Shimoda.

7) Revert skge PCI mapping changes that are causing crashes for some
   folks, from Stephen Hemminger.

8) IPV4 route lookups fill in the wildcarded fields of the given flow
   lookup key passed in, which is fine most of the time as this is
   exactly what the caller's want.  However there are a few cases that
   want to retain the original flow key values afterwards, so handle
   those cases properly.  Fix from Julian Anastasov.

9) IGB/IXGBE VF lookup bug fixes from Greg Rose.

10) Properly null terminate filename passed to ethtool flash device
    method, from Ben Hutchings.

11) S3 resume fix in via-velocity from David Lv.

12) Fix double SKB free during xmit failure in CAIF, from Dmitry Tarnyagin.

Please pull, thanks a lot!

The following changes since commit 612b8507c5d545feed2437b3d2239929cac7688d:

  Merge branch 'drm-fixes' of git://people.freedesktop.org/~airlied/linux (2012-02-10 09:06:25 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Al Viro (1):
      CONFIG_TR/CONFIG_LLC: work around the problem with select

Alexander Duyck (1):
      ixgbe: Fix broken dependency on MAX_SKB_FRAGS being related to page size

Amitkumar Karwar (2):
      mwifiex: handle association failure case correctly
      mwifiex: add NULL checks in driver unload path

Anisse Astier (1):
      net: Fix build regression when INET_UDP_DIAG=y and IPV6=m

Arun Sharma (1):
      net: Disambiguate kernel message

Atsushi Nemoto (1):
      net: enable TC35815 for MIPS again

Ben Hutchings (1):
      ethtool: Null-terminate filename passed to ethtool_ops::flash_device

Dan Carpenter (2):
      isdn: type bug in isdn_net_header()
      bna: fix error handling of bnad_get_flash_partition_by_offset()

David Lv (1):
      via-velocity: S3 resume fix.

David S. Miller (3):
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wireless
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wireless
      net: Make qdisc_skb_cb upper size bound explicit.

Dean Nelson (1):
      e1000: add dropped DMA receive enable back in for WoL

Dmitry Tarnyagin (1):
      caif: Bugfix double kfree_skb upon xmit failure

Don Skidmore (1):
      ixgbe: update copyright to 2012

Eliad Peller (1):
      mac80211: timeout a single frame in the rx reorder buffer

Emmanuel Grumbach (1):
      iwlwifi: don't mess up QoS counters with non-QoS frames

Eric Dumazet (1):
      gro: more generic L2 header check

Eugenia Emantayev (3):
      mlx4_core: fix memory leak at multi_func_cleanup
      mlx4_core: use correct flag for unicast_promisc
      mlx4_core: use correct port for steering

Felix Fietkau (2):
      ath9k: fix a WEP crypto related regression
      ath9k_hw: fix a RTS/CTS timeout regression

Greg Rose (6):
      ixgbe: Add warning when no space left for more MAC filters
      ixgbevf: Fix mailbox interrupt ack bug
      ixgbevf: Update copyright notices
      igb: fix vf lookup
      ixgbe: fix vf lookup
      ixgbe: Fix case of Tx Hang in PF with 32 VFs

Haiyang Zhang (2):
      net/hyperv: Use netif_tx_disable() instead of netif_stop_queue() when necessary
      net/hyperv: Fix the page buffer when an RNDIS message goes beyond page boundary

Hauke Mehrtens (1):
      ssb: fix cardbus slot in hostmode

Henrik Rydberg (1):
      bcma: don't fail for bad SPROM CRC

Jason Wang (1):
      tcp: properly initialize tcp memory limits

Jesper Juhl (2):
      bcma: Fix mem leak in bcma_bus_scan()
      bnx2x: Fix mem leak in bnx2x_tpa_stop() if build_skb() fails.

John Fastabend (2):
      ixgbe: dcb: up2tc mapping lost on disable/enable CEE DCB state
      ixgbe: ethtool: stats user buffer overrun

John W. Linville (4):
      iwlwifi: make "Tx aggregation enabled on ra =" be at DEBUG level
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem
      ath9k: use WARN_ON_ONCE in ath_rc_get_highest_rix
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Julia Lawall (1):
      drivers/net/ethernet/ti: Move call to PTR_ERR after reassignment

Julian Anastasov (1):
      ipv4: reset flowi parameters on route connect

Li Wei (1):
      ipv4: Fix wrong order of ip_rt_get_source() and update iph->daddr.

Luigi Tarenga (1):
      rt2800lib: fix wrong -128dBm when signal is stronger than -12dBm

Masanari Iida (1):
      ixgbe: Fix typo in ixgbe_common.h

Mitch A Williams (1):
      igbvf: change copyright date

Mohammed Shafi Shajakhan (1):
      ath9k: Fix kernel panic during driver initilization

Neil Horman (4):
      netprio_cgroup: Fix obo in get_prioidx
      netprio_cgroup: fix an off-by-one bug
      netprio_cgroup: don't allocate prio table when a device is registered
      netprio_cgroup: fix wrong memory access when NETPRIO_CGROUP=m

Richard Zhao (1):
      net: fec: correct phy_name buffer length when init phy_name

Roland Dreier (1):
      IPoIB: Stop lying about hard_header_len and use skb->cb to stash LL addresses

Sebastian Haas (1):
      can: ems_usb: Removed double netif_device_detach

Shawn Lu (1):
      tcp_v4_send_reset: binding oif to iif in no sock case

Stephane Grosjean (1):
      can: peak_pci: Fix the way channels are linked together

Stephen Hemminger (1):
      ixgbe: make ethtool strings table const

Thadeu Lima de Souza Cascardo (2):
      mlx4: allow device removal by fixing dma unmap size
      mlx4: fix DMA mapping leak when allocation fails

Thomas Graf (1):
      net: Don't proxy arp respond if iif == rt->dst.dev if private VLAN is disabled

Tomas Vanek (1):
      zd1211rw: firmware needs duration_id set to zero for non-pspoll frames

Wei Yongjun (2):
      net/hyperv: rx_bytes should account the ether header size
      net/hyperv: fix the issue that large packets be dropped under bridge

Wolfgang Grandegger (3):
      can: flexcan: fix irq flooding by clearing all interrupt sources
      can: cc770: store echo skb before starting the transfer
      can: ti_hecc: use netif_rx in the interrupt

Wolfgang Zarre (1):
      can: cc770: Fix indirect access deadlock on ISA cards

Xi Wang (1):
      can: pch_can: fix error passive level test

Yi Zou (1):
      ixgbe: do not update real num queues when netdev is going away

Yoshihiro Shimoda (1):
      net: sh_eth: fix skb_over_panic happen

sjur.brandeland@stericsson.com (1):
      caif: Bugfix list_del_rcu race in cfmuxl_ctrlcmd.

stephen hemminger (1):
      Revert "skge: check for PCI dma mapping errors"

 drivers/bcma/main.c                                |    4 +-
 drivers/bcma/scan.c                                |   19 +++--
 drivers/infiniband/ulp/ipoib/ipoib.h               |    6 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c          |   55 ++++--------
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c     |   10 +--
 drivers/isdn/i4l/isdn_net.c                        |    2 +-
 drivers/net/can/cc770/cc770.c                      |    4 +-
 drivers/net/can/cc770/cc770_isa.c                  |   16 +++-
 drivers/net/can/flexcan.c                          |    7 ++-
 drivers/net/can/pch_can.c                          |    3 +-
 drivers/net/can/sja1000/peak_pci.c                 |   23 ++---
 drivers/net/can/ti_hecc.c                          |    3 +-
 drivers/net/can/usb/ems_usb.c                      |    9 --
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |    3 +-
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c    |   10 +--
 drivers/net/ethernet/emulex/benet/be_ethtool.c     |    6 +-
 drivers/net/ethernet/freescale/fec.c               |    2 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c      |   10 ++-
 drivers/net/ethernet/intel/igb/igb_main.c          |    3 +-
 drivers/net/ethernet/intel/igbvf/Makefile          |    2 +-
 drivers/net/ethernet/intel/igbvf/defines.h         |    2 +-
 drivers/net/ethernet/intel/igbvf/ethtool.c         |    2 +-
 drivers/net/ethernet/intel/igbvf/igbvf.h           |    2 +-
 drivers/net/ethernet/intel/igbvf/mbx.c             |    2 +-
 drivers/net/ethernet/intel/igbvf/mbx.h             |    2 +-
 drivers/net/ethernet/intel/igbvf/netdev.c          |    4 +-
 drivers/net/ethernet/intel/igbvf/regs.h            |    2 +-
 drivers/net/ethernet/intel/igbvf/vf.c              |    2 +-
 drivers/net/ethernet/intel/igbvf/vf.h              |    2 +-
 drivers/net/ethernet/intel/ixgbe/Makefile          |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h           |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c     |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c     |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h    |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c       |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h       |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.h |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c    |   13 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |   92 +++++++++++--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c      |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.h      |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   22 +++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c       |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h       |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c       |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h       |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |    8 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h     |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c      |    2 +-
 drivers/net/ethernet/intel/ixgbevf/Makefile        |    2 +-
 drivers/net/ethernet/intel/ixgbevf/defines.h       |    2 +-
 drivers/net/ethernet/intel/ixgbevf/ethtool.c       |    2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h       |    2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |   12 ++-
 drivers/net/ethernet/intel/ixgbevf/mbx.c           |    2 +-
 drivers/net/ethernet/intel/ixgbevf/mbx.h           |    2 +-
 drivers/net/ethernet/intel/ixgbevf/regs.h          |    2 +-
 drivers/net/ethernet/intel/ixgbevf/vf.c            |   21 ++++-
 drivers/net/ethernet/intel/ixgbevf/vf.h            |    2 +-
 drivers/net/ethernet/marvell/skge.c                |   71 +++------------
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |   10 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |    3 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |   10 ++-
 drivers/net/ethernet/mellanox/mlx4/mcg.c           |   16 ++--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |    3 +-
 drivers/net/ethernet/renesas/sh_eth.c              |    4 +-
 drivers/net/ethernet/renesas/sh_eth.h              |    3 -
 drivers/net/ethernet/ti/davinci_emac.c             |    3 +-
 drivers/net/ethernet/ti/davinci_mdio.c             |    2 +-
 drivers/net/ethernet/toshiba/Kconfig               |    2 +-
 drivers/net/ethernet/via/via-velocity.c            |    3 -
 drivers/net/hyperv/netvsc_drv.c                    |   18 ++--
 drivers/net/hyperv/rndis_filter.c                  |   32 +++++++
 drivers/net/tokenring/Kconfig                      |    5 +-
 drivers/net/wireless/ath/ath9k/hw.c                |    7 +-
 drivers/net/wireless/ath/ath9k/init.c              |    9 +-
 drivers/net/wireless/ath/ath9k/rc.c                |    2 +-
 drivers/net/wireless/ath/ath9k/recv.c              |    8 ++
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |   14 ++-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |    1 +
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      |    1 +
 drivers/net/wireless/mwifiex/init.c                |    3 +-
 drivers/net/wireless/mwifiex/main.c                |   12 ++-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |    8 ++-
 drivers/net/wireless/rt2x00/rt2800lib.c            |    8 +-
 drivers/net/wireless/zd1211rw/zd_mac.c             |    8 ++
 drivers/ssb/driver_pcicore.c                       |    2 +-
 include/linux/hyperv.h                             |    2 +-
 include/net/flow.h                                 |   10 ++
 include/net/netprio_cgroup.h                       |   48 +++++++++--
 include/net/route.h                                |    4 +
 include/net/sch_generic.h                          |    9 ++-
 include/net/tcp.h                                  |   14 ++-
 net/caif/caif_socket.c                             |   10 ++-
 net/caif/cfmuxl.c                                  |   12 +--
 net/core/dev.c                                     |   10 ++-
 net/core/ethtool.c                                 |    2 +
 net/core/netprio_cgroup.c                          |   15 +--
 net/core/sock.c                                    |    7 +-
 net/ipv4/Kconfig                                   |    2 +-
 net/ipv4/arp.c                                     |    3 +-
 net/ipv4/ip_options.c                              |    2 +-
 net/ipv4/sysctl_net_ipv4.c                         |    6 --
 net/ipv4/tcp.c                                     |   23 ++++--
 net/ipv4/tcp_ipv4.c                                |    5 +
 net/ipv4/tcp_timer.c                               |    5 +-
 net/mac80211/rx.c                                  |    2 +-
 net/sched/sch_choke.c                              |    3 +-
 net/sched/sch_netem.c                              |    3 +-
 net/sched/sch_sfb.c                                |    3 +-
 net/sched/sch_sfq.c                                |    5 +-
 116 files changed, 518 insertions(+), 400 deletions(-)
