From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH] can: flexcan: fix use after free of priv
Date: Thu, 21 Oct 2010 17:07:58 +0200
Message-ID: <1287673678-27510-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
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

Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---

The following changes since commit 27b75c95f10d249574d9c4cb9dab878107faede8:
  Eric Dumazet (1):
        net: avoid RCU for NOCACHE dst

are available in the git repository at:

  git://git.pengutronix.de/git/mkl/linux-2.6.git can/flexcan-for-net-next

Marc Kleine-Budde (1):
      can: flexcan: fix use after free of priv

 drivers/net/can/flexcan.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index ef443a0..d499056 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -992,7 +992,6 @@ static int __devexit flexcan_remove(struct platform_device *pdev)
 
 	unregister_flexcandev(dev);
 	platform_set_drvdata(pdev, NULL);
-	free_candev(dev);
 	iounmap(priv->base);
 
 	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
@@ -1000,6 +999,8 @@ static int __devexit flexcan_remove(struct platform_device *pdev)
 
 	clk_put(priv->clk);
 
+	free_candev(dev);
+
 	return 0;
 }
 
-- 
1.7.0.4
