From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2008-09-24
Date: Thu, 25 Sep 2008 15:29:44 -0400
Message-ID: <20080925192943.GC3277@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(Again, I know it is 2008-09-25, but I let this one cook overnight...)

Dave,

Another batch intended for 2.6.28...mostly a hodgepodge, including
another bunch of bits from Johannes...

Let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit d87798450a7635ab1bcc80271a13ce4a53b016a9:
  David S. Miller (1):
        aoe: Fix OOPS after SKB queue changes.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Alan Cox (1):
      pcmcia: Fix up legacy driver IRQs

David Kilroy (1):
      wireless: Read scan flags correctly on x86-64

Denis ChengRq (1):
      wireless: a global static to local static improvement

Emmanuel Grumbach (2):
      iwlwifi: remove HT flags from RXON when not in HT anymore
      mac80211: fix led behavior in IBSS

Ivo van Doorn (1):
      rt2x00: Fix HW crypto key handling

Javier Cardona (1):
      libertas: Reduce the WPA key installation time (fixups)

Johannes Berg (14):
      cfg80211: fix static regdomains
      cfg80211: clean up regulatory mess
      cfg80211: fix regulatory code const
      cfg80211: clean up static regdomain mess
      cfg80211: fix code ordering in header file
      mac80211: make master iface not wireless
      cfg80211: show interface type
      cfg80211: allow set_interface without type
      mac80211: allow interface settings changes only when down
      cfg80211: reject invalid configuration items
      mac80211: fix mesh action frame handling
      mac80211: clean up rate control API
      mac80211: probe with correct SSID
      iwlagn: downgrade BUG_ON in interrupt

Larry Finger (1):
      b43: Issue warning when RFKILL_INPUT is not enabled

Luis R. Rodriguez (1):
      ath9k: Add a few comments about mibevents

Nick Kossifidis (1):
      ath5k: Fix bad udelay calls on AR5210 code

Sujith (3):
      ath9k: Whitespace cleanup
      ath9k: Fix nexttbtt calculation
      ath9k: Fix TSF Adjust usage

Tomas Winkler (3):
      iwlwifi: don't delay scan in IBSS mode
      iwlwifi: make PS use named constants
      iwlwifi: don't fail if scan is issued too early

YanBo (1):
      mac80211: mesh portal functionality support

 drivers/net/wireless/airo.c                 |    2 +-
 drivers/net/wireless/airo_cs.c              |    2 +-
 drivers/net/wireless/ath5k/phy.c            |    2 +-
 drivers/net/wireless/ath5k/reg.h            |    2 -
 drivers/net/wireless/ath5k/reset.c          |   20 ++-
 drivers/net/wireless/ath9k/beacon.c         |  145 ++++++-------
 drivers/net/wireless/ath9k/core.c           |    3 +-
 drivers/net/wireless/ath9k/core.h           |    1 +
 drivers/net/wireless/ath9k/hw.c             |   18 ++-
 drivers/net/wireless/ath9k/rc.c             |   98 ++++-----
 drivers/net/wireless/atmel.c                |    2 +-
 drivers/net/wireless/atmel_cs.c             |    2 +-
 drivers/net/wireless/b43/rfkill.c           |    5 +
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c  |  182 ++++------------
 drivers/net/wireless/iwlwifi/iwl-3945-rs.h  |    9 -
 drivers/net/wireless/iwlwifi/iwl-3945.h     |    4 +
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c   |  146 +++++--------
 drivers/net/wireless/iwlwifi/iwl-agn.c      |   24 ++-
 drivers/net/wireless/iwlwifi/iwl-core.c     |   27 ++-
 drivers/net/wireless/iwlwifi/iwl-scan.c     |    8 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c       |    7 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   11 +-
 drivers/net/wireless/libertas/dev.h         |    1 +
 drivers/net/wireless/libertas/wext.c        |   26 ++-
 drivers/net/wireless/netwave_cs.c           |    2 +-
 drivers/net/wireless/orinoco.c              |    2 +-
 drivers/net/wireless/orinoco_cs.c           |    2 +-
 drivers/net/wireless/ray_cs.c               |    2 +-
 drivers/net/wireless/rndis_wlan.c           |    3 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c     |    3 +-
 drivers/net/wireless/rt2x00/rt61pci.c       |    4 +-
 drivers/net/wireless/rt2x00/rt73usb.c       |    4 +-
 drivers/net/wireless/spectrum_cs.c          |    2 +-
 drivers/net/wireless/wavelan_cs.c           |    2 +-
 drivers/net/wireless/wl3501_cs.c            |    2 +-
 include/linux/ieee80211.h                   |    5 +
 include/net/cfg80211.h                      |    6 +-
 include/net/mac80211.h                      |   68 ++++++
 include/net/wireless.h                      |   20 +-
 net/mac80211/cfg.c                          |   64 +-----
 net/mac80211/debugfs_sta.c                  |    3 +-
 net/mac80211/ieee80211_i.h                  |    6 +
 net/mac80211/iface.c                        |    1 +
 net/mac80211/main.c                         |   23 ++-
 net/mac80211/mesh.c                         |    2 +-
 net/mac80211/mesh.h                         |    4 +
 net/mac80211/mesh_pathtbl.c                 |  127 +++++++++++-
 net/mac80211/mlme.c                         |   10 +-
 net/mac80211/rate.c                         |   71 +++++--
 net/mac80211/rate.h                         |  102 +++-------
 net/mac80211/rc80211_pid.h                  |    2 -
 net/mac80211/rc80211_pid_algo.c             |  158 +++++---------
 net/mac80211/rx.c                           |   59 ++++--
 net/mac80211/sta_info.c                     |   17 +-
 net/mac80211/sta_info.h                     |    2 +-
 net/mac80211/tx.c                           |   75 +++++--
 net/wireless/core.c                         |  162 +-------------
 net/wireless/nl80211.c                      |   45 +++--
 net/wireless/reg.c                          |  311 ++++++++++++++++++---------
 net/wireless/reg.h                          |   39 +---
 60 files changed, 1077 insertions(+), 1080 deletions(-)

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2008-09-24.patch.bz2

-- 
John W. Linville		Linux should be at the core
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			of your literate lifestyle.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
