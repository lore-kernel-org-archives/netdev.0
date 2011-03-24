From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 2/2] can: c_can_platform: fix irq check in probe
Date: Thu, 24 Mar 2011 13:34:33 +0100
Message-ID: <1300970073-25522-3-git-send-email-mkl@pengutronix.de>
References: <1300970073-25522-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	jan-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1300970073-25522-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch fixes the check in the probe function whether a IRQ was supplied
to the driver. The original driver check the irq "struct resource *" against
<= 0. Use "platform_get_irq" instead.

Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Cc: Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
---
 drivers/net/can/c_can/c_can_platform.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index e629b96..cc90824 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -73,7 +73,8 @@ static int __devinit c_can_plat_probe(struct platform_device *pdev)
 	void __iomem *addr;
 	struct net_device *dev;
 	struct c_can_priv *priv;
-	struct resource *mem, *irq;
+	struct resource *mem;
+	int irq;
 #ifdef CONFIG_HAVE_CLK
 	struct clk *clk;
 
@@ -88,8 +89,8 @@ static int __devinit c_can_plat_probe(struct platform_device *pdev)
 
 	/* get the platform data */
 	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	irq = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
-	if (!mem || (irq <= 0)) {
+	irq = platform_get_irq(pdev, 0);
+	if (!mem || irq <= 0) {
 		ret = -ENODEV;
 		goto exit_free_clk;
 	}
@@ -117,7 +118,7 @@ static int __devinit c_can_plat_probe(struct platform_device *pdev)
 
 	priv = netdev_priv(dev);
 
-	dev->irq = irq->start;
+	dev->irq = irq;
 	priv->regs = addr;
 #ifdef CONFIG_HAVE_CLK
 	priv->can.clock.freq = clk_get_rate(clk);
-- 
1.7.2.3
