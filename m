From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 27 Jun 2012 22:21:20 -0700 (PDT)
Message-ID: <20120627.222120.1580932639112330883.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Pairing and deadlock fixes in bluetooth from Johan Hedberg.

2) Add device IDs for AR3011 and AR3012 bluetooth chips.  From
   Giancarlo Formicuccia and Marek Vasut.

3) Fix wireless regulatory deadlock, from Eliad Peller.

4) Fix full TX ring panic in bnx2x driver, from Eric Dumazet.

5) Revert the two commits that added skb_orphan_try(), it causes
   erratic bonding behavior with UDP clients and the gains it
   used to give are mostly no longer happening due to how BQL
   works.  From Eric Dumazet.

6) It took two tries, but Thomas Graf fixed a problem wherein we
   registered ipv6 routing procfs files before their backend data
   were initialized properly.

7) Fix max GSO size setting in be2net, from Sarveshwar Bandi.

8) PHY device id mask is wrong for KSZ9021 and KS8001 chips, fix
   from Jason Wang.

9) Fix use of stale SKB data pointer after skb_linearize() call in=09
   batman-adv, from Antonio Quartulli.

10) Fix memory leak in IXGBE due to missing __GFP_COMP, from Alexander
    Duyck.

11) Fix probing of Gobi devices in qmi_wwan usbnet driver, from Bj=F8rn=
 Mork.

12) Fix suspend/resume and open failure handling in usbnet from Ming
    Lei.

13) Attempt to fix device r8169 hangs for certain chips, from Francois
    Romieu.

14) Fix advancement of RX dirty pointer in some situations in sh_eth
    driver, from Yoshihiro Shimoda.

15) Attempt to fix restart of IPV6 routing table dumps when there is
    an intervening table update.  From Eric Dumazet.

16) Respect security_inet_conn_request() return value in ipv6 TCP.  Fro=
m
    Neal Cardwell.

17) Add another iPAD device ID to ipheth driver, from Davide Gerhard.

18) Fix access to freed SKB in l2tp_eth_dev_xmit(), and fix l2tp lockde=
p
    splats, from Eric Dumazet.

19) Make sure all bridge devices, regardless of whether they were creat=
ed
    via netlink or ioctls, have their rtnetlink ops hooked up.  From
    Thomas Graf and Stephen Hemminger.

Please pull, thanks a lot!

The following changes since commit 424d54d2dca03805942055e5b19926d33a7d=
1e31:

  Merge git://git.kernel.org/pub/scm/virt/kvm/kvm (2012-06-14 15:46:59 =
+0300)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to a969dd139cc2f2bccdcb11894f0695517cf84d4d=
:

  Merge branch 'for-davem' of git://gitorious.org/linux-can/linux-can (=
2012-06-27 15:27:24 -0700)

----------------------------------------------------------------

Alexander Duyck (2):
      ixgbe: Fix memory leak in ixgbe when receiving traffic on DDP ena=
bled rings
      ixgbe: Do not pad FCoE frames as this can cause issues with FCoE =
DDP

Amerigo Wang (1):
      bonding: show all the link status of slaves

Andrei Emeltchenko (1):
      Bluetooth: btmrvl: Do not send vendor events to bluetooth stack

Antonio Quartulli (2):
      batman-adv: fix skb->data assignment
      batman-adv: fix race condition in TT full-table replacement

Ashok Nagarajan (1):
      mac80211: add missing kernel-doc

Avinash Patil (2):
      mwifiex: fix incorrect privacy setting in beacon and probe respon=
se
      mwifiex: fix uAP TX packet timeout issue

Bing Zhao (1):
      mwifiex: fix wrong return values in add_virtual_intf() error case=
s

Bj=F8rn Mork (1):
      net: qmi_wwan: fix Gobi device probing

Bob Copeland (1):
      ath5k: remove _bh from inner locks

Carolyn Wyborny (2):
      igb: Fix incorrect RAR address entries for i210/i211 device.
      Kconfig: Fix Kconfig for Intel ixgbe and igb PTP support.

Dan Carpenter (4):
      can: c_can: precedence error in c_can_chip_config()
      qlcnic: off by one in qlcnic_init_pci_info()
      airo: copying wrong data in airo_get_aplist()
      9p: fix min_t() casting in p9pdu_vwritef()

Daniel Halperin (1):
      sctp: fix warning when compiling without IPv6

David S. Miller (2):
      Revert "ipv6: Prevent access to uninitialized fib_table_hash via =
/proc/net/ipv6_route"
      Merge branch 'for-davem' of git://gitorious.org/linux-can/linux-c=
an

David Spinadel (1):
      mac80211: stop polling in disassociation

Davide Gerhard (1):
      ipheth: add support for iPad

Eliad Peller (2):
      cfg80211: fix potential deadlock in regulatory
      mac80211: check sdata_running on ieee80211_set_bitrate_mask

