From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 31 Mar 2013 23:33:11 -0400 (EDT)
Message-ID: <20130331.233311.2279935752360417908.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) sadb_msg prepared for IPSEC userspace forgets to initialize the
   satype field, fix from Nicolas Dichtel.

2) Fix mac80211 synchronization during station removal, from Johannes
   Berg.

3) Fix IPSEC sequence number notifications when they wrap, from
   Steffen Klassert.

4) Fix cfg80211 wdev tracing crashes when add_virtual_intf() returns
   an error pointer, from Johannes Berg.

5) In mac80211, don't call into the channel context code with the
   interface list mutex held.  From Johannes Berg.

6) In mac80211, if we don't actually associate, do not restart the STA
   timer, otherwise we can crash.  From Ben Greear.

7) Missing dma_mapping_error() check in e1000, ixgb, and e1000e.  From
   Christoph Paasch.

8) Fix sja1000 driver defines to not conflict with SH port, from
   Marc Kleine-Budde.

9) Don't call il4965_rs_use_green with a NULL station, from Colin Ian
   King.

10) Suspend/Resume in the FEC driver fail because the buffer descriptor=
s
    are not initialized at all the moments in which they should.  Fix
    from Frank Li.

11) cpsw and davinci_emac drivers both use the wrong interface to resta=
rt
    a stopped TX queue.  Use netif_wake_queue not netif_start_queue,
    the latter is for initialization/bringup not active management of
    the queue.  From Mugunthan V N.

12) Fix regression in rate calculations done by psched_ratecfg_precompu=
te(),
    missing u64 type promotion.  From Sergey Popovich.

13) Fix length overflow in tg3 VPD parsing, from Kees Cook.

14) AOE driver fails to allocate enough headroom, resulting in crashes.
    Fix from Eric Dumazet.

15) RX overflow happens too quickly in sky2 driver because pause packet
    thresholds are not programmed correctly.  From Mirko Lindner.

16) Bonding driver manages arp_interval and miimon settings incorrectly=
,
    disabling one unintentionally disables both.  Fix from Nikolay
    Aleksandrov.

17) smsc75xx drivers don't program the RX mac properly for jumbo frames=
=2E
    Fix from Steve Glendinning.

18) Fix off-by-one in Codel packet scheduler.  From Vijay Subramanian.

19) Fix packet corruption in atl1c by disabling MSI support, from
    Hannes Frederic Sowa.

20) netdev_rx_handler_unregister() needs a synchronize_net() to fix cra=
shes
    in bonding driver unload stress tests.  From Eric Dumazet.

21) rxlen field of ks8851 RX packet descriptors not interpreted
    correctly (it is 12 bits not 16 bits, so needs to be masked after
    shifting the 32-bit value down 16 bits).  Fix from Max Nekludov.

22) Fix missed RX/TX enable in sh_eth driver due to mishandling of link
    change indications.  From Sergei Shtylyov.

23) Fix crashes during spurious ECI interrupts in sh_eth driver, also f=
rom
    Sergei Shtylyov.

24) dm9000 driver initialization is done wrong for revision B devices
    with DSP PHY, from Joseph CHANG.

Please pull, thanks a lot!

The following changes since commit a8c45289f215e137825bf9630d0abb41c1dc=
41ff:

  Merge tag 'iommu-fixes-v3.9-rc4' of git://git.kernel.org/pub/scm/linu=
