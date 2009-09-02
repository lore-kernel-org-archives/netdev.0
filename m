From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2009-09-02
Date: Wed, 2 Sep 2009 15:56:51 -0400
Message-ID: <20090902195651.GF2662@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Once again, the usual batch of wireless updates for -next...  This time
its mostly a random collection of driver updates...

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6/

---

The following changes since commit 9e39f7c5b311a306977c5471f9e2ce4c456a=
a038:
  Joe Perches (1):
        s2io: Generate complete messages using single line DBG_PRINTs

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Bob Copeland (1):
      cfg80211: fix looping soft lockup in find_ie()

Daniel C Halperin (3):
      iwlwifi: remove 60 Mbps from sband bitrates table
      iwlwifi: remove incorrect uses of ieee80211_get_tx_rate to preven=
t TX stall
      iwlwifi: use iwl_hwrate_get_mac80211_idx where appropriate

G=E1bor Stefanik (4):
      b43: Refactor and update antenna diversity for A/G-PHY
      b43: Add myself to module authors & to LP-PHY file copyright noti=
ces
      b43: Fix typo in modparam_btcoex description
      b43: LP-PHY: Fix TX gain tables

Ivo van Doorn (2):
      rt2x00: Fix TX status reporting
      rt2x00: Reorganize padding & L2 padding

Johannes Berg (2):
      iwlwifi: use sleep interval succession
      rfkill: relicense header file

Jussi Kivilinna (4):
      rndis_wlan: use bool for on/off switches
      rndis_wlan: cleanup
      rndis_wlan: fix sparse endianess warnings
      rndis_wlan: remove 'select WIRELESS_EXT' in Kconfig

Luis R. Rodriguez (3):
      wireless: update top level wireless driver entry
      wireless: update reg debug kconfig entry
      wireless: remove mac80211 rate selection extra menu

Randy Dunlap (1):
      ipw2200: fix kconfig dependencies

Reinette Chatre (2):
      iwlwifi: fix situation in which debug message is printed
      iwl3945: reduce debug noise when default debug flags used

Samuel Ortiz (5):
      iwmc3200wifi: Set WEP key from connect
      iwmc3200wifi: Fix sparse warning
      iwmc3200wifi: New initial LMAC calibration
      iwmc3200wifi: Handle UMAC stalls and UMAC assert properly
      iwmc3200wifi: Add a last_fw_err debugfs entry

Vasanthakumar Thiagarajan (3):
      ath9k: Do an AHB reset before doing RTC reset
      ath9k: Move generic hw timer intr handler to bottom-half
      ath9k: Call spin_lock_bh() on btcoex_lock

Vivek Natarajan (1):
      ath9k: Reconfigure beacon timers after the scan is completed.

Zhu Yi (4):
      iwmc3200wifi: invalidate profile when necessary before connect
      iwmc3200wifi: use cfg80211_roamed to send roam event
      iwmc3200wifi: add disconnect work
      iwmc3200wifi: fix misuse of le16_to_cpu

 drivers/net/wireless/Kconfig                 |   14 +-
 drivers/net/wireless/ath/ath9k/btcoex.c      |   10 +-
 drivers/net/wireless/ath/ath9k/hw.c          |    7 +
 drivers/net/wireless/ath/ath9k/main.c        |   12 +-
 drivers/net/wireless/b43/main.c              |    3 +-
 drivers/net/wireless/b43/phy_a.c             |   48 ++---
 drivers/net/wireless/b43/phy_g.c             |   53 ++---
 drivers/net/wireless/b43/phy_lp.c            |    3 +-
 drivers/net/wireless/b43/tables_lpphy.c      |  309 +++++++++++++-----=
--------
 drivers/net/wireless/ipw2x00/Kconfig         |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c    |   56 +++---
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h    |    1 +
 drivers/net/wireless/iwlwifi/iwl-core.c      |   39 +++-
 drivers/net/wireless/iwlwifi/iwl-core.h      |    1 +
 drivers/net/wireless/iwlwifi/iwl-power.c     |   24 ++-
 drivers/net/wireless/iwlwifi/iwl-rx.c        |    9 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c        |  111 +++++----
 drivers/net/wireless/iwlwifi/iwl3945-base.c  |    8 +-
 drivers/net/wireless/iwmc3200wifi/cfg80211.c |   66 +++++-
 drivers/net/wireless/iwmc3200wifi/commands.c |    1 +
 drivers/net/wireless/iwmc3200wifi/debug.h    |    2 +
 drivers/net/wireless/iwmc3200wifi/debugfs.c  |  105 +++++++++-
 drivers/net/wireless/iwmc3200wifi/fw.c       |   56 ++++--
 drivers/net/wireless/iwmc3200wifi/iwm.h      |    8 +-
 drivers/net/wireless/iwmc3200wifi/lmac.h     |   15 ++
 drivers/net/wireless/iwmc3200wifi/main.c     |   60 +++++-
 drivers/net/wireless/iwmc3200wifi/rx.c       |   87 ++++++--
 drivers/net/wireless/rndis_wlan.c            |   98 ++------
 drivers/net/wireless/rt2x00/rt2x00crypto.c   |    6 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c      |   38 ++--
 drivers/net/wireless/rt2x00/rt2x00lib.h      |   45 +++-
 drivers/net/wireless/rt2x00/rt2x00queue.c    |   99 +++++++--
 include/linux/rfkill.h                       |   23 +-
 net/mac80211/Kconfig                         |    5 +-
 net/wireless/Kconfig                         |    4 +
 net/wireless/scan.c                          |    2 +-
 36 files changed, 894 insertions(+), 540 deletions(-)

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2009-09-02.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
