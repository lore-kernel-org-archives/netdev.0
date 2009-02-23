From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2009-02-23
Date: Mon, 23 Feb 2009 14:26:59 -0500
Message-ID: <20090223192659.GB3553@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44583 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753042AbZBWTaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2009 14:30:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is a big batch of changes intended for 2.6.30.  They run the usual
gamut of wireless driver and mac80211 changes...

There is an ugly one from me.  It is a kluge but it prevents a crash on
my Lenovo T400.  I bisected the crash down to "mac80211: use cfg80211s
BSS infrastructure", which is already in net-next-2.6.  Still, if it is
too ugly then let me know and I'll reformulate without it.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit ce16c5337ab0d165f95c88aa857207efd7c01139:
  Eric W. Biederman (1):
        netns: Remove net_alive

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Bing Zhao (1):
      libertas: fix power save issue in libertas_sdio module

Bob Copeland (10):
      ath9k: remove write-only current_rd_inuse
      ath9k: save a few calls to ath9k_regd_get_eepromRD
      ath9k: convert isWwrSKU macro into C code
      ath9k: remove ath9k_regd_get_rd()
      ath9k: remove prototype for ath9k_regd_get_current_country
      ath9k: move common regulatory code out of if() branches
      ath5k: don't mask off interrupt bits
      ath5k: use spin_lock_irqsave for beacon lock
      ath5k: move beacon processing to a tasklet
      ath5k: compute rts/cts duration after computing full pktlen

Dan Williams (4):
      hostap: convert usage of net/ieee80211.h to linux/ieee80211.h
      make net/ieee80211.h private to ipw2x00
      cfg80211: age scan results on resume
      ipw2x00: age scan results on resume

Helmut Schaa (1):
      iwlagn: clean up error path in iwl_pci_probe

Ivo van Doorn (4):
      rt2x00: uncomment get_tsf
      rt2x00: Remove check for rf word 0
      rt2x00: Add various new USB IDs for rt73usb
      rt2x00: Fix RF offset

Jiri Slaby (1):
      ipw2200, fix ipw io functions

Johannes Berg (10):
      mac80211: disallow moving netns
      mac80211: fix aggregation for hardware with ampdu queues
      mac80211: split IBSS/managed code
      genetlink: introduce pre/post methods
      nl80211: lock rtnl around all operations
      cfg80211/mac80211: fill qual.qual value/adjust max_qual.qual
      mac80211: add missing kernel-doc
      nl80211: remove admin requirement from station get
      cfg80211: clean up signal type
      mac80211/cfg80211: move iwrange handler to cfg80211

John W. Linville (2):
      airo: correct improper initialization of local variable
      iwlagn: default to MAX_UCODE_BEACON_INTERVAL in iwl_adjust_beacon_interval

Jouni Malinen (2):
      nl80211: Optional IEs into scan request
      nl80211: Provide access to STA TX/RX packet counters

Randy Dunlap (1):
      wireless: fix for CONFIG_NL80211=n

Reinette Chatre (2):
      iwlwifi: use singlethread workqueue
      iwlwifi: Fix and rework Kconfig file

Roel Kluin (3):
      wavelan: Test arraysize before an element of the array.
      p54: misplaced parentheses
      b43: Fix LO calibration txctl reg value

Senthil Balasubramanian (1):
      ath9k: Add open loop control support

Sujith (16):
      ath9k: Store the correct max TX power level
      ath9k: Fix rd_ext EEPROM capability for AR9285
      ath9k: Enable Fractional N mode
      ath9k: Enable TSF Out of Range Interrupt
      ath9k: Initialize AGC calibration properly
      ath9k: Fix bug in disabling MIB counters
      ath9k: Fix incorrect noise floor reading for 4k EEPROM
      ath9k: Decrease minimum NF threshold
      mac80211: Extend the rate control API with an update callback
      ath9k: Program the RTC registers correctly
      ath9k: Fix HW wait timeout
      ath9k: Fix antenna assignment bug in TX status processing
      ath9k: Initialize channel change time
      ath9k: Remove a few unused capability macros
      ath9k: Remove ath_txq_depth and get the queue depth directly
      ath9k: Use beacon interval directly

Vasanthakumar Thiagarajan (2):
      mac80211: Make sure non-HT connection when IEEE80211_STA_TKIP_WEP_USED is set
      ath9k: Fix PTK/GTK handshake timeout

