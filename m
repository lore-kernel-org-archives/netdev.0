From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 21 Nov 2014 17:37:46 -0500 (EST)
Message-ID: <20141121.173746.1458052246678898679.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix BUG when decrypting empty packets in mac80211, from Ronald Wahl.

2) nf_nat_range is not fully initialized and this is copied back to
   userspace, from Daniel Borkmann.

3) Fix read past end of b uffer in netfilter ipset, also from Dan
   Carpenter.

4) Signed integer overflow in ipv4 address mask creation helper
   inet_make_mask(), from Vincent BENAYOUN.

5) VXLAN, be2net, mlx4_en, and qlcnic need ->ndo_gso_check() methods
   to properly describe the device's capabilities, from Joe
   Stringer.

6) Fix memory leaks and checksum miscalculations in openvswitch, from
   Pravin B SHelar and Jesse Gross.

7) FIB rules passes back ambiguous error code for unreachable routes,
   making behavior confusing for userspace.  Fix from Panu Matilainen.

8) ieee802154fake_probe() doesn't release resources properly on error,
   from Alexey Khoroshilov.

9) Fix skb_over_panic in add_grhead(), from Daniel Borkmann.

10) Fix access of stale slave pointers in bonding code, from Nikolay
    Aleksandrov.

11) Fix stack info leak in PPP pptp code, from Mathias Krause.

12) Cure locking bug in IPX stack, from Jiri Bohac.

13) Revert SKB fclone memory freeing optimization that is racey and can
    allow accesses to freed up memory, from Eric Dumazet.

Please pull, thanks a lot!

