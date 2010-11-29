From: Joe Perches <joe@perches.com>
Subject: [PATCH 06/11] forcedeth: Convert pr_<level> to netdev_<level>
Date: Mon, 29 Nov 2010 09:41:57 -0800
Message-ID: <14d7a26428c55bac45d07a41bba4d423dbaee883.1291051316.git.joe@perches.com>
References: <cover.1291051316.git.joe@perches.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Szymon Janc <szymon@janc.net.pl>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirqus@gmail.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1957 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755409Ab0K2RmL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Nov 2010 12:42:11 -0500
In-Reply-To: <cover.1291051316.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_<level> when a struct net_device * is available.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/forcedeth.c |  293 ++++++++++++++++++++++++++---------------------
 1 files changed, 161 insertions(+), 132 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 1c6f4ef9..c3a9783 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1192,8 +1192,8 @@ static int phy_init(struct net_device *dev)
 		reg = mii_rw(dev, np->phyaddr, MII_NCONFIG, MII_READ);
 		reg &= ~PHY_MARVELL_E3016_INITMASK;
 		if (mii_rw(dev, np->phyaddr, MII_NCONFIG, reg)) {
-			pr_info("%s: phy write to errata reg failed\n",
-				pci_name(np->pci_dev));
+			netdev_info(dev, "%s: phy write to errata reg failed\n",
+				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 	}
@@ -1201,38 +1201,38 @@ static int phy_init(struct net_device *dev)
 		if (np->phy_model == PHY_MODEL_REALTEK_8211 &&
 		    np->phy_rev == PHY_REV_REALTEK_8211B) {
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
-				pr_info("%s: phy init failed\n",
-					pci_name(np->pci_dev));
+				netdev_info(dev, "%s: phy init failed\n",
+					    pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, PHY_REALTEK_INIT2)) {
-				pr_info("%s: phy init failed\n",
-					pci_name(np->pci_dev));
+				netdev_info(dev, "%s: phy init failed\n",
+					    pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT3)) {
-				pr_info("%s: phy init failed\n",
-					pci_name(np->pci_dev));
+				netdev_info(dev, "%s: phy init failed\n",
+					    pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG3, PHY_REALTEK_INIT4)) {
-				pr_info("%s: phy init failed\n",
-					pci_name(np->pci_dev));
+				netdev_info(dev, "%s: phy init failed\n",
+					    pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG4, PHY_REALTEK_INIT5)) {
-				pr_info("%s: phy init failed\n",
-					pci_name(np->pci_dev));
+				netdev_info(dev, "%s: phy init failed\n",
+					    pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG5, PHY_REALTEK_INIT6)) {
-				pr_info("%s: phy init failed\n",
-					pci_name(np->pci_dev));
+				netdev_info(dev, "%s: phy init failed\n",
+					    pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
-				pr_info("%s: phy init failed\n",
-					pci_name(np->pci_dev));
+				netdev_info(dev, "%s: phy init failed\n",
+					    pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 		}
@@ -1252,27 +1252,27 @@ static int phy_init(struct net_device *dev)
 			reg = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, MII_READ);
 			reg |= PHY_REALTEK_INIT9;
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, reg)) {
-				pr_info("%s: phy init failed\n",
-					pci_name(np->pci_dev));
+				netdev_info(dev, "%s: phy init failed\n",
+					    pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT10)) {
-				pr_info("%s: phy init failed\n",
-					pci_name(np->pci_dev));
+				netdev_info(dev, "%s: phy init failed\n",
+					    pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			reg = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG7, MII_READ);
 			if (!(reg & PHY_REALTEK_INIT11)) {
 				reg |= PHY_REALTEK_INIT11;
 				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG7, reg)) {
-					pr_info("%s: phy init failed\n",
-						pci_name(np->pci_dev));
+					netdev_info(dev, "%s: phy init failed\n",
+						    pci_name(np->pci_dev));
 					return PHY_ERROR;
 				}
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
-				pr_info("%s: phy init failed\n",
-					pci_name(np->pci_dev));
+				netdev_info(dev, "%s: phy init failed\n",
+					    pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 		}
@@ -1281,8 +1281,8 @@ static int phy_init(struct net_device *dev)
 				phy_reserved = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, MII_READ);
 				phy_reserved |= PHY_REALTEK_INIT7;
 				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, phy_reserved)) {
-					pr_info("%s: phy init failed\n",
-						pci_name(np->pci_dev));
+					netdev_info(dev, "%s: phy init failed\n",
+						    pci_name(np->pci_dev));
 					return PHY_ERROR;
 				}
 			}
