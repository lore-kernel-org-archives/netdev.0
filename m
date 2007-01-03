From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 2/12] d80211: Fix 64bit printk warnings
Date: Wed,  3 Jan 2007 19:05:10 +0100 (CET)
Message-ID: <20070103180510.0917D3AA7EA@silver.suse.cz>
References: <20070103190418.710197000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:42223 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751009AbXACSFL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 13:05:11 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20070103190418.710197000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Buesch <mb@bu3sch.de>

Fix several warnings due to incompatible datatypes on
64bit platforms.

Signed-off-by: Michael Buesch <mb@bu3sch.de>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_sta.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

eabaa6c4f7b0546bbb5dcb9835d70d2858035bc0
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 0d46c66..35fb571 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -1368,9 +1368,12 @@ #ifdef CONFIG_D80211_IBSS_DEBUG
 		if (time_after(jiffies, last_tsf_debug + 5 * HZ)) {
 			printk(KERN_DEBUG "RX beacon SA=" MAC_FMT " BSSID="
 			       MAC_FMT " TSF=0x%llx BCN=0x%llx diff=%lld "
-			       "@%ld\n",
+			       "@%lu\n",
 			       MAC_ARG(mgmt->sa), MAC_ARG(mgmt->bssid),
-			       tsf, timestamp, tsf - timestamp, jiffies);
+			       (unsigned long long)tsf,
+			       (unsigned long long)timestamp,
+			       (unsigned long long)(tsf - timestamp),
+			       jiffies);
 			last_tsf_debug = jiffies;
 		}
 #endif /* CONFIG_D80211_IBSS_DEBUG */
@@ -2693,7 +2696,7 @@ ieee80211_sta_scan_result(struct net_dev
 		if (buf) {
 			memset(&iwe, 0, sizeof(iwe));
 			iwe.cmd = IWEVCUSTOM;
-			sprintf(buf, "tsf=%016llx", bss->timestamp);
+			sprintf(buf, "tsf=%016llx", (unsigned long long)(bss->timestamp));
 			iwe.u.data.length = strlen(buf);
 			current_ev = iwe_stream_add_point(current_ev, end_buf,
 							  &iwe, buf);
-- 
1.3.0