Eric Dumazet (5):
      bnx2x: fix panic when TX ring is full
      net: remove skb_orphan_try()
      ipv6: fib: fix fib dump restart
      net: l2tp_eth: fix l2tp_eth_dev_xmit race
      net: l2tp_eth: use LLTX to avoid LOCKDEP splats

=46elix Fietkau (2):
      ath9k: fix a tx rate duration calculation bug
      ath9k: fix invalid pointer access in the tx path

Giancarlo Formicuccia (1):
      Bluetooth: add support for atheros 0930:0219

Grazvydas Ignotas (3):
      wl1251: fix TSF calculation
      wl1251: always report beacon loss to the stack
      wl1251: Fix memory leaks in SPI initialization

Hui Wang (1):
      can: flexcan: use be32_to_cpup to handle the value of dt entry

Ian Campbell (1):
      xen/netfront: teardown the device before unregistering it.

Jacob Keller (1):
      ixgbe: Fix PHC loophole allowing misconfiguration of increment re=
gister

Jason Wang (1):
      phy/micrel: change phy_id_mask for KSZ9021 and KS8001

Jens Freimann (1):
      vhost: use USER_DS in vhost_worker thread

Johan Hedberg (4):
      Bluetooth: Fix SMP pairing method selection
      Bluetooth: Fix deadlock and crash when SMP pairing times out
      Bluetooth: Fix SMP security elevation from medium to high
      Bluetooth: Add support for encryption key refresh

Johannes Berg (2):
      mac80211: add some missing kernel-doc
      iwlwifi: remove log_event debugfs file debugging is disabled

John W. Linville (5):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac8021=
1
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Jussi Kivilinna (1):
      rndis_wlan: fix matching bssid check in rndis_check_bssid_list()

Marek Lindner (1):
      batman-adv: only drop packets of known wifi clients

Marek Vasut (1):
      Bluetooth: Support AR3011 in Acer Iconia Tab W500

Michal Kazior (1):
      cfg80211: check iface combinations only when iface is running

Ming Lei (3):
      usbnet: clear OPEN flag in failure path
      usbnet: decrease suspend count if returning -EBUSY for runtime su=
spend
      usbnet: handle remote wakeup asap

Mohammed Shafi Shajakhan (4):
      ath9k: Fix a WARNING on suspend/resume with IBSS
      ath9k: remove incompatible IBSS interface check in change_iface
      ath9k: Fix softlockup in AR9485
      ath9k_hw: avoid possible infinite loop in ar9003_get_pll_sqsum_dv=
c

Neal Cardwell (1):
      tcp: heed result of security_inet_conn_request() in tcp_v6_conn_r=
equest()

Per Ellefsen (1):
      caif-hsi: Bugfix - Piggyback'ed embedded CAIF frame lost

Phil Sutter (1):
      usbnet: sanitise overlong driver information strings

Rajkumar Manoharan (1):
      ath9k_htc: configure bssid on ASSOC/IBSS change

R=E9mi Denis-Courmont (1):
      net: remove my future former mail address

Sarveshwar Bandi (1):
      be2net: reduce gso_max_size setting to account for ethernet heade=
r.

Sjur Br=E6ndeland (2):
      caif: Clear shutdown mask to zero at reconnect.
      caif-hsi: Add missing return in error path

Szymon Janc (1):
      Bluetooth: Fix using uninitialized option in RFCMode

Thomas Graf (2):
      ipv6: Prevent access to uninitialized fib_table_hash via /proc/ne=
t/ipv6_route
      ipv6: Move ipv6 proc file registration to end of init order

Vasundhara Volam (2):
      be2net: Modify error message to incorporate subsystem
      be2net: Increase statistics structure size for skyhawk.

Vishal Agarwal (2):
      Bluetooth: Fix LE pairing completion on connection failure
      Bluetooth: Fix sending HCI_Disconnect only when connected

Yevgeny Petrilin (3):
      net/mlx4_en: Set correct port parameters during device initializa=
tion
      net/mlx4: Use single completion vector after NOP failure
      net/mlx4_en: Release QP range in free_resources

Yoshihiro Shimoda (1):
      net: sh_eth: fix the condition to fix the cur_tx/dirty_rx

Yuval Mintz (2):
      bnx2x: fix I2C non-respondent issue
      bnx2x: fix link for BCM57711 with 84823 phy

alex.bluesman.smirnov@gmail.com (1):
      mac802154: add missed braces

fran=E7ois romieu (1):
      r8169: RxConfig hack for the 8168evl.

stephen hemminger (1):
      bridge: Assign rtnl_link_ops to bridge devices created via ioctl =
(v2)

 drivers/bluetooth/ath3k.c                        |    3 ++
 drivers/bluetooth/btmrvl_drv.h                   |    2 +-
 drivers/bluetooth/btmrvl_main.c                  |   14 +++++++--
 drivers/bluetooth/btmrvl_sdio.c                  |    8 +++--
 drivers/bluetooth/btusb.c                        |    2 ++
 drivers/net/bonding/bond_procfs.c                |   15 +++++++--
 drivers/net/caif/caif_hsi.c                      |    5 +--
 drivers/net/can/c_can/c_can.c                    |    4 +--
 drivers/net/can/flexcan.c                        |    4 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |    8 ++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   54 ++++++++++++++=
