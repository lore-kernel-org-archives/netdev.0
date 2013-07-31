From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 31 Jul 2013 00:37:05 -0700 (PDT)
Message-ID: <20130731.003705.119063818851248678.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47713 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752340Ab3GaHhG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 03:37:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Fix association failures not triggering a connect-failure event in
   cfg80211, from Johannes Berg.

2) Eliminate a potential NULL deref with older iptables tools when
   configuring xt_socket rules, from Eric Dumazet.

3) Missing RTNL locking in wireless regulatory code, from Johannes
   Berg.

4) Fix OOPS caused by firmware loading races in ath9k_htc, from Alexey
   Khoroshilov.

5) Fix usb URB leak in usb_8dev CAN driver, also from Alexey
   Khoroshilov.

6) VXLAN namespace teardown fails to unregister devices, from
   Stephen Hemminger.

7) Fix multicast settings getting dropped by firmware in qlcnic
   driver, from Sucheta Chakraborty.

8) Add sysctl range enforcement for tcp_syn_retries, from Michal Tesar.

9) Fix a nasty bug in bridging where an active timer would get
   reinitialized with a setup_timer() call.  From Eric Dumazet.

10) Fix use after free in new mlx5 driver, from Dan Carpenter.

11) Fix freed pointer reference in ipv6 multicast routing on
    namespace cleanup, from Hannes Frederic Sowa.

12) Some usbnet drivers report TSO and SG in their feature set, but
    the usbnet layer doesn't really support them.  From Eric Dumazet.

13) Fix crash on EEH errors in tg3 driver, from Gavin Shan.

14) Drop cb_lock when requesting modules in genetlink, from Stanislaw
    Gruszka.

15) Kernel stack leaks in cbq scheduler and af_key pfkey messages, from
    Dan Carpenter.

16) FEC driver erroneously signals NETDEV_TX_BUSY on transmit leading
    to endless loops, from Uwe Kleine-K=F6nig.

17) Fix hangs from loading mvneta driver, from Arnaud Patard.

Please pull, thanks a lot!

The following changes since commit ecb2cf1a6b63825a258ff4fe0d7f3070fbe4=
676b:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2013-0=
7-18 20:08:47 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to a661b43fd047ef501da43a19975415f861c7c3db=
:

  mlx5: fix error return code in mlx5_alloc_uuars() (2013-07-30 19:33:4=
5 -0700)

----------------------------------------------------------------
Alexander Bondar (1):
      iwlwifi: mvm: Fix VIF specific debugfs directory creation

Alexey Khoroshilov (2):
      ath9k_htc: fix data race between request_firmware_nowait() callba=
ck and suspend()
      can: usb_8dev: fix urb leak on failure path in usb_8dev_start()

Arend van Spriel (2):
      brcmfmac: decrement pending 8021x count upon tx failure
      brcmfmac: bail out of brcmf_txflowblock_if() for non-netdev inter=
face

Arnaud Patard (2):
      mvneta: Fix hang when loading the mvneta driver
      mvneta: Try to fix mvneta when compiled as module

Arnd Bergmann (1):
      ssb: fix alignment of struct bcma_device_id

Ben Hutchings (1):
      sfc: Enable RX scatter for flows steered by RFS

Bob Copeland (1):
      ath5k: fix extra set bit in multicast mask

Chun-Yeow Yeoh (1):
      nl80211: fix the setting of RSSI threshold value for mesh

Dan Carpenter (3):
      arcnet: cleanup sizeof parameter
      mlx5: use after free in mlx5_cmd_comp_handler()
      af_key: more info leaks in pfkey messages

Daniel Drake (1):
      mwifiex: fix IRQ enable/disable

David S. Miller (6):
      Merge branch 'fixes-for-3.11' of git://gitorious.org/linux-can/li=
nux-can
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge branch 'master' of git://git.kernel.org/.../pablo/nf
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Revert "atl1c: Fix misuse of netdev_alloc_skb in refilling rx rin=
g"
      net_sched: Fix stack info leak in cbq_dump_wrr().

David Spinadel (2):
      iwlwifi: mvm: fix bug in scan ssid
      iwlwifi: mvm: remove extra SSID from probe request

Emil Tantilov (1):
      igb: fix vlan filtering in promisc mode when not in VT mode

Emilio L=F3pez (1):
      net: sun4i: fix timeout check

Emmanuel Grumbach (3):
      iwlwifi: mvm: unregister leds when registration failed
      iwlwifi: mvm: fix L2P BA ressources leak
      iwlwifi: mvm: track the number of Rx BA sessions

Eric Dumazet (4):
      netfilter: xt_socket: fix broken v0 support
      bridge: do not call setup_timer() multiple times
      usbnet: do not pretend to support SG/TSO
      atl1c: Fix misuse of netdev_alloc_skb in refilling rx ring

=46abio Estevam (1):
      fec: Add MODULE_ALIAS

