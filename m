From: Sebastian Siewior <netdev@ml.breakpoint.cc>
Subject: [PATCH] [net] fix gianfar (compile and warning)
Date: Tue, 16 Oct 2007 19:25:05 +0200
Message-ID: <E1IhqCT-0007Wu-Lz@Chamillionaire.breakpoint.cc>
Cc: Li Yang <leoli@freescale.com>, netdev@vger.kernel.org,
	Grant Likely <grant.likely@secretlab.ca>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:40386 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759291AbXJPR1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 13:27:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently it does not compile because a not declared variable is used.
struct net_device_stats in driver's private struct is also unsued.
This patch uses (hopefully) the right stats.

Cc: Li Yang <leoli@freescale.com>
Signed-off-by: Sebastian Siewior <bigeasy@linutronix.de>
---
 drivers/net/gianfar.c |    7 +++----
 drivers/net/gianfar.h |    1 -
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 558440c..cc288d8 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1237,8 +1237,6 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
  * starting over will fix the problem. */
 static void gfar_timeout(struct net_device *dev)
 {
-	struct gfar_private *priv = netdev_priv(dev);
-
 	dev->stats.tx_errors++;
 
 	if (dev->flags & IFF_UP) {
@@ -1344,8 +1342,9 @@ struct sk_buff * gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp)
 	return skb;
 }
 
-static inline void count_errors(unsigned short status, struct gfar_private *priv)
+static inline void count_errors(unsigned short status, struct net_device *dev)
 {
+	struct gfar_private *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
 	struct gfar_extra_stats *estats = &priv->extra_stats;
 
@@ -1539,7 +1538,7 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 
 			dev->stats.rx_bytes += pkt_len;
 		} else {
-			count_errors(bdp->status, priv);
+			count_errors(bdp->status, dev);
 
 			if (skb)
 				dev_kfree_skb_any(skb);
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index c16cc8b..46cd773 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -749,7 +749,6 @@ struct gfar_private {
 	uint32_t msg_enable;
 
 	/* Network Statistics */
-	struct net_device_stats stats;
 	struct gfar_extra_stats extra_stats;
 };
 
-- 
1.5.3.4