++++--------------
 drivers/net/ethernet/emulex/benet/be_cmds.c      |   12 +++----
 drivers/net/ethernet/emulex/benet/be_cmds.h      |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c      |    2 +-
 drivers/net/ethernet/intel/Kconfig               |   10 ++++--
 drivers/net/ethernet/intel/igb/e1000_82575.c     |    2 --
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    4 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c     |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   16 +++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c     |   13 ++++++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |   18 +++++++----
 drivers/net/ethernet/mellanox/mlx4/main.c        |    2 ++
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h     |    1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    2 +-
 drivers/net/ethernet/realtek/r8169.c             |    1 +
 drivers/net/ethernet/renesas/sh_eth.c            |   12 ++++---
 drivers/net/phy/micrel.c                         |    8 ++---
 drivers/net/usb/ipheth.c                         |    5 +++
 drivers/net/usb/qmi_wwan.c                       |   83 ++++++++++++++=
++++++++++-------------------------
 drivers/net/usb/usbnet.c                         |   53 ++++++++++++++=
+++++------------
 drivers/net/wireless/airo.c                      |    4 +--
 drivers/net/wireless/ath/ath5k/base.c            |    4 +--
 drivers/net/wireless/ath/ath9k/ath9k.h           |    1 +
 drivers/net/wireless/ath/ath9k/htc_drv_main.c    |    5 ++-
 drivers/net/wireless/ath/ath9k/hw.c              |   14 ++++++++-
 drivers/net/wireless/ath/ath9k/main.c            |   27 ++++++--------=
--
 drivers/net/wireless/ath/ath9k/xmit.c            |   31 ++++++++++----=
----
 drivers/net/wireless/iwlwifi/iwl-debugfs.c       |    6 ++++
 drivers/net/wireless/mwifiex/cfg80211.c          |   25 +++++++-------=
-
 drivers/net/wireless/mwifiex/txrx.c              |   10 ++----
 drivers/net/wireless/mwifiex/uap_cmd.c           |   11 +++++++
 drivers/net/wireless/rndis_wlan.c                |    2 +-
 drivers/net/wireless/ti/wl1251/acx.c             |    2 +-
 drivers/net/wireless/ti/wl1251/event.c           |    3 +-
 drivers/net/wireless/ti/wl1251/spi.c             |    4 +++
 drivers/net/xen-netfront.c                       |    8 ++---
 drivers/vhost/vhost.c                            |    3 ++
 include/linux/skbuff.h                           |    7 ++---
 include/net/bluetooth/hci.h                      |    6 ++++
 include/net/mac80211.h                           |    6 ++++
 include/net/phonet/gprs.h                        |    2 +-
 net/9p/protocol.c                                |    2 +-
 net/batman-adv/routing.c                         |    2 ++
 net/batman-adv/translation-table.c               |   12 +++----
 net/bluetooth/hci_event.c                        |   48 ++++++++++++++=
++++++++++++++
 net/bluetooth/l2cap_core.c                       |   21 ++++++++-----
 net/bluetooth/mgmt.c                             |   20 +++++++++++-
 net/bluetooth/smp.c                              |   11 ++++---
 net/bridge/br_if.c                               |    1 +
 net/bridge/br_netlink.c                          |    2 +-
 net/bridge/br_private.h                          |    1 +
 net/caif/caif_dev.c                              |    3 +-
 net/caif/caif_socket.c                           |    1 +
 net/can/raw.c                                    |    3 --
 net/core/dev.c                                   |   23 +-------------
 net/ipv6/ip6_fib.c                               |    4 +--
 net/ipv6/route.c                                 |   41 ++++++++++++++=
++++------
 net/ipv6/tcp_ipv6.c                              |    3 +-
 net/iucv/af_iucv.c                               |    1 -
 net/l2tp/l2tp_eth.c                              |   45 ++++++++++++++=
++++++-------
 net/mac80211/cfg.c                               |    3 ++
 net/mac80211/mlme.c                              |    4 +--
 net/mac80211/sta_info.h                          |    5 +++
 net/mac802154/tx.c                               |    3 +-
 net/phonet/af_phonet.c                           |    4 +--
 net/phonet/datagram.c                            |    4 +--
 net/phonet/pep-gprs.c                            |    2 +-
 net/phonet/pep.c                                 |    2 +-
 net/phonet/pn_dev.c                              |    4 +--
 net/phonet/pn_netlink.c                          |    4 +--
 net/phonet/socket.c                              |    4 +--
 net/phonet/sysctl.c                              |    2 +-
 net/sctp/protocol.c                              |    2 ++
 net/wireless/reg.c                               |    2 +-
 net/wireless/util.c                              |    2 +-
 85 files changed, 529 insertions(+), 310 deletions(-)
