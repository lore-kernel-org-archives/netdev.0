From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH V2 1/4] net: ethernet: remove unnecessary platform_set_drvdata()
Date: Tue, 28 May 2013 14:01:12 +0900
Message-ID: <000101ce5b60$5fcef5f0$1f6ce1d0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	'Rob Herring' <rob.herring@calxeda.com>,
	'Roland Stigge' <stigge@antcom.de>,
	'Mugunthan V N' <mugunthanvnm@ti.com>,
	'H Hartley Sweeten' <hsweeten@visionengravers.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:48724 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932124Ab3E1FBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 01:01:14 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MNH00JROSM0YLG0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Tue, 28 May 2013 14:01:12 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
Acked-by: Rob Herring <rob.herring@calxeda.com>
Acked-by: Roland Stigge <stigge@antcom.de>
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>
Reviewed-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Tested-by: Roland Stigge <stigge@antcom.de>
---
 drivers/net/ethernet/8390/ne.c                        |    1 -
 drivers/net/ethernet/adi/bfin_mac.c                   |    4 ----
 drivers/net/ethernet/amd/au1000_eth.c                 |    2 --
 drivers/net/ethernet/broadcom/bcm63xx_enet.c          |    1 -
 drivers/net/ethernet/cadence/at91_ether.c             |    1 -
 drivers/net/ethernet/cadence/macb.c                   |    2 --
 drivers/net/ethernet/calxeda/xgmac.c                  |    2 --
 drivers/net/ethernet/cirrus/ep93xx_eth.c              |    1 -
 drivers/net/ethernet/davicom/dm9000.c                 |    2 --
 drivers/net/ethernet/ethoc.c                          |    2 --
 drivers/net/ethernet/faraday/ftgmac100.c              |    2 --
 drivers/net/ethernet/faraday/ftmac100.c               |    2 --
 drivers/net/ethernet/freescale/fec_main.c             |    2 --
 drivers/net/ethernet/korina.c                         |    1 -
 drivers/net/ethernet/marvell/mv643xx_eth.c            |    2 --
 drivers/net/ethernet/marvell/mvneta.c                 |    2 --
 drivers/net/ethernet/marvell/pxa168_eth.c             |    1 -
 drivers/net/ethernet/micrel/ks8695net.c               |    1 -
 drivers/net/ethernet/micrel/ks8842.c                  |    1 -
 drivers/net/ethernet/micrel/ks8851_mll.c              |    1 -
 drivers/net/ethernet/netx-eth.c                       |    1 -
 drivers/net/ethernet/nuvoton/w90p910_ether.c          |    2 --
 drivers/net/ethernet/nxp/lpc_eth.c                    |    2 --
 drivers/net/ethernet/renesas/sh_eth.c                 |    1 -
 drivers/net/ethernet/s6gmac.c                         |    1 -
 drivers/net/ethernet/seeq/sgiseeq.c                   |    1 -
 drivers/net/ethernet/sgi/meth.c                       |    1 -
 drivers/net/ethernet/smsc/smc911x.c                   |    2 --
 drivers/net/ethernet/smsc/smc91x.c                    |    3 ---
 drivers/net/ethernet/smsc/smsc911x.c                  |    2 --
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |    2 --
 drivers/net/ethernet/ti/cpsw.c                        |    1 -
 drivers/net/ethernet/ti/davinci_emac.c                |    2 --
 drivers/net/ethernet/tundra/tsi108_eth.c              |    1 -
 drivers/net/ethernet/wiznet/w5100.c                   |    2 --
 drivers/net/ethernet/wiznet/w5300.c                   |    2 --
 drivers/net/ethernet/xscale/ixp4xx_eth.c              |    2 --
 37 files changed, 61 deletions(-)

diff --git a/drivers/net/ethernet/8390/ne.c b/drivers/net/ethernet/8390/ne.c
index 47618e5..b2e8405 100644
--- a/drivers/net/ethernet/8390/ne.c
+++ b/drivers/net/ethernet/8390/ne.c
@@ -849,7 +849,6 @@ static int ne_drv_remove(struct platform_device *pdev)
 		free_irq(dev->irq, dev);
 		release_region(dev->base_addr, NE_IO_EXTENT);
 		free_netdev(dev);
-		platform_set_drvdata(pdev, NULL);
 	}
 	return 0;
 }
diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index dada66b..e904b38 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1719,7 +1719,6 @@ out_err_mii_probe:
 	mdiobus_unregister(lp->mii_bus);
 	mdiobus_free(lp->mii_bus);
 out_err_probe_mac:
