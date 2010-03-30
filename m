From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH] gianfar: Fix a memory leak in gianfar close code
Date: Mon, 29 Mar 2010 20:42:23 -0500
Message-ID: <1269913343-6566-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	Sandeep.Kumar@freescale.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:55202 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753591Ab0C3Bm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 21:42:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gianfar needed to ensure existence of the *skbuff arrays before
freeing the skbs in them, rather than ensuring their nonexistence.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index b671555..ad59608 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1638,13 +1638,13 @@ static void free_skb_resources(struct gfar_private *priv)
 	/* Go through all the buffer descriptors and free their data buffers */
 	for (i = 0; i < priv->num_tx_queues; i++) {
 		tx_queue = priv->tx_queue[i];
-		if(!tx_queue->tx_skbuff)
+		if(tx_queue->tx_skbuff)
 			free_skb_tx_queue(tx_queue);
 	}
 
 	for (i = 0; i < priv->num_rx_queues; i++) {
 		rx_queue = priv->rx_queue[i];
-		if(!rx_queue->rx_skbuff)
+		if(rx_queue->rx_skbuff)
 			free_skb_rx_queue(rx_queue);
 	}
 
-- 
1.6.5.2.g6ff9a

