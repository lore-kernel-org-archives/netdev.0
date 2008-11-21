From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2008-11-21
Date: Fri, 21 Nov 2008 14:03:38 -0500
Message-ID: <20081121190338.GB3540@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53097 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbYKUTQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 14:16:11 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is another big round of updates intended for 2.6.29.  This version
is rebased after the 2.6.28-rc6 rebasing of net-next-2.6.  This batch is
mostly driver updates as well as a bunch of file movement.  Also, some
patches from me are working towards refactoring/minimizing the old
ieee80211 component into a support library for ipw2100 and ipw2200 and
also collecting more code into lib80211 for sharing between more
drivers.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit 9d2f4720971c00852a3fc8278a76f1a5e9add5c7:
  Wang Chen (1):
        ixgbe: convert directly reference of netdev->priv

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Alexey Fisher (1):
      ipw2200: make association only if SSID is known.

Andrey Yurovsky (2):
      mac80211: disable BSSID filtering for mesh interfaces
      mac80211_hwsim: enable Mesh Point operation

Anna Neal (1):
      libertas: Fine grained configuration of wake-on-lan.

Benoit PAPILLAULT (1):
      ath9k : Display MAC/BB and RF version at startup (v2)

Felix Fietkau (2):
      ath5k: ignore the return value of ath5k_hw_noise_floor_calibration
      mac80211: fix BUILD_BUG_ON() caused by misalignment on arm

Halperin, Daniel C (1):
      iwlwifi: update iwl-commands.h for 3 stream support

Ivo van Doorn (7):
      rt2x00: Remove RATE_BASIC flag
      rt2x00: Fix LED state handling
      rt2x00: Block set_key() during suspend/shutdown
      rt2x00: Fix BUG_ON() with antenna handling
      rt2x00: Cleanup TX/RX entry handling
      rt2x00: Optimize get_duration / get_duration_res
      rt2x00: Fix race condition when using inderect registers

Johannes Berg (3):
      b43legacy: implement short slot and basic rate handling
      b43: remove rate index warning
      wireless: clean up sysfs code using %pM

John W. Linville (9):
      netdevice zd1201: Convert directly reference of netdev->priv to netdev_priv()
      ipw2100, ipw2200: select LIB80211
      lib80211: absorb crypto bits from net/ieee80211
      lib80211: consolidate crypt init routines
      ipw2x00: relocate ipw2100/ipw2200 to common directory
      net/ieee80211 -> drivers/net/ipw2x00/libipw_* rename
      mac80211: add explicit padding in struct ieee80211_tx_info
      rtl8180: adapt for deprecated IEEE80211_CONF_SHORT_SLOT_TIME flag
      MAINTAINERS: claim maintenance over rtl818x drivers

Jouni Malinen (1):
      mac80211_hwsim: Update documentation (AP mode enabled)

Julia Lawall (1):
      drivers/net/wireless/ath9k/rc.c: use ARRAY_SIZE

Kay Sievers (1):
      ssb: struct device - replace bus_id with dev_name(), dev_set_name()

Kolekar, Abhijeet (2):
      iwl3945 : Fix Sparse Warnings
      iwl3945 : Simplify iwl3945_send_beacon_cmd

Larry Finger (3):
      Move all rtl818x files to a common directory.
      Update of MAINTAINERS for RTL8187
      rtl8187: Update file authorship in comments

Luis R. Rodriguez (2):
      ath5k: allow APs to receive beacons
      ath9k: enable RXing of beacons on STA/IBSS

Mohamed Abbas (2):
      iwlagn: fix resume for ADHOC network
      iwl3945: fix resume for ADHOC network

Nick Kossifidis (1):
      ath5k: Fix IMR init

Pavel Roskin (1):
      orinoco: fix last beacon reporting on 64-bit systems

Rami Rosen (2):
      mac80211: remove unnecessary include.
      wireless: missing include in lib80211.h

Randy Dunlap (1):
      mac80211: remove more excess kernel-doc

Tomas Winkler (3):
      iwlwifi: revamp tx scheduler byte count tables handling
      iwlwifi: move spectrum measurement code to iwl-spectrum.c file
      mac80211: rc80211_pid eliminate sparse warnings

