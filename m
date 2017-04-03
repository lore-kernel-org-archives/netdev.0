From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH] can: rcar_can: Do not print virtual addresses
Date: Mon,  3 Apr 2017 12:11:26 +0200
Message-ID: <1491214286-14370-1-git-send-email-geert+renesas@glider.be>
Cc: linux-renesas-soc@vger.kernel.org, linux-can@vger.kernel.org,
        netdev@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: Wolfgang Grandegger <wg@grandegger.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

During probe, the rcar_can driver prints:

    rcar_can e6e80000.can: device registered (regs @ e08bc000, IRQ76)

The "regs" value is a virtual address, exposing internal information,
hence stop printing it.  The (useful) physical address is already
printed as part of the device name.

Fixes: fd1159318e55e901 ("can: add Renesas R-Car CAN driver")
Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
 drivers/net/can/rcar/rcar_can.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/can/rcar/rcar_can.c b/drivers/net/can/rcar/rcar_can.c
index caed4e6960f8c77f..11662f479e760ba7 100644
--- a/drivers/net/can/rcar/rcar_can.c
+++ b/drivers/net/can/rcar/rcar_can.c
@@ -826,8 +826,7 @@ static int rcar_can_probe(struct platform_device *pdev)
 
 	devm_can_led_init(ndev);
 
-	dev_info(&pdev->dev, "device registered (regs @ %p, IRQ%d)\n",
-		 priv->regs, ndev->irq);
+	dev_info(&pdev->dev, "device registered (IRQ%d)\n", ndev->irq);
 
 	return 0;
 fail_candev:
-- 
2.7.4
