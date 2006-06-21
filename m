From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: [Patch] skb used after passing to netif_rx in
	net/ieee80211/ieee80211_rx.c
Date: Wed, 21 Jun 2006 21:05:58 +0200
Message-ID: <1150916758.23715.1.camel@alice>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.21]:41908 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S932669AbWFUTGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2006 15:06:00 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi,

this patch fixes coverity id #913. ieee80211_monitor_rx() passes the skb
to netif_rx() and we should not reference it any longer.

Signed-off-by: Eric Sesterhenn <snakebyte@gmx.de>

--- linux-2.6/net/ieee80211/ieee80211_rx.c.orig	2006-06-21 21:02:16.000000000 +0200
+++ linux-2.6/net/ieee80211/ieee80211_rx.c	2006-06-21 21:02:59.000000000 +0200
@@ -403,9 +403,9 @@ int ieee80211_rx(struct ieee80211_device
 #endif
 
 	if (ieee->iw_mode == IW_MODE_MONITOR) {
-		ieee80211_monitor_rx(ieee, skb, rx_stats);
 		stats->rx_packets++;
 		stats->rx_bytes += skb->len;
+		ieee80211_monitor_rx(ieee, skb, rx_stats);
 		return 1;
 	}
 


