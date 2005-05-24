From: Jiri Benc <jbenc@suse.cz>
Subject: [6/6] ipw2200: fix after "ieee80211: ethernet independency"
Date: Tue, 24 May 2005 15:20:36 +0200
Message-ID: <20050524152036.1bd618b1@griffin.suse.cz>
References: <20050524150711.01632672@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>
In-Reply-To: <20050524150711.01632672@griffin.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fixes ipw2200 after making the 802.11 layer independent of ethernet
(patch [4/5] ieee80211: ethernet independency).


Signed-off-by: Jiri Benc <jbenc@suse.cz>
Signed-off-by: Jirka Bohac <jbohac@suse.cz>

--- a/drivers/net/wireless/ipw2200.c	2005-05-18 16:50:29.000000000 +0200
+++ b/drivers/net/wireless/ipw2200.c	2005-05-20 14:16:40.000000000 +0200
@@ -6316,8 +6316,8 @@
 			return 0;
 
 		/* {broad,multi}cast packets to our IBSS go through */
-		if (is_broadcast_ether_addr(header->addr1) ||
-		    is_multicast_ether_addr(header->addr1))
+		if (is_broadcast_ieee80211_addr(header->addr1) ||
+		    is_multicast_ieee80211_addr(header->addr1))
 			return !memcmp(header->addr3, priv->bssid, ETH_ALEN);
 
 		/* packets to our adapter go through */
@@ -6329,8 +6329,8 @@
 			return 0;
 
 		/* {broad,multi}cast packets to our IBSS go through */
-		if (is_broadcast_ether_addr(header->addr1) ||
-		    is_multicast_ether_addr(header->addr1))
+		if (is_broadcast_ieee80211_addr(header->addr1) ||
+		    is_multicast_ieee80211_addr(header->addr1))
 			return !memcmp(header->addr2, priv->bssid, ETH_ALEN);
 
 		/* packets to our adapter go through */
@@ -7847,8 +7847,8 @@
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
@@ -7863,8 +7863,8 @@
 
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