-	platform_set_drvdata(pdev, NULL);
 	free_netdev(ndev);
 
 	return rc;
@@ -1732,8 +1731,6 @@ static int bfin_mac_remove(struct platform_device *pdev)
 
 	bfin_phc_release(lp);
 
-	platform_set_drvdata(pdev, NULL);
-
 	lp->mii_bus->priv = NULL;
 
 	unregister_netdev(ndev);
@@ -1868,7 +1865,6 @@ static int bfin_mii_bus_remove(struct platform_device *pdev)
 	struct bfin_mii_bus_platform_data *mii_bus_pd =
 		dev_get_platdata(&pdev->dev);
 
-	platform_set_drvdata(pdev, NULL);
 	mdiobus_unregister(miibus);
 	kfree(miibus->irq);
 	mdiobus_free(miibus);
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index 688aede..ceb45bc 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -1301,8 +1301,6 @@ static int au1000_remove(struct platform_device *pdev)
 	int i;
 	struct resource *base, *macen;
 
-	platform_set_drvdata(pdev, NULL);
-
 	unregister_netdev(dev);
 	mdiobus_unregister(aup->mii_bus);
 	mdiobus_free(aup->mii_bus);
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 0b3e23e..e46466c 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1847,7 +1847,6 @@ static int bcm_enet_remove(struct platform_device *pdev)
 	clk_disable_unprepare(priv->mac_clk);
 	clk_put(priv->mac_clk);
 
-	platform_set_drvdata(pdev, NULL);
 	free_netdev(dev);
 	return 0;
 }
diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index cc9a185..3f19571 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -435,7 +435,6 @@ static int at91ether_remove(struct platform_device *pdev)
 	unregister_netdev(dev);
 	clk_disable(lp->pclk);
 	free_netdev(dev);
-	platform_set_drvdata(pdev, NULL);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index c89aa41..4465e27 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1649,7 +1649,6 @@ err_out_put_pclk:
 err_out_free_dev:
 	free_netdev(dev);
 err_out:
-	platform_set_drvdata(pdev, NULL);
 	return err;
 }
 
@@ -1675,7 +1674,6 @@ static int __exit macb_remove(struct platform_device *pdev)
 		clk_disable_unprepare(bp->pclk);
 		clk_put(bp->pclk);
 		free_netdev(dev);
-		platform_set_drvdata(pdev, NULL);
 	}
 
 	return 0;
diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 4a1f2fa..7cb148c 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -1790,7 +1790,6 @@ err_io:
 	free_netdev(ndev);
 err_alloc:
 	release_mem_region(res->start, resource_size(res));
-	platform_set_drvdata(pdev, NULL);
 	return ret;
 }
 
@@ -1813,7 +1812,6 @@ static int xgmac_remove(struct platform_device *pdev)
 	free_irq(ndev->irq, ndev);
 	free_irq(priv->pmt_irq, ndev);
 
-	platform_set_drvdata(pdev, NULL);
 	unregister_netdev(ndev);
 	netif_napi_del(&priv->napi);
 
diff --git a/drivers/net/ethernet/cirrus/ep93xx_eth.c b/drivers/net/ethernet/cirrus/ep93xx_eth.c
index 67b0388..e3d4ec8 100644
--- a/drivers/net/ethernet/cirrus/ep93xx_eth.c
+++ b/drivers/net/ethernet/cirrus/ep93xx_eth.c
@@ -783,7 +783,6 @@ static int ep93xx_eth_remove(struct platform_device *pdev)
 	dev = platform_get_drvdata(pdev);
 	if (dev == NULL)
 		return 0;
-	platform_set_drvdata(pdev, NULL);
 
 	ep = netdev_priv(dev);
 
diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index dd243a1..a13b312 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1699,8 +1699,6 @@ dm9000_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 
-	platform_set_drvdata(pdev, NULL);
-
 	unregister_netdev(ndev);
 	dm9000_release_board(pdev, netdev_priv(ndev));
 	free_netdev(ndev);		/* free device structure */
diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 5722bc6..cf579fb 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -1147,8 +1147,6 @@ static int ethoc_remove(struct platform_device *pdev)
 	struct net_device *netdev = platform_get_drvdata(pdev);
 	struct ethoc *priv = netdev_priv(netdev);
 
