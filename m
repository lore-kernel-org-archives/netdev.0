From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2017-01-13
Date: Fri, 13 Jan 2017 14:55:15 +0100
Message-ID: <20170113135516.19593-1-johannes@sipsolutions.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Here's another update for the current cycle. Some of those
patches have been sitting in our tree and I haven't been
pulling them out quickly enough - will try to do better...

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 03430fa10b99e95e3a15eb7c00978fb1652f3b24:

  Merge branch 'bcm_sf2-fixes' (2017-01-08 22:01:22 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2017-01-13

for you to fetch changes up to dbef53621116474bb883f76f0ba6b7640bc42332:

  mac80211: prevent skb/txq mismatch (2017-01-13 14:47:21 +0100)

----------------------------------------------------------------
We have a number of fixes, in part because I was late
in actually sending them out - will try to do better in
the future:
 * handle VHT opmode properly when hostapd is controlling
   full station state
 * two fixes for minimum channel width in mac80211
 * don't leave SMPS set to junk in HT capabilities
 * fix headroom when forwarding mesh packets, recently
   broken by another fix that failed to take into account
   frame encryption
 * fix the TID in null-data packets indicating EOSP (end
   of service period) in U-APSD
 * prevent attempting to use (and then failing which
   results in crashes) TXQs on stations that aren't added
   to the driver yet

----------------------------------------------------------------
Beni Lev (1):
      cfg80211: consider VHT opmode on station update

Cedric Izoard (1):
      mac80211: Fix headroom allocation when forwarding mesh pkt

Emmanuel Grumbach (1):
      mac80211: fix the TID on NDPs sent as EOSP carrier

Felix Fietkau (1):
      mac80211: initialize SMPS field in HT capabilities

Johannes Berg (3):
      mac80211: implement multicast forwarding on fast-RX path
      mac80211: calculate min channel width correctly
      mac80211: recalculate min channel width on VHT opmode changes

Michal Kazior (1):
      mac80211: prevent skb/txq mismatch

 include/uapi/linux/nl80211.h |  4 +++-
 net/mac80211/chan.c          |  3 ---
 net/mac80211/iface.c         | 21 +++++++++++++++++++++
 net/mac80211/main.c          | 13 +++++++++----
 net/mac80211/rate.c          |  2 ++
 net/mac80211/rx.c            | 38 +++++++++++++++++++++-----------------
 net/mac80211/sta_info.c      |  4 ++--
 net/mac80211/tx.c            | 17 +++++++----------
 net/mac80211/vht.c           |  4 +++-
 net/wireless/nl80211.c       | 15 +++++++++++++++
 10 files changed, 83 insertions(+), 38 deletions(-)