@@ -1293,8 +1293,8 @@ static int phy_init(struct net_device *dev)
 	reg = mii_rw(dev, np->phyaddr, MII_ADVERTISE, MII_READ);
 	reg |= (ADVERTISE_10HALF|ADVERTISE_10FULL|ADVERTISE_100HALF|ADVERTISE_100FULL|ADVERTISE_PAUSE_ASYM|ADVERTISE_PAUSE_CAP);
 	if (mii_rw(dev, np->phyaddr, MII_ADVERTISE, reg)) {
-		pr_info("%s: phy write to advertise failed\n",
-			pci_name(np->pci_dev));
+		netdev_info(dev, "%s: phy write to advertise failed\n",
+			    pci_name(np->pci_dev));
 		return PHY_ERROR;
 	}
 
@@ -1313,7 +1313,8 @@ static int phy_init(struct net_device *dev)
 			mii_control_1000 &= ~ADVERTISE_1000FULL;
 
 		if (mii_rw(dev, np->phyaddr, MII_CTRL1000, mii_control_1000)) {
-			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
+			netdev_info(dev, "%s: phy init failed\n",
+				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 	} else
@@ -1328,7 +1329,8 @@ static int phy_init(struct net_device *dev)
 		/* start autoneg since we already performed hw reset above */
 		mii_control |= BMCR_ANRESTART;
 		if (mii_rw(dev, np->phyaddr, MII_BMCR, mii_control)) {
-			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
+			netdev_info(dev, "%s: phy init failed\n",
+				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 	} else {
@@ -1336,7 +1338,8 @@ static int phy_init(struct net_device *dev)
 		 * (certain phys need bmcr to be setup with reset)
 		 */
 		if (phy_reset(dev, mii_control)) {
-			pr_info("%s: phy reset failed\n", pci_name(np->pci_dev));
+			netdev_info(dev, "%s: phy reset failed\n",
+				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 	}
@@ -1347,13 +1350,15 @@ static int phy_init(struct net_device *dev)
 		phy_reserved &= ~(PHY_CICADA_INIT1 | PHY_CICADA_INIT2);
 		phy_reserved |= (PHY_CICADA_INIT3 | PHY_CICADA_INIT4);
 		if (mii_rw(dev, np->phyaddr, MII_RESV1, phy_reserved)) {
-			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
+			netdev_info(dev, "%s: phy init failed\n",
+				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		phy_reserved = mii_rw(dev, np->phyaddr, MII_NCONFIG, MII_READ);
 		phy_reserved |= PHY_CICADA_INIT5;
 		if (mii_rw(dev, np->phyaddr, MII_NCONFIG, phy_reserved)) {
-			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
+			netdev_info(dev, "%s: phy init failed\n",
+				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 	}
@@ -1361,77 +1366,92 @@ static int phy_init(struct net_device *dev)
 		phy_reserved = mii_rw(dev, np->phyaddr, MII_SREVISION, MII_READ);
 		phy_reserved |= PHY_CICADA_INIT6;
 		if (mii_rw(dev, np->phyaddr, MII_SREVISION, phy_reserved)) {
-			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
+			netdev_info(dev, "%s: phy init failed\n",
+				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 	}
 	if (np->phy_oui == PHY_OUI_VITESSE) {
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG1, PHY_VITESSE_INIT1)) {
-			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
+			netdev_info(dev, "%s: phy init failed\n",
+				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT2)) {
-			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
+			netdev_info(dev, "%s: phy init failed\n",
+				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, MII_READ);
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, phy_reserved)) {
-			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
+			netdev_info(dev, "%s: phy init failed\n",
+				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, MII_READ);
 		phy_reserved &= ~PHY_VITESSE_INIT_MSK1;
 		phy_reserved |= PHY_VITESSE_INIT3;
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, phy_reserved)) {
-			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
+			netdev_info(dev, "%s: phy init failed\n",
+				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT4)) {
-			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
+			netdev_info(dev, "%s: phy init failed\n",
+				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT5)) {
-			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
+			netdev_info(dev, "%s: phy init failed\n",
+				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, MII_READ);
 		phy_reserved &= ~PHY_VITESSE_INIT_MSK1;
 		phy_reserved |= PHY_VITESSE_INIT3;
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, phy_reserved)) {
-			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
+			netdev_info(dev, "%s: phy init failed\n",
+				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, MII_READ);
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, phy_reserved)) {
-			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
+			netdev_info(dev, "%s: phy init failed\n",
+				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT6)) {
-			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
+			netdev_info(dev, "%s: phy init failed\n",
+				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT7)) {
-			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
+			netdev_info(dev, "%s: phy init failed\n",
+				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, MII_READ);
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, phy_reserved)) {
-			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
+			netdev_info(dev, "%s: phy init failed\n",
+				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, MII_READ);
 		phy_reserved &= ~PHY_VITESSE_INIT_MSK2;
 		phy_reserved |= PHY_VITESSE_INIT8;
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, phy_reserved)) {
-			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
+			netdev_info(dev, "%s: phy init failed\n",
+				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT9)) {
-			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
+			netdev_info(dev, "%s: phy init failed\n",
+				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG1, PHY_VITESSE_INIT10)) {
-			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
+			netdev_info(dev, "%s: phy init failed\n",
+				    pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 	}
@@ -1440,38 +1460,38 @@ static int phy_init(struct net_device *dev)
 		    np->phy_rev == PHY_REV_REALTEK_8211B) {
 			/* reset could have cleared these out, set them back */
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
-				pr_info("%s: phy init failed\n",
-					pci_name(np->pci_dev));
+				netdev_info(dev, "%s: phy init failed\n",
+					    pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, PHY_REALTEK_INIT2)) {
-				pr_info("%s: phy init failed\n",
-					pci_name(np->pci_dev));
+				netdev_info(dev, "%s: phy init failed\n",
+					    pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT3)) {
-				pr_info("%s: phy init failed\n",
-					pci_name(np->pci_dev));
+				netdev_info(dev, "%s: phy init failed\n",
+					    pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG3, PHY_REALTEK_INIT4)) {
-				pr_info("%s: phy init failed\n",
-					pci_name(np->pci_dev));
+				netdev_info(dev, "%s: phy init failed\n",
+					    pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG4, PHY_REALTEK_INIT5)) {
-				pr_info("%s: phy init failed\n",
-					pci_name(np->pci_dev));
+				netdev_info(dev, "%s: phy init failed\n",
+					    pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG5, PHY_REALTEK_INIT6)) {
-				pr_info("%s: phy init failed\n",
-					pci_name(np->pci_dev));
+				netdev_info(dev, "%s: phy init failed\n",
+					    pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
-				pr_info("%s: phy init failed\n",
-					pci_name(np->pci_dev));
+				netdev_info(dev, "%s: phy init failed\n",
+					    pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 		}
@@ -1480,28 +1500,28 @@ static int phy_init(struct net_device *dev)
 				phy_reserved = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, MII_READ);
 				phy_reserved |= PHY_REALTEK_INIT7;
 				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, phy_reserved)) {
-					pr_info("%s: phy init failed\n",
-						pci_name(np->pci_dev));
+					netdev_info(dev, "%s: phy init failed\n",
+						    pci_name(np->pci_dev));
 					return PHY_ERROR;
 				}
 			}
 			if (phy_cross == NV_CROSSOVER_DETECTION_DISABLED) {
 				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT3)) {
-					pr_info("%s: phy init failed\n",
-						pci_name(np->pci_dev));
+					netdev_info(dev, "%s: phy init failed\n",
+						    pci_name(np->pci_dev));
 					return PHY_ERROR;
 				}
 				phy_reserved = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, MII_READ);
 				phy_reserved &= ~PHY_REALTEK_INIT_MSK1;
 				phy_reserved |= PHY_REALTEK_INIT3;
 				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, phy_reserved)) {
-					pr_info("%s: phy init failed\n",
-						pci_name(np->pci_dev));
+					netdev_info(dev, "%s: phy init failed\n",
+						    pci_name(np->pci_dev));
 					return PHY_ERROR;
 				}
 				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
