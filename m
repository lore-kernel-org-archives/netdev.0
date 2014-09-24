From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 1/5] ARCNET: return IRQ_NONE if the interface isn't running
Date: Wed, 24 Sep 2014 13:01:59 +0200
Message-ID: <1411556523-28100-2-git-send-email-m.grzeschik@pengutronix.de>
References: <1411556523-28100-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: linux-kernel@vger.kernel.org, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1411556523-28100-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The interrupt handler needs to return IRQ_NONE in case
two devices are used with the shared interrupt handler.
Otherwise it could steal interrupts from the other
interface.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arcnet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index a956053..abcbd3c 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -776,7 +776,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 			ACOMMAND(CFLAGScmd | RESETclear);
 		AINTMASK(0);
 		spin_unlock(&lp->lock);
-		return IRQ_HANDLED;
+		return retval;
 	}
 
 	BUGMSG(D_DURING, "in arcnet_inthandler (status=%Xh, intmask=%Xh)\n",
-- 
2.1.0
