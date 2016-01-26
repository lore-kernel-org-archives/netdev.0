From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2016-01-26
Date: Tue, 26 Jan 2016 12:00:33 +0100
Message-ID: <1453806034-10185-1-git-send-email-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:38804 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934165AbcAZLAl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2016 06:00:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

After split up the patches from the previous pull request that was
lost in the process, here's a new one with fixes for the current
cycle (I'll follow up with a -next one later.)

I've also scripted my pull-request sending process a bit more, so
hopefully the emails will no longer have any unexpected UTF-8 contents
that tripped up patchwork :)

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit 701a0fd5231866db08cebcd502894699f49cb960:

  hip04_eth: fix missing error handle for build_skb failed (2016-01-13 15:48:14 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2016-01-26

for you to fetch changes up to 6736fde9672ff6717ac576e9bba2fd5f3dfec822:

  rfkill: fix rfkill_fop_read wait_event usage (2016-01-26 11:32:05 +0100)

----------------------------------------------------------------
Here's a first set of fixes for the 4.5-rc cycle:
 * make regulatory messages much less verbose by default
 * various remain-on-channel fixes
 * scheduled scanning fixes with hardware restart
 * a PS-Poll handling fix; was broken just recently
 * bugfix to avoid buffering non-bufferable MMPDUs
 * world regulatory domain data fix
 * a fix for scanning causing other work to get stuck
 * hwsim: revert an older problematic patch that caused some
   userspace tools to have issues - not that big a deal as
   it's a debug only driver though

----------------------------------------------------------------
Bob Copeland (1):
      Revert "mac80211_hwsim: support any address in userspace"

Dave Young (1):
      wireless: change cfg80211 regulatory domain info as debug messages

Eliad Peller (3):
      mac80211: avoid ROC during hw restart
      mac80211: clear local->sched_scan_req properly on reconfig
      mac80211: handle sched_scan_stopped vs. hw restart race

Emmanuel Grumbach (1):
      mac80211: fix PS-Poll handling

Helmut Schaa (1):
      mac80211: Don't buffer non-bufferable MMPDUs

Johannes Berg (4):
      mac80211: recalculate SW ROC only when needed
      mac80211: fix remain-on-channel cancellation
      regulatory: fix world regulatory domain data
      rfkill: fix rfkill_fop_read wait_event usage

Sachin Kulkarni (1):
      mac80211: Requeue work after scan complete for all VIF types.

 drivers/net/wireless/mac80211_hwsim.c |  5 ++--
 net/mac80211/ibss.c                   |  1 -
 net/mac80211/main.c                   |  6 +++++
 net/mac80211/mesh.c                   | 11 ---------
 net/mac80211/mesh.h                   |  4 ----
 net/mac80211/mlme.c                   |  2 --
 net/mac80211/offchannel.c             | 16 +++++++------
 net/mac80211/scan.c                   | 20 +++++++++++++++-
 net/mac80211/sta_info.c               |  2 +-
 net/mac80211/status.c                 |  5 ++++
 net/mac80211/util.c                   | 16 ++++++++++---
 net/rfkill/core.c                     | 16 ++++---------
 net/wireless/reg.c                    | 45 +++++++++++++++++++----------------
 13 files changed, 85 insertions(+), 64 deletions(-)
