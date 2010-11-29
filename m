From: Joe Perches <joe@perches.com>
Subject: [PATCH 05/11] forcedeth: Use pr_fmt and pr_<level>
Date: Mon, 29 Nov 2010 09:41:56 -0800
Message-ID: <914713437a6f3f40b77b52bdb5f16038919d1b69.1291051316.git.joe@perches.com>
References: <cover.1291051316.git.joe@perches.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Szymon Janc <szymon@janc.net.pl>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirqus@gmail.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1291051316.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert printks to pr_<level>.
Remove "forcedeth: " from some calls as it's now added by pr_fmt.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/forcedeth.c |  256 ++++++++++++++++++++++++++---------------------
 1 files changed, 142 insertions(+), 114 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index b30a599..1c6f4ef9 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -39,6 +39,9 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define FORCEDETH_VERSION		"0.64"
 #define DRV_NAME			"forcedeth"
 
@@ -1189,7 +1192,8 @@ static int phy_init(struct net_device *dev)
 		reg = mii_rw(dev, np->phyaddr, MII_NCONFIG, MII_READ);
 		reg &= ~PHY_MARVELL_E3016_INITMASK;
 		if (mii_rw(dev, np->phyaddr, MII_NCONFIG, reg)) {
-			printk(KERN_INFO "%s: phy write to errata reg failed.\n", pci_name(np->pci_dev));
+			pr_info("%s: phy write to errata reg failed\n",
+				pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 	}
@@ -1197,31 +1201,38 @@ static int phy_init(struct net_device *dev)
 		if (np->phy_model == PHY_MODEL_REALTEK_8211 &&
 		    np->phy_rev == PHY_REV_REALTEK_8211B) {
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
-				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				pr_info("%s: phy init failed\n",
+					pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, PHY_REALTEK_INIT2)) {
-				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				pr_info("%s: phy init failed\n",
+					pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT3)) {
-				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				pr_info("%s: phy init failed\n",
+					pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG3, PHY_REALTEK_INIT4)) {
-				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				pr_info("%s: phy init failed\n",
+					pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG4, PHY_REALTEK_INIT5)) {
-				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				pr_info("%s: phy init failed\n",
+					pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG5, PHY_REALTEK_INIT6)) {
-				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				pr_info("%s: phy init failed\n",
+					pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
-				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				pr_info("%s: phy init failed\n",
+					pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 		}
@@ -1241,23 +1252,27 @@ static int phy_init(struct net_device *dev)
 			reg = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, MII_READ);
 			reg |= PHY_REALTEK_INIT9;
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, reg)) {
-				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				pr_info("%s: phy init failed\n",
+					pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT10)) {
-				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				pr_info("%s: phy init failed\n",
+					pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			reg = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG7, MII_READ);
 			if (!(reg & PHY_REALTEK_INIT11)) {
 				reg |= PHY_REALTEK_INIT11;
 				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG7, reg)) {
-					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					pr_info("%s: phy init failed\n",
+						pci_name(np->pci_dev));
 					return PHY_ERROR;
 				}
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
-				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				pr_info("%s: phy init failed\n",
+					pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 		}
@@ -1266,7 +1281,8 @@ static int phy_init(struct net_device *dev)
 				phy_reserved = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, MII_READ);
 				phy_reserved |= PHY_REALTEK_INIT7;
 				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, phy_reserved)) {
-					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					pr_info("%s: phy init failed\n",
+						pci_name(np->pci_dev));
 					return PHY_ERROR;
 				}
 			}
@@ -1277,7 +1293,8 @@ static int phy_init(struct net_device *dev)
 	reg = mii_rw(dev, np->phyaddr, MII_ADVERTISE, MII_READ);
 	reg |= (ADVERTISE_10HALF|ADVERTISE_10FULL|ADVERTISE_100HALF|ADVERTISE_100FULL|ADVERTISE_PAUSE_ASYM|ADVERTISE_PAUSE_CAP);
 	if (mii_rw(dev, np->phyaddr, MII_ADVERTISE, reg)) {
-		printk(KERN_INFO "%s: phy write to advertise failed.\n", pci_name(np->pci_dev));
+		pr_info("%s: phy write to advertise failed\n",
+			pci_name(np->pci_dev));
 		return PHY_ERROR;
 	}
 
