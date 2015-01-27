From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/4] can: kvaser_usb: Send correct context to URB completion
Date: Tue, 27 Jan 2015 09:01:25 +0100
Message-ID: <1422345687-12839-3-git-send-email-mkl@pengutronix.de>
References: <1422345687-12839-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	"Ahmed S. Darwish" <ahmed.darwish@valeo.com>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1422345687-12839-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ahmed S. Darwish" <ahmed.darwish@valeo.com>

Send expected argument to the URB completion hander: a CAN
netdevice instead of the network interface private context
`kvaser_usb_net_priv'.

This was discovered by having some garbage in the kernel
log in place of the netdevice names: can0 and can1.

Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/kvaser_usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 978a25e9cd3c..f0c62075df0a 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -587,7 +587,7 @@ static int kvaser_usb_simple_msg_async(struct kvaser_usb_net_priv *priv,
 			  usb_sndbulkpipe(dev->udev,
 					  dev->bulk_out->bEndpointAddress),
 			  buf, msg->len,
-			  kvaser_usb_simple_msg_callback, priv);
+			  kvaser_usb_simple_msg_callback, netdev);
 	usb_anchor_urb(urb, &priv->tx_submitted);
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
-- 
2.1.4

