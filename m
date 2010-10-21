From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 03/10] can: at91_can: fix use after free of priv
Date: Thu, 21 Oct 2010 13:01:15 +0200
Message-ID: <1287658882-26914-4-git-send-email-mkl@pengutronix.de>
References: <1287658882-26914-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1287658882-26914-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

The priv is part of the memory allocated by alloc_candev().
This patch moved the free it after last usage of priv.

While there convert all free_netdev() to free_candev() (which is currently
just a wrapper around free_netdev()) to be symetrically with the allocation
via alloc_candev().

Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 drivers/net/can/at91_can.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 3b66c67..2c17e74 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -1101,7 +1101,7 @@ static int __init at91_can_probe(struct platform_device *pdev)
 	return 0;
 
  exit_free:
-	free_netdev(dev);
+	free_candev(dev);
  exit_iounmap:
 	iounmap(addr);
  exit_release:
@@ -1122,8 +1122,6 @@ static int __devexit at91_can_remove(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, NULL);
 
-	free_netdev(dev);
-
 	iounmap(priv->reg_base);
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
@@ -1131,6 +1129,8 @@ static int __devexit at91_can_remove(struct platform_device *pdev)
 
 	clk_put(priv->clk);
 
+	free_candev(dev);
+
 	return 0;
 }
 
-- 
1.7.0.4
