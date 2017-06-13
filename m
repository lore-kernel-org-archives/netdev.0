From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2017-06-13
Date: Tue, 13 Jun 2017 11:44:08 +0200
Message-ID: <20170613094409.12965-1-johannes@sipsolutions.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Here are some more fixes for the current cycle. Nothing really
big, though my own patches look bigger than they are due to some
code moving. The commit logs are far longer than the changes :-)

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 0bed865060836dc5f26b68052de0a504d66d9fae:

  net: Fix build regression in rtl8723bs staging driver. (2017-06-08 11:51:59 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2017-06-13

for you to fetch changes up to b3dd8279659f14f3624bb32559782d699fa6f7d1:

  mac80211: don't send SMPS action frame in AP mode when not needed (2017-06-13 10:24:35 +0200)

----------------------------------------------------------------
Some fixes:
 * Avi fixes some fallout from my mac80211 RX flags changes
 * Emmanuel fixes an issue with adhering to the spec, and
   an oversight in the SMPS management code
 * Jason's patch makes mac80211 use constant-time memory
   comparisons for message authentication, to avoid having
   potentially observable timing differences
 * my fix makes mac80211 set the basic rates bitmap before
   the channel so the next update to the driver has more
   consistent data - this required another rework patch to
   remove some useless 5/10 MHz code that can never be hit

----------------------------------------------------------------
Avraham Stern (1):
      mac80211: Fix incorrect condition when checking rx timestamp

Emmanuel Grumbach (2):
      mac80211: don't look at the PM bit of BAR frames
      mac80211: don't send SMPS action frame in AP mode when not needed

Jason A. Donenfeld (1):
      mac80211/wpa: use constant time memory comparison for MACs

Johannes Berg (2):
      mac80211: remove 5/10 MHz rate code from station MLME
      mac80211: set bss_info data before configuring the channel

 net/mac80211/cfg.c         |  2 ++
 net/mac80211/ieee80211_i.h |  2 +-
 net/mac80211/mlme.c        | 62 +++++++++++++++++++++++-----------------------
 net/mac80211/rx.c          |  6 ++++-
 net/mac80211/wpa.c         |  9 ++++---
 5 files changed, 44 insertions(+), 37 deletions(-)