-					pr_info("%s: phy init failed\n",
-						pci_name(np->pci_dev));
+					netdev_info(dev, "%s: phy init failed\n",
+						    pci_name(np->pci_dev));
 					return PHY_ERROR;
 				}
 			}
@@ -1560,7 +1580,8 @@ static void nv_stop_rx(struct net_device *dev)
 	writel(rx_ctrl, base + NvRegReceiverControl);
 	if (reg_delay(dev, NvRegReceiverStatus, NVREG_RCVSTAT_BUSY, 0,
 		      NV_RXSTOP_DELAY1, NV_RXSTOP_DELAY1MAX))
-		pr_info("%s: ReceiverStatus remained busy\n", __func__);
+		netdev_info(dev, "%s: ReceiverStatus remained busy\n",
+			    __func__);
 
 	udelay(NV_RXSTOP_DELAY2);
 	if (!np->mac_in_use)
@@ -1595,7 +1616,8 @@ static void nv_stop_tx(struct net_device *dev)
 	writel(tx_ctrl, base + NvRegTransmitterControl);
 	if (reg_delay(dev, NvRegTransmitterStatus, NVREG_XMITSTAT_BUSY, 0,
 		      NV_TXSTOP_DELAY1, NV_TXSTOP_DELAY1MAX))
