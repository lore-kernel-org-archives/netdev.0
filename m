From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2016-08-30
Date: Tue, 30 Aug 2016 08:19:18 +0200
Message-ID: <1472537959-8249-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:48754 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751966AbcH3GTZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 Aug 2016 02:19:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Nothing much, but we have three little fixes, see below. I've included the
static inline so that BATMAN_ADV_BATMAN_V can be changed to be allowed w/o
cfg80211 sooner, and it's a trivial change.

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit 2439ca0402091badb24415e1b073ba12b34ba423:

  mac80211: Add ieee80211_hw pointer to get_expected_throughput (2016-08-05 14:23:25 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2016-08-30

for you to fetch changes up to 61aaa0e8c1c15d9e045f0577f046be50f2f571ab:

  cfg80211: Add stub for cfg80211_get_station() (2016-08-30 08:05:28 +0200)

----------------------------------------------------------------
Three little fixes:
 * revert a recent wext patch, which Ben Hutchings noticed was
   wrong, and it turns out not to be necessary for any driver

 * fix an infinite loop that can occur under certain conditions
   in mac80211's TDLS code (depending on regulatory information)

 * add a cfg80211_get_station() static inline when cfg80211 isn't
   built, to allow other modules to not have to depend on it for it

----------------------------------------------------------------
Arik Nemtsov (1):
      mac80211: TDLS: don't require beaconing for AP BW

Johannes Berg (1):
      Revert "wext: Fix 32 bit iwpriv compatibility issue with 64 bit Kernel"

Linus Lüssing (1):
      cfg80211: Add stub for cfg80211_get_station()

 include/net/cfg80211.h   |  9 +++++++++
 net/mac80211/tdls.c      |  7 ++++---
 net/wireless/wext-core.c | 25 ++-----------------------
 3 files changed, 15 insertions(+), 26 deletions(-)
