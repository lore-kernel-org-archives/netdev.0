From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 01 Apr 2015 15:48:47 -0400 (EDT)
Message-ID: <20150401.154847.612566794393812348.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix use-after-free with mac80211 RX A-MPDU reorder timer, from Johan=
nes
   Berg.

2) iwlwifi leaks memory every module load/unload cycles, fix from Larry
   Finger.

3) Need to use for_each_netdev_safe() in rtnl_group_changelink() otherw=
ise
   we can crash, from WANG Cong.

4) mlx4 driver does register_netdev() too early in the probe sequence,
   from Ido Shamay.

5) Don't allow router discovery hop limit to decrease the interface's
   hop limit, from D.S. Ljungmark.

6) tx_packets and tx_bytes improperly accounted for certain classes of
   USB network devices, fix from Ben Hutchings.

7) ip{6}mr_rules_init() mistakenly use plain kfree to release the ipmr =
tables
   in the error path, they must instead use ip{6}mr_free_table().  Fix =
from
   WANG Cong.

8) cxgb4 doesn't properly quiesce all RX activity before unregistering =
the
   netdevice.  Fix from Hariprasad Shenai.

9) Fix hash corruptions in ipvlan driver, from Jiri Benc.

10) nla_memcpy(), like a real memcpy, should fully initialize the
    destination buffer, even if the source attribute is smaller.  Fix
    from Jiri Benc.

11) Fix wrong error code returned from iucv_sock_sendmsg().  We should
    use whatever sock_alloc_send_skb() put into 'err'.  From Eugene
    Crosser.

12) Fix slab object leak on module unload in TIPC, from Ying Xue.

13) Need a READ_ONCE() when reading the cached RX socket route in
    tcp_v{4,6}_early_demux().  From Michal Kubecek.

14) Still too many problems with TPC support in the ath9k driver, so
    disable it for now.  From Felix Fietkau.

15) When in AP mode the rtlwifi driver can leak DMA mappings, fix from
    Larry Finger.

16) Missing kzalloc() failure check in gs_usb CAN driver, from Colin
    Ian King.

Please pull, thanks a lot!

The following changes since commit 90a5a895cc8b284ac522757a01de15e36710=
c2b9:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-0=
3-23 10:16:13 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to f5f321c43150cb4db8f342c8479c6fbdbe20b338=
:

  Merge tag 'wireless-drivers-for-davem-2015-04-01' of git://git.kernel=
=2Eorg/pub/scm/linux/kernel/git/kvalo/wireless-drivers (2015-04-01 14:4=
8:50 -0400)

----------------------------------------------------------------

Ahmed S. Darwish (2):
      can: kvaser_usb: Comply with firmware max tx URBs value
      can: kvaser_usb: Fix sparse warning __le16 degrades to integer

Alexey Kodanev (1):
      net: tcp6: fix double call of tcp_v6_fill_cb()

Andreas Werner (1):
      can: flexcan: Deferred on Regulator return EPROBE_DEFER

Andri Yngvason (1):
      can: flexcan: fix bus-off error state handling.

Anton Nayshtut (1):
      bonding: Bonding Overriding Configuration logic restored.

Arend van Spriel (1):
      brcmfmac: disable MBSS feature for BCM43362

Ben Hutchings (2):
      usbnet: Fix tx_packets stat for FLAG_MULTI_FRAME drivers
      usbnet: Fix tx_bytes statistic running backward in cdc_ncm

Christian Hesse (1):
      net/usb/r8152: add device id for Lenovo TP USB 3.0 Ethernet

Cliff Clark (1):
      ucc_geth: Intialize link state to down before register_netdev

Colin Ian King (1):
      can: gs_usb: check for kzalloc allocation failure

D.S. Ljungmark (1):
      ipv6: Don't reduce hop limit for an interface

David S. Miller (9):
      Merge tag 'linux-can-fixes-for-4.0-20150322' of git://git.kernel.=
org/.../mkl/linux-can
      Merge tag 'wireless-drivers-for-davem-2015-03-24' of git://git.ke=
