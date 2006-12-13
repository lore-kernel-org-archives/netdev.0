From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] d80211: Fix 64bit printk warnings
Date: Wed, 13 Dec 2006 18:54:01 +0100
Message-ID: <200612131854.01410.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:49876
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965058AbWLMRz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 12:55:26 -0500
To: Jiri Benc <jbenc@suse.cz>, John Linville <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix several warnings due to incompatible datatypes on
64bit platforms.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: jbenc-dscape.git/net/d80211/ieee80211_sta.c
===================================================================
--- jbenc-dscape.git.orig/net/d80211/ieee80211_sta.c	2006-12-13 18:44:27.000000000 +0100
+++ jbenc-dscape.git/net/d80211/ieee80211_sta.c	2006-12-13 18:49:59.000000000 +0100
@@ -1371,9 +1371,12 @@ static void ieee80211_rx_bss_info(struct
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
@@ -2697,7 +2700,7 @@ ieee80211_sta_scan_result(struct net_dev
 		if (buf) {
 			memset(&iwe, 0, sizeof(iwe));
 			iwe.cmd = IWEVCUSTOM;
-			sprintf(buf, "tsf=%016llx", bss->timestamp);
+			sprintf(buf, "tsf=%016llx", (unsigned long long)(bss->timestamp));
 			iwe.u.data.length = strlen(buf);
 			current_ev = iwe_stream_add_point(current_ev, end_buf,
 							  &iwe, buf);

-- 
Greetings Michael.
