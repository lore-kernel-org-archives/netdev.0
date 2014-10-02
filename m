From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: ethernet: Remove superfluous ether_setup after alloc_etherdev
Date: Thu,  2 Oct 2014 10:15:30 +0200
Message-ID: <1412237730-5811-1-git-send-email-tklauser@distanz.ch>
Cc: Maxime Ripard <maxime.ripard@free-electrons.com>,
	Vince Bridgers <vbridgers2013@gmail.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Nicolas Pitre <nico@fluxnic.net>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:57025 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750954AbaJBIPy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 04:15:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to call ether_setup after alloc_ethdev since it was
already called there.

Follow commits c706471b2601 ("net: axienet: remove unnecessary
ether_setup after alloc_etherdev") and 3c87dcbfb36c ("net: ll_temac:
Remove unnecessary ether_setup after alloc_etherdev") and fix the
pattern in all remaining ethernet drivers.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/adi/bfin_mac.c               | 3 ---
 drivers/net/ethernet/allwinner/sun4i-emac.c       | 2 --
 drivers/net/ethernet/altera/altera_tse_main.c     | 1 -
 drivers/net/ethernet/cadence/at91_ether.c         | 1 -
 drivers/net/ethernet/calxeda/xgmac.c              | 1 -
 drivers/net/ethernet/davicom/dm9000.c             | 3 ---
 drivers/net/ethernet/ethoc.c                      | 2 --
 drivers/net/ethernet/lantiq_etop.c                | 1 -
 drivers/net/ethernet/moxa/moxart_ether.c          | 1 -
 drivers/net/ethernet/netx-eth.c                   | 2 --
 drivers/net/ethernet/nuvoton/w90p910_ether.c      | 1 -
 drivers/net/ethernet/nxp/lpc_eth.c                | 3 ---
 drivers/net/ethernet/qualcomm/qca_spi.c           | 2 --
 drivers/net/ethernet/smsc/smc911x.c               | 3 ---
 drivers/net/ethernet/smsc/smc91x.c                | 3 ---
 drivers/net/ethernet/smsc/smsc911x.c              | 1 -
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 --
 drivers/net/ethernet/wiznet/w5100.c               | 1 -
 drivers/net/ethernet/wiznet/w5300.c               | 1 -
 19 files changed, 34 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index afa6684..8ed4d340 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1692,9 +1692,6 @@ static int bfin_mac_probe(struct platform_device *pdev)
 	lp->vlan1_mask = ETH_P_8021Q | mii_bus_data->vlan1_mask;
 	lp->vlan2_mask = ETH_P_8021Q | mii_bus_data->vlan2_mask;
 
-	/* Fill in the fields of the device structure with ethernet values. */
-	ether_setup(ndev);
-
 	ndev->netdev_ops = &bfin_mac_netdev_ops;
 	ndev->ethtool_ops = &bfin_mac_ethtool_ops;
 
diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index 29b9f08..1fcd556 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -878,8 +878,6 @@ static int emac_probe(struct platform_device *pdev)
 	emac_powerup(ndev);
 	emac_reset(db);
 
-	ether_setup(ndev);
-
 	ndev->netdev_ops = &emac_netdev_ops;
 	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
 	ndev->ethtool_ops = &emac_ethtool_ops;
diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index 7330681..fc2d555 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -1433,7 +1433,6 @@ static int altera_tse_probe(struct platform_device *pdev)
 		goto err_free_netdev;
 
 	/* initialize netdev */
-	ether_setup(ndev);
 	ndev->mem_start = control_port->start;
 	ndev->mem_end = control_port->end;
 	ndev->netdev_ops = &altera_tse_netdev_ops;
diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 4a79eda..4a24b9a 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -351,7 +351,6 @@ static int __init at91ether_probe(struct platform_device *pdev)
 	if (res)
 		goto err_disable_clock;
 
-	ether_setup(dev);
 	dev->netdev_ops = &at91ether_netdev_ops;
 	dev->ethtool_ops = &macb_ethtool_ops;
 	platform_set_drvdata(pdev, dev);
diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 25d6b2a..47bfea2 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -1735,7 +1735,6 @@ static int xgmac_probe(struct platform_device *pdev)
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 	priv = netdev_priv(ndev);
 	platform_set_drvdata(pdev, ndev);
-	ether_setup(ndev);
 	ndev->netdev_ops = &xgmac_netdev_ops;
 	ndev->ethtool_ops = &xgmac_ethtool_ops;
 	spin_lock_init(&priv->stats_lock);
diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 70089c2..f3ba840 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1613,9 +1613,6 @@ dm9000_probe(struct platform_device *pdev)
 
 	/* from this point we assume that we have found a DM9000 */
 
-	/* driver system function */
-	ether_setup(ndev);
-
 	ndev->netdev_ops	= &dm9000_netdev_ops;
 	ndev->watchdog_timeo	= msecs_to_jiffies(watchdog);
 	ndev->ethtool_ops	= &dm9000_ethtool_ops;
diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index f3658bd..0bc6c10 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -1222,8 +1222,6 @@ static int ethoc_probe(struct platform_device *pdev)
 		goto error;
 	}
 
