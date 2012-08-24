From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/2] can: sja1000_platform: fix wrong flag IRQF_SHARED for interrupt sharing
Date: Fri, 24 Aug 2012 11:30:43 +0200
Message-ID: <1345800643-29456-3-git-send-email-mkl@pengutronix.de>
References: <1345800643-29456-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Sven Schmitt <sven.schmitt@volkswagen.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1345800643-29456-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sven Schmitt <sven.schmitt@volkswagen.de>

The sja1000 platform driver wrongly assumes that a shared IRQ is indicated
with the IRQF_SHARED flag in irq resource flags. This patch changes the
driver to handle the correct flag IORESOURCE_IRQ_SHAREABLE instead.

There are no mainline users of the platform driver which wrongly make use
of IRQF_SHARED.

Signed-off-by: Sven Schmitt <sven.schmitt@volkswagen.de>
Acked-by: Yegor Yefremov <yegorslists@googlemail.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/sja1000/sja1000_platform.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/can/sja1000/sja1000_platform.c
index 4f50145..662c5f7 100644
--- a/drivers/net/can/sja1000/sja1000_platform.c
+++ b/drivers/net/can/sja1000/sja1000_platform.c
@@ -109,7 +109,9 @@ static int sp_probe(struct platform_device *pdev)
 	priv = netdev_priv(dev);
 
 	dev->irq = res_irq->start;
-	priv->irq_flags = res_irq->flags & (IRQF_TRIGGER_MASK | IRQF_SHARED);
+	priv->irq_flags = res_irq->flags & IRQF_TRIGGER_MASK;
+	if (res_irq->flags & IORESOURCE_IRQ_SHAREABLE)
+		priv->irq_flags |= IRQF_SHARED;
 	priv->reg_base = addr;
 	/* The CAN clock frequency is half the oscillator clock frequency */
 	priv->can.clock.freq = pdata->osc_freq / 2;
-- 
1.7.10