@@ -1296,7 +1313,7 @@ static int phy_init(struct net_device *dev)
 			mii_control_1000 &= ~ADVERTISE_1000FULL;
 
 		if (mii_rw(dev, np->phyaddr, MII_CTRL1000, mii_control_1000)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 	} else
@@ -1311,7 +1328,7 @@ static int phy_init(struct net_device *dev)
 		/* start autoneg since we already performed hw reset above */
 		mii_control |= BMCR_ANRESTART;
 		if (mii_rw(dev, np->phyaddr, MII_BMCR, mii_control)) {
-			printk(KERN_INFO "%s: phy init failed\n", pci_name(np->pci_dev));
+			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 	} else {
@@ -1319,7 +1336,7 @@ static int phy_init(struct net_device *dev)
 		 * (certain phys need bmcr to be setup with reset)
 		 */
 		if (phy_reset(dev, mii_control)) {
-			printk(KERN_INFO "%s: phy reset failed\n", pci_name(np->pci_dev));
+			pr_info("%s: phy reset failed\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 	}
@@ -1330,13 +1347,13 @@ static int phy_init(struct net_device *dev)
 		phy_reserved &= ~(PHY_CICADA_INIT1 | PHY_CICADA_INIT2);
 		phy_reserved |= (PHY_CICADA_INIT3 | PHY_CICADA_INIT4);
 		if (mii_rw(dev, np->phyaddr, MII_RESV1, phy_reserved)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		phy_reserved = mii_rw(dev, np->phyaddr, MII_NCONFIG, MII_READ);
 		phy_reserved |= PHY_CICADA_INIT5;
 		if (mii_rw(dev, np->phyaddr, MII_NCONFIG, phy_reserved)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 	}
@@ -1344,77 +1361,77 @@ static int phy_init(struct net_device *dev)
 		phy_reserved = mii_rw(dev, np->phyaddr, MII_SREVISION, MII_READ);
 		phy_reserved |= PHY_CICADA_INIT6;
 		if (mii_rw(dev, np->phyaddr, MII_SREVISION, phy_reserved)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 	}
 	if (np->phy_oui == PHY_OUI_VITESSE) {
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG1, PHY_VITESSE_INIT1)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT2)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, MII_READ);
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, phy_reserved)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, MII_READ);
 		phy_reserved &= ~PHY_VITESSE_INIT_MSK1;
 		phy_reserved |= PHY_VITESSE_INIT3;
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, phy_reserved)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT4)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT5)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, MII_READ);
 		phy_reserved &= ~PHY_VITESSE_INIT_MSK1;
 		phy_reserved |= PHY_VITESSE_INIT3;
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, phy_reserved)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, MII_READ);
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, phy_reserved)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT6)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT7)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, MII_READ);
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG4, phy_reserved)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		phy_reserved = mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, MII_READ);
 		phy_reserved &= ~PHY_VITESSE_INIT_MSK2;
 		phy_reserved |= PHY_VITESSE_INIT8;
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG3, phy_reserved)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG2, PHY_VITESSE_INIT9)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 		if (mii_rw(dev, np->phyaddr, PHY_VITESSE_INIT_REG1, PHY_VITESSE_INIT10)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			pr_info("%s: phy init failed\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
 	}
@@ -1423,31 +1440,38 @@ static int phy_init(struct net_device *dev)
 		    np->phy_rev == PHY_REV_REALTEK_8211B) {
 			/* reset could have cleared these out, set them back */
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
-				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				pr_info("%s: phy init failed\n",
+					pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, PHY_REALTEK_INIT2)) {
-				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				pr_info("%s: phy init failed\n",
+					pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT3)) {
-				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				pr_info("%s: phy init failed\n",
+					pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG3, PHY_REALTEK_INIT4)) {
-				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				pr_info("%s: phy init failed\n",
+					pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG4, PHY_REALTEK_INIT5)) {
-				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				pr_info("%s: phy init failed\n",
+					pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG5, PHY_REALTEK_INIT6)) {
-				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				pr_info("%s: phy init failed\n",
+					pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
-				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				pr_info("%s: phy init failed\n",
+					pci_name(np->pci_dev));
 				return PHY_ERROR;
 			}
 		}