-		pr_info("%s: TransmitterStatus remained busy\n", __func__);
+		netdev_info(dev, "%s: TransmitterStatus remained busy\n",
+			    __func__);
 
 	udelay(NV_TXSTOP_DELAY2);
 	if (!np->mac_in_use)
@@ -2520,46 +2542,49 @@ static void nv_tx_timeout(struct net_device *dev)
 	else
 		status = readl(base + NvRegIrqStatus) & NVREG_IRQSTAT_MASK;
 
-	pr_info("%s: Got tx_timeout. irq: %08x\n", dev->name, status);
+	netdev_info(dev, "Got tx_timeout. irq: %08x\n", status);
 
-	pr_info("%s: Ring at %lx\n", dev->name, (unsigned long)np->ring_addr);
-	pr_info("%s: Dumping tx registers\n", dev->name);
+	netdev_info(dev, "Ring at %lx\n", (unsigned long)np->ring_addr);
+	netdev_info(dev, "Dumping tx registers\n");
 	for (i = 0; i <= np->register_size; i += 32) {
-		pr_info("%3x: %08x %08x %08x %08x %08x %08x %08x %08x\n",
-			i,
-			readl(base + i + 0), readl(base + i + 4),
-			readl(base + i + 8), readl(base + i + 12),
-			readl(base + i + 16), readl(base + i + 20),
-			readl(base + i + 24), readl(base + i + 28));
-	}
-	pr_info("%s: Dumping tx ring\n", dev->name);
+		netdev_info(dev,
+			    "%3x: %08x %08x %08x %08x %08x %08x %08x %08x\n",
+			    i,
+			    readl(base + i + 0), readl(base + i + 4),
+			    readl(base + i + 8), readl(base + i + 12),
+			    readl(base + i + 16), readl(base + i + 20),
+			    readl(base + i + 24), readl(base + i + 28));
+	}
+	netdev_info(dev, "Dumping tx ring\n");
 	for (i = 0; i < np->tx_ring_size; i += 4) {
 		if (!nv_optimized(np)) {
-			pr_info("%03x: %08x %08x // %08x %08x // %08x %08x // %08x %08x\n",
-				i,
-				le32_to_cpu(np->tx_ring.orig[i].buf),
-				le32_to_cpu(np->tx_ring.orig[i].flaglen),
-				le32_to_cpu(np->tx_ring.orig[i+1].buf),
-				le32_to_cpu(np->tx_ring.orig[i+1].flaglen),
-				le32_to_cpu(np->tx_ring.orig[i+2].buf),
-				le32_to_cpu(np->tx_ring.orig[i+2].flaglen),
-				le32_to_cpu(np->tx_ring.orig[i+3].buf),
-				le32_to_cpu(np->tx_ring.orig[i+3].flaglen));
+			netdev_info(dev,
+				    "%03x: %08x %08x // %08x %08x // %08x %08x // %08x %08x\n",
+				    i,
+				    le32_to_cpu(np->tx_ring.orig[i].buf),
+				    le32_to_cpu(np->tx_ring.orig[i].flaglen),
+				    le32_to_cpu(np->tx_ring.orig[i+1].buf),
+				    le32_to_cpu(np->tx_ring.orig[i+1].flaglen),
+				    le32_to_cpu(np->tx_ring.orig[i+2].buf),
+				    le32_to_cpu(np->tx_ring.orig[i+2].flaglen),
+				    le32_to_cpu(np->tx_ring.orig[i+3].buf),
+				    le32_to_cpu(np->tx_ring.orig[i+3].flaglen));
 		} else {
-			pr_info("%03x: %08x %08x %08x // %08x %08x %08x // %08x %08x %08x // %08x %08x %08x\n",
-				i,
-				le32_to_cpu(np->tx_ring.ex[i].bufhigh),
-				le32_to_cpu(np->tx_ring.ex[i].buflow),
-				le32_to_cpu(np->tx_ring.ex[i].flaglen),
-				le32_to_cpu(np->tx_ring.ex[i+1].bufhigh),
-				le32_to_cpu(np->tx_ring.ex[i+1].buflow),
-				le32_to_cpu(np->tx_ring.ex[i+1].flaglen),
-				le32_to_cpu(np->tx_ring.ex[i+2].bufhigh),
-				le32_to_cpu(np->tx_ring.ex[i+2].buflow),
-				le32_to_cpu(np->tx_ring.ex[i+2].flaglen),
-				le32_to_cpu(np->tx_ring.ex[i+3].bufhigh),
-				le32_to_cpu(np->tx_ring.ex[i+3].buflow),
-				le32_to_cpu(np->tx_ring.ex[i+3].flaglen));
+			netdev_info(dev,
+				    "%03x: %08x %08x %08x // %08x %08x %08x // %08x %08x %08x // %08x %08x %08x\n",
+				    i,
+				    le32_to_cpu(np->tx_ring.ex[i].bufhigh),
+				    le32_to_cpu(np->tx_ring.ex[i].buflow),
+				    le32_to_cpu(np->tx_ring.ex[i].flaglen),
+				    le32_to_cpu(np->tx_ring.ex[i+1].bufhigh),
+				    le32_to_cpu(np->tx_ring.ex[i+1].buflow),
+				    le32_to_cpu(np->tx_ring.ex[i+1].flaglen),
+				    le32_to_cpu(np->tx_ring.ex[i+2].bufhigh),
+				    le32_to_cpu(np->tx_ring.ex[i+2].buflow),
+				    le32_to_cpu(np->tx_ring.ex[i+2].flaglen),
+				    le32_to_cpu(np->tx_ring.ex[i+3].bufhigh),
+				    le32_to_cpu(np->tx_ring.ex[i+3].buflow),
+				    le32_to_cpu(np->tx_ring.ex[i+3].flaglen));
 		}
 	}
 
