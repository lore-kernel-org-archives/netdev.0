From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2009-06-10
Date: Wed, 10 Jun 2009 14:56:39 -0400
Message-ID: <20090610185639.GC3892@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Despite my previous optimistic prediction, I need to ask for one more
2.6.31 pull before/during the merge window... :-)

This one actually does have a number of bug fixes embedded within, as
well as some further fleshing-out and usage of the new rfkill
infrastructure changes that are already queued for 2.6.31.  The other
bits are more minor, but they have already spent at least a few days in
-next and I believe they are safe for 2.6.31.

Please let me know if there are problems!

Thanks,

John

P.S.  For some reason (probably the 2.6.30 release) the public push on
kernel.org seems to be taking a lot longer than usual.  So you probably
want to ensure that the wireless-next-2.6 head matches 2f0accc13520 or
just pull using ssh (or direct file access).

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/
	
---

The following changes since commit 1506e30b5f25f6c3357167a18f0e4ae6f5662a28:
  Johannes Berg (1):
        rfkill: include err.h

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git

Alan Jenkins (3):
      rfkill: remove set_global_sw_state
      sony-laptop: no need to unblock rfkill on load
      rfkill: don't impose global states on resume (just restore the previous states)

Bob Copeland (2):
      mac80211: fix minstrel single-rate memory corruption
      ath5k: minor rfkill cleanup

Christian Lamparter (1):
      ar9170: xmit code revamp

Johannes Berg (11):
      iwlwifi: port to cfg80211 rfkill
      ar9170: interpret firmware debug commands
      rfkill: print events when input handler is disabled/enabled
      b43/legacy: port to cfg80211 rfkill
      rfkill: remove input Kconfig
      sony: fix rfkill code
      mac80211: do not pass PS frames out of mac80211 again
      mac80211: don't use master netdev name
      mac80211: clean up return value of __ieee80211_parse_tx_radiotap
      mac80211: disable PS while probing AP
      cfg80211: fix rfkill locking problem

Jussi Kivilinna (2):
      rndis_wlan: cleanup: capitalize enum labels
      rndis_wlan: cleanup: rename all rndis_wext* objects to rndis_wlan*

Luis R. Rodriguez (2):
      cfg80211: fix for duplicate response for driver reg request
      mac80211: disable moving between PS modes during scan

Matthieu CASTET (2):
      b43: Fix possible unaligned u32 access
      mac80211 : fix unaligned rx skb

Michael Buesch (1):
      b43: Add fw capabilities

Sebastian Andrzej Siewior (1):
      net/libertas: remove GPIO-CS handling in SPI interface code

Tobias Doerffel (1):
      ath5k: added cfg80211 based rfkill support

Vasanthakumar Thiagarajan (2):
      mac80211: Fix the way ADDBA request count being modified
      ath9k: Fix tx stuck when connected to aggr disabled HT AP

 drivers/net/wireless/Kconfig                |    2 +-
 drivers/net/wireless/ath/ar9170/ar9170.h    |   34 +-
 drivers/net/wireless/ath/ar9170/hw.h        |    3 +
 drivers/net/wireless/ath/ar9170/main.c      |  676 ++++++++++++++++++---------
 drivers/net/wireless/ath/ar9170/usb.c       |  122 ++++-
 drivers/net/wireless/ath/ar9170/usb.h       |    7 +-
 drivers/net/wireless/ath/ath5k/Makefile     |    1 +
 drivers/net/wireless/ath/ath5k/ath5k.h      |    4 +
 drivers/net/wireless/ath/ath5k/base.c       |    7 +
 drivers/net/wireless/ath/ath5k/base.h       |   12 +
 drivers/net/wireless/ath/ath5k/reset.c      |   17 -
 drivers/net/wireless/ath/ath5k/rfkill.c     |  121 +++++
 drivers/net/wireless/ath/ath9k/xmit.c       |    1 +
 drivers/net/wireless/b43/Kconfig            |    7 -
 drivers/net/wireless/b43/Makefile           |    2 +-
 drivers/net/wireless/b43/b43.h              |   17 +-
 drivers/net/wireless/b43/dma.c              |    2 +-
 drivers/net/wireless/b43/leds.c             |    7 +-
 drivers/net/wireless/b43/main.c             |   83 +++--
 drivers/net/wireless/b43/main.h             |    1 -
 drivers/net/wireless/b43/phy_common.h       |    2 +-
 drivers/net/wireless/b43/pio.c              |    2 +-
 drivers/net/wireless/b43/rfkill.c           |  113 +----
 drivers/net/wireless/b43/rfkill.h           |   44 +--
 drivers/net/wireless/b43/xmit.c             |    5 +-
 drivers/net/wireless/b43legacy/Kconfig      |    8 -
 drivers/net/wireless/b43legacy/Makefile     |    2 +-
 drivers/net/wireless/b43legacy/b43legacy.h  |    3 -
 drivers/net/wireless/b43legacy/leds.c       |    7 +-
 drivers/net/wireless/b43legacy/main.c       |   17 +-
 drivers/net/wireless/b43legacy/rfkill.c     |  115 +----
 drivers/net/wireless/b43legacy/rfkill.h     |   50 +--
 drivers/net/wireless/iwlwifi/Kconfig        |    4 -
 drivers/net/wireless/iwlwifi/Makefile       |    1 -
 drivers/net/wireless/iwlwifi/iwl-3945.h     |    5 -
 drivers/net/wireless/iwlwifi/iwl-agn.c      |   42 +--
 drivers/net/wireless/iwlwifi/iwl-core.c     |  138 ------
 drivers/net/wireless/iwlwifi/iwl-core.h     |   16 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c  |    2 -
 drivers/net/wireless/iwlwifi/iwl-dev.h      |    5 -
 drivers/net/wireless/iwlwifi/iwl-rfkill.c   |  131 ------
 drivers/net/wireless/iwlwifi/iwl-rfkill.h   |   48 --
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   41 +--
 drivers/net/wireless/libertas/if_spi.c      |   92 ++--
 drivers/net/wireless/rndis_wlan.c           |  292 ++++++------
 drivers/platform/x86/acer-wmi.c             |    3 -
 drivers/platform/x86/eeepc-laptop.c         |    8 +-
 drivers/platform/x86/hp-wmi.c               |    4 -
 drivers/platform/x86/sony-laptop.c          |    4 +-
 drivers/platform/x86/thinkpad_acpi.c        |   31 +-
 include/linux/rfkill.h                      |   35 +-
 include/linux/skbuff.h                      |    4 -
 include/linux/spi/libertas_spi.h            |    3 -
 include/net/mac80211.h                      |    3 +
 net/core/skbuff.c                           |    1 -
 net/mac80211/agg-tx.c                       |    6 +-
 net/mac80211/cfg.c                          |    4 +-
 net/mac80211/ieee80211_i.h                  |    5 +
 net/mac80211/main.c                         |   61 +---
 net/mac80211/mlme.c                         |   57 ++-
 net/mac80211/rc80211_minstrel.c             |    2 +-
 net/mac80211/rx.c                           |   27 +-
 net/mac80211/tx.c                           |   19 +-
 net/mac80211/util.c                         |   46 ++
 net/mac80211/wme.c                          |    2 +-
 net/rfkill/Kconfig                          |    2 +-
 net/rfkill/core.c                           |   93 ++---
 net/wireless/core.c                         |   19 +-
 net/wireless/reg.c                          |    7 +-
 69 files changed, 1275 insertions(+), 1482 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath5k/rfkill.c
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-rfkill.c
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-rfkill.h

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2009-06-10.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
