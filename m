From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 11/12] can: usb_8dev: don't touch skb after netif_rx()
Date: Wed, 15 Jul 2015 09:09:48 +0200
Message-ID: <1436944189-26618-12-git-send-email-mkl@pengutronix.de>
References: <1436944189-26618-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
	Bernd Krumboeck <b.krumboeck@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1436944189-26618-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no guarantee that the skb is in the same state after calling
net_receive_skb() or netif_rx(). It might be freed or reused. Not really
harmful as its a read access, except you turn on the proper debugging options
which catch a use after free.

Cc: Bernd Krumboeck <b.krumboeck@gmail.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/usb_8dev.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/usb/usb_8dev.c b/drivers/net/can/usb/usb_8dev.c
index dd52c7a4c80d..de95b1ccba3e 100644
--- a/drivers/net/can/usb/usb_8dev.c
+++ b/drivers/net/can/usb/usb_8dev.c
@@ -461,10 +461,9 @@ static void usb_8dev_rx_err_msg(struct usb_8dev_priv *priv,
 	priv->bec.txerr = txerr;
 	priv->bec.rxerr = rxerr;
 
-	netif_rx(skb);
-
 	stats->rx_packets++;
 	stats->rx_bytes += cf->can_dlc;
+	netif_rx(skb);
 }
 
 /* Read data and status frames */
@@ -494,10 +493,9 @@ static void usb_8dev_rx_can_msg(struct usb_8dev_priv *priv,
 		else
 			memcpy(cf->data, msg->data, cf->can_dlc);
 
-		netif_rx(skb);
-
 		stats->rx_packets++;
 		stats->rx_bytes += cf->can_dlc;
+		netif_rx(skb);
 
 		can_led_event(priv->netdev, CAN_LED_EVENT_RX);
 	} else {
-- 
2.1.4

