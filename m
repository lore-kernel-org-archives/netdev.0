From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/3] rcar_can: print signed IRQ #
Date: Sat, 20 Jun 2015 03:33:53 +0300
Message-ID: <2390389.thI8mIvbv5@wasted.cogentembedded.com>
References: <2010452.WyFito6egU@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org, wg@grandegger.com, mkl@pengutronix.de,
	linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <2010452.WyFito6egU@wasted.cogentembedded.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Printing IRQ # using "%x" and "%u" unsigned formats isn't quite correct as
'ndev->irq' is of  type *int*, so  the "%d" format  needs to be used instead.

While fixing this, beautify the dev_info() message in rcar_can_probe() a bit.

Fixes: fd1159318e55 ("can: add Renesas R-Car CAN driver")
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/can/rcar_can.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-can/drivers/net/can/rcar_can.c
===================================================================
--- linux-can.orig/drivers/net/can/rcar_can.c
+++ linux-can/drivers/net/can/rcar_can.c
@@ -526,7 +526,7 @@ static int rcar_can_open(struct net_devi
 	napi_enable(&priv->napi);
 	err = request_irq(ndev->irq, rcar_can_interrupt, 0, ndev->name, ndev);
 	if (err) {
-		netdev_err(ndev, "error requesting interrupt %x\n", ndev->irq);
+		netdev_err(ndev, "error requesting interrupt %d\n", ndev->irq);
 		goto out_close;
 	}
 	can_led_event(ndev, CAN_LED_EVENT_OPEN);
@@ -824,7 +824,7 @@ static int rcar_can_probe(struct platfor
 
 	devm_can_led_init(ndev);
 
-	dev_info(&pdev->dev, "device registered (reg_base=%p, irq=%u)\n",
+	dev_info(&pdev->dev, "device registered (regs @ %p, IRQ%d)\n",
 		 priv->regs, ndev->irq);
 
 	return 0;

--
To unsubscribe from this list: send the line "unsubscribe linux-can" in
