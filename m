From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 8/8] can: mcp251x: optimize 2515, rx int gets cleared automatically
Date: Mon, 18 Oct 2010 15:31:14 +0200
Message-ID: <1287408674-15412-9-git-send-email-mkl@pengutronix.de>
References: <1287408674-15412-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>
To: socketcan-core@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:33918 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755524Ab0JRNbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 09:31:23 -0400
In-Reply-To: <1287408674-15412-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
Acked-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/mcp251x.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 7f8aa4c..c664be2 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -793,15 +793,20 @@ static irqreturn_t mcp251x_can_ist(int irq, void *dev_id)
 		/* receive buffer 0 */
 		if (intf & CANINTF_RX0IF) {
 			mcp251x_hw_rx(spi, 0);
-			/* Free one buffer ASAP */
-			mcp251x_write_bits(spi, CANINTF, intf & CANINTF_RX0IF,
-					   0x00);
+			/*
+			 * Free one buffer ASAP
+			 * (The MCP2515 does this automatically.)
+			 */
+			if (mcp251x_is_2510(spi))
+				mcp251x_write_bits(spi, CANINTF, CANINTF_RX0IF, 0x00);
 		}
 
 		/* receive buffer 1 */
 		if (intf & CANINTF_RX1IF) {
 			mcp251x_hw_rx(spi, 1);
-			clear_intf |= CANINTF_RX1IF;
+			/* the MCP2515 does this automatically */
+			if (mcp251x_is_2510(spi))
+				clear_intf |= CANINTF_RX1IF;
 		}
 
 		/* any error or tx interrupt we need to clear? */
-- 
1.7.0.4

