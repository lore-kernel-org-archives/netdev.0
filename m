From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/2] can: rcar_can: Do not print virtual addresses
Date: Tue,  4 Apr 2017 17:59:49 +0200
Message-ID: <20170404155949.30965-3-mkl@pengutronix.de>
References: <20170404155949.30965-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:38131 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754693AbdDDP7y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 11:59:54 -0400
In-Reply-To: <20170404155949.30965-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert+renesas@glider.be>

During probe, the rcar_can driver prints:

    rcar_can e6e80000.can: device registered (regs @ e08bc000, IRQ76)

The "regs" value is a virtual address, exposing internal information,
hence stop printing it.  The (useful) physical address is already
printed as part of the device name.

Fixes: fd1159318e55e901 ("can: add Renesas R-Car CAN driver")
Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/rcar/rcar_can.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/can/rcar/rcar_can.c b/drivers/net/can/rcar/rcar_can.c
index caed4e6960f8..11662f479e76 100644
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
2.11.0