-	platform_set_drvdata(pdev, NULL);
-
 	if (netdev) {
 		netif_napi_del(&priv->napi);
 		phy_disconnect(priv->phy);
diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 21b85fb..934e1ae 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1311,7 +1311,6 @@ err_ioremap:
 	release_resource(priv->res);
 err_req_mem:
 	netif_napi_del(&priv->napi);
-	platform_set_drvdata(pdev, NULL);
 	free_netdev(netdev);
 err_alloc_etherdev:
 	return err;
@@ -1335,7 +1334,6 @@ static int __exit ftgmac100_remove(struct platform_device *pdev)
 	release_resource(priv->res);
 
 	netif_napi_del(&priv->napi);
-	platform_set_drvdata(pdev, NULL);
 	free_netdev(netdev);
 	return 0;
 }
diff --git a/drivers/net/ethernet/faraday/ftmac100.c b/drivers/net/ethernet/faraday/ftmac100.c
index a6eda8d..4658f4c 100644
--- a/drivers/net/ethernet/faraday/ftmac100.c
+++ b/drivers/net/ethernet/faraday/ftmac100.c
@@ -1149,7 +1149,6 @@ err_ioremap:
 	release_resource(priv->res);
 err_req_mem:
 	netif_napi_del(&priv->napi);
-	platform_set_drvdata(pdev, NULL);
 	free_netdev(netdev);
 err_alloc_etherdev:
 	return err;
@@ -1169,7 +1168,6 @@ static int __exit ftmac100_remove(struct platform_device *pdev)
 	release_resource(priv->res);
 
 	netif_napi_del(&priv->napi);
-	platform_set_drvdata(pdev, NULL);
 	free_netdev(netdev);
 	return 0;
 }
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 0936b26..8db6bc9 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2019,8 +2019,6 @@ fec_drv_remove(struct platform_device *pdev)
 	}
 	free_netdev(ndev);
 
-	platform_set_drvdata(pdev, NULL);
-
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 0b57085..64646eb 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -1211,7 +1211,6 @@ static int korina_remove(struct platform_device *pdev)
 	iounmap(lp->rx_dma_regs);
 	iounmap(lp->tx_dma_regs);
 
-	platform_set_drvdata(pdev, NULL);
 	unregister_netdev(bif->dev);
 	free_netdev(bif->dev);
 
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 2ad1494..afb8bcb 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2813,8 +2813,6 @@ static int mv643xx_eth_remove(struct platform_device *pdev)
 
 	free_netdev(mp->dev);
 
-	platform_set_drvdata(pdev, NULL);
-
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index c966785..cd0ea20 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2804,8 +2804,6 @@ static int mvneta_remove(struct platform_device *pdev)
 	irq_dispose_mapping(dev->irq);
 	free_netdev(dev);
 
-	platform_set_drvdata(pdev, NULL);
-
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 339bb32..2602cf7 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1602,7 +1602,6 @@ static int pxa168_eth_remove(struct platform_device *pdev)
 	unregister_netdev(dev);
 	cancel_work_sync(&pep->tx_timeout_task);
 	free_netdev(dev);
-	platform_set_drvdata(pdev, NULL);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/micrel/ks8695net.c b/drivers/net/ethernet/micrel/ks8695net.c
index b6c60fd..106eb97 100644
--- a/drivers/net/ethernet/micrel/ks8695net.c
+++ b/drivers/net/ethernet/micrel/ks8695net.c
@@ -1600,7 +1600,6 @@ ks8695_drv_remove(struct platform_device *pdev)
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct ks8695_priv *ksp = netdev_priv(ndev);
 
-	platform_set_drvdata(pdev, NULL);
 	netif_napi_del(&ksp->napi);
 
 	unregister_netdev(ndev);
diff --git a/drivers/net/ethernet/micrel/ks8842.c b/drivers/net/ethernet/micrel/ks8842.c
index fbcb9e7..e393d99 100644
--- a/drivers/net/ethernet/micrel/ks8842.c
+++ b/drivers/net/ethernet/micrel/ks8842.c
@@ -1250,7 +1250,6 @@ static int ks8842_remove(struct platform_device *pdev)
 	iounmap(adapter->hw_addr);
 	free_netdev(netdev);
 	release_mem_region(iomem->start, resource_size(iomem));
-	platform_set_drvdata(pdev, NULL);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index ddaf138ce..e9b1a83 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -1671,7 +1671,6 @@ static int ks8851_remove(struct platform_device *pdev)
 	iounmap(ks->hw_addr);
 	free_netdev(netdev);
 	release_mem_region(iomem->start, resource_size(iomem));
-	platform_set_drvdata(pdev, NULL);
 	return 0;
 
 }
