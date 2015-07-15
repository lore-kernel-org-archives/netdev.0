From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 05/12] can: slcan: don't touch skb after netif_rx_ni()
Date: Wed, 15 Jul 2015 09:09:42 +0200
Message-ID: <1436944189-26618-6-git-send-email-mkl@pengutronix.de>
References: <1436944189-26618-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
	Oliver Hartkopp <socketcan@hartkopp.net>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1436944189-26618-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no guarantee that the skb is in the same state after calling
net_receive_skb() or netif_rx(). It might be freed or reused. Not really
harmful as its a read access, except you turn on the proper debugging options
which catch a use after free.

Cc: Oliver Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/slcan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index a23a7af8eb9a..9a3f15cb7ef4 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -218,10 +218,10 @@ static void slc_bump(struct slcan *sl)
 
 	memcpy(skb_put(skb, sizeof(struct can_frame)),
 	       &cf, sizeof(struct can_frame));
-	netif_rx_ni(skb);
 
 	sl->dev->stats.rx_packets++;
 	sl->dev->stats.rx_bytes += cf.can_dlc;
+	netif_rx_ni(skb);
 }
 
 /* parse tty input stream */
-- 
2.1.4

