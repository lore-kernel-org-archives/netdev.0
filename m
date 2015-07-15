From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 07/12] can: cc770: don't touch skb after netif_rx()
Date: Wed, 15 Jul 2015 09:09:44 +0200
Message-ID: <1436944189-26618-8-git-send-email-mkl@pengutronix.de>
References: <1436944189-26618-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1436944189-26618-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no guarantee that the skb is in the same state after calling
net_receive_skb() or netif_rx(). It might be freed or reused. Not really
harmful as its a read access, except you turn on the proper debugging options
which catch a use after free.

Cc: Wolfgang Grandegger <wg@grandegger.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/cc770/cc770.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/cc770/cc770.c b/drivers/net/can/cc770/cc770.c
index c11d44984036..70a8cbb29e75 100644
--- a/drivers/net/can/cc770/cc770.c
+++ b/drivers/net/can/cc770/cc770.c
@@ -504,10 +504,10 @@ static void cc770_rx(struct net_device *dev, unsigned int mo, u8 ctrl1)
 		for (i = 0; i < cf->can_dlc; i++)
 			cf->data[i] = cc770_read_reg(priv, msgobj[mo].data[i]);
 	}
-	netif_rx(skb);
 
 	stats->rx_packets++;
 	stats->rx_bytes += cf->can_dlc;
+	netif_rx(skb);
 }
 
 static int cc770_err(struct net_device *dev, u8 status)
@@ -584,10 +584,10 @@ static int cc770_err(struct net_device *dev, u8 status)
 		}
 	}
 
-	netif_rx(skb);
 
 	stats->rx_packets++;
 	stats->rx_bytes += cf->can_dlc;
+	netif_rx(skb);
 
 	return 0;
 }
-- 
2.1.4

