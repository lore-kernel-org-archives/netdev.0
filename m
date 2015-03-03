From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 13/14] wireless: Use eth_<foo>_addr instead of memset
Date: Mon,  2 Mar 2015 19:54:58 -0800
Message-ID: <0c710456e4875ff00c1a9fcff9378ed15110dcd3.1425354528.git.joe@perches.com>
References: <cover.1425354527.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1425354527.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the built-in function instead of memset.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/wireless/ibss.c     | 2 +-
 net/wireless/nl80211.c  | 4 ++--
 net/wireless/trace.h    | 9 +++++----
 net/wireless/wext-sme.c | 2 +-
 4 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/wireless/ibss.c b/net/wireless/ibss.c
index e24fc58..6309b9c 100644
--- a/net/wireless/ibss.c
+++ b/net/wireless/ibss.c
@@ -533,7 +533,7 @@ int cfg80211_ibss_wext_giwap(struct net_device *dev,
 	else if (wdev->wext.ibss.bssid)
 		memcpy(ap_addr->sa_data, wdev->wext.ibss.bssid, ETH_ALEN);
 	else
-		memset(ap_addr->sa_data, 0, ETH_ALEN);
+		eth_zero_addr(ap_addr->sa_data);
 
 	wdev_unlock(wdev);
 
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index d78fd8b..96fe328 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -5683,8 +5683,8 @@ static int nl80211_parse_random_mac(struct nlattr **attrs,
 	int i;
 
 	if (!attrs[NL80211_ATTR_MAC] && !attrs[NL80211_ATTR_MAC_MASK]) {
-		memset(mac_addr, 0, ETH_ALEN);
-		memset(mac_addr_mask, 0, ETH_ALEN);
+		eth_zero_addr(mac_addr);
+		eth_zero_addr(mac_addr_mask);
 		mac_addr[0] = 0x2;
 		mac_addr_mask[0] = 0x3;
 
diff --git a/net/wireless/trace.h b/net/wireless/trace.h
index b17b369..a00ee88 100644
--- a/net/wireless/trace.h
+++ b/net/wireless/trace.h
@@ -7,6 +7,7 @@
 #include <linux/tracepoint.h>
 
 #include <linux/rtnetlink.h>
+#include <linux/etherdevice.h>
 #include <net/cfg80211.h>
 #include "core.h"
 
@@ -15,7 +16,7 @@
 	if (given_mac)						     \
 		memcpy(__entry->entry_mac, given_mac, ETH_ALEN);     \
 	else							     \
-		memset(__entry->entry_mac, 0, ETH_ALEN);	     \
+		eth_zero_addr(__entry->entry_mac);		     \
 	} while (0)
 #define MAC_PR_FMT "%pM"
 #define MAC_PR_ARG(entry_mac) (__entry->entry_mac)
@@ -1077,7 +1078,7 @@ TRACE_EVENT(rdev_auth,
 		if (req->bss)
 			MAC_ASSIGN(bssid, req->bss->bssid);
 		else
-			memset(__entry->bssid, 0, ETH_ALEN);
+			eth_zero_addr(__entry->bssid);
 		__entry->auth_type = req->auth_type;
 	),
 	TP_printk(WIPHY_PR_FMT ", " NETDEV_PR_FMT ", auth type: %d, bssid: " MAC_PR_FMT,
@@ -1103,7 +1104,7 @@ TRACE_EVENT(rdev_assoc,
 		if (req->bss)
 			MAC_ASSIGN(bssid, req->bss->bssid);
 		else
-			memset(__entry->bssid, 0, ETH_ALEN);
+			eth_zero_addr(__entry->bssid);
 		MAC_ASSIGN(prev_bssid, req->prev_bssid);
 		__entry->use_mfp = req->use_mfp;
 		__entry->flags = req->flags;
@@ -1153,7 +1154,7 @@ TRACE_EVENT(rdev_disassoc,
 		if (req->bss)
 			MAC_ASSIGN(bssid, req->bss->bssid);
 		else
-			memset(__entry->bssid, 0, ETH_ALEN);
+			eth_zero_addr(__entry->bssid);
 		__entry->reason_code = req->reason_code;
 		__entry->local_state_change = req->local_state_change;
 	),
diff --git a/net/wireless/wext-sme.c b/net/wireless/wext-sme.c
index 368611c..a4e8af3 100644
--- a/net/wireless/wext-sme.c
+++ b/net/wireless/wext-sme.c
@@ -322,7 +322,7 @@ int cfg80211_mgd_wext_giwap(struct net_device *dev,
 	if (wdev->current_bss)
 		memcpy(ap_addr->sa_data, wdev->current_bss->pub.bssid, ETH_ALEN);
 	else
-		memset(ap_addr->sa_data, 0, ETH_ALEN);
+		eth_zero_addr(ap_addr->sa_data);
 	wdev_unlock(wdev);
 
 	return 0;
-- 
2.1.2
