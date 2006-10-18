From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 10/18] d80211: Fix overflow when creating AVS header
Date: Wed, 18 Oct 2006 17:49:33 +0200 (CEST)
Message-ID: <20061018154933.D7D6B47F90@silver.suse.cz>
References: <20061018174838.116675768.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:14498 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1161188AbWJRPtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 11:49:04 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061018174838.116675768.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Kimdon <david.kimdon@devicescape.com>

Fix overflow when converting timespec to microseconds.  Without this patch you
can get an overflow during the multiplication which can result in a negative number.
hostime is define here:

4.4 hosttime
The hosttime field is set to the current value of the host maintained
clock variable when the frame is received.

(from http://www.locustworld.com/tracker/getfile/prism2drivers/doc/capturefrm.txt)

it is a u64.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

4fdbfdf950c3260f16bad12bb1a5ebeac97bee37
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index ce56fd3..6847610 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -2579,7 +2579,7 @@ ieee80211_rx_mgmt(struct net_device *dev
 		struct ieee80211_rate *rate;
 
                 jiffies_to_timespec(status->hosttime, &ts);
-		fi->hosttime = cpu_to_be64(ts.tv_sec * 1000000 +
+		fi->hosttime = cpu_to_be64((u64) ts.tv_sec * 1000000 +
 					   ts.tv_nsec / 1000);
 		fi->mactime = cpu_to_be64(status->mactime);
 		switch (status->phymode) {
-- 
1.3.0