@@ -3332,14 +3357,14 @@ static void nv_linkchange(struct net_device *dev)
 	if (nv_update_linkspeed(dev)) {
 		if (!netif_carrier_ok(dev)) {
 			netif_carrier_on(dev);
-			pr_info("%s: link up\n", dev->name);
+			netdev_info(dev, "link up\n");
 			nv_txrx_gate(dev, false);
 			nv_start_rx(dev);
 		}
 	} else {
 		if (netif_carrier_ok(dev)) {
 			netif_carrier_off(dev);
-			pr_info("%s: link down\n", dev->name);
+			netdev_info(dev, "link down\n");
 			nv_txrx_gate(dev, true);
 			nv_stop_rx(dev);
 		}
@@ -3788,8 +3813,9 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 				sprintf(np->name_rx, "%s-rx", dev->name);
 				if (request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector,
 						nv_nic_irq_rx, IRQF_SHARED, np->name_rx, dev) != 0) {
-					pr_info("request_irq failed for rx %d\n",
-						ret);
+					netdev_info(dev,
+						    "request_irq failed for rx %d\n",
+						    ret);
 					pci_disable_msix(np->pci_dev);
 					np->msi_flags &= ~NV_MSI_X_ENABLED;
 					goto out_err;
@@ -3798,8 +3824,9 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 				sprintf(np->name_tx, "%s-tx", dev->name);
 				if (request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_TX].vector,
 						nv_nic_irq_tx, IRQF_SHARED, np->name_tx, dev) != 0) {
-					pr_info("request_irq failed for tx %d\n",
-						ret);
+					netdev_info(dev,
+						    "request_irq failed for tx %d\n",
+						    ret);
 					pci_disable_msix(np->pci_dev);
 					np->msi_flags &= ~NV_MSI_X_ENABLED;
 					goto out_free_rx;
@@ -3808,8 +3835,9 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 				sprintf(np->name_other, "%s-other", dev->name);
 				if (request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_OTHER].vector,
 						nv_nic_irq_other, IRQF_SHARED, np->name_other, dev) != 0) {
-					pr_info("request_irq failed for link %d\n",
-						ret);
+					netdev_info(dev,
+						    "request_irq failed for link %d\n",
+						    ret);
 					pci_disable_msix(np->pci_dev);
 					np->msi_flags &= ~NV_MSI_X_ENABLED;
 					goto out_free_tx;
@@ -3823,7 +3851,9 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 			} else {
 				/* Request irq for all interrupts */
 				if (request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector, handler, IRQF_SHARED, dev->name, dev) != 0) {
-					pr_info("request_irq failed %d\n", ret);
+					netdev_info(dev,
+						    "request_irq failed %d\n",
+						    ret);
 					pci_disable_msix(np->pci_dev);
 					np->msi_flags &= ~NV_MSI_X_ENABLED;
 					goto out_err;
@@ -3841,7 +3871,8 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 			np->msi_flags |= NV_MSI_ENABLED;
 			dev->irq = np->pci_dev->irq;
 			if (request_irq(np->pci_dev->irq, handler, IRQF_SHARED, dev->name, dev) != 0) {
-				pr_info("request_irq failed %d\n", ret);
+				netdev_info(dev, "request_irq failed %d\n",
+					    ret);
 				pci_disable_msi(np->pci_dev);
 				np->msi_flags &= ~NV_MSI_ENABLED;
 				dev->irq = np->pci_dev->irq;
@@ -3926,7 +3957,7 @@ static void nv_do_nic_poll(unsigned long data)
 
 	if (np->recover_error) {
 		np->recover_error = 0;
-		pr_info("%s: MAC in recoverable error state\n", dev->name);
+		netdev_info(dev, "MAC in recoverable error state\n");
 		if (netif_running(dev)) {
 			netif_tx_lock_bh(dev);
 			netif_addr_lock(dev);
@@ -4222,14 +4253,14 @@ static int nv_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		}
 
 		if (netif_running(dev))
-			pr_info("%s: link down\n", dev->name);
+			netdev_info(dev, "link down\n");
 		bmcr = mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ);
 		if (np->phy_model == PHY_MODEL_MARVELL_E3016) {
 			bmcr |= BMCR_ANENABLE;
 			/* reset the phy in order for settings to stick,
 			 * and cause autoneg to start */
 			if (phy_reset(dev, bmcr)) {
-				pr_info("%s: phy reset failed\n", dev->name);
+				netdev_info(dev, "phy reset failed\n");
 				return -EINVAL;
 			}
 		} else {
@@ -4278,7 +4309,7 @@ static int nv_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		if (np->phy_oui == PHY_OUI_MARVELL) {
 			/* reset the phy in order for forced mode settings to stick */
 			if (phy_reset(dev, bmcr)) {
-				pr_info("%s: phy reset failed\n", dev->name);
+				netdev_info(dev, "phy reset failed\n");
 				return -EINVAL;
 			}
 		} else {
@@ -4340,7 +4371,7 @@ static int nv_nway_reset(struct net_device *dev)
 			spin_unlock(&np->lock);
 			netif_addr_unlock(dev);
 			netif_tx_unlock_bh(dev);
-			pr_info("%s: link down\n", dev->name);
+			netdev_info(dev, "link down\n");
 		}
 
 		bmcr = mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ);
@@ -4348,7 +4379,7 @@ static int nv_nway_reset(struct net_device *dev)
 			bmcr |= BMCR_ANENABLE;
 			/* reset the phy in order for settings to stick*/
 			if (phy_reset(dev, bmcr)) {
-				pr_info("%s: phy reset failed\n", dev->name);
+				netdev_info(dev, "phy reset failed\n");
 				return -EINVAL;
 			}
 		} else {
@@ -4521,13 +4552,11 @@ static int nv_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam*
 
 	if ((!np->autoneg && np->duplex == 0) ||
 	    (np->autoneg && !pause->autoneg && np->duplex == 0)) {
-		pr_info("%s: can not set pause settings when forced link is in half duplex\n",
-			dev->name);
+		netdev_info(dev, "can not set pause settings when forced link is in half duplex\n");
 		return -EINVAL;
 	}
 	if (pause->tx_pause && !(np->pause_flags & NV_PAUSEFRAME_TX_CAPABLE)) {
-		pr_info("%s: hardware does not support tx pause frames\n",
-			dev->name);
+		netdev_info(dev, "hardware does not support tx pause frames\n");
 		return -EINVAL;
 	}
 
@@ -4562,7 +4591,7 @@ static int nv_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam*
 		mii_rw(dev, np->phyaddr, MII_ADVERTISE, adv);
 
 		if (netif_running(dev))
-			pr_info("%s: link down\n", dev->name);
+			netdev_info(dev, "link down\n");
 		bmcr = mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ);
 		bmcr |= (BMCR_ANENABLE | BMCR_ANRESTART);
 		mii_rw(dev, np->phyaddr, MII_BMCR, bmcr);
@@ -4824,8 +4853,7 @@ static int nv_loopback_test(struct net_device *dev)
 	pkt_len = ETH_DATA_LEN;
 	tx_skb = dev_alloc_skb(pkt_len);
 	if (!tx_skb) {
-		pr_err("dev_alloc_skb() failed during loopback test of %s\n",
-		       dev->name);
+		netdev_err(dev, "dev_alloc_skb() failed during loopback test\n");
 		ret = 0;
 		goto out;
 	}
@@ -5188,7 +5216,8 @@ static int nv_open(struct net_device *dev)
 	if (reg_delay(dev, NvRegUnknownSetupReg5,
 		      NVREG_UNKSETUP5_BIT31, NVREG_UNKSETUP5_BIT31,
 		      NV_SETUP5_DELAY, NV_SETUP5_DELAYMAX))
-		pr_info("%s: SetupReg5, Bit 31 remained off\n", __func__);
+		netdev_info(dev,
+			    "%s: SetupReg5, Bit 31 remained off\n", __func__);
 
 	writel(0, base + NvRegMIIMask);
 	writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
@@ -5277,7 +5306,7 @@ static int nv_open(struct net_device *dev)
 	if (ret) {
 		netif_carrier_on(dev);
 	} else {
-		pr_info("%s: no link during initialization\n", dev->name);
+		netdev_info(dev, "no link during initialization\n");
 		netif_carrier_off(dev);
 	}
 	if (oom)
-- 
1.7.3.2.245.g03276.dirty