Wu, Fengguang (1):
      iwlwifi: report correct and detailed values about requested txpower

 drivers/net/wireless/airo.c                        |    3 +-
 drivers/net/wireless/ath5k/base.c                  |   84 +-
 drivers/net/wireless/ath5k/base.h                  |    1 +
 drivers/net/wireless/ath9k/ani.c                   |    7 +-
 drivers/net/wireless/ath9k/beacon.c                |    3 +
 drivers/net/wireless/ath9k/calib.c                 |   66 +-
 drivers/net/wireless/ath9k/calib.h                 |    2 +-
 drivers/net/wireless/ath9k/eeprom.c                |  234 +++-
 drivers/net/wireless/ath9k/eeprom.h                |   34 +-
 drivers/net/wireless/ath9k/hw.c                    |  106 +-
 drivers/net/wireless/ath9k/hw.h                    |   20 +-
 drivers/net/wireless/ath9k/mac.c                   |   30 +-
 drivers/net/wireless/ath9k/main.c                  |   36 +-
 drivers/net/wireless/ath9k/pci.c                   |    3 +-
 drivers/net/wireless/ath9k/phy.c                   |   19 +-
 drivers/net/wireless/ath9k/phy.h                   |   29 +
 drivers/net/wireless/ath9k/rc.c                    |    7 +-
 drivers/net/wireless/ath9k/recv.c                  |    1 -
 drivers/net/wireless/ath9k/reg.h                   |   12 +-
 drivers/net/wireless/ath9k/regd.c                  |   28 +-
 drivers/net/wireless/ath9k/regd.h                  |    9 -
 drivers/net/wireless/ath9k/xmit.c                  |   28 +-
 drivers/net/wireless/b43/lo.c                      |    2 +-
 drivers/net/wireless/hostap/hostap.h               |    2 +-
 drivers/net/wireless/hostap/hostap_80211.h         |    2 +-
 drivers/net/wireless/hostap/hostap_80211_rx.c      |   88 +-
 drivers/net/wireless/hostap/hostap_80211_tx.c      |   51 +-
 drivers/net/wireless/hostap/hostap_ap.c            |  138 +-
 drivers/net/wireless/hostap/hostap_ap.h            |    6 +-
 drivers/net/wireless/hostap/hostap_hw.c            |   24 +-
 drivers/net/wireless/hostap/hostap_info.c          |    1 +
 drivers/net/wireless/hostap/hostap_ioctl.c         |    1 +
 drivers/net/wireless/hostap/hostap_main.c          |   38 +-
 drivers/net/wireless/ipw2x00/Kconfig               |    2 +-
 .../net/wireless/ipw2x00}/ieee80211.h              |    3 +
 drivers/net/wireless/ipw2x00/ipw2100.c             |   12 +-
 drivers/net/wireless/ipw2x00/ipw2100.h             |    8 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |  116 +-
 drivers/net/wireless/ipw2x00/ipw2200.h             |    7 +-
 drivers/net/wireless/ipw2x00/libipw_geo.c          |    2 +-
 drivers/net/wireless/ipw2x00/libipw_module.c       |   17 +-
 drivers/net/wireless/ipw2x00/libipw_rx.c           |    5 +-
 drivers/net/wireless/ipw2x00/libipw_tx.c           |    2 +-
 drivers/net/wireless/ipw2x00/libipw_wx.c           |   27 +-
 drivers/net/wireless/iwlwifi/Kconfig               |   56 +-
 drivers/net/wireless/iwlwifi/Makefile              |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |   13 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |   10 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |    4 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |    2 +-
 drivers/net/wireless/libertas/defs.h               |    1 +
 drivers/net/wireless/libertas/if_sdio.c            |    6 +
 drivers/net/wireless/p54/p54common.c               |    4 +-
 drivers/net/wireless/rt2x00/rt2400pci.c            |    3 -
 drivers/net/wireless/rt2x00/rt2400pci.h            |    4 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |    3 -
 drivers/net/wireless/rt2x00/rt2500pci.h            |    4 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |    3 -
 drivers/net/wireless/rt2x00/rt2500usb.h            |    4 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c          |   10 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |    3 -
 drivers/net/wireless/rt2x00/rt61pci.h              |    4 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |   19 +-
 drivers/net/wireless/rt2x00/rt73usb.h              |    4 +-
 drivers/net/wireless/wavelan.c                     |    3 +-
 include/linux/nl80211.h                            |    5 +
 include/net/cfg80211.h                             |   23 +-
 include/net/genetlink.h                            |   47 +-
 include/net/mac80211.h                             |   18 +-
 include/net/wireless.h                             |    3 +
 net/mac80211/Makefile                              |    1 +
 net/mac80211/agg-rx.c                              |    6 +-
 net/mac80211/agg-tx.c                              |  191 ++-
 net/mac80211/cfg.c                                 |   49 +-
 net/mac80211/debugfs_netdev.c                      |   48 +-
 net/mac80211/ht.c                                  |   19 +-
 net/mac80211/ibss.c                                |  888 +++++++++++
 net/mac80211/ieee80211_i.h                         |  138 ++-
 net/mac80211/iface.c                               |   77 +-
 net/mac80211/key.c                                 |    2 +-
 net/mac80211/main.c                                |   24 +-
 net/mac80211/mlme.c                                | 1648 +++++---------------
 net/mac80211/rate.h                                |   12 +
 net/mac80211/rx.c                                  |   37 +-
 net/mac80211/scan.c                                |   57 +-
 net/mac80211/spectmgmt.c                           |   26 +-
 net/mac80211/sta_info.c                            |   15 +-
 net/mac80211/sta_info.h                            |    5 +-
 net/mac80211/tx.c                                  |   29 +-
 net/mac80211/util.c                                |  254 +++-
 net/mac80211/wext.c                                |  262 ++--
 net/mac80211/wme.c                                 |  161 +--
 net/mac80211/wme.h                                 |    6 -
 net/netlink/genetlink.c                            |   19 +-
 net/wireless/core.h                                |    3 +
 net/wireless/nl80211.c                             |  124 +-
 net/wireless/nl80211.h                             |    4 +
 net/wireless/scan.c                                |   61 +-
 net/wireless/sysfs.c                               |    7 +
 net/wireless/wext-compat.c                         |   97 ++
 101 files changed, 3315 insertions(+), 2533 deletions(-)
 rename {include/net => drivers/net/wireless/ipw2x00}/ieee80211.h (99%)
 create mode 100644 net/mac80211/ibss.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2009-02-23.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
