From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 1/2] gianfar: Remove superfluous gfar_new_skb()
Date: Mon, 11 Mar 2013 18:54:36 +0200
Message-ID: <1363020877-30223-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0188.outbound.messaging.microsoft.com ([213.199.154.188]:9905
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753213Ab3CKRJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 13:09:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gfar_new_skb() does nothing more than to call the static
gfar_alloc_skb() routine.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index d2c5441..af91196 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -110,7 +110,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static void gfar_reset_task(struct work_struct *work);
 static void gfar_timeout(struct net_device *dev);
 static int gfar_close(struct net_device *dev);
-struct sk_buff *gfar_new_skb(struct net_device *dev);
+static struct sk_buff *gfar_alloc_skb(struct net_device *dev);
 static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
 			   struct sk_buff *skb);
 static int gfar_set_mac_address(struct net_device *dev);
@@ -207,7 +207,7 @@ static int gfar_init_bds(struct net_device *ndev)
 				gfar_init_rxbdp(rx_queue, rxbdp,
 						rxbdp->bufPtr);
 			} else {
-				skb = gfar_new_skb(ndev);
+				skb = gfar_alloc_skb(ndev);
 				if (!skb) {
 					netdev_err(ndev, "Can't allocate RX buffers\n");
 					return -ENOMEM;
@@ -2626,11 +2626,6 @@ static struct sk_buff *gfar_alloc_skb(struct net_device *dev)
 	return skb;
 }
 
-struct sk_buff *gfar_new_skb(struct net_device *dev)
-{
-	return gfar_alloc_skb(dev);
-}
-
 static inline void count_errors(unsigned short status, struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
@@ -2766,7 +2761,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 		rmb();
 
 		/* Add another skb for the future */
-		newskb = gfar_new_skb(dev);
+		newskb = gfar_alloc_skb(dev);
 
 		skb = rx_queue->rx_skbuff[rx_queue->skb_currx];
 
-- 
1.7.7.4
