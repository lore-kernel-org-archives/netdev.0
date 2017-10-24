From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/3] can: kvaser_usb: Correct return value in printout
Date: Tue, 24 Oct 2017 13:27:24 +0200
Message-ID: <20171024112725.13203-3-mkl@pengutronix.de>
References: <20171024112725.13203-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de, Jimmy Assarsson <jimmyassarsson@gmail.com>,
        linux-stable <stable@vger.kernel.org>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:48243 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932352AbdJXL1f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 07:27:35 -0400
In-Reply-To: <20171024112725.13203-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jimmy Assarsson <jimmyassarsson@gmail.com>

If the return value from kvaser_usb_send_simple_msg() was non-zero, the
return value from kvaser_usb_flush_queue() was printed in the kernel
warning.

Signed-off-by: Jimmy Assarsson <jimmyassarsson@gmail.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/kvaser_usb.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 18cc529fb807..861e90efab86 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -1609,7 +1609,8 @@ static int kvaser_usb_close(struct net_device *netdev)
 	if (err)
 		netdev_warn(netdev, "Cannot flush queue, error %d\n", err);
 
-	if (kvaser_usb_send_simple_msg(dev, CMD_RESET_CHIP, priv->channel))
+	err = kvaser_usb_send_simple_msg(dev, CMD_RESET_CHIP, priv->channel);
+	if (err)
 		netdev_warn(netdev, "Cannot reset card, error %d\n", err);
 
 	err = kvaser_usb_stop_chip(priv);
-- 
2.14.2
