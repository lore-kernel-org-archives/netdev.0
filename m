From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2008-12-05
Date: Fri, 5 Dec 2008 11:55:47 -0500
Message-ID: <20081205165546.GB18988@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46521 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754244AbYLERAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 12:00:12 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is another big round of updates intended for 2.6.29 -- mostly
drivers stuff this time around.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit e061b165c7f4ec5e2e160d990b49011b5b6e5c6a:
  Martin Willi (1):
        xfrm: Accept ESP packets regardless of UDP encapsulation mode

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Abbas, Mohamed (2):
      iwl3945: add debugfs support
      iwl3945: Fix iwl3945 rate scaling.

Abhijeet Kolekar (1):
      iwl3945 : Fix a-band association for passive channels

Bob Copeland (3):
      ath5k: preserve higher order bits when setting mac address
      ath5k: clean up ath5k_hw_set_key
      ath5k: enable combined michael mic in key cache

Chatre, Reinette (1):
      iwlwifi: store ucode version number

Christian Lamparter (6):
      mac80211: add sta_notify_ps callback
      p54: revamp station power save management in access point mode
      p54: utilize cryptographic accelerator
      p54: include support for 2.13.24.0 USB LM87 Firmwares
      p54: refactoring
      p54: per-device names

Colin McCabe (1):
      ath9k: Replace ath9k_opmode with nl80211_iftype

Fabio Rossi (1):
      mac80211: accept empty strings for hidden SSIDs

Harvey Harrison (1):
      iwlwifi: remove uses of __constant_{endian} helpers

Helmut Schaa (1):
      iwl3945: remove obsolete irq handling

Ivo van Doorn (9):
      rt2x00: Optimize IV/EIV handling
      rt2x00: Store retry limit values
      rt2x00: Remove duplicate code
      rt2x00: Implement HW encryption (rt2500usb)
      rt2x00: Release rt2x00 2.2.3
      rt2x00: Add RXDONE_CRYPTO_IV/ICV flags
      rt2x00: Fix check for BSS info changes
      rt2x00: Move crypto TX descriptor handling to rt2x00crypto.c
      rt2x00: Correctly initialize AID during set_key()

Johannes Berg (8):
      mac80211: only transition STAs ps->wake on data frames
      cfg80211: handle SIOCGIWNAME
      cfg80211: handle SIOCGIWMODE/SIOCSIWMODE
      wireless: clean up radiotap a bit
      cfg80211: fix wiphy remove if no regulatory request
      cfg80211: "fix" 11d oops
      p54: fix lm87 checksum endianness
      iwlwifi: disable AP mode

John W. Linville (2):
      hostap: select required crypto bits in Kconfig
      mac80211: deauth when interface is marked down

Jouni Malinen (1):
      nl80211: Add frequency configuration (including HT40)

Kalle Valo (1):
      mac80211: document ieee80211_tx_info.pad

Luis R. Rodriguez (3):
      nl80211: relicense nl80211.h under the ISC
      ath9k: Check for pci_map_single() errors
      ath9k: Use GFP_ATOMIC when allocating TX private area

Rami Rosen (1):
      mac80211: tx module cleanup.

Reinette Chatre (1):
      iwlwifi: rely on API version read from firmware

Samuel Ortiz (1):
      iwl3945: Select correct sta ID from find_station()

Sujith (7):
      ath9k: Handle channel initialization for AP mode
      ath9k: Use cleaner debug masks
      ath9k: Add ATH9K_DEBUG configuration option
      ath9k: Remove includes that are not needed
      ath9k: Add initial layout for an ath9k specific debugfs mechanism
      ath9k: Add a debugfs file for dumping DMA status
      ath9k: Choose correct ANI calibration period

Tomas Winkler (6):
      mac80211: disassociate prior to unlinking AP/station
      iwlwifi: properly initialize calibration command header
      iwlwifi: 5150 add support for 5150
      iwlwifi: 5150 enable DC calibration
      iwlwifi: 5150 compute ct kill threshold
      iwlwifi: 5150 parametrize eeprom versions

Winkler, Tomas (4):
      iwlwifi: 5150 enable LO, TXIQ and BB calibrations
      iwlwifi: move host command check function into separate file
      iwlwifi: move disable/enable interrupts to iwl-core.c
      iwlwifi: move channels sysfs to debugfs

Wu Fengguang (1):
      generic swap(): ath9k: rename swap() to swap_array()

Zhu Yi (2):
      iwlwifi: fix printk size format error
      iwlwifi: fix DMA channel number in iwl_txq_ctx_stop

