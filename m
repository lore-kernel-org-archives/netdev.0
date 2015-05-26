From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2015-05-26
Date: Tue, 26 May 2015 09:25:03 +0200
Message-ID: <1432625103.2141.5.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:41730 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751011AbbEZHZG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 May 2015 03:25:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Unfortunately I neglected to send this to you last week before our long
weekend.

These changes look fairly big, but they're fairly contained to the
remain-on- channel and AP_VLAN key handling code.

However, if you think you don't want to pull them into net any more at
this stage just let me know.

Thanks,
johannes


The following changes since commit 47b4e1fc4972cc43a19121bc2608a60aef3bf216:

  mac80211: move WEP tailroom size check (2015-05-11 14:51:29 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2015-05-26

for you to fetch changes up to f9dca80b98caac8b4bfb43a2edf1e9f877ccf322:

  mac80211: fix AP_VLAN crypto tailroom calculation (2015-05-20 15:10:11 +0200)

----------------------------------------------------------------
We have three more fixes:
 * AP_VLAN tailroom calculation fix, the bug leads to warnings
   along with dropped packets
 * NAPI context issue, calling napi_gro_receive() from a timer
   (obviously) can lead to crashes
 * remain-on-channel combining leads to dropped requests and not
   being able to finish certain operations, so remove it

----------------------------------------------------------------
Johannes Berg (2):
      mac80211: don't use napi_gro_receive() outside NAPI context
      mac80211: don't split remain-on-channel for coalescing

Michal Kazior (1):
      mac80211: fix AP_VLAN crypto tailroom calculation

 net/mac80211/cfg.c         | 59 +++++++--------------------------
 net/mac80211/ieee80211_i.h |  9 ++---
 net/mac80211/iface.c       |  6 ++++
 net/mac80211/key.c         | 82 +++++++++++++++++++++++++++++++++++++++++-----
 net/mac80211/key.h         |  1 +
 net/mac80211/rx.c          |  5 +--
 net/mac80211/util.c        |  3 ++
 7 files changed, 100 insertions(+), 65 deletions(-)
