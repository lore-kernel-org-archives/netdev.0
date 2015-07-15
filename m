From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 04/12] can: grcan: don't touch skb after netif_rx()
Date: Wed, 15 Jul 2015 09:09:41 +0200
Message-ID: <1436944189-26618-5-git-send-email-mkl@pengutronix.de>
References: <1436944189-26618-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
	Andreas Larsson <andreas@gaisler.com>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1436944189-26618-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no guarantee that the skb is in the same state after calling
net_receive_skb() or netif_rx(). It might be freed or reused. Not really
harmful as its a read access, except you turn on the proper debugging options
which catch a use after free.

Cc: Andreas Larsson <andreas@gaisler.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/grcan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/grcan.c b/drivers/net/can/grcan.c
index e3d7e22a4fa0..db9538d4b358 100644
--- a/drivers/net/can/grcan.c
+++ b/drivers/net/can/grcan.c
@@ -1216,11 +1216,12 @@ static int grcan_receive(struct net_device *dev, int budget)
 				cf->data[i] = (u8)(slot[j] >> shift);
 			}
 		}
-		netif_receive_skb(skb);
 
 		/* Update statistics and read pointer */
 		stats->rx_packets++;
 		stats->rx_bytes += cf->can_dlc;
+		netif_receive_skb(skb);
+
 		rd = grcan_ring_add(rd, GRCAN_MSG_SIZE, dma->rx.size);
 	}
 
-- 
2.1.4

