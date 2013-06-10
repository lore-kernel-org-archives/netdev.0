From: Tushar Behera <tushar.behera@linaro.org>
Subject: [PATCH 09/15] net: can: Convert to use devm_ioremap_resource
Date: Mon, 10 Jun 2013 17:05:07 +0530
Message-ID: <1370864113-17895-10-git-send-email-tushar.behera@linaro.org>
References: <1370864113-17895-1-git-send-email-tushar.behera@linaro.org>
Cc: thierry.reding@gmail.com, patches@linaro.org,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370864113-17895-1-git-send-email-tushar.behera@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 75096579c3ac ("lib: devres: Introduce devm_ioremap_resource()")
introduced devm_ioremap_resource() and deprecated the use of
devm_request_and_ioremap().

Signed-off-by: Tushar Behera <tushar.behera@linaro.org>
CC: netdev@vger.kernel.org
CC: linux-can@vger.kernel.org
CC: Marc Kleine-Budde <mkl@pengutronix.de>
CC: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/c_can/c_can_platform.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index 6b6130b..b918c73 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -201,8 +201,8 @@ static int c_can_plat_probe(struct platform_device *pdev)
 			priv->instance = pdev->id;
 
 		res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
-		priv->raminit_ctrlreg =	devm_request_and_ioremap(&pdev->dev, res);
-		if (!priv->raminit_ctrlreg || priv->instance < 0)
+		priv->raminit_ctrlreg = devm_ioremap_resource(&pdev->dev, res);
+		if (IS_ERR(priv->raminit_ctrlreg) || priv->instance < 0)
 			dev_info(&pdev->dev, "control memory is not used for raminit\n");
 		else
 			priv->raminit = c_can_hw_raminit;
-- 
1.7.9.5
