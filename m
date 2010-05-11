From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2010-05-11
Date: Tue, 11 May 2010 15:05:10 -0400
Message-ID: <20100511190510.GD2400@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44651 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757387Ab0EKTPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 15:15:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Another round of bits intended for 2.6.35...mostly driver updates this
time.  The biggest item of note is some continued attention for rt2800
from the rt2x00 team.

Please let me know if there are problems!

John

---

The following changes since commit d250fe91ae129bff0968e685cc9c466d3a5e3482:
  David S. Miller (1):
        Merge branch 'master' of git://git.kernel.org/.../kaber/nf-next-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git for-davem

Christian Lamparter (1):
      ar9170usb: remove deprecated aggregation code

Dan Carpenter (4):
      iwlwifi: remove stray mutex_unlock()
      ath9k/htc_drv_main: null dereference typo
      ath9k/htc_drv_main: off by one error
      ath5k: several off by one range checks

David Kilroy (1):
      orinoco: refactor xmit path

Felix Fietkau (1):
      ath9k: fix another source of corrupt frames

Gertjan van Wingerde (9):
      rt2x00: Fix setting of txdesc->length field.
      rt2x00: Clean up rt2800usb.h.
      rt2x00: Don't check whether hardware crypto is enabled when reading RXD.
      rt2x00: Factor out TXWI writing to common rt2800 code.
      rt2x00: Factor out RXWI processing to common rt2800 code.
      rt2x00: Clean up all driver's kick_tx_queue callback functions.
      rt2x00: provide beacon's txdesc to write_beacon callback function.
      rt2x00: Fix beaconing on rt2800.
      rt2x00: Clean up generic procedures on descriptor writing.

Helmut Schaa (3):
      rt2x00: rt2800: update initial SIFS values
      rt2x00: rt2800: don't overwrite SIFS values on erp changes
      rt2x00: rt2800: use correct txop value in tx descriptor

Ivo van Doorn (1):
      rt2x00: Fix RF3052 channel initialization

Johannes Berg (3):
      mac80211: fix BSS info reconfiguration
      cfg80211/mac80211: better channel handling
      mac80211: improve HT channel handling

John W. Linville (5):
      mac80211: set IEEE80211_TX_CTL_FIRST_FRAGMENT for beacons
      rtl8180: assign sequence numbers in the driver
      rtl8180: add software-based support for IBSS mode
      rtl8180: change PCI DMA mask to DMA_BIT_MASK(32)
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-next-2.6 into for-davem

Juuso Oikarinen (4):
      wl1271: Add sysfs file to retrieve HW PG-version and ROM-version
      wl1271: Fix 32 bit register read related endiannes bug
      wl1271: Fix to join and channel number handling
      wl1271: Reduce PSM entry hang over period from 128 => 1 ms

Luis R. Rodriguez (4):
      ath9k_common: move the rate status setting into ath9k_process_rate()
      ath9k_common: drop incomming frames with an invalid hardware rate
      ath9k_hw: Update initvals for AR9003 for xb113
      ath9k_hw: enable PCIe low power mode for AR9003

Randy Dunlap (1):
      wireless: depends on NET

Stephen Rothwell (1):
      ar9170: fix for driver-core ABI change

Sujith (2):
      ath9k_htc: Fix beaconing in IBSS mode
      ath9k_htc: Handle IDLE LED properly

Teemu Paasikivi (1):
      wl1271: Increase timeout for command event waiting

