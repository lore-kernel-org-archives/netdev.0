From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/2] can: usb_8dev: fix urb leak on failure path in usb_8dev_start()
Date: Fri, 19 Jul 2013 15:17:49 +0200
Message-ID: <1374239869-27085-3-git-send-email-mkl@pengutronix.de>
References: <1374239869-27085-1-git-send-email-mkl@pengutronix.de>
Cc: kernel@pengutronix.de, linux-can@vger.kernel.org,
	davem@davemloft.net, Alexey Khoroshilov <khoroshilov@ispras.ru>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42806 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843Ab3GSNSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 09:18:15 -0400
In-Reply-To: <1374239869-27085-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Khoroshilov <khoroshilov@ispras.ru>

If usb_8dev_start() fails to submit urb,
it unanchors the urb but forgets to free it.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/usb_8dev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/can/usb/usb_8dev.c b/drivers/net/can/usb/usb_8dev.c
index cbd388e..8becd3d 100644
--- a/drivers/net/can/usb/usb_8dev.c
+++ b/drivers/net/can/usb/usb_8dev.c
@@ -779,6 +779,7 @@ static int usb_8dev_start(struct usb_8dev_priv *priv)
 			usb_unanchor_urb(urb);
 			usb_free_coherent(priv->udev, RX_BUFFER_SIZE, buf,
 					  urb->transfer_dma);
+			usb_free_urb(urb);
 			break;
 		}
 
-- 
1.8.3.1