=46elix Fietkau (3):
      mac80211/minstrel_ht: fix cck rate sampling
      mac80211/minstrel: fix NULL pointer dereference issue
      ath9k: fix tx pending frames accounting for dropped packets

=46lavio Leitner (1):
      veth: add vlan features

=46lorian Fainelli (1):
      net: fix comment above build_skb()

=46rancesco Fusco (2):
      neigh: prevent overflowing params in /proc/sys/net/ipv4/neigh/
      sysctl: range checking in do_proc_dointvec_ms_jiffies_conv

=46rank Li (1):
      net: fec: workaround stop tx during errata ERR006358

Gavin Shan (2):
      net/tg3: Fix kernel crash
      net/tg3: Fix warning from pci_disable_device()

Geert Uytterhoeven (1):
      rt2x00: RT2X00 should depend on HAS_DMA

Hannes Frederic Sowa (1):
      ipv6: take rtnl_lock and mark mrt6 table as freed on namespace cl=
eanup

Himanshu Madhani (1):
      qlcnic: Fix ethtool display for 83xx adapter.

Jacob Keller (1):
      ixgbe: Fix Tx Hang issue with lldpad on 82598EB

Jerry Snitselaar (1):
      fib_trie: potential out of bounds access in trie_show_stats()

Jiri Slaby (1):
      net: pch_gbe depends on x86

Jitendra Kalsaria (2):
      qlcnic: Fix releasing of Tx frag which was never mapped.
      qlcnic: Fix initialization of work function.

Johannes Berg (6):
      cfg80211: fix bugs in new SME implementation
      regulatory: add missing rtnl locking
      mac80211: fix ethtool stats for non-station interfaces
      mac80211: fix duplicate retransmission detection
      iwlwifi: dvm: don't send BT_CONFIG on devices w/o Bluetooth
      iwlwifi: mvm: refuse connection to APs with BI < 16

John W. Linville (4):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac8021=
1
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwi=
fi-fixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Larry Finger (3):
      rtlwifi: Initialize power-setting callback for USB devices
      rtlwifi: Fix build errors for unusual cases
      ath: wil6210: Fix build error

Lekensteyn (1):
      r8169: fix lockdep warning when removing interface

Manish Chopra (4):
      qlcnic: Fix panic while setting VF's MAC address
      qlcnic: Fix guest VLAN
      qlcnic: Fix setting Guest VLAN
      qlcnic: Fix diagnostic interrupt test for 83xx adapters.

Maxime Ripard (2):
      drivers: net: allwinner: Fix Kconfig indentation
      drivers: net: sun4i-emac: select MDIO_SUN4I

Maximilian Schneider (1):
      net: can: esd_usb2: check index of array before accessing

Michal Kazior (1):
      nl80211: fix mgmt tx status and testmode reporting for netns

Michal Tesar (1):
      sysctl net: Keep tcp_syn_retries inside the boundary

Neil Horman (1):
      atl1c: Fix misuse of netdev_alloc_skb in refilling rx ring

Oleksij Rempel (2):
      ath9k_htc: do some initial hardware configuration
      ath9k_htc: reboot firmware if it was loaded

Pablo Neira (1):
      genetlink: fix usage of NLM_F_EXCL or NLM_F_REPLACE

Pablo Neira Ayuso (1):
      netfilter: ctnetlink: fix incorrect NAT expectation dumping

Pratik Pujar (2):
      qlcnic: Set __QLCNIC_DEV_UP in adapter state before enabling inte=
rrupts
      qlcnic: Fix operation type and command type.

Shahed Shaikh (2):
      qlcnic: Fix invalid register offset calculation
      qlcnic: Fix dump template version mask

Solomon Peachy (1):
      cw1200: Fix OOPS in monitor mode

Stanislaw Gruszka (1):
      genetlink: release cb_lock before requesting additional module

Sucheta Chakraborty (2):
      qlcnic: Fix NULL pointer dereference in VF probe path.
      qlcnic: Fix multicast packet handling for PF and VF.

Sujith Manoharan (1):
      ath9k_hw: Fix multicast search for AR9002 family

Uwe Kleine-K=F6nig (1):
      net/fec: Don't let ndo_start_xmit return NETDEV_TX_BUSY without l=
ink

Wei Yongjun (1):
      mlx5: fix error return code in mlx5_alloc_uuars()

stephen hemminger (2):
      vxlan: unregister on namespace exit
      vxlan: fix igmp races

 drivers/net/arcnet/arcnet.c                              |  2 +-
 drivers/net/can/usb/esd_usb2.c                           | 10 +++++++
 drivers/net/can/usb/usb_8dev.c                           |  1 +
 drivers/net/ethernet/allwinner/Kconfig                   | 26 ++++++++=
+--------
 drivers/net/ethernet/atheros/atl1c/atl1c.h               |  3 ++
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c          | 40 ++++++++=
+++++++++++++++++-
 drivers/net/ethernet/broadcom/tg3.c                      |  6 ++--
 drivers/net/ethernet/freescale/fec.h                     |  1 +
 drivers/net/ethernet/freescale/fec_main.c                | 38 ++++++++=