Xose Vazquez Perez (1):
      wireless: rt2x00: rt2800usb: replace X by x

 drivers/net/wireless/Kconfig                     |    1 +
 drivers/net/wireless/ath/ar9170/ar9170.h         |   52 +--
 drivers/net/wireless/ath/ar9170/main.c           |  558 +---------------------
 drivers/net/wireless/ath/ar9170/usb.c            |    5 +-
 drivers/net/wireless/ath/ath5k/ani.c             |    6 +-
 drivers/net/wireless/ath/ath9k/ar9003_initvals.h |  204 ++++----
 drivers/net/wireless/ath/ath9k/common.c          |   49 ++-
 drivers/net/wireless/ath/ath9k/htc.h             |    5 +-
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c  |   39 +--
 drivers/net/wireless/ath/ath9k/htc_drv_init.c    |    2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c    |   42 +-
 drivers/net/wireless/ath/ath9k/hw.c              |   20 +
 drivers/net/wireless/iwlwifi/iwl-3945.c          |    1 -
 drivers/net/wireless/libertas/cfg.c              |    1 +
 drivers/net/wireless/mac80211_hwsim.c            |   19 +-
 drivers/net/wireless/orinoco/cfg.c               |    1 +
 drivers/net/wireless/orinoco/main.c              |  169 ++++---
 drivers/net/wireless/orinoco/orinoco.h           |    6 +
 drivers/net/wireless/orinoco/orinoco_usb.c       |   91 ++--
 drivers/net/wireless/rndis_wlan.c                |    4 +-
 drivers/net/wireless/rt2x00/rt2400pci.c          |   22 +-
 drivers/net/wireless/rt2x00/rt2500pci.c          |   22 +-
 drivers/net/wireless/rt2x00/rt2500usb.c          |   66 +--
 drivers/net/wireless/rt2x00/rt2800lib.c          |  178 +++++++-
 drivers/net/wireless/rt2x00/rt2800lib.h          |    3 +
 drivers/net/wireless/rt2x00/rt2800pci.c          |  166 ++-----
 drivers/net/wireless/rt2x00/rt2800usb.c          |  182 ++------
 drivers/net/wireless/rt2x00/rt2800usb.h          |   40 --
 drivers/net/wireless/rt2x00/rt2x00.h             |    3 +-
 drivers/net/wireless/rt2x00/rt2x00crypto.c       |    1 +
 drivers/net/wireless/rt2x00/rt2x00ht.c           |   17 +
 drivers/net/wireless/rt2x00/rt2x00queue.c        |   23 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h        |    2 +
 drivers/net/wireless/rt2x00/rt2x00reg.h          |   10 +
 drivers/net/wireless/rt2x00/rt61pci.c            |   41 +-
 drivers/net/wireless/rt2x00/rt73usb.c            |   51 +--
 drivers/net/wireless/rtl818x/rtl8180.h           |   11 +
 drivers/net/wireless/rtl818x/rtl8180_dev.c       |   96 ++++-
 drivers/net/wireless/wl12xx/wl1271.h             |    4 +-
 drivers/net/wireless/wl12xx/wl1271_boot.c        |   12 +
 drivers/net/wireless/wl12xx/wl1271_boot.h        |    3 +
 drivers/net/wireless/wl12xx/wl1271_cmd.c         |    2 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.h         |    2 +-
 drivers/net/wireless/wl12xx/wl1271_io.h          |    4 +-
 drivers/net/wireless/wl12xx/wl1271_main.c        |   63 +++-
 include/linux/nl80211.h                          |   13 +
 include/net/cfg80211.h                           |   11 +-
 include/net/mac80211.h                           |    6 +
 net/mac80211/Makefile                            |    3 +-
 net/mac80211/cfg.c                               |   58 +++-
 net/mac80211/chan.c                              |  127 +++++
 net/mac80211/ibss.c                              |    5 +-
 net/mac80211/ieee80211_i.h                       |   16 +-
 net/mac80211/main.c                              |    2 +-
 net/mac80211/mlme.c                              |   44 +-
 net/mac80211/tx.c                                |    5 +-
 net/mac80211/util.c                              |   25 +-
 net/wireless/chan.c                              |   56 +--
 net/wireless/core.h                              |   12 +-
 net/wireless/ibss.c                              |    5 -
 net/wireless/nl80211.c                           |  171 +++++--
 net/wireless/sme.c                               |    5 -
 net/wireless/wext-compat.c                       |   15 +-
 net/wireless/wext-sme.c                          |    2 +-
 64 files changed, 1369 insertions(+), 1511 deletions(-)
 create mode 100644 net/mac80211/chan.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2010-05-11.patch.bz2
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
