From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 06/11] can: at91_can: rename AT91_MB_RX_MASK to AT91_IRQ_MB_RX
Date: Mon,  6 Jun 2011 15:42:55 +0200
Message-ID: <1307367780-30715-7-git-send-email-mkl@pengutronix.de>
References: <1307367780-30715-1-git-send-email-mkl@pengutronix.de>
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48435 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756897Ab1FFNnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 09:43:10 -0400
In-Reply-To: <1307367780-30715-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

... and use it for AT91_NEXT_MB_MASK,
AT91_IRQ_MB_RX and AT91_IRQ_MB_RX, too.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/at91_can.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 9ce00fa..8699484 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -52,11 +52,11 @@
 #define AT91_MB_RX_FIRST	1
 #define AT91_MB_RX_LAST		11
 
-#define AT91_MB_RX_MASK(i)	((1 << (i)) - 1)
+#define AT91_MB_MASK(i)		((1 << (i)) - 1)
 #define AT91_MB_RX_SPLIT	8
 #define AT91_MB_RX_LOW_LAST	(AT91_MB_RX_SPLIT - 1)
-#define AT91_MB_RX_LOW_MASK	(AT91_MB_RX_MASK(AT91_MB_RX_SPLIT) & \
-				 ~AT91_MB_RX_MASK(AT91_MB_RX_FIRST))
+#define AT91_MB_RX_LOW_MASK	(AT91_MB_MASK(AT91_MB_RX_SPLIT) & \
+				 ~AT91_MB_MASK(AT91_MB_RX_FIRST))
 
 #define AT91_MB_TX_NUM		(1 << AT91_MB_TX_SHIFT)
 #define AT91_MB_TX_FIRST	(AT91_MB_RX_LAST + 1)
@@ -64,7 +64,7 @@
 
 #define AT91_NEXT_PRIO_SHIFT	(AT91_MB_TX_SHIFT)
 #define AT91_NEXT_PRIO_MASK	(0xf << AT91_MB_TX_SHIFT)
-#define AT91_NEXT_MB_MASK	(AT91_MB_TX_NUM - 1)
+#define AT91_NEXT_MB_MASK	(AT91_MB_MASK(AT91_MB_TX_SHIFT))
 #define AT91_NEXT_MASK		((AT91_MB_TX_NUM - 1) | AT91_NEXT_PRIO_MASK)
 
 /* Common registers */
@@ -127,10 +127,10 @@ enum at91_mb_mode {
 };
 
 /* Interrupt mask bits */
-#define AT91_IRQ_MB_RX		((1 << (AT91_MB_RX_LAST + 1)) \
-				 - (1 << AT91_MB_RX_FIRST))
-#define AT91_IRQ_MB_TX		((1 << (AT91_MB_TX_LAST + 1)) \
-				 - (1 << AT91_MB_TX_FIRST))
+#define AT91_IRQ_MB_RX		(AT91_MB_MASK(AT91_MB_RX_LAST + 1) & \
+				 ~AT91_MB_MASK(AT91_MB_RX_FIRST))
+#define AT91_IRQ_MB_TX		(AT91_MB_MASK(AT91_MB_TX_LAST + 1) & \
+				 ~AT91_MB_MASK(AT91_MB_TX_FIRST))
 #define AT91_IRQ_MB_ALL		(AT91_IRQ_MB_RX | AT91_IRQ_MB_TX)
 
 #define AT91_IRQ_ERRA		(1 << 16)
@@ -735,7 +735,7 @@ static int at91_poll(struct napi_struct *napi, int quota)
 	if (work_done < quota) {
 		/* enable IRQs for frame errors and all mailboxes >= rx_next */
 		u32 reg_ier = AT91_IRQ_ERR_FRAME;
-		reg_ier |= AT91_IRQ_MB_RX & ~AT91_MB_RX_MASK(priv->rx_next);
+		reg_ier |= AT91_IRQ_MB_RX & ~AT91_MB_MASK(priv->rx_next);
 
 		napi_complete(napi);
 		at91_write(priv, AT91_IER, reg_ier);
-- 
1.7.4.1

