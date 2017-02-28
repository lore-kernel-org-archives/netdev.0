From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2017-02-28
Date: Tue, 28 Feb 2017 10:50:18 +0100
Message-ID: <20170228095019.10637-1-johannes@sipsolutions.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

First round of fixes - we actually have quite a few.

Please pull and let me know if there's any problem.

I had another question - I have this average.h API change pending
(you saw it before). It seems it might be a good time to get it in
now, since no new users should be showing up. If I put it in only
with the next merge window, new users might show up and break.

Thoughts?

Thanks,
johannes



The following changes since commit 51fb60eb162ab84c5edf2ae9c63cf0b878e5547e:

  l2tp: avoid use-after-free caused by l2tp_ip_backlog_recv (2017-02-26 22:57:17 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2017-02-28

for you to fetch changes up to 19d19e960598161be92a7e4828eb7706c6410ce6:

  mac80211: use driver-indicated transmitter STA only for data frames (2017-02-28 07:42:05 +0100)

----------------------------------------------------------------
First round of fixes - details in the commits:
 * use a valid hrtimer clock ID in mac80211_hwsim
 * don't reorder frames prior to BA session
 * flush a delayed work at suspend so the state is all valid before
   suspend/resume
 * fix packet statistics in fast-RX, the RX packets
   counter increment was simply missing
 * don't try to re-transmit filtered frames in an aggregation session
 * shorten (for tracing) a debug message
 * typo fix in another debug message
 * fix nul-termination with HWSIM_ATTR_RADIO_NAME in hwsim
 * fix mgmt RX processing when station is looked up by driver/device

----------------------------------------------------------------
Emmanuel Grumbach (1):
      mac80211: fix power saving clients handling in iwlwifi

Felix Fietkau (1):
      mac80211: don't handle filtered frames within a BA session

Johannes Berg (3):
      mac80211: fix packet statistics for fast-RX
      mac80211_hwsim: check HWSIM_ATTR_RADIO_NAME length
      mac80211: use driver-indicated transmitter STA only for data frames

Matt Chen (1):
      mac80211: flush delayed work when entering suspend

Sara Sharon (3):
      mac80211: don't reorder frames with SN smaller than SSN
      mac80211: shorten debug message
      mac80211: fix typo in debug print

Thomas Gleixner (1):
      mac80211_hwsim: Replace bogus hrtimer clockid

 drivers/net/wireless/mac80211_hwsim.c | 30 ++++++++++++++++++++++--------
 net/mac80211/agg-rx.c                 |  3 ++-
 net/mac80211/pm.c                     |  1 +
 net/mac80211/rx.c                     | 31 +++++++++++++++++++++++--------
 net/mac80211/sta_info.c               |  4 ++--
 net/mac80211/sta_info.h               |  6 ++++--
 net/mac80211/status.c                 |  3 ++-
 7 files changed, 56 insertions(+), 22 deletions(-)
