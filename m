From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw: Use compare_ether_addr()
Date: Sun, 11 Mar 2007 19:53:40 +0000 (GMT)
Message-ID: <20070311195340.80E017B409F@zog.reactivated.net>
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Suggested by Maxime Austruy, based on mac80211 changes from Stephen
Hemminger

Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 zd_mac.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_mac.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_mac.c
+++ linux/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -974,14 +974,14 @@ static int is_data_packet_for_us(struct 
 	switch (ieee->iw_mode) {
 	case IW_MODE_ADHOC:
 		if ((fc & (IEEE80211_FCTL_TODS|IEEE80211_FCTL_FROMDS)) != 0 ||
-		    memcmp(hdr->addr3, ieee->bssid, ETH_ALEN) != 0)
+		    compare_ether_addr(hdr->addr3, ieee->bssid) != 0)
 			return 0;
 		break;
 	case IW_MODE_AUTO:
 	case IW_MODE_INFRA:
 		if ((fc & (IEEE80211_FCTL_TODS|IEEE80211_FCTL_FROMDS)) !=
 		    IEEE80211_FCTL_FROMDS ||
-		    memcmp(hdr->addr2, ieee->bssid, ETH_ALEN) != 0)
+		    compare_ether_addr(hdr->addr2, ieee->bssid) != 0)
 			return 0;
 		break;
 	default:
@@ -989,9 +989,9 @@ static int is_data_packet_for_us(struct 
 		return 0;
 	}
 
-	return memcmp(hdr->addr1, netdev->dev_addr, ETH_ALEN) == 0 ||
+	return compare_ether_addr(hdr->addr1, netdev->dev_addr) == 0 ||
 	       (is_multicast_ether_addr(hdr->addr1) &&
-		memcmp(hdr->addr3, netdev->dev_addr, ETH_ALEN) != 0) ||
+		compare_ether_addr(hdr->addr3, netdev->dev_addr) != 0) ||
 	       (netdev->flags & IFF_PROMISC);
 }
 
@@ -1047,7 +1047,7 @@ static void update_qual_rssi(struct zd_m
 	hdr = (struct ieee80211_hdr_3addr *)buffer;
 	if (length < offsetof(struct ieee80211_hdr_3addr, addr3))
 		return;
-	if (memcmp(hdr->addr2, zd_mac_to_ieee80211(mac)->bssid, ETH_ALEN) != 0)
+	if (compare_ether_addr(hdr->addr2, zd_mac_to_ieee80211(mac)->bssid) != 0)
 		return;
 
 	spin_lock_irqsave(&mac->lock, flags);