rnel.org/.../kvalo/wireless-drivers
      Merge branch 'mlx4'
      Merge branch 'cxgb4'
      Merge branch 'ipvlan-corruptions'
      Merge branch 'bnx2'
      Merge tag 'mac80211-for-davem-2015-04-01' of git://git.kernel.org=
/.../jberg/mac80211
      Merge branch 'cxgb4-net'
      Merge tag 'wireless-drivers-for-davem-2015-04-01' of git://git.ke=
rnel.org/.../kvalo/wireless-drivers

Emmanuel Grumbach (2):
      iwlwifi: dvm: drop VO packets when mac80211 tells us to
      iwlwifi: dvm: run INIT firmware again upon .start()

Eugene Crosser (1):
      af_iucv: fix AF_IUCV sendmsg() errno

=46elix Fietkau (2):
      ath9k: fix tracking of enabled AP beacons
      ath9k: disable TPC support again (for now)

Hariprasad Shenai (6):
      cxgb4: Fix frame size warning for 32 bit arch
      cxgb4: Allocate dynamic mem. for egress and ingress queue maps
      cxgb4: Disable interrupts and napi before unregistering netdev
      cxgb4vf: Fix sparse warnings
      cxgb4: Firmware macro changes for fw verison 1.13.32.0
      cxgb4: Fix to dump devlog, even if FW is crashed

Ido Shamay (1):
      net/mlx4_en: Call register_netdevice in the proper location

Jack Morgenstein (1):
      net/mlx4_core: Fix GEN_EQE accessing uninitialixed mutex

Jeff Kirsher (1):
      MAINTAINERS: Update Intel Wired Ethernet Driver info

Jiri Benc (5):
      ipvlan: fix addr hash list corruption
      ipvlan: protect against concurrent link removal
      ipvlan: do not use rcu operations for address list
      ipvlan: fix check for IP addresses in control path
      netlink: pad nla_memcpy dest buffer with zeroes

Johannes Berg (4):
      iwlwifi: mvm: disconnect if CSA time event fails scheduling
      iwlwifi: mvm: protect rate scaling against non-mvm IBSS stations
      iwlwifi: mvm: remove WARN_ON for invalid BA notification
      mac80211: fix RX A-MPDU session reorder timer deletion

Kalle Valo (2):
      Merge tag 'iwlwifi-for-kalle-2014-03-22' of https://git.kernel.or=
g/.../iwlwifi/iwlwifi-fixes
      Merge tag 'iwlwifi-for-kalle-2015-03-30' of https://git.kernel.or=
g/.../iwlwifi/iwlwifi-fixes

Larry Finger (2):
      rtlwifi: Fix IOMMU mapping leak in AP mode
      iwlwifi: Fix memory leak in iwl_req_fw_callback()

Michal Kube=E8ek (1):
      tcp: prevent fetching dst twice in early demux code

Nicolas Dichtel (1):
      netns: don't clear nsid too early on removal

Oren Givon (1):
      iwlwifi: add new 3165 series PCI IDs

Simon Horman (1):
      rocker: handle non-bridge master change

Stephane Grosjean (2):
      can: peak_usb: rename usb option cmds definition and structs
      can: peak_usb_fd: add support for ISO / non-ISO mode switching

Thomas Graf (1):
      openvswitch: Return vport module ref before destruction

Uwe Kleine-K=F6nig (1):
      net: fec: setup right value for mdio hold time

WANG Cong (2):
      net: use for_each_netdev_safe() in rtnl_group_changelink()
      ipmr,ip6mr: call ip6mr_free_table() on failure path

Ying Xue (1):
      tipc: fix a slab object leak

Yuval Mintz (3):
      bnx2x: Fix statistics locking scheme
      bnx2x: Fix kdump on 4-port device
      bnx2x: Fix kdump when iommu=3Don

 MAINTAINERS                                           |  25 ++++++----=
--
 drivers/net/bonding/bond_main.c                       |   3 +-
 drivers/net/can/flexcan.c                             |  18 +++++----
 drivers/net/can/usb/gs_usb.c                          |   2 +
 drivers/net/can/usb/kvaser_usb.c                      |  69 ++++++++++=
