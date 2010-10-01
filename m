From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2010-10-01
Date: Fri, 1 Oct 2010 12:18:19 -0400
Message-ID: <20101001161819.GD3049@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52252 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563Ab0JAQV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 12:21:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is the latest round of wireless LAN updates intended for 2.6.37.
Included are some ath5k bits from Bruno Randolf, some carl9170 updates
from Christian Lamparter, some mac80211 updates from Johannes Berg,
some work for supporting multiple VIFs on one device from Ben Greear,
and a smattering of other bits.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 94d57c4cfaa43e29ca5fa5ff874048cfc67276f5:

  enic: Update MAINTAINERS (2010-10-01 00:36:53 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git for-davem

Ben Greear (4):
      ath5k: Add bssid mask and rxfilter to debugfs.
      mac80211: Support multiple VIFS per AP in debugfs.
      mac80211/ath9k: Support AMPDU with multiple VIFs.
      mac80211: Support receiving data frames on multiple vifs.

Bruno Randolf (5):
      ath5k: Remove unused variable for atim window
      ath5k: Check and fix ATIM window
      ath5k: Increase "fudge" for beacon timers
      ath5k: Disable interrupts in ath5k_hw_get_tsf64
      ath5k: Fix bitmasks and typos for PCU Diagnostic register

Christian Lamparter (8):
      mac80211: clear txflags for ps-filtered frames
      carl9170: remove non-standard ba session teardown
      carl9170: angle brackets for wiki link
      carl9170: remove lost-frame workaround
      carl9170: fix tx_ampdu_upload counter
      carl9170: fix WARN_ON triggered by Broadcom HT STAs
      carl9170: revamp carl9170_tx_prepare
      carl9170: interrupt urbs must not set URB_ZERO_PACKET

Dan Carpenter (1):
      airo: remove "basic_rate" module option

Felix Fietkau (3):
      ath9k_hw: simplify revision checks for AR9280
      ath9k_hw: simplify revision checks for AR9285
      ath9k_hw: simplify revision checks for AR9287

Florian Mickler (1):
      iwl3945: queue the right work if the scan needs to be aborted

Ido Yariv (1):
      wl1271: Fix overflow in wl1271_boot_upload_nvs

Johannes Berg (7):
      mac80211: fix use-after-free
      mac80211: remove prepare_for_handlers sdata argument
      mac80211: consolidate packet processing
      mac80211: clean up rx handling wrt. found_sta
      mac80211: fix release_reorder_timeout in scan
      mac80211: move packet flags into packet
      cfg80211: always set IBSS basic rates

John W. Linville (5):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Revert "mac80211: fix use-after-free"
      wl12xx: fix separate-object-folder builds
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-next-2.6 into for-davem

Jouni Malinen (2):
      mac80211: Filter ProbeReq SuppRates based on TX rate mask
      mac80211: Add DS Parameter Set into Probe Request on 2.4 GHz

Juuso Oikarinen (1):
      mac80211: Fix WMM driver queue configuration

Luis R. Rodriguez (1):
      mac80211: fix offchannel assumption upon association

Rajkumar Manoharan (2):
      ath9k_htc: Fix beacon distribution in IBSS mode
      ath9k_htc: Fix TKIP disconnect failure with HTC drivers

Teemu Paasikivi (1):
      nl80211: Fix exit from nl80211_set_power_save

Vasanthakumar Thiagarajan (1):
      ath9k: Fix tx struck state with paprd

 drivers/net/wireless/Makefile                   |    3 +-
 drivers/net/wireless/airo.c                     |   11 -
 drivers/net/wireless/ath/ath5k/ath5k.h          |    2 +-
 drivers/net/wireless/ath/ath5k/attach.c         |    1 -
 drivers/net/wireless/ath/ath5k/base.c           |   16 +-
 drivers/net/wireless/ath/ath5k/debug.c          |   58 +++++
 drivers/net/wireless/ath/ath5k/debug.h          |    1 +
 drivers/net/wireless/ath/ath5k/dma.c            |    4 +-
 drivers/net/wireless/ath/ath5k/pcu.c            |   99 ++++++++-
 drivers/net/wireless/ath/ath5k/phy.c            |    4 +-
 drivers/net/wireless/ath/ath5k/reg.h            |   29 +--
 drivers/net/wireless/ath/ath9k/ar5008_phy.c     |   22 +-
 drivers/net/wireless/ath/ath9k/ar9002_calib.c   |   21 +--
 drivers/net/wireless/ath/ath9k/ar9002_hw.c      |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom.h         |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c      |   10 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c    |    6 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c     |   18 +-
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c |    9 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c   |    3 +
 drivers/net/wireless/ath/ath9k/hw.c             |   27 +-
 drivers/net/wireless/ath/ath9k/init.c           |    2 +-
 drivers/net/wireless/ath/ath9k/main.c           |    6 +-
 drivers/net/wireless/ath/ath9k/recv.c           |   10 +-
 drivers/net/wireless/ath/ath9k/reg.h            |   34 +---
 drivers/net/wireless/ath/ath9k/xmit.c           |    3 +-
 drivers/net/wireless/ath/carl9170/Kconfig       |    2 +-
 drivers/net/wireless/ath/carl9170/carl9170.h    |    1 -
 drivers/net/wireless/ath/carl9170/debug.c       |    4 -
 drivers/net/wireless/ath/carl9170/main.c        |   20 ++-
 drivers/net/wireless/ath/carl9170/tx.c          |  192 ++++++---------
 drivers/net/wireless/ath/carl9170/usb.c         |    2 -
 drivers/net/wireless/wl12xx/Makefile            |    3 +
 drivers/net/wireless/wl12xx/wl1271_boot.c       |   17 +-
 include/net/mac80211.h                          |   47 +++--
 net/mac80211/debugfs.c                          |    1 -
 net/mac80211/debugfs_netdev.c                   |    3 +
 net/mac80211/debugfs_sta.c                      |    2 +-
 net/mac80211/ieee80211_i.h                      |   43 +++-
 net/mac80211/main.c                             |    3 +-
 net/mac80211/mlme.c                             |   16 +-
 net/mac80211/rx.c                               |  291 ++++++++++++-----------
 net/mac80211/scan.c                             |    3 +-
 net/mac80211/sta_info.c                         |   15 +-
 net/mac80211/status.c                           |    1 +
 net/mac80211/util.c                             |   47 +++-
 net/mac80211/wpa.c                              |    2 +-
 net/wireless/ibss.c                             |   19 ++
 net/wireless/nl80211.c                          |   20 +--
 49 files changed, 671 insertions(+), 486 deletions(-)

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2010-10-01.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