The following changes since commit b23dc5a7cc6ebc9a0d57351da7a0e8454c9f=
fea3:

  Merge tag 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/mst/vhost (2014-11-13 18:07:52 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 0c228e833c88e3aa029250f5db77d5968c5ce5b5=
:

  tcp: Restore RFC5961-compliant behavior for SYN packets (2014-11-21 1=
5:33:50 -0500)

----------------------------------------------------------------
Alexey Khoroshilov (2):
      ieee802154: fix error handling in ieee802154fake_probe()
      can: esd_usb2: fix memory leak on disconnect

Anish Bhatt (3):
      dcbnl : Disable software interrupts before taking dcb_lock
      cxgb4i : Don't block unload/cxgb4 unload when remote closes TCP c=
onnection
      cxgb4 : Fix DCB priority groups being returned in wrong order

Arend van Spriel (1):
      brcmfmac: fix conversion of channel width 20MHZ_NOHT

Ben Greear (1):
      ath9k: fix regression in bssidmask calculation

Calvin Owens (2):
      ipvs: Keep skb->sk when allocating headroom on tunnel xmit
      tcp: Restore RFC5961-compliant behavior for SYN packets

Dan Carpenter (1):
      netfilter: ipset: small potential read beyond the end of buffer

Daniel Borkmann (2):
      netfilter: nft_masq: fix uninitialized range in nft_masq_{ipv4, i=
pv6}_eval
      ipv6: mld: fix add_grhead skb_over_panic for devs with large MTUs

Daniele Di Proietto (1):
      openvswitch: Fix NDP flow mask validation

David Cohen (1):
      can: m_can: add CONFIG_HAS_IOMEM dependence

David S. Miller (7):
      Merge tag 'master-2014-11-11' of git://git.kernel.org/.../linvill=
e/wireless
      Merge branch 'vxlan_gso_check'
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'net_ovs' of git://git.kernel.org/.../pshelar/openvs=
witch
      Merge tag 'linux-can-fixes-for-3.18-20141118' of git://gitorious.=
org/linux-can/linux-can
      Merge tag 'master-2014-11-20' of git://git.kernel.org/.../linvill=
e/wireless
      Merge git://git.kernel.org/.../pablo/nf

Dmitry Torokhov (1):
      brcmfmac: fix error handling of irq_of_parse_and_map

Dong Aisheng (8):
      can: dev: add can_is_canfd_skb() API
      can: m_can: add .ndo_change_mtu function
      can: m_can: add missing message RAM initialization
      can: m_can: fix possible sleep in napi poll
      can: m_can: fix not set can_dlc for remote frame
      can: m_can: add missing delay after setting CCCR_INIT bit
      can: m_can: fix incorrect error messages
      can: m_can: update to support CAN FD features

Duan Jiong (1):
      ipv6: delete protocol and unregister rtnetlink when cleanup

Emmanuel Grumbach (1):
      iwlwifi: mvm: abort scan upon RFKILL

Eric Dumazet (1):
      net: Revert "net: avoid one atomic operation in skb_clone()"

=46elix Fietkau (1):
      mac80211: minstrel_ht: fix a crash in rate sorting

Hannes Frederic Sowa (1):
      reciprocal_div: objects with exported symbols should be obj-y rat=
her than lib-y

Hauke Mehrtens (1):
      b43: fix NULL pointer dereference in b43_phy_copy()

Jarno Rajahalme (1):
      openvswitch: Validate IPv6 flow key and mask values.

Jason Wang (1):
      virtio-net: validate features during probe

Jesse Gross (1):
      openvswitch: Fix checksum calculation when modifying ICMPv6 packe=
ts.

Jiri Bohac (1):
      ipx: fix locking regression in ipx_sendmsg and ipx_recvmsg

Joe Stringer (6):
      net: Add vxlan_gso_check() helper
      be2net: Implement ndo_gso_check()
      net/mlx4_en: Implement ndo_gso_check()
      qlcnic: Implement ndo_gso_check()
      vxlan: Inline vxlan_gso_check().
      openvswitch: Don't validate IPv6 label masks.

Johannes Berg (1):
      brcmfmac: don't include linux/unaligned/access_ok.h

John Ogness (1):
      drivers: net: cpsw: Fix TX_IN_SEL offset

John W. Linville (3):
      Merge tag 'mac80211-for-john-2014-11-10' of git://git.kernel.org/=
=2E../jberg/mac80211
      Merge tag 'iwlwifi-for-john-2014-11-10' of git://git.kernel.org/.=
=2E./iwlwifi/iwlwifi-fixes
      Merge tag 'mac80211-for-john-2014-11-18' of git://git.kernel.org/=
=2E../jberg/mac80211

Larry Finger (3):
      rtlwifi: Fix setting of tx descriptor for new trx flow
      rtlwifi: Fix errors in descriptor manipulation
      rtlwifi: rtl8192se: Fix connection problems

Liad Kaufman (1):
      iwlwifi: pcie: fix prph dump length

Linus L=FCssing (1):
      bridge: fix netfilter/NF_BR_LOCAL_OUT for own, locally generated =
queries

Marc Kleine-Budde (3):
      can: xilinx_can: add .ndo_change_mtu function
      can: rcar_can: add .ndo_change_mtu function
      can: gs_usb: add .ndo_change_mtu function

Martin Hauke (1):
      qmi_wwan: Add support for HP lt4112 LTE/HSPA+ Gobi 4G Modem

Mathias Krause (1):
      pptp: fix stack info leak in pptp_getname()

Mathy Vanhoef (1):
      brcmfmac: kill URB when request timed out

Miaoqing Pan (1):
      ath9k: Fix RTC_DERIVED_CLK usage

Nikolay Aleksandrov (1):
      bonding: fix curr_active_slave/carrier with loadbalance arp monit=
oring

Or Gerlitz (1):
      net/mlx4_en: Add VXLAN ndo calls to the PF net device ops too

Pablo Neira Ayuso (5):
      netfilter: nft_compat: use current net namespace
      netfilter: nft_compat: relax chain type validation
      netfilter: nft_compat: use the match->table to validate dependenc=
ies
      netfilter: nf_tables: restore synchronous object release from com=
mit/abort
      netfilter: nfnetlink: fix insufficient validation in nfnetlink_bi=
nd

Panu Matilainen (1):
      ipv4: Fix incorrect error code when adding an unreachable route

Pravin B Shelar (2):
      openvswitch: Fix memory leak.
      openvswitch: Convert dp rcu read operation to locked operations

Roman Fietze (1):
      can: dev: fix typo CIA -> CiA, CAN in Automation

Ronald Wahl (1):
      mac80211: Fix regression that triggers a kernel BUG with CCMP

Stanislaw Gruszka (1):
      rt2x00: do not align payload on modern H/W

Sudip Mukherjee (2):
      can: remove unused variable
      can: xilinx_can: fix comparison of unsigned variable

Thomas K=F6rper (1):
      can: dev: avoid calling kfree_skb() from interrupt context

Vincent BENAYOUN (1):
      inetdevice: fixed signed integer overflow

bill bonaparte (1):
      netfilter: conntrack: fix race in __nf_conntrack_confirm against =
get_next_corpse

 drivers/net/bonding/bond_main.c                       |   3 +-
 drivers/net/can/dev.c                                 |   4 +-
 drivers/net/can/m_can/Kconfig                         |   1 +
 drivers/net/can/m_can/m_can.c                         | 219 ++++++++++=
++++++++++++++++++++++++++++++++++++++++++++------------------
 drivers/net/can/rcar_can.c                            |   1 +
 drivers/net/can/sja1000/kvaser_pci.c                  |   5 +-
 drivers/net/can/usb/ems_usb.c                         |   3 +-
 drivers/net/can/usb/esd_usb2.c                        |   3 +-
 drivers/net/can/usb/gs_usb.c                          |   1 +
 drivers/net/can/xilinx_can.c                          |   4 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c        |   2 +-
 drivers/net/ethernet/emulex/benet/be_main.c           |   6 ++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c        |  13 ++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c      |   6 ++
 drivers/net/ethernet/ti/cpsw.c                        |   6 +-
 drivers/net/ieee802154/fakehard.c                     |  13 +++--
 drivers/net/ppp/pptp.c                                |   4 +-
 drivers/net/usb/qmi_wwan.c                            |   1 +
 drivers/net/virtio_net.c                              |  37 ++++++++++=
++
 drivers/net/vxlan.c                                   |   6 --
 drivers/net/wireless/ath/ath9k/ar9003_phy.c           |  13 +++++
 drivers/net/wireless/ath/ath9k/hw.c                   |  13 -----
 drivers/net/wireless/ath/ath9k/main.c                 |   9 ++-
 drivers/net/wireless/b43/phy_common.c                 |   4 +-
 drivers/net/wireless/brcm80211/brcmfmac/of.c          |   4 +-
 drivers/net/wireless/brcm80211/brcmfmac/pcie.c        |   2 +-
 drivers/net/wireless/brcm80211/brcmfmac/usb.c         |   6 +-
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c |   6 ++
 drivers/net/wireless/iwlwifi/mvm/scan.c               |  20 +++----
 drivers/net/wireless/iwlwifi/pcie/trans.c             |   3 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c             |  50 ++++------=
-------
 drivers/net/wireless/rtlwifi/pci.c                    |  19 ++++---
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c           |   7 ++-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c          |   2 +
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c           |  16 ++++++
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c                    |   2 +
 drivers/scsi/cxgbi/libcxgbi.c                         |   2 +-
 include/linux/can/dev.h                               |   6 ++
 include/linux/inetdevice.h                            |   2 +-
 include/net/netfilter/nf_tables.h                     |   2 -
 include/net/vxlan.h                                   |  18 ++++++
 lib/Makefile                                          |   4 +-
 net/bridge/br_multicast.c                             |   3 +-
 net/core/skbuff.c                                     |  23 ++------
 net/dcb/dcbnl.c                                       |  36 ++++++----=
--
 net/ipv4/fib_rules.c                                  |   4 ++
 net/ipv4/igmp.c                                       |  11 ++--
 net/ipv4/netfilter/nft_masq_ipv4.c                    |   1 +
 net/ipv4/tcp_input.c                                  |   4 +-
 net/ipv6/ip6mr.c                                      |   4 ++
 net/ipv6/mcast.c                                      |   9 +--
 net/ipv6/netfilter/nft_masq_ipv6.c                    |   1 +
 net/ipx/af_ipx.c                                      |   6 +-
 net/mac80211/aes_ccm.c                                |   3 +
 net/mac80211/rc80211_minstrel_ht.c                    |  15 ++---
 net/netfilter/ipset/ip_set_core.c                     |   6 ++
 net/netfilter/ipvs/ip_vs_xmit.c                       |   2 +
 net/netfilter/nf_conntrack_core.c                     |  14 +++--
 net/netfilter/nf_tables_api.c                         |  24 +++-----
 net/netfilter/nfnetlink.c                             |  12 +++-
 net/netfilter/nft_compat.c                            |  40 ++--------=
---
 net/openvswitch/actions.c                             |  10 ++--
 net/openvswitch/datapath.c                            |  14 ++---
 net/openvswitch/flow_netlink.c                        |   9 ++-
 64 files changed, 500 insertions(+), 299 deletions(-)
