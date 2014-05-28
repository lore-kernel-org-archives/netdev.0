From: Benoit Taine <benoit.taine@lip6.fr>
Subject: [PATCH 2/2] lpc_eth: Use resource_size instead of computation
Date: Wed, 28 May 2014 17:14:07 +0200
Message-ID: <1401290047-30005-3-git-send-email-benoit.taine@lip6.fr>
References: <1401290047-30005-1-git-send-email-benoit.taine@lip6.fr>
Cc: benoit.taine@lip6.fr, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401290047-30005-1-git-send-email-benoit.taine@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This issue was reported by coccicheck using the semantic patch 
at scripts/coccinelle/api/resource_size.cocci

Signed-off-by: Benoit Taine <benoit.taine@lip6.fr>
---
Not compile tested, due incompatible architecture.

 drivers/net/ethernet/nxp/lpc_eth.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 422d9b5..dc2f15c 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -1361,7 +1361,7 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
 	__lpc_eth_clock_enable(pldat, true);
 
 	/* Map IO space */
-	pldat->net_base = ioremap(res->start, res->end - res->start + 1);
+	pldat->net_base = ioremap(res->start, resource_size(res));
 	if (!pldat->net_base) {
 		dev_err(&pdev->dev, "failed to map registers\n");
 		ret = -ENOMEM;
@@ -1419,8 +1419,7 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
 
 	netdev_dbg(ndev, "IO address start     :0x%08x\n",
 			res->start);
-	netdev_dbg(ndev, "IO address size      :%d\n",
-			res->end - res->start + 1);
+	netdev_dbg(ndev, "IO address size      :%d\n", resource_size(res));
 	netdev_dbg(ndev, "IO address (mapped)  :0x%p\n",
 			pldat->net_base);
 	netdev_dbg(ndev, "IRQ number           :%d\n", ndev->irq);
