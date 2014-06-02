From: Benoit Taine <benoit.taine@lip6.fr>
Subject: [PATCH 2/2 v2] lpc_eth: Use resource_size instead of computation
Date: Mon, 2 Jun 2014 13:24:19 +0200
Message-ID: <20140602112419.GA3625@lip6.fr>
References: <1401290047-30005-1-git-send-email-benoit.taine@lip6.fr>
 <1401290047-30005-3-git-send-email-benoit.taine@lip6.fr>
 <20140601.192705.693805935389177182.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140601.192705.693805935389177182.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This issue was reported by coccicheck using the semantic patch 
at scripts/coccinelle/api/resource_size.cocci

Signed-off-by: Benoit Taine <benoit.taine@lip6.fr>
---
Not compile tested, due incompatible architecture.

diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 422d9b5..645dac3 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -1361,7 +1361,7 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
        __lpc_eth_clock_enable(pldat, true);
 
        /* Map IO space */
-       pldat->net_base = ioremap(res->start, res->end - res->start + 1);
+       pldat->net_base = ioremap(res->start, resource_size(res));
        if (!pldat->net_base) {
                dev_err(&pdev->dev, "failed to map registers\n");
                ret = -ENOMEM;
@@ -1417,10 +1417,8 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
        }
        pldat->dma_buff_base_p = dma_handle;
 
-       netdev_dbg(ndev, "IO address start     :0x%08x\n",
-                       res->start);
-       netdev_dbg(ndev, "IO address size      :%d\n",
-                       res->end - res->start + 1);
+       netdev_dbg(ndev, "IO address space     :%pR", res);
+       netdev_dbg(ndev, "IO address size      :%d\n", resource_size(res));
        netdev_dbg(ndev, "IO address (mapped)  :0x%p\n",
                        pldat->net_base);
        netdev_dbg(ndev, "IRQ number           :%d\n", ndev->irq);