herton (1):
      rtl8187: fix retry count passed in rtl8187_tx

 drivers/net/wireless/ath5k/ath5k.h                |    1 +
 drivers/net/wireless/ath5k/attach.c               |    6 +
 drivers/net/wireless/ath5k/pcu.c                  |   95 +++--
 drivers/net/wireless/ath5k/reg.h                  |    1 +
 drivers/net/wireless/ath9k/Kconfig                |   11 +
 drivers/net/wireless/ath9k/Makefile               |    2 +
 drivers/net/wireless/ath9k/ani.c                  |   46 +-
 drivers/net/wireless/ath9k/ath9k.h                |   11 +-
 drivers/net/wireless/ath9k/beacon.c               |  118 +++---
 drivers/net/wireless/ath9k/calib.c                |   69 ++--
 drivers/net/wireless/ath9k/core.h                 |  206 ++++-----
 drivers/net/wireless/ath9k/debug.c                |  160 +++++++
 drivers/net/wireless/ath9k/eeprom.c               |   16 +-
 drivers/net/wireless/ath9k/hw.c                   |  218 ++++-----
 drivers/net/wireless/ath9k/mac.c                  |  138 ++-----
 drivers/net/wireless/ath9k/main.c                 |  342 +++++++-------
 drivers/net/wireless/ath9k/phy.c                  |   14 +-
 drivers/net/wireless/ath9k/rc.c                   |   58 ++-
 drivers/net/wireless/ath9k/recv.c                 |   47 ++-
 drivers/net/wireless/ath9k/regd.c                 |   85 ++--
 drivers/net/wireless/ath9k/regd.h                 |    2 +-
 drivers/net/wireless/ath9k/xmit.c                 |  123 +++---
 drivers/net/wireless/hostap/Kconfig               |    7 +
 drivers/net/wireless/ipw2x00/ipw2200.c            |   24 +-
 drivers/net/wireless/iwlwifi/Makefile             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-commands.h  |  140 +++---
 drivers/net/wireless/iwlwifi/iwl-3945-core.h      |   26 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c        |  145 +++++--
 drivers/net/wireless/iwlwifi/iwl-3945.c           |   43 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h           |   18 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c           |   26 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c           |  111 ++++-
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd-check.c |  108 +++++
 drivers/net/wireless/iwlwifi/iwl-agn.c            |  232 +++-------
 drivers/net/wireless/iwlwifi/iwl-commands.h       |  234 +++++-----
 drivers/net/wireless/iwlwifi/iwl-core.c           |   26 +-
 drivers/net/wireless/iwlwifi/iwl-core.h           |   38 ++-
 drivers/net/wireless/iwlwifi/iwl-debug.h          |    1 +
 drivers/net/wireless/iwlwifi/iwl-debugfs.c        |   76 ++++
 drivers/net/wireless/iwlwifi/iwl-dev.h            |   15 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h         |    1 +
 drivers/net/wireless/iwlwifi/iwl-tx.c             |   11 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c       |  130 ++++---
 drivers/net/wireless/libertas/radiotap.h          |    3 -
 drivers/net/wireless/p54/p54.h                    |    4 +-
 drivers/net/wireless/p54/p54common.c              |  500 ++++++++++++++-------
 drivers/net/wireless/p54/p54common.h              |   20 +-
 drivers/net/wireless/p54/p54usb.c                 |   49 ++-
 drivers/net/wireless/rt2x00/Kconfig               |    1 +
 drivers/net/wireless/rt2x00/rt2500usb.c           |  134 ++++++-
 drivers/net/wireless/rt2x00/rt2500usb.h           |    3 +
 drivers/net/wireless/rt2x00/rt2x00.h              |    9 +-
 drivers/net/wireless/rt2x00/rt2x00config.c        |   39 +-
 drivers/net/wireless/rt2x00/rt2x00crypto.c        |   79 ++--
 drivers/net/wireless/rt2x00/rt2x00dev.c           |    3 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h           |   15 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c           |   16 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c         |   46 +--
 drivers/net/wireless/rt2x00/rt2x00queue.h         |   16 +-
 drivers/net/wireless/rt2x00/rt61pci.c             |   11 +-
 drivers/net/wireless/rt2x00/rt73usb.c             |   11 +-
 drivers/net/wireless/rtl818x/rtl8187_dev.c        |    4 +-
 include/linux/nl80211.h                           |   44 ++-
 include/net/cfg80211.h                            |   20 +
 include/net/ieee80211_radiotap.h                  |   15 +-
 include/net/mac80211.h                            |   22 +
 net/mac80211/cfg.c                                |   13 +
 net/mac80211/ieee80211_i.h                        |    1 +
 net/mac80211/iface.c                              |   10 +-
 net/mac80211/main.c                               |   30 ++-
 net/mac80211/mlme.c                               |   20 +-
 net/mac80211/rx.c                                 |   35 ++-
 net/mac80211/tx.c                                 |   11 +-
 net/mac80211/util.c                               |    1 +
 net/mac80211/wext.c                               |  120 +-----
 net/wireless/Makefile                             |    1 +
 net/wireless/nl80211.c                            |   57 +++
 net/wireless/reg.c                                |    5 +-
 net/wireless/wext-compat.c                        |  139 ++++++
 79 files changed, 2854 insertions(+), 1836 deletions(-)
 create mode 100644 drivers/net/wireless/ath9k/debug.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-hcmd-check.c
 create mode 100644 net/wireless/wext-compat.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2008-12-05.patch.bz2

-- 
John W. Linville		Linux should be at the core
linville@tuxdriver.com			of your literate lifestyle.
