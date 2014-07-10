From: varkabhadram@gmail.com
Subject: [PATCH net v2 6/7] net: cpmac: fix proper spacing before return statement
Date: Thu, 10 Jul 2014 11:05:44 +0530
Message-ID: <1404970545-26508-7-git-send-email-varkabhadram@gmail.com>
References: <1404970545-26508-1-git-send-email-varkabhadram@gmail.com>
Cc: mugunthanvnm@ti.com, linux@rainbow-software.org, balbi@ti.com,
	george.cherian@ti.com, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:44298 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbaGJFhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 01:37:22 -0400
Received: by mail-pd0-f174.google.com with SMTP id y10so10107596pdj.5
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2014 22:37:22 -0700 (PDT)
In-Reply-To: <1404970545-26508-1-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkab@cdac.in>

This patch insert proper spaces before return statement.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/ti/cpmac.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 3d3ead4..b6efe3e 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -283,6 +283,7 @@ static int cpmac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
 		    MDIO_PHY(phy_id));
 	while ((val = cpmac_read(bus->priv, CPMAC_MDIO_ACCESS(0))) & MDIO_BUSY)
 		cpu_relax();
+
 	return MDIO_DATA(val);
 }
 
@@ -293,6 +294,7 @@ static int cpmac_mdio_write(struct mii_bus *bus, int phy_id,
 		cpu_relax();
 	cpmac_write(bus->priv, CPMAC_MDIO_ACCESS(0), MDIO_BUSY | MDIO_WRITE |
 		    MDIO_REG(reg) | MDIO_PHY(phy_id) | MDIO_DATA(val));
+
 	return 0;
 }
 
@@ -308,6 +310,7 @@ static int cpmac_mdio_reset(struct mii_bus *bus)
 	ar7_device_reset(AR7_RESET_BIT_MDIO);
 	cpmac_write(bus->priv, CPMAC_MDIO_CONTROL, MDIOC_ENABLE |
 		    MDIOC_CLKDIV(clk_get_rate(cpmac_clk) / 2200000 - 1));
+
 	return 0;
 }
 
@@ -537,6 +540,7 @@ fatal_error:
 	cpmac_hw_stop(priv->dev);
 	if (!schedule_work(&priv->reset_work))
 		atomic_dec(&priv->reset_pending);
+
 	return 0;
 
 }
@@ -883,6 +887,7 @@ static int cpmac_set_ringparam(struct net_device *dev,
 	if (netif_running(dev))
 		return -EBUSY;
 	priv->ring_size = ring->rx_pending;
+
 	return 0;
 }
 
@@ -1076,6 +1081,7 @@ static int cpmac_stop(struct net_device *dev)
 	dma_free_coherent(&dev->dev, sizeof(struct cpmac_desc) *
 			  (CPMAC_QUEUES + priv->ring_size),
 			  priv->desc_ring, priv->dma_ring);
+
 	return 0;
 }
 
@@ -1178,6 +1184,7 @@ static int cpmac_probe(struct platform_device *pdev)
 			 "mac: %pM\n", (void *)mem->start, dev->irq,
 			 priv->phy_name, dev->dev_addr);
 	}
+
 	return 0;
 
 fail:
@@ -1191,6 +1198,7 @@ static int cpmac_remove(struct platform_device *pdev)
 
 	unregister_netdev(dev);
 	free_netdev(dev);
+
 	return 0;
 }
 
-- 
1.7.9.5
