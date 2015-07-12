From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/8] can: rcar_can: print signed IRQ #
Date: Sun, 12 Jul 2015 21:18:05 +0200
Message-ID: <1436728691-1145-3-git-send-email-mkl@pengutronix.de>
References: <1436728691-1145-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48156 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284AbbGLTSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2015 15:18:17 -0400
In-Reply-To: <1436728691-1145-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Printing IRQ # using "%x" and "%u" unsigned formats isn't quite correct as
'ndev->irq' is of  type *int*, so  the "%d" format  needs to be used instead.

While fixing this, beautify the dev_info() message in rcar_can_probe() a bit.

Fixes: fd1159318e55 ("can: add Renesas R-Car CAN driver")
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/rcar_can.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/rcar_can.c b/drivers/net/can/rcar_can.c
index 93017c09cfc3..2f9ebad4ff56 100644
--- a/drivers/net/can/rcar_can.c
+++ b/drivers/net/can/rcar_can.c
@@ -526,7 +526,7 @@ static int rcar_can_open(struct net_device *ndev)
 	napi_enable(&priv->napi);
 	err = request_irq(ndev->irq, rcar_can_interrupt, 0, ndev->name, ndev);
 	if (err) {
-		netdev_err(ndev, "error requesting interrupt %x\n", ndev->irq);
+		netdev_err(ndev, "error requesting interrupt %d\n", ndev->irq);
 		goto out_close;
 	}
 	can_led_event(ndev, CAN_LED_EVENT_OPEN);
@@ -824,7 +824,7 @@ static int rcar_can_probe(struct platform_device *pdev)
 
 	devm_can_led_init(ndev);
 
-	dev_info(&pdev->dev, "device registered (reg_base=%p, irq=%u)\n",
+	dev_info(&pdev->dev, "device registered (regs @ %p, IRQ%d)\n",
 		 priv->regs, ndev->irq);
 
 	return 0;
-- 
2.1.4
