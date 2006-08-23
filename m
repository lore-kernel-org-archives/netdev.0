From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 11/21] d80211: surface IBSS debug
Date: Wed, 23 Aug 2006 21:24:20 +0200 (CEST)
Message-ID: <20060823192420.384C4483AB@silver.suse.cz>
References: <20060823212316.333159079.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:29392 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965138AbWHWTYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:24:20 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060823212316.333159079.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>

This patch surfaces the IBSS debug switch in Kconfig.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/Kconfig         |    6 ++++++
 net/d80211/ieee80211_sta.c |   30 ++++++++++++++----------------
 2 files changed, 20 insertions(+), 16 deletions(-)

9b827dcb576bb80d8dc837d777812fa69b8af438
diff --git a/net/d80211/Kconfig b/net/d80211/Kconfig
index ffe2bdf..ae39e6e 100644
--- a/net/d80211/Kconfig
+++ b/net/d80211/Kconfig
@@ -45,3 +45,9 @@ config D80211_DEBUG_COUNTERS
 config HOSTAPD_WPA_TESTING
 	bool "Support for TKIP countermeasures testing"
 	depends on D80211_DEBUG
+
+config D80211_IBSS_DEBUG
+	bool "Support for IBSS testing"
+	depends on D80211_DEBUG
+	---help---
+	  Say Y here if you intend to debug the IBSS code.
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 0c5bf88..12d6c99 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -31,8 +31,6 @@ #include "ieee80211_i.h"
 #include "rate_control.h"
 #include "hostapd_ioctl.h"
 
-/* #define IEEE80211_IBSS_DEBUG */
-
 #define IEEE80211_AUTH_TIMEOUT (HZ / 5)
 #define IEEE80211_AUTH_MAX_TRIES 3
 #define IEEE80211_ASSOC_TIMEOUT (HZ / 5)
@@ -1359,7 +1357,7 @@ #endif
 
 	if (sdata->type == IEEE80211_IF_TYPE_IBSS && beacon &&
 	    memcmp(mgmt->bssid, sdata->u.sta.bssid, ETH_ALEN) == 0) {
-#ifdef IEEE80211_IBSS_DEBUG
+#ifdef CONFIG_D80211_IBSS_DEBUG
 		static unsigned long last_tsf_debug = 0;
 		u64 tsf;
 		if (local->hw->get_tsf)
@@ -1374,7 +1372,7 @@ #ifdef IEEE80211_IBSS_DEBUG
 			       tsf, timestamp, tsf - timestamp, jiffies);
 			last_tsf_debug = jiffies;
 		}