++++++++++++-----
 drivers/net/ethernet/intel/igb/igb_main.c                |  3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c       |  3 +-
 drivers/net/ethernet/marvell/mvneta.c                    | 31 ++++++++=
+++----------
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c            | 11 +++++---
 drivers/net/ethernet/mellanox/mlx5/core/uar.c            |  1 +
 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig            |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h              |  3 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c      |  4 +--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c    |  4 +--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c      |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c           | 22 +++++++-=
-------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c         |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c         |  4 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c     |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c |  2 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c     | 46 ++++++++=
+++++++++++++++++-----
 drivers/net/ethernet/realtek/r8169.c                     |  4 +--
 drivers/net/ethernet/sfc/filter.c                        |  4 ++-
 drivers/net/phy/mdio-sun4i.c                             | 14 ++++----=
--
 drivers/net/usb/ax88179_178a.c                           |  9 +++---
 drivers/net/usb/smsc75xx.c                               | 12 ++------
 drivers/net/veth.c                                       |  1 +
 drivers/net/vxlan.c                                      | 57 ++++++++=
++++++++++++++++++-----------
 drivers/net/wireless/ath/ath5k/mac80211-ops.c            |  2 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c              | 10 ++++++-
 drivers/net/wireless/ath/ath9k/hif_usb.c                 | 13 ++++++--=
-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c            |  1 +
 drivers/net/wireless/ath/ath9k/xmit.c                    | 44 ++++++++=
++++++++++-----------
 drivers/net/wireless/ath/wil6210/debugfs.c               |  4 +--
 drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c      |  2 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c       |  8 +++++-
 drivers/net/wireless/cw1200/txrx.c                       |  2 +-
 drivers/net/wireless/iwlwifi/dvm/main.c                  |  2 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs.c               |  6 +++-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c              | 23 ++++++++=
++++++-
 drivers/net/wireless/iwlwifi/mvm/mvm.h                   |  1 +
 drivers/net/wireless/iwlwifi/mvm/scan.c                  | 10 ++++---
 drivers/net/wireless/iwlwifi/mvm/sta.c                   | 23 ++++++++=
+++++--
 drivers/net/wireless/mwifiex/init.c                      | 10 ++-----
 drivers/net/wireless/mwifiex/main.c                      | 13 ++++++++=
-
 drivers/net/wireless/mwifiex/main.h                      |  1 +
 drivers/net/wireless/mwifiex/sdio.c                      | 91 ++++++++=
++++++++++++++++++++--------------------------------
 drivers/net/wireless/mwifiex/sdio.h                      |  3 --
 drivers/net/wireless/rt2x00/Kconfig                      |  2 +-
 drivers/net/wireless/rtlwifi/Kconfig                     | 72 ++++++++=
+++++++++++++++++++++++----------------
 drivers/net/wireless/rtlwifi/Makefile                    | 10 +++----
 drivers/net/wireless/rtlwifi/base.c                      | 19 ++++++++=
+++--
 drivers/net/wireless/rtlwifi/base.h                      |  2 +-
 drivers/net/wireless/rtlwifi/core.c                      |  1 +
 drivers/net/wireless/rtlwifi/debug.c                     |  1 +
 drivers/net/wireless/rtlwifi/efuse.c                     |  1 +
 drivers/net/wireless/rtlwifi/pci.c                       | 22 ++++++--=
-------
 drivers/net/wireless/rtlwifi/ps.c                        | 16 ++++++++=
+++
 drivers/net/wireless/rtlwifi/ps.h                        |  1 +
 drivers/net/wireless/rtlwifi/usb.c                       |  9 ++++++
 include/linux/mod_devicetable.h                          |  5 ++--
 kernel/sysctl.c                                          |  6 +++-
 net/bridge/br_multicast.c                                |  5 ++--
 net/core/neighbour.c                                     | 29 ++++++++=
++++++-----
 net/core/skbuff.c                                        |  3 +-
 net/ipv4/fib_trie.c                                      |  2 +-
 net/ipv4/sysctl_net_ipv4.c                               |  6 +++-
 net/ipv6/ip6mr.c                                         |  5 ++++
 net/key/af_key.c                                         |  4 +++
 net/mac80211/cfg.c                                       |  2 ++
 net/mac80211/rc80211_minstrel.c                          |  3 +-
 net/mac80211/rc80211_minstrel_ht.c                       | 10 ++++++-
 net/mac80211/rx.c                                        | 10 +++++--
 net/netfilter/nf_conntrack_expect.c                      |  5 ++++
 net/netfilter/xt_socket.c                                | 10 +++++--
 net/netlink/genetlink.c                                  |  4 ++-
 net/sched/sch_cbq.c                                      |  1 +
 net/wireless/nl80211.c                                   | 11 +++++---
 net/wireless/reg.c                                       |  2 ++
 net/wireless/sme.c                                       | 29 ++++++++=
+++++++++--
 84 files changed, 656 insertions(+), 291 deletions(-)
