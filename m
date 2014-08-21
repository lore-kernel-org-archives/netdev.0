From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/4] can: c_can: checking IS_ERR() instead of NULL
Date: Thu, 21 Aug 2014 11:23:20 +0200
Message-ID: <1408613002-29693-3-git-send-email-mkl@pengutronix.de>
References: <1408613002-29693-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Dan Carpenter <dan.carpenter@oracle.com>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1408613002-29693-1-git-send-email-mkl@pengutronix.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>

devm_ioremap() returns NULL on error, not an ERR_PTR().

Fixes: 33cf75656923 ('can: c_can_platform: Fix raminit, use devm_ioremap() instead of devm_ioremap_resource()')

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Cc: linux-stable <stable@vger.kernel.org> # >= v3.11
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can_platform.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index 5dede6e..109cb44 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -280,7 +280,7 @@ static int c_can_plat_probe(struct platform_device *pdev)
 
 		priv->raminit_ctrlreg = devm_ioremap(&pdev->dev, res->start,
 						     resource_size(res));
-		if (IS_ERR(priv->raminit_ctrlreg) || priv->instance < 0)
+		if (!priv->raminit_ctrlreg || priv->instance < 0)
 			dev_info(&pdev->dev, "control memory is not used for raminit\n");
 		else
 			priv->raminit = c_can_hw_raminit_ti;
-- 
2.1.0.rc1
