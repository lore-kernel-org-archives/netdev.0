From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] ieee80211_if_set_type: make check for master dev more
	explicit
Date: Thu, 4 Oct 2007 14:09:00 -0400
Message-ID: <20071004180900.GG6037@tuxdriver.com>
References: <20071004113343.552139D502B@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3570 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759352AbXJDSid (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2007 14:38:33 -0400
Content-Disposition: inline
In-Reply-To: <20071004113343.552139D502B@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Problem description by Daniel Drake <dsd@gentoo.org>:

"This sequence of events causes loss of connectivity:

<plug in>
<associate as normal in managed mode>
ifconfig eth7 down
iwconfig eth7 mode monitor
ifconfig eth7 up
ifconfig eth7 down
iwconfig eth7 mode managed
<associate as normal>

At this point you are associated but TX does not work. This is because
the eth7 hard_start_xmit is still ieee80211_monitor_start_xmit."

The problem is caused by ieee80211_if_set_type checking for a non-zero
hard_start_xmit pointer value in order to avoid changing that value for
master devices.  The fix is to make that check more explicitly linked to
master devices rather than simply checking if the value has been
previously set.

CC: Daniel Drake <dsd@gentoo.org>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 net/mac80211/ieee80211_iface.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/mac80211/ieee80211_iface.c b/net/mac80211/ieee80211_iface.c
index be7e77f..6607b80 100644
--- a/net/mac80211/ieee80211_iface.c
+++ b/net/mac80211/ieee80211_iface.c
@@ -106,7 +106,7 @@ void ieee80211_if_set_type(struct net_device *dev, int type)
 	 * which already has a hard_start_xmit routine assigned
 	 * which must not be changed.
 	 */
-	if (!dev->hard_start_xmit)
+	if (dev->type != ARPHRD_IEEE80211)
 		dev->hard_start_xmit = ieee80211_subif_start_xmit;
 
 	/*
-- 
1.5.2.4

-- 
John W. Linville
linville@tuxdriver.com