@@ -1456,24 +1480,28 @@ static int phy_init(struct net_device *dev)
 				phy_reserved = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, MII_READ);
 				phy_reserved |= PHY_REALTEK_INIT7;
 				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, phy_reserved)) {
-					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					pr_info("%s: phy init failed\n",
+						pci_name(np->pci_dev));
 					return PHY_ERROR;
 				}
 			}
 			if (phy_cross == NV_CROSSOVER_DETECTION_DISABLED) {
 				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT3)) {
-					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					pr_info("%s: phy init failed\n",
+						pci_name(np->pci_dev));
 					return PHY_ERROR;
 				}
 				phy_reserved = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, MII_READ);
 				phy_reserved &= ~PHY_REALTEK_INIT_MSK1;
 				phy_reserved |= PHY_REALTEK_INIT3;
 				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, phy_reserved)) {
-					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					pr_info("%s: phy init failed\n",
+						pci_name(np->pci_dev));
 					return PHY_ERROR;
 				}
 				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
-					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					pr_info("%s: phy init failed\n",
+						pci_name(np->pci_dev));
 					return PHY_ERROR;
 				}
 			}
@@ -1532,7 +1560,7 @@ static void nv_stop_rx(struct net_device *dev)
 	writel(rx_ctrl, base + NvRegReceiverControl);
 	if (reg_delay(dev, NvRegReceiverStatus, NVREG_RCVSTAT_BUSY, 0,
 		      NV_RXSTOP_DELAY1, NV_RXSTOP_DELAY1MAX))
-		printk(KERN_INFO "nv_stop_rx: ReceiverStatus remained busy");
+		pr_info("%s: ReceiverStatus remained busy\n", __func__);
 
 	udelay(NV_RXSTOP_DELAY2);
 	if (!np->mac_in_use)
@@ -1567,7 +1595,7 @@ static void nv_stop_tx(struct net_device *dev)
 	writel(tx_ctrl, base + NvRegTransmitterControl);
 	if (reg_delay(dev, NvRegTransmitterStatus, NVREG_XMITSTAT_BUSY, 0,
 		      NV_TXSTOP_DELAY1, NV_TXSTOP_DELAY1MAX))
-		printk(KERN_INFO "nv_stop_tx: TransmitterStatus remained busy");
+		pr_info("%s: TransmitterStatus remained busy\n", __func__);
 
 	udelay(NV_TXSTOP_DELAY2);
 	if (!np->mac_in_use)
@@ -2485,57 +2513,53 @@ static void nv_tx_timeout(struct net_device *dev)
 	u32 status;
 	union ring_type put_tx;
 	int saved_tx_limit;
+	int i;
 
 	if (np->msi_flags & NV_MSI_X_ENABLED)
 		status = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQSTAT_MASK;
 	else
 		status = readl(base + NvRegIrqStatus) & NVREG_IRQSTAT_MASK;
 
-	printk(KERN_INFO "%s: Got tx_timeout. irq: %08x\n", dev->name, status);
+	pr_info("%s: Got tx_timeout. irq: %08x\n", dev->name, status);
 
