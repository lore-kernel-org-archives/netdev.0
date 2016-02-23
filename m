From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2016-02-23
Date: Tue, 23 Feb 2016 10:52:06 +0100
Message-ID: <1456221127-13079-1-git-send-email-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:59099 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751737AbcBWJwQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 04:52:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Unfortunately I neglected to send you a pull request last week,
so it's here now. We gave a number of fairly important fixes
(two found by KASAN, the wext thing that for some reason people
have started seeing issues with) so it'd be good if these can
still go into 4.5.

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit 6736fde9672ff6717ac576e9bba2fd5f3dfec822:

  rfkill: fix rfkill_fop_read wait_event usage (2016-01-26 11:32:05 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2016-02-23

for you to fetch changes up to b86071528f3261ab592fad5b9b1a02aea3dcabf3:

  cfg80211: stop critical protocol session upon disconnect event (2016-02-23 10:41:24 +0100)

----------------------------------------------------------------
Another small set of fixes:
 * stop critical protocol session on disconnect to avoid
   it getting stuck
 * wext: fix two RTNL message ordering issues
 * fix an uninitialized value (found by KASAN)
 * fix an out-of-bounds access (also found by KASAN)
 * clear connection keys when freeing them in all cases
   (IBSS, all other places already did so)
 * fix expected throughput unit to get consistent values
 * set default TX aggregation timeout to 0 in minstrel
   to avoid (really just hide) issues and perform better

----------------------------------------------------------------
Arend van Spriel (1):
      cfg80211: stop critical protocol session upon disconnect event

Chris Bainbridge (1):
      mac80211: fix use of uninitialised values in RX aggregation

Felix Fietkau (1):
      mac80211: minstrel_ht: set default tx aggregation timeout to 0

Johannes Berg (2):
      wext: fix message delay/ordering
      cfg80211/wext: fix message ordering

Konstantin Khlebnikov (1):
      mac80211: minstrel_ht: fix out-of-bound in minstrel_ht_set_best_prob_rate

Ola Olsson (1):
      nl80211: Zero out the connection keys memory when freeing them.

Sven Eckelmann (1):
      mac80211: minstrel: Change expected throughput unit back to Kbps

 include/net/iw_handler.h           |  6 +++++
 net/mac80211/agg-rx.c              |  2 +-
 net/mac80211/rc80211_minstrel.c    |  2 +-
 net/mac80211/rc80211_minstrel_ht.c | 14 +++++-----
 net/wireless/core.c                |  2 ++
 net/wireless/nl80211.c             |  2 +-
 net/wireless/sme.c                 |  6 +++++
 net/wireless/wext-core.c           | 52 ++++++++++++++++++++++++++++++--------
 8 files changed, 66 insertions(+), 20 deletions(-)
