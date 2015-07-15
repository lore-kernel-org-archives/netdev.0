From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 03/12] can: bfin_can: don't touch skb after netif_rx()
Date: Wed, 15 Jul 2015 09:09:40 +0200
Message-ID: <1436944189-26618-4-git-send-email-mkl@pengutronix.de>
References: <1436944189-26618-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
	Aaron Wu <Aaron.wu@analog.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:33071 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032AbbGOHJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 03:09:56 -0400
In-Reply-To: <1436944189-26618-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no guarantee that the skb is in the same state after calling
net_receive_skb() or netif_rx(). It might be freed or reused. Not really
harmful as its a read access, except you turn on the proper debugging options
which catch a use after free.

Cc: Aaron Wu <Aaron.wu@analog.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/bfin_can.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index 27ad312e7abf..57dadd52b428 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -424,10 +424,9 @@ static void bfin_can_rx(struct net_device *dev, u16 isrc)
 		cf->data[6 - i] = (6 - i) < cf->can_dlc ? (val >> 8) : 0;
 	}
 
-	netif_rx(skb);
-
 	stats->rx_packets++;
 	stats->rx_bytes += cf->can_dlc;
+	netif_rx(skb);
 }
 
 static int bfin_can_err(struct net_device *dev, u16 isrc, u16 status)
@@ -508,10 +507,9 @@ static int bfin_can_err(struct net_device *dev, u16 isrc, u16 status)
 
 	priv->can.state = state;
 
-	netif_rx(skb);
-
 	stats->rx_packets++;
 	stats->rx_bytes += cf->can_dlc;
+	netif_rx(skb);
 
 	return 0;
 }
-- 
2.1.4
