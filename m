From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: mcp251x: avoid write to error flag register if it's unnecessary
Date: Fri,  4 Mar 2016 08:55:55 +0100
Message-ID: <1457078155-8479-2-git-send-email-mkl@pengutronix.de>
References: <1457078155-8479-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Ed Spiridonov <edo.rus@gmail.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:50092 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752401AbcCDH4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 02:56:01 -0500
In-Reply-To: <1457078155-8479-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ed Spiridonov <edo.rus@gmail.com>

Only two bits (RX0OVR and RX1OVR) are writable in EFLG, write is useless
if these bits aren't set.

Signed-off-by: Ed Spiridonov <edo.rus@gmail.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/spi/mcp251x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/spi/mcp251x.c b/drivers/net/can/spi/mcp251x.c
index 575790e8a75a..74a7dfecee27 100644
--- a/drivers/net/can/spi/mcp251x.c
+++ b/drivers/net/can/spi/mcp251x.c
@@ -843,7 +843,7 @@ static irqreturn_t mcp251x_can_ist(int irq, void *dev_id)
 		if (clear_intf)
 			mcp251x_write_bits(spi, CANINTF, clear_intf, 0x00);
 
-		if (eflag)
+		if (eflag & (EFLG_RX0OVR | EFLG_RX1OVR))
 			mcp251x_write_bits(spi, EFLG, eflag, 0x00);
 
 		/* Update can state */
-- 
2.7.0
