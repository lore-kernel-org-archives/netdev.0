From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 01/16] can: usb_8dev: Fix memory leak in usb_8dev_start_xmit
Date: Tue,  1 Apr 2014 23:42:15 +0200
Message-ID: <1396388550-23081-2-git-send-email-mkl@pengutronix.de>
References: <1396388550-23081-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Bjorn Van Tilt <bjorn.vantilt@gmail.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1396388550-23081-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Van Tilt <bjorn.vantilt@gmail.com>

Fixed a memory leak when an error occurred in the transmit function. In the
error handling the urb wasn't freed before returning. There was also a call to
the usb_unanchor_urb() function but the urb wasn't anchored.

Signed-off-by: Bjorn Van Tilt <bjorn.vantilt@gmail.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/usb_8dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/usb/usb_8dev.c b/drivers/net/can/usb/usb_8dev.c
index a0fa1fd..e7247a5 100644
--- a/drivers/net/can/usb/usb_8dev.c
+++ b/drivers/net/can/usb/usb_8dev.c
@@ -697,8 +697,8 @@ static netdev_tx_t usb_8dev_start_xmit(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 
 nofreecontext:
-	usb_unanchor_urb(urb);
 	usb_free_coherent(priv->udev, size, buf, urb->transfer_dma);
+	usb_free_urb(urb);
 
 	netdev_warn(netdev, "couldn't find free context");
 
-- 
1.9.0.279.gdc9e3eb

