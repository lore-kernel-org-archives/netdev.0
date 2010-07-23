From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2010-07-23
Date: Fri, 23 Jul 2010 16:40:29 -0400
Message-ID: <20100723204029.GD2426@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Yet another batch intended for 2.6.36...  Mostly the usual random lot
of stuff, mostly driver updates.  This batch also includes a flurry
of Sparse-inspired patches from me -- it is hard to resist once the
"bug" bites!  As usual, all of these have been cooking in linux-next
for at least several days.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit e955cead031177b083fbf18d04a03c06e330a439:

  CAN: Add Flexcan CAN controller driver (2010-07-22 18:06:25 +0200)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Bob Copeland (2):
      ath5k: move reset to mac80211 workqueue
      ath5k: disable tasklets during reset

Bruno Randolf (1):
      ath5k: clean up rxlink handling

Christian Lamparter (1):
      mac80211: skip HT parsing if HW does not support HT

Dan Carpenter (1):
      orinoco_usb: potential null dereference

David Gnedt (1):
      mac80211: set carrier on for monitor interfaces on ieee80211_open

Felix Fietkau (3):
      ath9k: another fix for the A-MPDU buffer leak
      ath9k_hw: remove initvals for hardware which was never sold
      mac80211: fix aggregation action frame handling with AP VLANs

Joe Perches (1):
      drivers/net/wireless: Remove unnecessary casts of private_data

Johannes Berg (5):
      cfg80211: don't get expired BSSes
      mac80211: move QoS-enable to BSS info
      mac80211: refuse shared key auth when WEP is unavailable
      mac80211: fix IBSS lockdep complaint
      mac80211: proper IBSS locking

John W. Linville (16):
      libertas: convert new uses of __attribute__ ((packed)) to __packed
      iwlwifi: convert new uses of __attribute__ ((packed)) to __packed
      mac80211: improve error checking if WEP fails to init
      wireless: only use alpha2 regulatory information from country IE
      wireless: correct sparse warning in lib80211_crypt_tkip.c
      wireless: correct sparse warning in wext-compat.c
      wireless: correct sparse warning in generated regdb.c
      wireless: mark cfg80211_is_all_idle as static
      ath9k: correct sparse identified endian bug in ath_paprd_calibrate
      ipw2100: mark ipw2100_pm_qos_req static
      libipw: correct sparse warnings and mark some variables static
      rt2x00: correct sparse warning in rt2x00debug.c
      wireless: remove unnecessary reg_same_country_ie_hint
      mwl8k: correct/silence sparse warnings
      rtl8180: improve signal reporting for rtl8185 hardware
      b43: silence most sparse warnings

Kulikov Vasiliy (1):
      wireless: airo: delete netdev from list after it is freed

Larry Finger (1):
      b43: silence phy_n sparse warnings

Luis R. Rodriguez (2):
      ath9k_htc: make ath9k_htc_tx_aggr_oper() static
      ath9k_hw: Fix AR9003 MPDU delimeter CRC check for middle subframes

Maxime Bizon (1):
      cfg80211: fix race between sysfs and cfg80211

Pavel Roskin (1):
      ath9k: remove unneeded calculation of minimal calibration power

Rajkumar Manoharan (1):
      ath9k: fix panic while cleaning up virtaul wifis

Vivek Natarajan (1):
      ath9k: Fix the LED behaviour in idle unassociated state.

Wey-Yi Guy (3):
      iwlwifi: additional statistic debug counter
      iwlwifi: more statistics counter for agn in debugfs
      iwlwifi: "recover_from_tx_stall" function for 4965

 drivers/net/wireless/airo.c                      |   24 +-
 drivers/net/wireless/ath/ath5k/base.c            |   65 +-
 drivers/net/wireless/ath/ath5k/base.h            |    4 +-
 drivers/net/wireless/ath/ath5k/debug.c           |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_hw.c       |   66 -
 drivers/net/wireless/ath/ath9k/ar9002_initvals.h | 4141 ++++++----------------
 drivers/net/wireless/ath/ath9k/ar9003_mac.c      |   31 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c       |    7 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c     |    4 -
 drivers/net/wireless/ath/ath9k/eeprom_def.c      |    7 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c    |   18 +-
 drivers/net/wireless/ath/ath9k/init.c            |    2 +-
 drivers/net/wireless/ath/ath9k/main.c            |   21 +-
 drivers/net/wireless/ath/ath9k/xmit.c            |   19 +-
 drivers/net/wireless/b43/main.c                  |    2 +-
 drivers/net/wireless/b43/phy_g.c                 |    2 +-
 drivers/net/wireless/b43/phy_lp.c                |    8 +-
 drivers/net/wireless/b43/phy_n.c                 |   16 +-
 drivers/net/wireless/b43/wa.c                    |    8 +-
 drivers/net/wireless/ipw2x00/ipw2100.c           |    2 +-
 drivers/net/wireless/ipw2x00/libipw_module.c     |    4 +-
 drivers/net/wireless/ipw2x00/libipw_wx.c         |    4 -
 drivers/net/wireless/iwlwifi/iwl-4965.c          |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c   |    7 +
 drivers/net/wireless/iwlwifi/iwl-commands.h      |    7 +-
 drivers/net/wireless/iwlwifi/iwl-core.c          |   18 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c       |   10 +-
 drivers/net/wireless/libertas/cfg.c              |    6 +-
 drivers/net/wireless/libertas/debugfs.c          |    4 +-
 drivers/net/wireless/libertas/host.h             |    6 +-
 drivers/net/wireless/mwl8k.c                     |   22 +-
 drivers/net/wireless/orinoco/orinoco_usb.c       |   10 +-
 drivers/net/wireless/rt2x00/rt2x00dump.h         |    2 +-
 drivers/net/wireless/rtl818x/rtl8180_dev.c       |   11 +-
 include/net/cfg80211.h                           |    4 +
 include/net/mac80211.h                           |   11 +-
 include/net/regulatory.h                         |    1 -
 net/mac80211/cfg.c                               |    4 -
 net/mac80211/ht.c                                |    2 +-
 net/mac80211/ibss.c                              |   92 +-
 net/mac80211/ieee80211_i.h                       |    7 +-
 net/mac80211/iface.c                             |    6 +-
 net/mac80211/mlme.c                              |   13 +-
 net/mac80211/util.c                              |    7 +-
 net/mac80211/wep.c                               |    5 +-
 net/wireless/core.c                              |   14 +-
 net/wireless/genregdb.awk                        |    1 +
 net/wireless/lib80211_crypt_tkip.c               |    2 +-
 net/wireless/reg.c                               |  654 +----
 net/wireless/scan.c                              |    5 +
 net/wireless/sme.c                               |    2 +-
 net/wireless/wext-compat.c                       |    1 +
 52 files changed, 1405 insertions(+), 3987 deletions(-)

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2010-07-23.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