Winkler, Tomas (5):
      iwlwifi: trivial fix in includes
      iwlwifi: don't fail power set when calibration is not done yet
      iwlwifi: move rx queue read pointer into rxq
      iwlwifi: move iwl_print_hex_dump to iwl-debug.h
      iwlwifi: get some more information about command failure

Zhu, Yi (1):
      iwlwifi: use Rx single frame mode (one Rx frame per RB)

 Documentation/networking/mac80211_hwsim/README     |    9 +-
 MAINTAINERS                                        |   24 ++-
 drivers/net/wireless/Kconfig                       |  145 +-----------
 drivers/net/wireless/Makefile                      |   13 +-
 drivers/net/wireless/ath5k/base.c                  |   10 +-
 drivers/net/wireless/ath5k/phy.c                   |    4 +-
 drivers/net/wireless/ath5k/reset.c                 |    4 +-
 drivers/net/wireless/ath9k/hw.c                    |    3 +-
 drivers/net/wireless/ath9k/main.c                  |   74 +++++-
 drivers/net/wireless/ath9k/rc.c                    |    6 +-
 drivers/net/wireless/ath9k/recv.c                  |    5 +-
 drivers/net/wireless/b43/xmit.c                    |    4 +-
 drivers/net/wireless/b43legacy/b43legacy.h         |    5 +-
 drivers/net/wireless/b43legacy/main.c              |  111 ++++++++-
 drivers/net/wireless/hostap/Kconfig                |    6 +-
 drivers/net/wireless/hostap/hostap.h               |    2 +-
 drivers/net/wireless/hostap/hostap_80211.h         |    2 +-
 drivers/net/wireless/hostap/hostap_80211_rx.c      |   10 +-
 drivers/net/wireless/hostap/hostap_80211_tx.c      |    8 +-
 drivers/net/wireless/hostap/hostap_ap.c            |   12 +-
 drivers/net/wireless/hostap/hostap_ap.h            |    8 +-
 drivers/net/wireless/hostap/hostap_hw.c            |   61 +-----
 drivers/net/wireless/hostap/hostap_ioctl.c         |  141 +++++-------
 drivers/net/wireless/hostap/hostap_main.c          |   19 +-
 drivers/net/wireless/hostap/hostap_proc.c          |   20 +-
 drivers/net/wireless/hostap/hostap_wlan.h          |    6 +-
 drivers/net/wireless/ipw2x00/Kconfig               |  191 ++++++++++++++
 drivers/net/wireless/ipw2x00/Makefile              |   14 +
 drivers/net/wireless/{ => ipw2x00}/ipw2100.c       |   12 +-
 drivers/net/wireless/{ => ipw2x00}/ipw2100.h       |    0 
 drivers/net/wireless/{ => ipw2x00}/ipw2200.c       |   15 +-
 drivers/net/wireless/{ => ipw2x00}/ipw2200.h       |    0 
 .../net/wireless/ipw2x00/libipw_geo.c              |    0 
 .../net/wireless/ipw2x00/libipw_module.c           |   25 +--
 .../net/wireless/ipw2x00/libipw_rx.c               |    8 +-
 .../net/wireless/ipw2x00/libipw_tx.c               |    7 +-
 .../net/wireless/ipw2x00/libipw_wx.c               |   68 +++---
 drivers/net/wireless/iwlwifi/Makefile              |    1 +
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h         |  117 +---------
 drivers/net/wireless/iwlwifi/iwl-4965.c            |   44 +---
 drivers/net/wireless/iwlwifi/iwl-5000-hw.h         |   37 +---
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   54 +----
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  260 ++------------------
 drivers/net/wireless/iwlwifi/iwl-commands.h        |   12 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |   49 +----
 drivers/net/wireless/iwlwifi/iwl-core.h            |   16 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |   10 +
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   43 +---
 drivers/net/wireless/iwlwifi/iwl-fh.h              |   83 +++++++
 drivers/net/wireless/iwlwifi/iwl-power.c           |   17 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c              |   22 ++-
 drivers/net/wireless/iwlwifi/iwl-spectrum.c        |  198 +++++++++++++++
 drivers/net/wireless/iwlwifi/iwl-spectrum.h        |    1 +
 drivers/net/wireless/iwlwifi/iwl-tx.c              |   55 ++++-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |   49 +++--
 drivers/net/wireless/libertas/cmd.c                |   18 ++-
 drivers/net/wireless/libertas/cmd.h                |    3 +-
 drivers/net/wireless/libertas/defs.h               |   12 +
 drivers/net/wireless/libertas/ethtool.c            |    2 +-
 drivers/net/wireless/libertas/host.h               |    8 +
 drivers/net/wireless/libertas/hostcmd.h            |   26 ++-
 drivers/net/wireless/libertas/if_usb.c             |    3 +-
 drivers/net/wireless/mac80211_hwsim.c              |    6 +-
 drivers/net/wireless/orinoco/orinoco.c             |    4 +-
 drivers/net/wireless/rt2x00/rt2400pci.c            |  108 ++++++---
 drivers/net/wireless/rt2x00/rt2500pci.c            |  102 +++++---
 drivers/net/wireless/rt2x00/rt2500usb.c            |   25 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |   57 ++---
 drivers/net/wireless/rt2x00/rt2x00config.c         |   39 ++-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   45 ++--
 drivers/net/wireless/rt2x00/rt2x00leds.c           |   94 +++++---
 drivers/net/wireless/rt2x00/rt2x00lib.h            |   15 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |   17 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |   13 +-
 drivers/net/wireless/rt2x00/rt2x00pci.h            |   11 -
 drivers/net/wireless/rt2x00/rt2x00queue.c          |   32 +--
 drivers/net/wireless/rt2x00/rt2x00usb.c            |   42 ++--
 drivers/net/wireless/rt2x00/rt2x00usb.h            |    5 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |  113 ++++++---
 drivers/net/wireless/rt2x00/rt73usb.c              |   24 +-
 drivers/net/wireless/rtl818x/Makefile              |    7 +
 drivers/net/wireless/{ => rtl818x}/rtl8180.h       |    0 
 drivers/net/wireless/{ => rtl818x}/rtl8180_dev.c   |   12 +
 .../net/wireless/{ => rtl818x}/rtl8180_grf5101.c   |    0 
 .../net/wireless/{ => rtl818x}/rtl8180_grf5101.h   |    0 
 .../net/wireless/{ => rtl818x}/rtl8180_max2820.c   |    0 
 .../net/wireless/{ => rtl818x}/rtl8180_max2820.h   |    0 
 .../net/wireless/{ => rtl818x}/rtl8180_rtl8225.c   |   14 +-
 .../net/wireless/{ => rtl818x}/rtl8180_rtl8225.h   |    0 
 .../net/wireless/{ => rtl818x}/rtl8180_sa2400.c    |    0 
 .../net/wireless/{ => rtl818x}/rtl8180_sa2400.h    |    0 
 drivers/net/wireless/{ => rtl818x}/rtl8187.h       |    0 
 drivers/net/wireless/{ => rtl818x}/rtl8187_dev.c   |    8 +
 .../net/wireless/{ => rtl818x}/rtl8187_rtl8225.c   |    0 
 .../net/wireless/{ => rtl818x}/rtl8187_rtl8225.h   |    0 
 drivers/net/wireless/{ => rtl818x}/rtl818x.h       |    1 +
 drivers/net/wireless/zd1201.c                      |  115 +++++-----
 drivers/ssb/main.c                                 |   11 +-
 drivers/ssb/pcihost_wrapper.c                      |    2 +-
 include/net/ieee80211.h                            |   10 +-
 include/net/ieee80211_crypt.h                      |  108 --------
 include/net/lib80211.h                             |  113 +++++++++-
 include/net/mac80211.h                             |    5 +-
 net/Kconfig                                        |    1 -
 net/Makefile                                       |    1 -
 net/ieee80211/Kconfig                              |   50 ----
 net/ieee80211/Makefile                             |   12 -
 net/ieee80211/ieee80211_crypt.c                    |  206 ----------------
 net/mac80211/iface.c                               |   17 ++-
 net/mac80211/mlme.c                                |    1 -
 net/mac80211/rc80211_pid_algo.c                    |    6 +-
 net/mac80211/sta_info.h                            |    3 -
 net/wireless/Kconfig                               |    9 +
 net/wireless/Makefile                              |    3 +
 net/wireless/lib80211.c                            |  229 +++++++++++++++++-
 .../lib80211_crypt_ccmp.c}                         |  118 +++++-----
 .../lib80211_crypt_tkip.c}                         |  154 ++++++------
 .../lib80211_crypt_wep.c}                          |   79 +++---
 net/wireless/sysfs.c                               |   25 +--
 119 files changed, 2193 insertions(+), 2071 deletions(-)
 create mode 100644 drivers/net/wireless/ipw2x00/Kconfig
 create mode 100644 drivers/net/wireless/ipw2x00/Makefile
 rename drivers/net/wireless/{ => ipw2x00}/ipw2100.c (99%)
 rename drivers/net/wireless/{ => ipw2x00}/ipw2100.h (100%)
 rename drivers/net/wireless/{ => ipw2x00}/ipw2200.c (99%)
 rename drivers/net/wireless/{ => ipw2x00}/ipw2200.h (100%)
 rename net/ieee80211/ieee80211_geo.c => drivers/net/wireless/ipw2x00/libipw_geo.c (100%)
 rename net/ieee80211/ieee80211_module.c => drivers/net/wireless/ipw2x00/libipw_module.c (93%)
 rename net/ieee80211/ieee80211_rx.c => drivers/net/wireless/ipw2x00/libipw_rx.c (99%)
 rename net/ieee80211/ieee80211_tx.c => drivers/net/wireless/ipw2x00/libipw_tx.c (98%)
 rename net/ieee80211/ieee80211_wx.c => drivers/net/wireless/ipw2x00/libipw_wx.c (93%)
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-spectrum.c
 create mode 100644 drivers/net/wireless/rtl818x/Makefile
 rename drivers/net/wireless/{ => rtl818x}/rtl8180.h (100%)
 rename drivers/net/wireless/{ => rtl818x}/rtl8180_dev.c (98%)
 rename drivers/net/wireless/{ => rtl818x}/rtl8180_grf5101.c (100%)
 rename drivers/net/wireless/{ => rtl818x}/rtl8180_grf5101.h (100%)
 rename drivers/net/wireless/{ => rtl818x}/rtl8180_max2820.c (100%)
 rename drivers/net/wireless/{ => rtl818x}/rtl8180_max2820.h (100%)
 rename drivers/net/wireless/{ => rtl818x}/rtl8180_rtl8225.c (98%)
 rename drivers/net/wireless/{ => rtl818x}/rtl8180_rtl8225.h (100%)
 rename drivers/net/wireless/{ => rtl818x}/rtl8180_sa2400.c (100%)
 rename drivers/net/wireless/{ => rtl818x}/rtl8180_sa2400.h (100%)
 rename drivers/net/wireless/{ => rtl818x}/rtl8187.h (100%)
 rename drivers/net/wireless/{ => rtl818x}/rtl8187_dev.c (99%)
 rename drivers/net/wireless/{ => rtl818x}/rtl8187_rtl8225.c (100%)
 rename drivers/net/wireless/{ => rtl818x}/rtl8187_rtl8225.h (100%)
 rename drivers/net/wireless/{ => rtl818x}/rtl818x.h (98%)
 delete mode 100644 include/net/ieee80211_crypt.h
 delete mode 100644 net/ieee80211/Kconfig
 delete mode 100644 net/ieee80211/Makefile
 delete mode 100644 net/ieee80211/ieee80211_crypt.c
 rename net/{ieee80211/ieee80211_crypt_ccmp.c => wireless/lib80211_crypt_ccmp.c} (76%)
 rename net/{ieee80211/ieee80211_crypt_tkip.c => wireless/lib80211_crypt_tkip.c} (82%)
 rename net/{ieee80211/ieee80211_crypt_wep.c => wireless/lib80211_crypt_wep.c} (74%)

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2008-11-20.patch.bz2
-- 
John W. Linville		Linux should be at the core
linville@tuxdriver.com			of your literate lifestyle.
