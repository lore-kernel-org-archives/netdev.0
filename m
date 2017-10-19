From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 10/11] can: esd_usb2: Fix can_dlc value for received RTR, frames
Date: Thu, 19 Oct 2017 13:19:44 +0200
Message-ID: <20171019111945.13580-11-mkl@pengutronix.de>
References: <20171019111945.13580-1-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de,
        =?UTF-8?q?Stefan=20M=C3=A4tje?= <Stefan.Maetje@esd.eu>,
        =?UTF-8?q?Stefan=20M=C3=A4tje?= <stefan.maetje@esd.eu>,
        linux-stable <stable@vger.kernel.org>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:58543 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752088AbdJSLT5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 07:19:57 -0400
In-Reply-To: <20171019111945.13580-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Mätje <Stefan.Maetje@esd.eu>

The dlc member of the struct rx_msg contains also the ESD_RTR flag to
mark received RTR frames. Without the fix the can_dlc value for received
RTR frames would always be set to 8 by get_can_dlc() instead of the
received value.

Fixes: 96d8e90382dc ("can: Add driver for esd CAN-USB/2 device")
Signed-off-by: Stefan Mätje <stefan.maetje@esd.eu>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/esd_usb2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/usb/esd_usb2.c b/drivers/net/can/usb/esd_usb2.c
index be928ce62d32..9fdb0f0bfa06 100644
--- a/drivers/net/can/usb/esd_usb2.c
+++ b/drivers/net/can/usb/esd_usb2.c
@@ -333,7 +333,7 @@ static void esd_usb2_rx_can_msg(struct esd_usb2_net_priv *priv,
 		}
 
 		cf->can_id = id & ESD_IDMASK;
-		cf->can_dlc = get_can_dlc(msg->msg.rx.dlc);
+		cf->can_dlc = get_can_dlc(msg->msg.rx.dlc & ~ESD_RTR);
 
 		if (id & ESD_EXTID)
 			cf->can_id |= CAN_EFF_FLAG;
-- 
2.14.2
