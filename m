From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 5/8] can: rcar_can: unify error messages
Date: Sun, 12 Jul 2015 21:18:08 +0200
Message-ID: <1436728691-1145-6-git-send-email-mkl@pengutronix.de>
References: <1436728691-1145-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1436728691-1145-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

All the error messages in the driver but  the ones from devm_clk_get() failures
use similar format.  Make those  two messages consitent with others.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/rcar_can.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/rcar_can.c b/drivers/net/can/rcar_can.c
index 5e81afffc073..7bd54191f962 100644
--- a/drivers/net/can/rcar_can.c
+++ b/drivers/net/can/rcar_can.c
@@ -785,7 +785,8 @@ static int rcar_can_probe(struct platform_device *pdev)
 	priv->clk = devm_clk_get(&pdev->dev, "clkp1");
 	if (IS_ERR(priv->clk)) {
 		err = PTR_ERR(priv->clk);
-		dev_err(&pdev->dev, "cannot get peripheral clock: %d\n", err);
+		dev_err(&pdev->dev, "cannot get peripheral clock, error %d\n",
+			err);
 		goto fail_clk;
 	}
 
@@ -797,7 +798,7 @@ static int rcar_can_probe(struct platform_device *pdev)
 	priv->can_clk = devm_clk_get(&pdev->dev, clock_names[clock_select]);
 	if (IS_ERR(priv->can_clk)) {
 		err = PTR_ERR(priv->can_clk);
-		dev_err(&pdev->dev, "cannot get CAN clock: %d\n", err);
+		dev_err(&pdev->dev, "cannot get CAN clock, error %d\n", err);
 		goto fail_clk;
 	}
 
-- 
2.1.4

