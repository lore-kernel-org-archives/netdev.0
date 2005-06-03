From: Jiri Benc <jbenc@suse.cz>
Subject: [7/9] ipw: fix after "ieee80211: ethernet independency"
Date: Fri, 3 Jun 2005 18:35:26 +0200
Message-ID: <20050603183526.0effd2b0@griffin.suse.cz>
References: <20050603182625.64d33be3@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Jirka Bohac <jbohac@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>
In-Reply-To: <20050603182625.64d33be3@griffin.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fixes ipw2200 after making the ieee80211 layer independent of ethernet.


Signed-off-by: Jiri Benc <jbenc@suse.cz>
Signed-off-by: Jirka Bohac <jbohac@suse.cz>

Index: netdev/drivers/net/wireless/ipw2200.c
===================================================================
--- netdev.orig/drivers/net/wireless/ipw2200.c	2005-05-31 18:25:53.000000000 +0200
+++ netdev/drivers/net/wireless/ipw2200.c	2005-05-31 18:32:18.000000000 +0200
@@ -4920,8 +4920,8 @@
 						ETH_ALEN) ||
 					!memcmp(header->addr3, 
 						priv->bssid, ETH_ALEN) ||
-					is_broadcast_ether_addr(header->addr1) ||
-					is_multicast_ether_addr(header->addr1);
+					is_broadcast_ieee80211_addr(header->addr1) ||
+					is_multicast_ieee80211_addr(header->addr1);
 				break;
 
 			case IW_MODE_INFRA:
@@ -4932,8 +4932,8 @@
 					!memcmp(header->addr1, 
 						priv->net_dev->dev_addr, 
 						ETH_ALEN) ||
-					is_broadcast_ether_addr(header->addr1) ||
-					is_multicast_ether_addr(header->addr1);
+					is_broadcast_ieee80211_addr(header->addr1) ||
+					is_multicast_ieee80211_addr(header->addr1);
 				break;
 			}
 			
@@ -6285,8 +6285,8 @@
 	switch (priv->ieee->iw_mode) {
 	case IW_MODE_ADHOC:
 		hdr_len = IEEE80211_3ADDR_LEN;
-		unicast = !is_broadcast_ether_addr(hdr->addr1) &&
-			!is_multicast_ether_addr(hdr->addr1);
+		unicast = !is_broadcast_ieee80211_addr(hdr->addr1) &&
+			!is_multicast_ieee80211_addr(hdr->addr1);
 		id = ipw_find_station(priv, hdr->addr1);
 		if (id == IPW_INVALID_STATION) {
 			id = ipw_add_station(priv, hdr->addr1);
@@ -6301,8 +6301,8 @@
 
 	case IW_MODE_INFRA:
 	default:
-		unicast = !is_broadcast_ether_addr(hdr->addr3) &&
-			!is_multicast_ether_addr(hdr->addr3);
+		unicast = !is_broadcast_ieee80211_addr(hdr->addr3) &&
+			!is_multicast_ieee80211_addr(hdr->addr3);
 		hdr_len = IEEE80211_3ADDR_LEN;
 		id = 0;
 		break;


-- 
Jiri Benc
SUSE Labs
