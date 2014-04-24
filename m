From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 22/26] can: c_can: use proper type for 'instance'
Date: Fri, 25 Apr 2014 00:00:25 +0200
Message-ID: <1398376829-6771-23-git-send-email-mkl@pengutronix.de>
References: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Wolfram Sang <wsa@sang-engineering.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46148 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932576AbaDXWAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 18:00:45 -0400
In-Reply-To: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfram Sang <wsa@sang-engineering.com>

Commit 6439fbce1075 (can: c_can: fix error checking of priv->instance in
probe()) found the warning but applied a suboptimal solution. Since, both
pdev->id and of_alias_get_id() return integers, it makes sense to convert the
variable to an integer and avoid the cast.

Signed-off-by: Wolfram Sang <wsa@sang-engineering.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.h          | 2 +-
 drivers/net/can/c_can/c_can_platform.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
index e7de2b9..c56f1b1 100644
--- a/drivers/net/can/c_can/c_can.h
+++ b/drivers/net/can/c_can/c_can.h
@@ -183,7 +183,7 @@ struct c_can_priv {
 	void *priv;		/* for board-specific data */
 	enum c_can_dev_id type;
 	u32 __iomem *raminit_ctrlreg;
-	unsigned int instance;
+	int instance;
 	void (*raminit) (const struct c_can_priv *priv, bool enable);
 	u32 comm_rcv_high;
 	u32 rxmasked;
diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index 806d927..1df0b32 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -222,7 +222,7 @@ static int c_can_plat_probe(struct platform_device *pdev)
 
 		res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
 		priv->raminit_ctrlreg = devm_ioremap_resource(&pdev->dev, res);
-		if (IS_ERR(priv->raminit_ctrlreg) || (int)priv->instance < 0)
+		if (IS_ERR(priv->raminit_ctrlreg) || priv->instance < 0)
 			dev_info(&pdev->dev, "control memory is not used for raminit\n");
 		else
 			priv->raminit = c_can_hw_raminit;
-- 
1.9.0.279.gdc9e3eb
