From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Subject: [PATCH] net: lpc_eth: fix coccicheck warnings
Date: Wed, 13 Mar 2013 00:33:05 +0200
Message-ID: <1363127585-7925-1-git-send-email-silviupopescu1990@gmail.com>
Cc: davem@davemloft.net, stigge@antcom.de, edumazet@google.com,
	gregkh@linuxfoundation.org, jiri@resnulli.us,
	linux-kernel@vger.kernel.org,
	Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use resource_size() instead of explicit calculation and change the way
debugging for struct resource is done.

Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
---
 drivers/net/ethernet/nxp/lpc_eth.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index c4122c8..7862f96 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -1362,7 +1362,7 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
 	__lpc_eth_clock_enable(pldat, true);
 
 	/* Map IO space */
-	pldat->net_base = ioremap(res->start, res->end - res->start + 1);
+	pldat->net_base = ioremap(res->start, resource_size(res));
 	if (!pldat->net_base) {
 		dev_err(&pdev->dev, "failed to map registers\n");
 		ret = -ENOMEM;
@@ -1418,10 +1418,7 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
 	}
 	pldat->dma_buff_base_p = dma_handle;
 
-	netdev_dbg(ndev, "IO address start     :0x%08x\n",
-			res->start);
-	netdev_dbg(ndev, "IO address size      :%d\n",
-			res->end - res->start + 1);
+	netdev_dbg(ndev, "IO resource          :%pR\n", res);
 	netdev_dbg(ndev, "IO address (mapped)  :0x%p\n",
 			pldat->net_base);
 	netdev_dbg(ndev, "IRQ number           :%d\n", ndev->irq);
-- 
1.7.9.5