diff --git a/drivers/net/ethernet/netx-eth.c b/drivers/net/ethernet/netx-eth.c
index 5da3ffb..dc2c6f5 100644
--- a/drivers/net/ethernet/netx-eth.c
+++ b/drivers/net/ethernet/netx-eth.c
@@ -422,7 +422,6 @@ exit_free_pfifo:
 exit_free_xc:
 	free_xc(priv->xc);
 exit_free_netdev:
-	platform_set_drvdata(pdev, NULL);
 	free_netdev(ndev);
 exit:
 	return ret;
diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
index 3df8287..e88bdb1 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -1051,7 +1051,6 @@ failed_put_clk:
 	clk_put(ether->clk);
 failed_free_rxirq:
 	free_irq(ether->rxirq, pdev);
-	platform_set_drvdata(pdev, NULL);
 failed_free_txirq:
 	free_irq(ether->txirq, pdev);
 failed_free_io:
@@ -1080,7 +1079,6 @@ static int w90p910_ether_remove(struct platform_device *pdev)
 	free_irq(ether->rxirq, dev);
 
 	del_timer_sync(&ether->check_timer);
-	platform_set_drvdata(pdev, NULL);
 
 	free_netdev(dev);
 	return 0;
diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 55a5548..a061b93 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -1483,7 +1483,6 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
 	return 0;
 
 err_out_unregister_netdev:
-	platform_set_drvdata(pdev, NULL);
 	unregister_netdev(ndev);
 err_out_dma_unmap:
 	if (!use_iram_for_net(&pldat->pdev->dev) ||
@@ -1511,7 +1510,6 @@ static int lpc_eth_drv_remove(struct platform_device *pdev)
 	struct netdata_local *pldat = netdev_priv(ndev);
 
 	unregister_netdev(ndev);
-	platform_set_drvdata(pdev, NULL);
 
 	if (!use_iram_for_net(&pldat->pdev->dev) ||
 	    pldat->dma_buff_size > lpc32xx_return_iram_size())
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 42e9dd0..399a7c9 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2803,7 +2803,6 @@ static int sh_eth_drv_remove(struct platform_device *pdev)
 	unregister_netdev(ndev);
 	pm_runtime_disable(&pdev->dev);
 	free_netdev(ndev);
-	platform_set_drvdata(pdev, NULL);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/s6gmac.c b/drivers/net/ethernet/s6gmac.c
index b6739af..a99739c 100644
--- a/drivers/net/ethernet/s6gmac.c
+++ b/drivers/net/ethernet/s6gmac.c
@@ -1040,7 +1040,6 @@ static int s6gmac_remove(struct platform_device *pdev)
 		unregister_netdev(dev);
 		free_irq(dev->irq, dev);
 		free_netdev(dev);
-		platform_set_drvdata(pdev, NULL);
 	}
 	return 0;
 }
diff --git a/drivers/net/ethernet/seeq/sgiseeq.c b/drivers/net/ethernet/seeq/sgiseeq.c
index 0ad5694..856e523 100644
--- a/drivers/net/ethernet/seeq/sgiseeq.c
+++ b/drivers/net/ethernet/seeq/sgiseeq.c
@@ -818,7 +818,6 @@ static int __exit sgiseeq_remove(struct platform_device *pdev)
 	dma_free_noncoherent(&pdev->dev, sizeof(*sp->srings), sp->srings,
 			     sp->srings_dma);
 	free_netdev(dev);
-	platform_set_drvdata(pdev, NULL);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/sgi/meth.c b/drivers/net/ethernet/sgi/meth.c
index 4bdbaad9..9f5f35e 100644
--- a/drivers/net/ethernet/sgi/meth.c
+++ b/drivers/net/ethernet/sgi/meth.c
@@ -863,7 +863,6 @@ static int __exit meth_remove(struct platform_device *pdev)
 
 	unregister_netdev(dev);
 	free_netdev(dev);
