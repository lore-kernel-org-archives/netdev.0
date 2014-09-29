From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH v2 1/5] ARCNET: return IRQ_NONE if the interface isn't running
Date: Mon, 29 Sep 2014 11:55:34 +0200
Message-ID: <1411984538-953-2-git-send-email-m.grzeschik@pengutronix.de>
References: <1411984538-953-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: linux-kernel@vger.kernel.org, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:51406 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753683AbaI2J4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 05:56:07 -0400
In-Reply-To: <1411984538-953-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The interrupt handler needs to return IRQ_NONE in case
two devices are used with the shared interrupt handler.
Otherwise it could steal interrupts from the other
interface.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arcnet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index 3b790de..09de683 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -777,7 +777,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 			ACOMMAND(CFLAGScmd | RESETclear);
 		AINTMASK(0);
 		spin_unlock(&lp->lock);
-		return IRQ_HANDLED;
+		return retval;
 	}
 
 	BUGMSG(D_DURING, "in arcnet_inthandler (status=%Xh, intmask=%Xh)\n",
-- 
2.1.0
