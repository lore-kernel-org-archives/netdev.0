From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2009-05-18
Date: Mon, 18 May 2009 14:29:43 -0400
Message-ID: <20090518182943.GH2814@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is another dump of updates for 2.6.31...mostly the usual suspects,
some fixes for bugs in earlier patches (but not in 2.6.30), etc.
FWIW, most of this group is mac80211 and nl80211 infrastructure.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit ed9b58bc443a1210b5be1ded6421b17e015bf985:
  Richard Genoud (1):
        Remove duplicate slow protocol define in bond_3ad.h

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Abhijeet Kolekar (1):
      iwl3945: read rev id in nic config

Geert Uytterhoeven (1):
      wireless: WL12XX should depend on GENERIC_HARDIRQS

Ivo van Doorn (1):
      rt2x00: Fix chipset detection for rt73usb

Johannes Berg (23):
      mac80211: fix scan channel race
      mac80211: set default QoS values according to spec
      cfg80211: fix wext iw_freq parsing
      iwlwifi: make iwl_set_rate static
      mac80211: improve scan timing
      mac80211: move HT operation mode BSS info
      mac80211: properly track HT operation_mode
      mac80211: remove ieee80211_ht_bss_info
      iwlwifi: do proper hw restart
      iwlwifi: fix PS disable status race
      iwlwifi: clean up PS code
      cfg80211: constify key mac address in ops
      cfg80211: put wext data into substructure
      cfg80211: disallow interfering with stations on non-AP
      wext: fix get_wireless_stats locking
      cfg80211: implement wext key handling
      nl80211: improve station flags handling
      wext: remove seq_start/stop sparse annotations
      mac80211: respond to beacon loss report only once
      mac80211: split out and decrease probe wait time
      mac80211: don't connect to IBSS network with different privacy
      mac80211: IBSS supported rate fixes
      mac80211: make noack test available

Jouni Malinen (7):
      nl80211 : Add support for configuring MFP
      mac80211: Drop unencrypted frames based on key setup
      mac80211: MFP - Drop unprotected Action frames prior key setup
      mac80211: Robust Action frame categories for MFP
      nl80211: Validate MFP flag type when parsing STA flags
      nl80211: Add IEEE 802.1X PAE control for station mode
      nl80211: Add RSC configuration for new keys

Mohamed Abbas (1):
      iwlagn: improve rate scale table search

Reinette Chatre (1):
      iwlwifi: more descriptive unsupported hardware message

Vasanthakumar Thiagarajan (2):
      ath9k: Remove bogus break after return
      ath9k: Cleanup ineffective return values

Wey-Yi Guy (4):
      iwlwifi: use #define instead of hard coded value
      iwlagn: show current rate scale data in debugfs
      iwlwifi: show qos AC parameters
      iwlwifi: default WMM AC parameters

 drivers/net/wireless/ath/ath9k/eeprom.c     |   51 ++----
 drivers/net/wireless/ath/ath9k/eeprom.h     |    2 +-
 drivers/net/wireless/ath/ath9k/hw.c         |   59 ++----
 drivers/net/wireless/ath/ath9k/hw.h         |    2 +-
 drivers/net/wireless/ath/ath9k/phy.c        |    7 +-
 drivers/net/wireless/ath/ath9k/phy.h        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c     |   12 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c   |   89 ++++++++-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h   |    2 +
 drivers/net/wireless/iwlwifi/iwl-agn.c      |   89 ++++-----
 drivers/net/wireless/iwlwifi/iwl-calib.c    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-core.c     |   62 +++----
 drivers/net/wireless/iwlwifi/iwl-core.h     |    2 -
 drivers/net/wireless/iwlwifi/iwl-dev.h      |    2 -
 drivers/net/wireless/iwlwifi/iwl-eeprom.c   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-power.c    |  233 +++-------------------
 drivers/net/wireless/iwlwifi/iwl-power.h    |   39 +---
 drivers/net/wireless/iwlwifi/iwl-scan.c     |   14 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   56 ++----
 drivers/net/wireless/mac80211_hwsim.c       |    2 +-
 drivers/net/wireless/mwl8k.c                |    2 +-
 drivers/net/wireless/rt2x00/rt73usb.c       |    2 +-
 drivers/net/wireless/wl12xx/Kconfig         |    2 +-
 include/linux/ieee80211.h                   |    8 +-
 include/linux/nl80211.h                     |   51 +++++-
 include/net/cfg80211.h                      |   57 +++---
 include/net/mac80211.h                      |   28 +---
 net/mac80211/cfg.c                          |   50 ++++--
 net/mac80211/debugfs.c                      |   38 ++++
 net/mac80211/ibss.c                         |   77 +++++---
 net/mac80211/ieee80211_i.h                  |    9 +-
 net/mac80211/iface.c                        |    3 +-
 net/mac80211/key.c                          |   21 ++-
 net/mac80211/key.h                          |    3 +-
 net/mac80211/main.c                         |   14 +-
 net/mac80211/mlme.c                         |   41 +++-
 net/mac80211/rx.c                           |   58 ++++--
 net/mac80211/scan.c                         |   32 +++-
 net/mac80211/tx.c                           |    5 +-
 net/mac80211/util.c                         |   60 +++++--
 net/mac80211/wext.c                         |  282 +--------------------------
 net/mac80211/wme.c                          |    2 +-
 net/wireless/core.c                         |   10 +-
 net/wireless/core.h                         |    6 +-
 net/wireless/ibss.c                         |   60 +++---
 net/wireless/nl80211.c                      |  128 ++++++++-----
 net/wireless/util.c                         |   45 +++++
 net/wireless/wext-compat.c                  |  286 ++++++++++++++++++++++++++-
 net/wireless/wext.c                         |   20 ++-
 49 files changed, 1116 insertions(+), 1013 deletions(-)

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2009-05-18.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
