From: Li Yang <leoli@freescale.com>
Subject: [PATCH] gianfar: Fix compile regression caused by 09f75cd7
Date: Fri, 12 Oct 2007 21:53:52 +0800
Message-ID: <1192197233-24958-2-git-send-email-leoli@freescale.com>
References: <1192197233-24958-1-git-send-email-leoli@freescale.com>
Cc: Li Yang <leoli@freescale.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:57877 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755049AbXJLNnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 09:43:33 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw01.freescale.net (8.12.11/de01egw01) with ESMTP id l9CDhU7J021204
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 06:43:31 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id l9CDhPSb011003
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 08:43:30 -0500 (CDT)
In-Reply-To: <1192197233-24958-1-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Li Yang <leoli@freescale.com>
---
 drivers/net/gianfar.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 2b758fa..6d1456a 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1228,8 +1228,6 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
  * starting over will fix the problem. */
 static void gfar_timeout(struct net_device *dev)
 {
-	struct gfar_private *priv = netdev_priv(dev);
-
 	dev->stats.tx_errors++;
 
 	if (dev->flags & IFF_UP) {
@@ -1335,8 +1333,9 @@ struct sk_buff * gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp)
 	return skb;
 }
 
-static inline void count_errors(unsigned short status, struct gfar_private *priv)
+static inline void count_errors(unsigned short status, struct net_device *dev)
 {
+	struct gfar_private *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
 	struct gfar_extra_stats *estats = &priv->extra_stats;
 
@@ -1530,7 +1529,7 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 
 			dev->stats.rx_bytes += pkt_len;
 		} else {
-			count_errors(bdp->status, priv);
+			count_errors(bdp->status, dev);
 
 			if (skb)
 				dev_kfree_skb_any(skb);
-- 
1.5.3.2.104.g41ef

