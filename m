From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2016-08-05
Date: Fri,  5 Aug 2016 14:32:08 +0200
Message-ID: <1470400329-23256-1-git-send-email-johannes@sipsolutions.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Here's a first set of fixes for the current cycle. See the tag message
for more information.

I'll probably have a follow-up fix for the real problem in mac80211
that caused the crash later, but for now we have this patch and it
makes sense and fixes the crash, even if the behaviour isn't quite
right (afaict.)

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit ecd5a32318280133e8ae93f10ea693293a04a786:

  phy/micrel: Change phy_id_mask for KSZ8721 (2016-07-31 20:37:12 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2016-08-05

for you to fetch changes up to 2439ca0402091badb24415e1b073ba12b34ba423:

  mac80211: Add ieee80211_hw pointer to get_expected_throughput (2016-08-05 14:23:25 +0200)

----------------------------------------------------------------
First set of fixes for the current cycle:
 * fix 80+80 bandwidth warning
 * fix powersave with mac80211 TXQ implementation
 * use correct way to free SKBs from multicast buffering
 * mesh: fix operation ordering to work with all drivers
 * mesh: end service period even when peer goes away
 * mesh: correct HT opmode validity checks
 * pass hw pointer from mac80211 to driver in TPT method,
   fixing a bug (in a bit the wrong way, but that's what
   we have right now)

----------------------------------------------------------------
Colin Ian King (1):
      cfg80211: fix missing break in NL8211_CHAN_WIDTH_80P80 case

Felix Fietkau (2):
      mac80211: fix check for buffered powersave frames with txq
      mac80211: fix purging multicast PS buffer queue

Maital Hahn (1):
      mac80211: mesh: flush stations before beacons are stopped

Masashi Honma (2):
      mac80211: End the MPSP even if EOSP frame was not acked
      nl80211: correct checks for NL80211_MESHCONF_HT_OPMODE value

Maxim Altshul (1):
      mac80211: Add ieee80211_hw pointer to get_expected_throughput

 drivers/net/wireless/ti/wlcore/main.c |  5 +++--
 include/net/mac80211.h                |  3 ++-
 net/mac80211/cfg.c                    |  2 +-
 net/mac80211/driver-ops.h             |  2 +-
 net/mac80211/mesh.c                   | 10 ++++++----
 net/mac80211/rx.c                     |  2 +-
 net/mac80211/status.c                 | 14 +++++++-------
 net/mac80211/tx.c                     |  6 +++---
 net/wireless/chan.c                   |  1 +
 net/wireless/nl80211.c                | 34 +++++++++++++++++++++++++++++++---
 10 files changed, 56 insertions(+), 23 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
