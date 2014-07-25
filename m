From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: c_can_platform: Fix raminit, use devm_ioremap() instead of devm_ioremap_resource()
Date: Fri, 25 Jul 2014 09:36:50 +0200
Message-ID: <1406273810-19116-2-git-send-email-mkl@pengutronix.de>
References: <1406273810-19116-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, George Cherian <george.cherian@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1406273810-19116-1-git-send-email-mkl@pengutronix.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: George Cherian <george.cherian@ti.com>

The raminit register is shared register for both can0 and can1. Since commit:

    32766ff net: can: Convert to use devm_ioremap_resource

devm_ioremap_resource() is used to map raminit register. When using both
interfaces the mapping for the can1 interface fails, leading to a non
functional can interface.

Signed-off-by: George Cherian <george.cherian@ti.com>
Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
Cc: linux-stable <stable@vger.kernel.org> # >= v3.11
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can_platform.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index 824108c..12430be 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -287,7 +287,8 @@ static int c_can_plat_probe(struct platform_device *pdev)
 			break;
 		}
 
-		priv->raminit_ctrlreg = devm_ioremap_resource(&pdev->dev, res);
+		priv->raminit_ctrlreg = devm_ioremap(&pdev->dev, res->start,
+						     resource_size(res));
 		if (IS_ERR(priv->raminit_ctrlreg) || priv->instance < 0)
 			dev_info(&pdev->dev, "control memory is not used for raminit\n");
 		else
-- 
2.0.1
