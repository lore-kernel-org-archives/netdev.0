From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] rcar_can: unify error messages
Date: Sat, 20 Jun 2015 03:51:34 +0300
Message-ID: <2511974.9a3ucLkyEa@wasted.cogentembedded.com>
References: <1593397.kKIHxKLe5s@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org, wg@grandegger.com, mkl@pengutronix.de,
	linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1593397.kKIHxKLe5s@wasted.cogentembedded.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All the error messages in the driver but  the ones from devm_clk_get() failures
use similar format.  Make those  two messages consitent with others.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/can/rcar_can.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-can/drivers/net/can/rcar_can.c
===================================================================
--- linux-can.orig/drivers/net/can/rcar_can.c
+++ linux-can/drivers/net/can/rcar_can.c
@@ -785,7 +785,8 @@ static int rcar_can_probe(struct platfor
 	priv->clk = devm_clk_get(&pdev->dev, "clkp1");
 	if (IS_ERR(priv->clk)) {
 		err = PTR_ERR(priv->clk);
-		dev_err(&pdev->dev, "cannot get peripheral clock: %d\n", err);
+		dev_err(&pdev->dev, "cannot get peripheral clock, error %d\n",
+			err);
 		goto fail_clk;
 	}
 
@@ -797,7 +798,7 @@ static int rcar_can_probe(struct platfor
 	priv->can_clk = devm_clk_get(&pdev->dev, clock_names[clock_select]);
 	if (IS_ERR(priv->can_clk)) {
 		err = PTR_ERR(priv->can_clk);
-		dev_err(&pdev->dev, "cannot get CAN clock: %d\n", err);
+		dev_err(&pdev->dev, "cannot get CAN clock, error %d\n", err);
 		goto fail_clk;
 	}
 

--
To unsubscribe from this list: send the line "unsubscribe linux-can" in