-#endif /* IEEE80211_IBSS_DEBUG */
+#endif /* CONFIG_D80211_IBSS_DEBUG */
 	}
 
 	if (ieee802_11_parse_elems(mgmt->u.beacon.variable, len - baselen,
@@ -1654,12 +1652,12 @@ static void ieee80211_rx_mgmt_probe_req(
 	else
 		tx_last_beacon = 1;
 
-#ifdef IEEE80211_IBSS_DEBUG
+#ifdef CONFIG_D80211_IBSS_DEBUG
 	printk(KERN_DEBUG "%s: RX ProbeReq SA=" MAC_FMT " DA=" MAC_FMT " BSSID="
 	       MAC_FMT " (tx_last_beacon=%d)\n",
 	       dev->name, MAC_ARG(mgmt->sa), MAC_ARG(mgmt->da),
 	       MAC_ARG(mgmt->bssid), tx_last_beacon);
-#endif /* IEEE80211_IBSS_DEBUG */
+#endif /* CONFIG_D80211_IBSS_DEBUG */
 
 	if (!tx_last_beacon)
 		return;
@@ -1693,10 +1691,10 @@ #endif /* IEEE80211_IBSS_DEBUG */
 
 	resp = (struct ieee80211_mgmt *) skb->data;
 	memcpy(resp->da, mgmt->sa, ETH_ALEN);
-#ifdef IEEE80211_IBSS_DEBUG
+#ifdef CONFIG_D80211_IBSS_DEBUG
 	printk(KERN_DEBUG "%s: Sending ProbeResp to " MAC_FMT "\n",
 	       dev->name, MAC_ARG(resp->da));
-#endif /* IEEE80211_IBSS_DEBUG */
+#endif /* CONFIG_D80211_IBSS_DEBUG */
 	ieee80211_sta_tx(dev, skb, 0, 1);
 }
 
@@ -2193,10 +2191,10 @@ static int ieee80211_sta_find_ibss(struc
 		return -EINVAL;
 
 	active_ibss = ieee80211_sta_active_ibss(dev);
-#ifdef IEEE80211_IBSS_DEBUG
+#ifdef CONFIG_D80211_IBSS_DEBUG
 	printk(KERN_DEBUG "%s: sta_find_ibss (active_ibss=%d)\n",
 	       dev->name, active_ibss);
-#endif /* IEEE80211_IBSS_DEBUG */
+#endif /* CONFIG_D80211_IBSS_DEBUG */
 	spin_lock_bh(&local->sta_bss_lock);
 	list_for_each(ptr, &local->sta_bss_list) {
 		bss = list_entry(ptr, struct ieee80211_sta_bss, list);
@@ -2204,10 +2202,10 @@ #endif /* IEEE80211_IBSS_DEBUG */
 		    memcmp(ifsta->ssid, bss->ssid, bss->ssid_len) != 0
 		    || !(bss->capability & WLAN_CAPABILITY_IBSS))
 			continue;
-#ifdef IEEE80211_IBSS_DEBUG
+#ifdef CONFIG_D80211_IBSS_DEBUG
 		printk(KERN_DEBUG "   bssid=" MAC_FMT " found\n",
 		       MAC_ARG(bss->bssid));
-#endif /* IEEE80211_IBSS_DEBUG */
+#endif /* CONFIG_D80211_IBSS_DEBUG */
 		memcpy(bssid, bss->bssid, ETH_ALEN);
 		found = 1;
 		if (active_ibss || memcmp(bssid, ifsta->bssid, ETH_ALEN) != 0)
@@ -2215,10 +2213,10 @@ #endif /* IEEE80211_IBSS_DEBUG */
 	}
 	spin_unlock_bh(&local->sta_bss_lock);
 
-#ifdef IEEE80211_IBSS_DEBUG
+#ifdef CONFIG_D80211_IBSS_DEBUG
 	printk(KERN_DEBUG "   sta_find_ibss: selected " MAC_FMT " current "
 	       MAC_FMT "\n", MAC_ARG(bssid), MAC_ARG(ifsta->bssid));
-#endif /* IEEE80211_IBSS_DEBUG */
+#endif /* CONFIG_D80211_IBSS_DEBUG */
 	if (found && memcmp(ifsta->bssid, bssid, ETH_ALEN) != 0 &&
 	    (bss = ieee80211_rx_bss_get(dev, bssid))) {
 		printk(KERN_DEBUG "%s: Selected IBSS BSSID " MAC_FMT
@@ -2226,9 +2224,9 @@ #endif /* IEEE80211_IBSS_DEBUG */
 		       dev->name, MAC_ARG(bssid));
 		return ieee80211_sta_join_ibss(dev, ifsta, bss);
 	}
-#ifdef IEEE80211_IBSS_DEBUG
+#ifdef CONFIG_D80211_IBSS_DEBUG
 	printk(KERN_DEBUG "   did not try to join ibss\n");
-#endif /* IEEE80211_IBSS_DEBUG */
+#endif /* CONFIG_D80211_IBSS_DEBUG */
 
 	/* Selected IBSS not found in current scan results - try to scan */
 	if (ifsta->state == IEEE80211_IBSS_JOINED &&
-- 
1.3.0

