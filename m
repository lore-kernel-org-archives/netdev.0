From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 16/18] d80211: silence sparse warning: bad constant expression
Date: Wed, 18 Oct 2006 17:49:40 +0200 (CEST)
Message-ID: <20061018154940.18BDB47F5E@silver.suse.cz>
References: <20061018174838.116675768.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:15010 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1161214AbWJRPtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 11:49:10 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061018174838.116675768.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Kimdon <david.kimdon@devicescape.com>

Sparse does not figure out that algs[] isn't really a variable length array.
The message is:

net/d80211/ieee80211_sta.c:934:12: error: bad constant expression

This switches algs[] to be obviously a constant array, and derives the value of
num_algs algs[].  The code is correct and equivalent with or without this
change.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_sta.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

59e8ad6835a88cf25f958e9224b0d9b17ccd2d89
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 480e9c9..cc336bd 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -930,8 +930,8 @@ static void ieee80211_rx_mgmt_auth(struc
 		printk(KERN_DEBUG "%s: AP denied authentication (auth_alg=%d "
 		       "code=%d)\n", dev->name, ifsta->auth_alg, status_code);
 		if (status_code == WLAN_STATUS_NOT_SUPPORTED_AUTH_ALG) {
-			const int num_algs = 3;
-			u8 algs[num_algs];
+			u8 algs[3];
+			const int num_algs = ARRAY_SIZE(algs);
 			int i, pos;
 			algs[0] = algs[1] = algs[2] = 0xff;
 			if (ifsta->auth_algs & IEEE80211_AUTH_ALG_OPEN)
-- 
1.3.0