-	platform_set_drvdata(pdev, NULL);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index 9dd842d..345558f 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -2087,7 +2087,6 @@ static int smc911x_drv_probe(struct platform_device *pdev)
 	ndev->base_addr = res->start;
 	ret = smc911x_probe(ndev);
 	if (ret != 0) {
-		platform_set_drvdata(pdev, NULL);
 		iounmap(addr);
 release_both:
 		free_netdev(ndev);
@@ -2113,7 +2112,6 @@ static int smc911x_drv_remove(struct platform_device *pdev)
 	struct resource *res;
 
 	DBG(SMC_DEBUG_FUNC, "--> %s\n", __func__);
-	platform_set_drvdata(pdev, NULL);
 
 	unregister_netdev(ndev);
 
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index dfbf978..cde13be 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2299,7 +2299,6 @@ static int smc_drv_probe(struct platform_device *pdev)
 	return 0;
 
  out_iounmap:
-	platform_set_drvdata(pdev, NULL);
 	iounmap(addr);
  out_release_attrib:
 	smc_release_attrib(pdev, ndev);
@@ -2319,8 +2318,6 @@ static int smc_drv_remove(struct platform_device *pdev)
 	struct smc_local *lp = netdev_priv(ndev);
 	struct resource *res;
 
-	platform_set_drvdata(pdev, NULL);
-
 	unregister_netdev(ndev);
 
 	free_irq(ndev->irq, ndev);
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 3663b9e..a141921 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2284,7 +2284,6 @@ static int smsc911x_drv_remove(struct platform_device *pdev)
 	mdiobus_unregister(pdata->mii_bus);
 	mdiobus_free(pdata->mii_bus);
 
-	platform_set_drvdata(pdev, NULL);
 	unregister_netdev(dev);
 	free_irq(dev->irq, dev);
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
@@ -2539,7 +2538,6 @@ out_disable_resources:
 out_enable_resources_fail:
 	smsc911x_free_resources(pdev);
 out_request_resources_fail:
-	platform_set_drvdata(pdev, NULL);
 	iounmap(pdata->ioaddr);
 	free_netdev(dev);
 out_release_io_1:
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 1d3780f..17bc782 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -171,8 +171,6 @@ static int stmmac_pltfr_remove(struct platform_device *pdev)
 	if (priv->plat->exit)
 		priv->plat->exit(pdev);
 
-	platform_set_drvdata(pdev, NULL);
-
 	return ret;
 }
 
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 21a5b29..89a4c40 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1940,7 +1940,6 @@ static int cpsw_remove(struct platform_device *pdev)
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	int i;
 
-	platform_set_drvdata(pdev, NULL);
 	if (priv->data.dual_emac)
 		unregister_netdev(cpsw_get_slave_ndev(priv, 1));
 	unregister_netdev(ndev);
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 860e15d..efb6f65 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -2037,8 +2037,6 @@ static int davinci_emac_remove(struct platform_device *pdev)
 
 	dev_notice(&ndev->dev, "DaVinci EMAC: davinci_emac_remove()\n");
 
-	platform_set_drvdata(pdev, NULL);
-
 	if (priv->txchan)
 		cpdma_chan_destroy(priv->txchan);
 	if (priv->rxchan)
diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index 3c69a04..01bdc6c 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -1682,7 +1682,6 @@ static int tsi108_ether_remove(struct platform_device *pdev)
 
 	unregister_netdev(dev);
 	tsi108_stop_ethernet(dev);
-	platform_set_drvdata(pdev, NULL);
 	iounmap(priv->regs);
 	iounmap(priv->phyregs);
 	free_netdev(dev);
diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index a518dca..30fed08 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -734,7 +734,6 @@ err_hw_probe:
 	unregister_netdev(ndev);
 err_register:
 	free_netdev(ndev);
-	platform_set_drvdata(pdev, NULL);
 	return err;
 }
 
@@ -750,7 +749,6 @@ static int w5100_remove(struct platform_device *pdev)
 
 	unregister_netdev(ndev);
 	free_netdev(ndev);
-	platform_set_drvdata(pdev, NULL);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
index 6e00e3f..e928845 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -646,7 +646,6 @@ err_hw_probe:
 	unregister_netdev(ndev);
 err_register:
 	free_netdev(ndev);
-	platform_set_drvdata(pdev, NULL);
 	return err;
 }
 
@@ -662,7 +661,6 @@ static int w5300_remove(struct platform_device *pdev)
 
 	unregister_netdev(ndev);
 	free_netdev(ndev);
-	platform_set_drvdata(pdev, NULL);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index 6958a5e..3d689fc 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -1472,7 +1472,6 @@ err_phy_dis:
 	phy_disconnect(port->phydev);
 err_free_mem:
 	npe_port_tab[NPE_ID(port->id)] = NULL;
-	platform_set_drvdata(pdev, NULL);
 	release_resource(port->mem_res);
 err_npe_rel:
 	npe_release(port->npe);
@@ -1489,7 +1488,6 @@ static int eth_remove_one(struct platform_device *pdev)
 	unregister_netdev(dev);
 	phy_disconnect(port->phydev);
 	npe_port_tab[NPE_ID(port->id)] = NULL;
-	platform_set_drvdata(pdev, NULL);
 	npe_release(port->npe);
 	release_resource(port->mem_res);
 	free_netdev(dev);
-- 
1.7.10.4
