From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2009-09-23
Date: Wed, 23 Sep 2009 11:53:40 -0400
Message-ID: <20090923155339.GA14597@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55280 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbZIWPye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 11:54:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Please accept this one last round of wireless bits for the merge window.
They are fixes for the most part, and the teams involved are very eager
to have these for the 2.6.32 cycle.  In particular, the b43 and ath9k
teams have some late breakers -- yes, I have reminded them of the
process, but they are quite insistent...

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit 4142e0d1def2c0176c27fd2e810243045a62eb6d:
  Linus Torvalds (1):
        Merge branch 'osync_cleanup' of git://git.kernel.org/.../jack/linux-fs-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git

Albert Herranz (2):
      b43: Add Soft-MAC SDIO device support
      b43: fix build error if !CONFIG_B43_LEDS

Andrew Price (1):
      rt2x00: fix the definition of rt2x00crypto_rx_insert_iv

Christian Lamparter (2):
      p54usb: add Zcomax XG-705A usbid
      ar9170usb: add usbid for TP-Link TL-WN821N v2

Daniel C Halperin (1):
      iwlwifi: fix HT operation in 2.4 GHz band

Holger Schurig (2):
      cfg80211: use cfg80211_wext_freq() for freq conversion
      cfg80211: minimal error handling for wext-compat freq scanning

Johannes Berg (4):
      iwlwifi: disable powersave for 4965
      cfg80211: fix SME connect
      mac80211: fix DTIM setting
      cfg80211: don't overwrite privacy setting

Julia Lawall (1):
      drivers/net/wireless: Use usb_endpoint_dir_out

Larry Finger (2):
      ssb: Fix error when V1 SPROM extraction is forced
      b43: Implement RFKILL status for LP PHY

Luis R. Rodriguez (1):
      wireless: default CONFIG_WLAN to y

Martin Decky (1):
      hostap: Revert a toxic part of the conversion to net_device_ops

Michael Buesch (11):
      b43: Force-wake queues on init
      ssb: Disable verbose SDIO coreswitch
      b43: Fix resume failure
      b43: Rewrite suspend/resume code
      b43: Do not use _irqsafe callbacks
      b43: Fix SDIO interrupt handler deadlock
      b43: Fix IRQ sync for SDIO
      b43: Add optional verbose runtime statistics
      b43: Disable PMQ mechanism
      b43: Don't abuse wl->current_dev in the led work
      b43: Remove BROKEN attribute from SDIO

Pavel Roskin (1):
      rc80211_minstrel: fix contention window calculation

Randy Dunlap (2):
      ssb/sdio: fix printk format warnings
      wl12xx: fix kconfig/link errors

Reinette Chatre (3):
      iwlwifi: fix potential rx buffer loss
      iwlwifi: do not send sync command while holding spinlock
      iwlwifi: reduce noise when skb allocation fails

Senthil Balasubramanian (2):
      ath9k: Adjust the chainmasks properly
      ath9k: Fix bug in chain handling

Stanislaw Gruszka (1):
      iwlagn: fix panic in iwl{5000,4965}_rx_reply_tx

Sujith (5):
      ath9k: Fix bug in ANI channel handling
      ath9k: Restore TSF after RESET
      ath9k: Fix chip wakeup issue
      ath9k: Fix regression in PA calibration
      ath9k: Fix RFKILL bugs

Thomas Ilnseher (1):
      b43: Add LP PHY Analog Switch Support

Vasanthakumar Thiagarajan (3):
      ath9k: Fix rx data corruption
      ath9k: Don't read NF when chip has gone through full sleep mode
      ath9k: Do a full reset for AR9280

Vivek Natarajan (5):
      ath9k: Set default noise floor value for AR9287
      ath9k: Revamp PCIE workarounds
      ath9k: Fix AHB reset for AR9280
      ath9k: Disable autosleep feature by default.
      ath9k: Initialize txgain and rxgain for newer AR9287 chipsets.

Wey-Yi Guy (1):
      iwlwifi: find the correct first antenna

 drivers/net/wireless/Kconfig                |    1 +
 drivers/net/wireless/ath/ar9170/usb.c       |    2 +
 drivers/net/wireless/ath/ath9k/ani.c        |    6 +-
 drivers/net/wireless/ath/ath9k/calib.c      |   23 ++-
 drivers/net/wireless/ath/ath9k/calib.h      |    1 +
 drivers/net/wireless/ath/ath9k/eeprom_def.c |    4 +-
 drivers/net/wireless/ath/ath9k/hw.c         |  202 ++++++++++++--------
 drivers/net/wireless/ath/ath9k/hw.h         |    4 +-
 drivers/net/wireless/ath/ath9k/main.c       |   16 +-
 drivers/net/wireless/ath/ath9k/reg.h        |    3 +-
 drivers/net/wireless/b43/Kconfig            |   21 ++-
 drivers/net/wireless/b43/Makefile           |    1 +
 drivers/net/wireless/b43/b43.h              |   23 +--
 drivers/net/wireless/b43/debugfs.c          |    1 +
 drivers/net/wireless/b43/debugfs.h          |    1 +
 drivers/net/wireless/b43/dma.c              |    4 +-
 drivers/net/wireless/b43/leds.c             |  266 +++++++++++++++++++--------
 drivers/net/wireless/b43/leds.h             |   33 +++-
 drivers/net/wireless/b43/main.c             |  230 +++++++++++++----------
 drivers/net/wireless/b43/phy_lp.c           |   12 +-
 drivers/net/wireless/b43/pio.c              |    2 +-
 drivers/net/wireless/b43/rfkill.c           |    2 +-
 drivers/net/wireless/b43/sdio.c             |  202 ++++++++++++++++++++
 drivers/net/wireless/b43/sdio.h             |   45 +++++
 drivers/net/wireless/b43/xmit.c             |    5 +-
 drivers/net/wireless/hostap/hostap_main.c   |    3 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    7 +
 drivers/net/wireless/iwlwifi/iwl-5000.c     |    6 +
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c   |   10 +-
 drivers/net/wireless/iwlwifi/iwl-core.c     |    9 +-
 drivers/net/wireless/iwlwifi/iwl-core.h     |    1 +
 drivers/net/wireless/iwlwifi/iwl-power.c    |    5 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c       |   34 +++-
 drivers/net/wireless/iwlwifi/iwl-sta.c      |    2 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   33 +++-
 drivers/net/wireless/p54/p54usb.c           |    1 +
 drivers/net/wireless/rt2x00/rt2x00lib.h     |    2 +-
 drivers/net/wireless/wl12xx/Kconfig         |    2 +-
 drivers/net/wireless/zd1211rw/zd_usb.c      |    2 +-
 drivers/ssb/pci.c                           |    1 +
 drivers/ssb/sdio.c                          |    6 +-
 net/mac80211/rc80211_minstrel.c             |    2 +-
 net/mac80211/scan.c                         |    4 +-
 net/wireless/scan.c                         |    7 +-
 net/wireless/sme.c                          |   21 ++-
 net/wireless/wext-sme.c                     |    2 +-
 46 files changed, 921 insertions(+), 349 deletions(-)
 create mode 100644 drivers/net/wireless/b43/sdio.c
 create mode 100644 drivers/net/wireless/b43/sdio.h

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2009-09-23.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