+++++++++-------------
 drivers/net/can/usb/peak_usb/pcan_ucan.h              |  15 +++----
 drivers/net/can/usb/peak_usb/pcan_usb_fd.c            |  73 ++++++++++=
+++++++++++++-----------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h           |   4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c      |  99 ++++++++++=
+++++++++++++++---------------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c     |   4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c     | 162 ++++++++++=
++++++++++++++++++++++++-----------------------------------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h     |   6 +--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h            |  14 ++++---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c    |   8 +++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c       | 137 ++++++++++=
+++++++++++++++++++++++++++++++++++------------------
 drivers/net/ethernet/chelsio/cxgb4/sge.c              |   7 ++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c            |  53 ++++++++++=
+++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h          |   3 ++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h         |  39 ++++++++++=
+++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h     |   8 ++--
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c            |  12 ++++--
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c        |   6 +--
 drivers/net/ethernet/freescale/fec_main.c             |  30 ++++++++++=
++--
 drivers/net/ethernet/freescale/ucc_geth.c             |   3 ++
 drivers/net/ethernet/mellanox/mlx4/cmd.c              |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c        |  15 +++----
 drivers/net/ethernet/mellanox/mlx4/eq.c               |  18 ++++-----
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |   6 +++
 drivers/net/ethernet/rocker/rocker.c                  |   8 +++-
 drivers/net/ipvlan/ipvlan.h                           |   4 +-
 drivers/net/ipvlan/ipvlan_core.c                      |  28 +++++++++-=
---
 drivers/net/ipvlan/ipvlan_main.c                      |  30 ++++++++--=
----
 drivers/net/usb/asix_common.c                         |   2 +
 drivers/net/usb/cdc_ether.c                           |   8 ++++
 drivers/net/usb/cdc_ncm.c                             |   6 +--
 drivers/net/usb/r8152.c                               |   2 +
 drivers/net/usb/sr9800.c                              |   1 +
 drivers/net/usb/usbnet.c                              |  17 ++++++--
 drivers/net/wireless/ath/ath9k/beacon.c               |  20 ++++++----
 drivers/net/wireless/ath/ath9k/common.h               |   2 +-
 drivers/net/wireless/ath/ath9k/hw.c                   |   2 +-
 drivers/net/wireless/brcm80211/brcmfmac/feature.c     |   3 +-
 drivers/net/wireless/iwlwifi/dvm/dev.h                |   1 -
 drivers/net/wireless/iwlwifi/dvm/mac80211.c           |  17 ++++----
 drivers/net/wireless/iwlwifi/dvm/ucode.c              |   5 ---
 drivers/net/wireless/iwlwifi/iwl-drv.c                |   1 +
 drivers/net/wireless/iwlwifi/mvm/rs.c                 |  24 ++++++++++=
-
 drivers/net/wireless/iwlwifi/mvm/time-event.c         |   2 +
 drivers/net/wireless/iwlwifi/mvm/tx.c                 |   6 ++-
 drivers/net/wireless/iwlwifi/pcie/drv.c               |   6 ++-
 drivers/net/wireless/rtlwifi/pci.c                    |  12 +++++-
 include/linux/usb/usbnet.h                            |  16 +++++++-
 lib/nlattr.c                                          |   2 +
 net/core/net_namespace.c                              |  24 ++++++----=
-
 net/core/rtnetlink.c                                  |   4 +-
 net/ipv4/ipmr.c                                       |   2 +-
 net/ipv4/tcp_ipv4.c                                   |   2 +-
 net/ipv6/ip6mr.c                                      |   2 +-
 net/ipv6/ndisc.c                                      |   9 ++++-
 net/ipv6/tcp_ipv6.c                                   |  13 +++++-
 net/iucv/af_iucv.c                                    |   4 +-
 net/mac80211/agg-rx.c                                 |   8 +++-
 net/mac80211/rx.c                                     |   7 ++--
 net/mac80211/sta_info.h                               |   2 +
 net/openvswitch/vport.c                               |   4 +-
 net/tipc/core.c                                       |   2 +-
 66 files changed, 758 insertions(+), 391 deletions(-)
