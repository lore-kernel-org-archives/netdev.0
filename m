From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 5/9] can: mcp251x: don't copy data to rx'ed RTR frames
Date: Sat, 25 Dec 2010 15:40:30 +0100
Message-ID: <1293288034-22428-6-git-send-email-mkl@pengutronix.de>
References: <1293288034-22428-1-git-send-email-mkl@pengutronix.de>
Cc: socketcan-core@lists.berlios.de,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Christian Pellegrin <chripell@fsfe.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57228 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670Ab0LYOkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Dec 2010 09:40:47 -0500
In-Reply-To: <1293288034-22428-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: Christian Pellegrin <chripell@fsfe.org>
Acked-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/mcp251x.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 7ab534a..9e08acc 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -481,7 +481,8 @@ static void mcp251x_hw_rx(struct spi_device *spi, int buf_idx)
 	}
 	/* Data length */
 	frame->can_dlc = get_can_dlc(buf[RXBDLC_OFF] & RXBDLC_LEN_MASK);
-	memcpy(frame->data, buf + RXBDAT_OFF, frame->can_dlc);
+	if (!(frame->can_id & CAN_RTR_FLAG))
+		memcpy(frame->data, buf + RXBDAT_OFF, frame->can_dlc);
 
 	priv->net->stats.rx_packets++;
 	priv->net->stats.rx_bytes += frame->can_dlc;
-- 
1.7.2.3