-	ether_setup(netdev);
-
 	/* setup the net_device structure */
 	netdev->netdev_ops = &ethoc_netdev_ops;
 	netdev->watchdog_timeo = ETHOC_TIMEOUT;
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index fd4b6ae..2dad4d5 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -633,7 +633,6 @@ ltq_etop_init(struct net_device *dev)
 	int err;
 	bool random_mac = false;
 
-	ether_setup(dev);
 	dev->watchdog_timeo = 10 * HZ;
 	err = ltq_etop_hw_init(dev);
 	if (err)
diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 2f12c88..bde1b70 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -511,7 +511,6 @@ static int moxart_mac_probe(struct platform_device *pdev)
 		goto init_fail;
 	}
 
-	ether_setup(ndev);
 	ndev->netdev_ops = &moxart_netdev_ops;
 	netif_napi_add(ndev, &priv->napi, moxart_rx_poll, RX_DESC_NUM);
 	ndev->priv_flags |= IFF_UNICAST_FLT;
diff --git a/drivers/net/ethernet/netx-eth.c b/drivers/net/ethernet/netx-eth.c
index 31eb911..8176c8a 100644
--- a/drivers/net/ethernet/netx-eth.c
+++ b/drivers/net/ethernet/netx-eth.c
@@ -315,8 +315,6 @@ static int netx_eth_enable(struct net_device *ndev)
 	unsigned int mac4321, mac65;
 	int running, i;
 
-	ether_setup(ndev);
-
 	ndev->netdev_ops = &netx_eth_netdev_ops;
 	ndev->watchdog_timeo = msecs_to_jiffies(5000);
 
diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
index 79645f7..379b7fb 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -943,7 +943,6 @@ static int w90p910_ether_setup(struct net_device *dev)
 {
 	struct w90p910_ether *ether = netdev_priv(dev);
 
-	ether_setup(dev);
 	dev->netdev_ops = &w90p910_ether_netdev_ops;
 	dev->ethtool_ops = &w90p910_ether_ethtool_ops;
 
diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index a44a03c..66fd868 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -1377,9 +1377,6 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
 		goto err_out_iounmap;
 	}
 
-	/* Fill in the fields of the device structure with ethernet values. */
-	ether_setup(ndev);
-
 	/* Setup driver functions */
 	ndev->netdev_ops = &lpc_netdev_ops;
 	ndev->ethtool_ops = &lpc_eth_ethtool_ops;
diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index 74eb520..2c811f6 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -810,8 +810,6 @@ qcaspi_netdev_setup(struct net_device *dev)
 {
 	struct qcaspi *qca = NULL;
 
-	ether_setup(dev);
-
 	dev->netdev_ops = &qcaspi_netdev_ops;
 	qcaspi_set_ethtool_ops(dev);
 	dev->watchdog_timeo = QCASPI_TX_TIMEOUT;
diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index 9778cba..e88df9c 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -1927,9 +1927,6 @@ static int smc911x_probe(struct net_device *dev)
 	}
 	dev->irq = irq_canonicalize(dev->irq);
 
-	/* Fill in the fields of the device structure with ethernet values. */
-	ether_setup(dev);
-
 	dev->netdev_ops = &smc911x_netdev_ops;
 	dev->watchdog_timeo = msecs_to_jiffies(watchdog);
 	dev->ethtool_ops = &smc911x_ethtool_ops;
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index bcaa41a..5e94d00 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -1967,9 +1967,6 @@ static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
 	}
 	dev->irq = irq_canonicalize(dev->irq);
 
-	/* Fill in the fields of the device structure with ethernet values. */
-	ether_setup(dev);
-
 	dev->watchdog_timeo = msecs_to_jiffies(watchdog);
 	dev->netdev_ops = &smc_netdev_ops;
 	dev->ethtool_ops = &smc_ethtool_ops;
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 5e13fa5..affb29d 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2255,7 +2255,6 @@ static int smsc911x_init(struct net_device *dev)
 	if (smsc911x_soft_reset(pdata))
 		return -ENODEV;
 
-	ether_setup(dev);
 	dev->flags |= IFF_MULTICAST;
 	netif_napi_add(dev, &pdata->napi, smsc911x_poll, SMSC_NAPI_WEIGHT);
 	dev->netdev_ops = &smsc911x_netdev_ops;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 9979f67..6f77a46 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2765,8 +2765,6 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 	priv->device = device;
 	priv->dev = ndev;
 
-	ether_setup(ndev);
-
 	stmmac_set_ethtool_ops(ndev);
 	priv->pause = pause;
 	priv->plat = plat_dat;
diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index 104d46f..0f56b1c 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -708,7 +708,6 @@ static int w5100_probe(struct platform_device *pdev)
 	priv = netdev_priv(ndev);
 	priv->ndev = ndev;
 
-	ether_setup(ndev);
 	ndev->netdev_ops = &w5100_netdev_ops;
 	ndev->ethtool_ops = &w5100_ethtool_ops;
 	ndev->watchdog_timeo = HZ;
diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
index 1f33c4c..f961f14 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -620,7 +620,6 @@ static int w5300_probe(struct platform_device *pdev)
 	priv = netdev_priv(ndev);
 	priv->ndev = ndev;
 
-	ether_setup(ndev);
 	ndev->netdev_ops = &w5300_netdev_ops;
 	ndev->ethtool_ops = &w5300_ethtool_ops;
 	ndev->watchdog_timeo = HZ;
-- 
2.0.1
