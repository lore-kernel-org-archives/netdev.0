From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH 2/3][net-next] gianfar: Cleanup gfar_parse_group() code
Date: Tue, 29 Jan 2013 15:55:11 +0200
Message-ID: <1359467712-32079-2-git-send-email-claudiu.manoil@freescale.com>
References: <1359467712-32079-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe003.messaging.microsoft.com ([216.32.180.13]:12320
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756938Ab3A2N4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 08:56:12 -0500
In-Reply-To: <1359467712-32079-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Factor out redundant code (improve readability, source code size).

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c |   34 ++++++++++++++---------------
 1 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index e765b9b..fdb8080 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -563,40 +563,38 @@ static void enable_napi(struct gfar_private *priv)
 static int gfar_parse_group(struct device_node *np,
 			    struct gfar_private *priv, const char *model)
 {
+	struct gfar_priv_grp *grp = &priv->gfargrp[priv->num_grps];
 	u32 *queue_mask;
 
-	priv->gfargrp[priv->num_grps].regs = of_iomap(np, 0);
-	if (!priv->gfargrp[priv->num_grps].regs)
+	grp->regs = of_iomap(np, 0);
+	if (!grp->regs)
 		return -ENOMEM;
 
-	priv->gfargrp[priv->num_grps].interruptTransmit =
-			irq_of_parse_and_map(np, 0);
+	grp->interruptTransmit = irq_of_parse_and_map(np, 0);
 
 	/* If we aren't the FEC we have multiple interrupts */
 	if (model && strcasecmp(model, "FEC")) {
-		priv->gfargrp[priv->num_grps].interruptReceive =
-			irq_of_parse_and_map(np, 1);
-		priv->gfargrp[priv->num_grps].interruptError =
-			irq_of_parse_and_map(np,2);
-		if (priv->gfargrp[priv->num_grps].interruptTransmit == NO_IRQ ||
-		    priv->gfargrp[priv->num_grps].interruptReceive  == NO_IRQ ||
-		    priv->gfargrp[priv->num_grps].interruptError    == NO_IRQ)
+		grp->interruptReceive =	irq_of_parse_and_map(np, 1);
+		grp->interruptError =	irq_of_parse_and_map(np, 2);
+		if (grp->interruptTransmit == NO_IRQ ||
+		    grp->interruptReceive  == NO_IRQ ||
+		    grp->interruptError    == NO_IRQ)
 			return -EINVAL;
 	}
 
-	priv->gfargrp[priv->num_grps].grp_id = priv->num_grps;
-	priv->gfargrp[priv->num_grps].priv = priv;
-	spin_lock_init(&priv->gfargrp[priv->num_grps].grplock);
+	grp->grp_id = priv->num_grps;
+	grp->priv = priv;
+	spin_lock_init(&grp->grplock);
 	if (priv->mode == MQ_MG_MODE) {
 		queue_mask = (u32 *)of_get_property(np, "fsl,rx-bit-map", NULL);
-		priv->gfargrp[priv->num_grps].rx_bit_map = queue_mask ?
+		grp->rx_bit_map = queue_mask ?
 			*queue_mask : (DEFAULT_MAPPING >> priv->num_grps);
 		queue_mask = (u32 *)of_get_property(np, "fsl,tx-bit-map", NULL);
-		priv->gfargrp[priv->num_grps].tx_bit_map = queue_mask ?
+		grp->tx_bit_map = queue_mask ?
 			*queue_mask : (DEFAULT_MAPPING >> priv->num_grps);
 	} else {
-		priv->gfargrp[priv->num_grps].rx_bit_map = 0xFF;
-		priv->gfargrp[priv->num_grps].tx_bit_map = 0xFF;
+		grp->rx_bit_map = 0xFF;
+		grp->tx_bit_map = 0xFF;
 	}
 	priv->num_grps++;
 
-- 
1.6.6