-	{
-		int i;
-
-		printk(KERN_INFO "%s: Ring at %lx\n",
-		       dev->name, (unsigned long)np->ring_addr);
-		printk(KERN_INFO "%s: Dumping tx registers\n", dev->name);
-		for (i = 0; i <= np->register_size; i += 32) {
-			printk(KERN_INFO "%3x: %08x %08x %08x %08x %08x %08x %08x %08x\n",
-					i,
-					readl(base + i + 0), readl(base + i + 4),
-					readl(base + i + 8), readl(base + i + 12),
-					readl(base + i + 16), readl(base + i + 20),
-					readl(base + i + 24), readl(base + i + 28));
-		}
-		printk(KERN_INFO "%s: Dumping tx ring\n", dev->name);
-		for (i = 0; i < np->tx_ring_size; i += 4) {
-			if (!nv_optimized(np)) {
-				printk(KERN_INFO "%03x: %08x %08x // %08x %08x // %08x %08x // %08x %08x\n",
-				       i,
-				       le32_to_cpu(np->tx_ring.orig[i].buf),
-				       le32_to_cpu(np->tx_ring.orig[i].flaglen),
-				       le32_to_cpu(np->tx_ring.orig[i+1].buf),
-				       le32_to_cpu(np->tx_ring.orig[i+1].flaglen),
-				       le32_to_cpu(np->tx_ring.orig[i+2].buf),
-				       le32_to_cpu(np->tx_ring.orig[i+2].flaglen),
-				       le32_to_cpu(np->tx_ring.orig[i+3].buf),
-				       le32_to_cpu(np->tx_ring.orig[i+3].flaglen));
-			} else {
-				printk(KERN_INFO "%03x: %08x %08x %08x // %08x %08x %08x // %08x %08x %08x // %08x %08x %08x\n",
-				       i,
-				       le32_to_cpu(np->tx_ring.ex[i].bufhigh),
-				       le32_to_cpu(np->tx_ring.ex[i].buflow),
-				       le32_to_cpu(np->tx_ring.ex[i].flaglen),
-				       le32_to_cpu(np->tx_ring.ex[i+1].bufhigh),
-				       le32_to_cpu(np->tx_ring.ex[i+1].buflow),
-				       le32_to_cpu(np->tx_ring.ex[i+1].flaglen),
-				       le32_to_cpu(np->tx_ring.ex[i+2].bufhigh),
-				       le32_to_cpu(np->tx_ring.ex[i+2].buflow),
-				       le32_to_cpu(np->tx_ring.ex[i+2].flaglen),
-				       le32_to_cpu(np->tx_ring.ex[i+3].bufhigh),
-				       le32_to_cpu(np->tx_ring.ex[i+3].buflow),
-				       le32_to_cpu(np->tx_ring.ex[i+3].flaglen));
-			}
+	pr_info("%s: Ring at %lx\n", dev->name, (unsigned long)np->ring_addr);
+	pr_info("%s: Dumping tx registers\n", dev->name);
+	for (i = 0; i <= np->register_size; i += 32) {
+		pr_info("%3x: %08x %08x %08x %08x %08x %08x %08x %08x\n",
+			i,
+			readl(base + i + 0), readl(base + i + 4),
+			readl(base + i + 8), readl(base + i + 12),
+			readl(base + i + 16), readl(base + i + 20),
+			readl(base + i + 24), readl(base + i + 28));
+	}
+	pr_info("%s: Dumping tx ring\n", dev->name);
+	for (i = 0; i < np->tx_ring_size; i += 4) {
+		if (!nv_optimized(np)) {
+			pr_info("%03x: %08x %08x // %08x %08x // %08x %08x // %08x %08x\n",
+				i,
+				le32_to_cpu(np->tx_ring.orig[i].buf),
+				le32_to_cpu(np->tx_ring.orig[i].flaglen),
+				le32_to_cpu(np->tx_ring.orig[i+1].buf),
+				le32_to_cpu(np->tx_ring.orig[i+1].flaglen),
+				le32_to_cpu(np->tx_ring.orig[i+2].buf),
+				le32_to_cpu(np->tx_ring.orig[i+2].flaglen),
+				le32_to_cpu(np->tx_ring.orig[i+3].buf),
+				le32_to_cpu(np->tx_ring.orig[i+3].flaglen));
+		} else {
+			pr_info("%03x: %08x %08x %08x // %08x %08x %08x // %08x %08x %08x // %08x %08x %08x\n",
+				i,
+				le32_to_cpu(np->tx_ring.ex[i].bufhigh),
+				le32_to_cpu(np->tx_ring.ex[i].buflow),
+				le32_to_cpu(np->tx_ring.ex[i].flaglen),
+				le32_to_cpu(np->tx_ring.ex[i+1].bufhigh),
+				le32_to_cpu(np->tx_ring.ex[i+1].buflow),
+				le32_to_cpu(np->tx_ring.ex[i+1].flaglen),
+				le32_to_cpu(np->tx_ring.ex[i+2].bufhigh),
+				le32_to_cpu(np->tx_ring.ex[i+2].buflow),
+				le32_to_cpu(np->tx_ring.ex[i+2].flaglen),
+				le32_to_cpu(np->tx_ring.ex[i+3].bufhigh),
+				le32_to_cpu(np->tx_ring.ex[i+3].buflow),
+				le32_to_cpu(np->tx_ring.ex[i+3].flaglen));
 		}
 	}
 
@@ -3308,14 +3332,14 @@ static void nv_linkchange(struct net_device *dev)
 	if (nv_update_linkspeed(dev)) {
 		if (!netif_carrier_ok(dev)) {
 			netif_carrier_on(dev);
-			printk(KERN_INFO "%s: link up.\n", dev->name);
+			pr_info("%s: link up\n", dev->name);
 			nv_txrx_gate(dev, false);
 			nv_start_rx(dev);
 		}
 	} else {
 		if (netif_carrier_ok(dev)) {
 			netif_carrier_off(dev);
-			printk(KERN_INFO "%s: link down.\n", dev->name);
+			pr_info("%s: link down\n", dev->name);
 			nv_txrx_gate(dev, true);
 			nv_stop_rx(dev);
 		}
@@ -3764,7 +3788,8 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 				sprintf(np->name_rx, "%s-rx", dev->name);
 				if (request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector,
 						nv_nic_irq_rx, IRQF_SHARED, np->name_rx, dev) != 0) {
-					printk(KERN_INFO "forcedeth: request_irq failed for rx %d\n", ret);
+					pr_info("request_irq failed for rx %d\n",
+						ret);
 					pci_disable_msix(np->pci_dev);
 					np->msi_flags &= ~NV_MSI_X_ENABLED;
 					goto out_err;
@@ -3773,7 +3798,8 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 				sprintf(np->name_tx, "%s-tx", dev->name);
 				if (request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_TX].vector,
 						nv_nic_irq_tx, IRQF_SHARED, np->name_tx, dev) != 0) {
-					printk(KERN_INFO "forcedeth: request_irq failed for tx %d\n", ret);
+					pr_info("request_irq failed for tx %d\n",
+						ret);
 					pci_disable_msix(np->pci_dev);
 					np->msi_flags &= ~NV_MSI_X_ENABLED;
 					goto out_free_rx;
@@ -3782,7 +3808,8 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 				sprintf(np->name_other, "%s-other", dev->name);
 				if (request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_OTHER].vector,
 						nv_nic_irq_other, IRQF_SHARED, np->name_other, dev) != 0) {
-					printk(KERN_INFO "forcedeth: request_irq failed for link %d\n", ret);
+					pr_info("request_irq failed for link %d\n",
+						ret);
 					pci_disable_msix(np->pci_dev);
 					np->msi_flags &= ~NV_MSI_X_ENABLED;
 					goto out_free_tx;
@@ -3796,7 +3823,7 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 			} else {
 				/* Request irq for all interrupts */
 				if (request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector, handler, IRQF_SHARED, dev->name, dev) != 0) {
-					printk(KERN_INFO "forcedeth: request_irq failed %d\n", ret);
+					pr_info("request_irq failed %d\n", ret);
 					pci_disable_msix(np->pci_dev);
 					np->msi_flags &= ~NV_MSI_X_ENABLED;
 					goto out_err;
@@ -3814,7 +3841,7 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 			np->msi_flags |= NV_MSI_ENABLED;
 			dev->irq = np->pci_dev->irq;
 			if (request_irq(np->pci_dev->irq, handler, IRQF_SHARED, dev->name, dev) != 0) {
-				printk(KERN_INFO "forcedeth: request_irq failed %d\n", ret);
+				pr_info("request_irq failed %d\n", ret);
 				pci_disable_msi(np->pci_dev);
 				np->msi_flags &= ~NV_MSI_ENABLED;
 				dev->irq = np->pci_dev->irq;
@@ -3899,7 +3926,7 @@ static void nv_do_nic_poll(unsigned long data)
 
 	if (np->recover_error) {
 		np->recover_error = 0;
-		printk(KERN_INFO "%s: MAC in recoverable error state\n", dev->name);
+		pr_info("%s: MAC in recoverable error state\n", dev->name);
 		if (netif_running(dev)) {
 			netif_tx_lock_bh(dev);
 			netif_addr_lock(dev);
@@ -4195,14 +4222,14 @@ static int nv_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		}
 
 		if (netif_running(dev))
-			printk(KERN_INFO "%s: link down.\n", dev->name);
+			pr_info("%s: link down\n", dev->name);
 		bmcr = mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ);
 		if (np->phy_model == PHY_MODEL_MARVELL_E3016) {
 			bmcr |= BMCR_ANENABLE;
 			/* reset the phy in order for settings to stick,
 			 * and cause autoneg to start */
 			if (phy_reset(dev, bmcr)) {
-				printk(KERN_INFO "%s: phy reset failed\n", dev->name);
+				pr_info("%s: phy reset failed\n", dev->name);
 				return -EINVAL;
 			}
 		} else {
@@ -4251,7 +4278,7 @@ static int nv_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		if (np->phy_oui == PHY_OUI_MARVELL) {
 			/* reset the phy in order for forced mode settings to stick */
 			if (phy_reset(dev, bmcr)) {
-				printk(KERN_INFO "%s: phy reset failed\n", dev->name);
+				pr_info("%s: phy reset failed\n", dev->name);
 				return -EINVAL;
 			}
 		} else {
@@ -4313,7 +4340,7 @@ static int nv_nway_reset(struct net_device *dev)
 			spin_unlock(&np->lock);
 			netif_addr_unlock(dev);
 			netif_tx_unlock_bh(dev);
-			printk(KERN_INFO "%s: link down.\n", dev->name);
+			pr_info("%s: link down\n", dev->name);
 		}
 
 		bmcr = mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ);
@@ -4321,7 +4348,7 @@ static int nv_nway_reset(struct net_device *dev)
 			bmcr |= BMCR_ANENABLE;
 			/* reset the phy in order for settings to stick*/
 			if (phy_reset(dev, bmcr)) {
-				printk(KERN_INFO "%s: phy reset failed\n", dev->name);
+				pr_info("%s: phy reset failed\n", dev->name);
 				return -EINVAL;
 			}
 		} else {
@@ -4494,12 +4521,13 @@ static int nv_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam*
 
 	if ((!np->autoneg && np->duplex == 0) ||
 	    (np->autoneg && !pause->autoneg && np->duplex == 0)) {
-		printk(KERN_INFO "%s: can not set pause settings when forced link is in half duplex.\n",
-		       dev->name);
+		pr_info("%s: can not set pause settings when forced link is in half duplex\n",
+			dev->name);
 		return -EINVAL;
 	}
 	if (pause->tx_pause && !(np->pause_flags & NV_PAUSEFRAME_TX_CAPABLE)) {
-		printk(KERN_INFO "%s: hardware does not support tx pause frames.\n", dev->name);
+		pr_info("%s: hardware does not support tx pause frames\n",
+			dev->name);
 		return -EINVAL;
 	}
 
@@ -4534,7 +4562,7 @@ static int nv_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam*
 		mii_rw(dev, np->phyaddr, MII_ADVERTISE, adv);
 
 		if (netif_running(dev))
-			printk(KERN_INFO "%s: link down.\n", dev->name);
+			pr_info("%s: link down\n", dev->name);
 		bmcr = mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ);
 		bmcr |= (BMCR_ANENABLE | BMCR_ANRESTART);
 		mii_rw(dev, np->phyaddr, MII_BMCR, bmcr);
@@ -4796,8 +4824,8 @@ static int nv_loopback_test(struct net_device *dev)
 	pkt_len = ETH_DATA_LEN;
 	tx_skb = dev_alloc_skb(pkt_len);
 	if (!tx_skb) {
-		printk(KERN_ERR "dev_alloc_skb() failed during loopback test"
-			 " of %s\n", dev->name);
+		pr_err("dev_alloc_skb() failed during loopback test of %s\n",
+		       dev->name);
 		ret = 0;
 		goto out;
 	}
@@ -5160,7 +5188,7 @@ static int nv_open(struct net_device *dev)
 	if (reg_delay(dev, NvRegUnknownSetupReg5,
 		      NVREG_UNKSETUP5_BIT31, NVREG_UNKSETUP5_BIT31,
 		      NV_SETUP5_DELAY, NV_SETUP5_DELAYMAX))
-		printk(KERN_INFO "open: SetupReg5, Bit 31 remained off\n");
+		pr_info("%s: SetupReg5, Bit 31 remained off\n", __func__);
 
 	writel(0, base + NvRegMIIMask);
 	writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
@@ -5249,7 +5277,7 @@ static int nv_open(struct net_device *dev)
 	if (ret) {
 		netif_carrier_on(dev);
 	} else {
-		printk(KERN_INFO "%s: no link during initialization.\n", dev->name);
+		pr_info("%s: no link during initialization\n", dev->name);
 		netif_carrier_off(dev);
 	}
 	if (oom)
@@ -5361,8 +5389,8 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	static int printed_version;
 
 	if (!printed_version++)
-		printk(KERN_INFO "%s: Reverse Engineered nForce ethernet"
-		       " driver. Version %s.\n", DRV_NAME, FORCEDETH_VERSION);
+		pr_info("Reverse Engineered nForce ethernet driver. Version %s.\n",
+			FORCEDETH_VERSION);
 
 	dev = alloc_etherdev(sizeof(struct fe_priv));
 	err = -ENOMEM;
-- 
1.7.3.2.245.g03276.dirty
