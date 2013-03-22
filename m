From: Steffen Trumtrar <s.trumtrar@pengutronix.de>
Subject: [PATCH 3/3] net/macb: make clk_enable atomic
Date: Fri, 22 Mar 2013 18:33:35 +0100
Message-ID: <1363973615-17863-3-git-send-email-s.trumtrar@pengutronix.de>
References: <1363973615-17863-1-git-send-email-s.trumtrar@pengutronix.de>
Cc: Steffen Trumtrar <s.trumtrar@pengutronix.de>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37964 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161079Ab3CVRdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 13:33:51 -0400
In-Reply-To: <1363973615-17863-1-git-send-email-s.trumtrar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use clk_prepare_enable to be safe on SMP systems.

Signed-off-by: Steffen Trumtrar <s.trumtrar@pengutronix.de>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 71e766b..733b3fc 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1561,14 +1561,14 @@ static int __init macb_probe(struct platform_device *pdev)
 		dev_err(&pdev->dev, "failed to get macb_clk\n");
 		goto err_out_free_dev;
 	}
-	clk_enable(bp->pclk);
+	clk_prepare_enable(bp->pclk);
 
 	bp->hclk = clk_get(&pdev->dev, "hclk");
 	if (IS_ERR(bp->hclk)) {
 		dev_err(&pdev->dev, "failed to get hclk\n");
 		goto err_out_put_pclk;
 	}
-	clk_enable(bp->hclk);
+	clk_prepare_enable(bp->hclk);
 
 	bp->regs = ioremap(regs->start, resource_size(regs));
 	if (!bp->regs) {
-- 
1.8.2.rc2