x/kernel/git/joro/iommu (2013-03-27 09:25:11 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 6741f40d198c6a5feb23653a1efd4ca47f93d83d=
:

  DM9000B: driver initialization upgrade (2013-03-31 19:43:23 -0400)

----------------------------------------------------------------
Avinash Patil (1):
      mwifiex: reset skb->data after processing PCIe sleep confirm cmd =
respose

Ben Greear (1):
      mac80211: Don't restart sta-timer if not associated.

Christoph Paasch (3):
      e1000: ethtool: Add missing dma_mapping_error-call in e1000_setup=
_desc_rings
      ixgb: Add missing dma_mapping_error-call in ixgb_alloc_rx_buffers
      e1000e: Add missing dma_mapping_error-call in e1000_alloc_jumbo_r=
x_buffers

Colin Ian King (1):
      iwlegacy: 4965-rs: avoid null pointer dereference error

Dan Williams (1):
      libertas: drop maintainership

David S. Miller (4):
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net
      Merge branch 'fixes-for-3.9' of git://gitorious.org/linux-can/lin=
ux-can
      Merge branch 'wireless'

Dmitry Kravkov (1):
      line up comment for ndo_bridge_getlink

Emmanuel Grumbach (3):
      iwlwifi: fix length check in multi-TB HCMD
      iwlwifi: set rfkill in internal state of the transport
      iwlwifi: dvm: don't send HCMD in restart flow

Eric Dumazet (2):
      aoe: reserve enough headroom on skbs
      net: add a synchronize_net() in netdev_rx_handler_unregister()

=46rank Li (1):
      enet: fec: fix fail resume from suspend state

Hannes Frederic Sowa (2):
      ipv6: don't accept node local multicast traffic from the wire
      atl1e: drop pci-msi support because of packet corruption

Iestyn C. Elfick (1):
      b43: A fix for DMA transmission sequence errors

Johannes Berg (6):
      mac80211: always synchronize_net() during station removal
      cfg80211: fix potential BSS memory leak and update
      mac80211: fix crash with P2P Device returning action frames
      cfg80211: fix wdev tracing crash
      mac80211: fix virtual monitor interface locking
      cfg80211: always check for scan end on P2P device

John W. Linville (4):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac8021=
1
      Revert "brcmsmac: support 4313iPA"
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwi=
fi-fixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Joseph CHANG (1):
      DM9000B: driver initialization upgrade

Kees Cook (1):
      tg3: fix length overflow in VPD firmware parsing

Li RongQing (1):
      net: fix the use of this_cpu_ptr

Luis R. Rodriguez (1):
      ath9k: avoid queueing hw check work when suspended

Manish Chopra (1):
      MAINTAINERS: Update netxen_nic maintainers list

Marc Kleine-Budde (2):
      can: sja1000: fix define conflict on SH
      can: sja1000: limit PEAK PCAN-PC Card to HAS_IOPORT

Mathias Krause (1):
      xfrm: Fix esn sequence number diff calculation in xfrm_replay_not=
ify_esn()

Max.Nekludov@us.elster.com (1):
      ks8851: Fix interpretation of rxlen field.

Mirko Lindner (2):
      sky2: Receive Overflows not counted
      sky2: Threshold for Pause Packet is set wrong

Mugunthan V N (2):
      drivers: net: ethernet: cpsw: use netif_wake_queue() while restar=
ting tx queue
      drivers: net: ethernet: davinci_emac: use netif_wake_queue() whil=
e restarting tx queue

Nicolas Dichtel (1):
      af_key: initialize satype in key_notify_policy_flush()

Rafa=A9=A9 Mi=A9=A9ecki (2):
      b43: N-PHY: increase initial value of "mind" in RSSI calibration
      b43: N-PHY: use more bits for offset in RSSI calibration

Rob Herring (2):
      net: calxedaxgmac: fix rx ring handling when OOM
      net: calxedaxgmac: Wake-on-LAN fixes

Sergei Shtylyov (3):
      sh_eth: fix handling of no LINK signal
      sh_eth: workaround for spurious ECI interrupt
      sh_eth: make 'link' field of 'struct sh_eth_private' *int*

Sergey Popovich (1):
      sch: add missing u64 in psched_ratecfg_precompute()

Shmulik Ladkani (1):
      net: core: Remove redundant call to 'nf_reset' in 'dev_forward_sk=
b'

Steffen Klassert (1):
      xfrm: Fix replay notification for esn.

Steve Glendinning (1):
      smsc75xx: fix jumbo frame support

Vijay Subramanian (1):
      net: fq_codel: Fix off-by-one error

Vladimir Kondratiev (1):
      cfg80211: fix inconsistency in trace for rdev_set_mac_acl

Wei Yongjun (1):
      rtnetlink: fix error return code in rtnl_link_fill()

nikolay@redhat.com (1):
      bonding: fix disabling of arp_interval and miimon

 MAINTAINERS                                              |   4 +-
 drivers/block/aoe/aoecmd.c                               |   3 +-
 drivers/net/bonding/bond_sysfs.c                         |  92 ++++++-=
-----
 drivers/net/can/sja1000/Kconfig                          |   1 +
 drivers/net/can/sja1000/plx_pci.c                        |   4 +-
 drivers/net/can/sja1000/sja1000.c                        |   6 +-
 drivers/net/can/sja1000/sja1000.h                        |   2 +-
 drivers/net/ethernet/atheros/atl1e/atl1e.h               |   1 -
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c          |  19 +--
 drivers/net/ethernet/broadcom/tg3.c                      |   7 +-
 drivers/net/ethernet/calxeda/xgmac.c                     |   9 +-
 drivers/net/ethernet/davicom/dm9000.c                    | 214 +++++++=
+++++++--------------
 drivers/net/ethernet/davicom/dm9000.h                    |  11 +-
 drivers/net/ethernet/freescale/fec.c                     |  82 ++++++-=
----
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c         |  14 +-
 drivers/net/ethernet/intel/e1000e/netdev.c               |   7 +-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c              |   7 +-
 drivers/net/ethernet/marvell/sky2.c                      |   2 +-
 drivers/net/ethernet/marvell/sky2.h                      |   2 +-
 drivers/net/ethernet/micrel/ks8851.c                     |   2 +-
 drivers/net/ethernet/renesas/sh_eth.c                    |  28 ++--
 drivers/net/ethernet/renesas/sh_eth.h                    |   2 +-
 drivers/net/ethernet/ti/cpsw.c                           |   2 +-
 drivers/net/ethernet/ti/davinci_emac.c                   |   2 +-
 drivers/net/usb/smsc75xx.c                               |  12 +-
 drivers/net/wireless/ath/ath9k/link.c                    |   3 +-
 drivers/net/wireless/b43/dma.c                           |  65 +++++++=
--
 drivers/net/wireless/b43/phy_n.c                         |   8 +-
 drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c    | 369 +++++++=
++++++++++--------------------------------
 drivers/net/wireless/brcm80211/brcmsmac/phy/phytbl_lcn.c |  64 ++++---=
--
 drivers/net/wireless/iwlegacy/4965-rs.c                  |   3 +-
 drivers/net/wireless/iwlwifi/dvm/lib.c                   |   9 ++
 drivers/net/wireless/iwlwifi/dvm/ucode.c                 |   4 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c                |  13 ++
 drivers/net/wireless/iwlwifi/pcie/tx.c                   |   2 +-
 drivers/net/wireless/mwifiex/pcie.c                      |   1 +
 include/linux/netdevice.h                                |   2 +-
 net/core/dev.c                                           |   7 +-
 net/core/flow.c                                          |   2 +-
 net/core/rtnetlink.c                                     |   4 +-
 net/ipv6/ip6_input.c                                     |  12 ++
 net/key/af_key.c                                         |   1 +
 net/mac80211/iface.c                                     |  35 ++---
 net/mac80211/mesh.c                                      |   3 +-
 net/mac80211/mlme.c                                      |   6 +-
 net/mac80211/rx.c                                        |  14 +-
 net/mac80211/sta_info.c                                  |  12 +-
 net/sched/sch_fq_codel.c                                 |   2 +-
 net/sched/sch_generic.c                                  |   2 +-
 net/wireless/core.c                                      |  64 ++++++-=
--
 net/wireless/core.h                                      |   3 +
 net/wireless/nl80211.c                                   |  52 +++----
 net/wireless/scan.c                                      |  24 ++--
 net/wireless/sme.c                                       |   6 +-
 net/wireless/trace.h                                     |   5 +-
 net/wireless/wext-sme.c                                  |   6 +
 net/xfrm/xfrm_replay.c                                   |  66 +++++++=
+-
 57 files changed, 793 insertions(+), 611 deletions(-)
