From: Joe Perches <joe@perches.com>
Subject: [PATCH 09/11] forcedeth: Convert dev_printk(<level> to dev_<level>(
Date: Mon, 29 Nov 2010 09:42:00 -0800
Message-ID: <ac4e55f5a0ff29d2a7e4697fe93f8478248056ae.1291051316.git.joe@perches.com>
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

Use vsprintf extension %pM for a mac address in one instance.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/forcedeth.c |   64 +++++++++++++++++++----------------------------
 1 files changed, 26 insertions(+), 38 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 0b1d562..60edf01 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -5442,8 +5442,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		}
 	}
 	if (i == DEVICE_COUNT_RESOURCE) {
-		dev_printk(KERN_INFO, &pci_dev->dev,
-			   "Couldn't find register window\n");
+		dev_info(&pci_dev->dev, "Couldn't find register window\n");
 		goto out_relreg;
 	}
 
@@ -5459,13 +5458,13 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		np->txrxctl_bits = NVREG_TXRXCTL_DESC_3;
 		if (dma_64bit) {
 			if (pci_set_dma_mask(pci_dev, DMA_BIT_MASK(39)))
-				dev_printk(KERN_INFO, &pci_dev->dev,
-					"64-bit DMA failed, using 32-bit addressing\n");
+				dev_info(&pci_dev->dev,
+					 "64-bit DMA failed, using 32-bit addressing\n");
 			else
 				dev->features |= NETIF_F_HIGHDMA;
 			if (pci_set_consistent_dma_mask(pci_dev, DMA_BIT_MASK(39))) {
-				dev_printk(KERN_INFO, &pci_dev->dev,
-					"64-bit DMA (consistent) failed, using 32-bit ring buffers\n");
+				dev_info(&pci_dev->dev,
+					 "64-bit DMA (consistent) failed, using 32-bit ring buffers\n");
 			}
 		}
 	} else if (id->driver_data & DEV_HAS_LARGEDESC) {
@@ -5595,11 +5594,11 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		 * Bad mac address. At least one bios sets the mac address
 		 * to 01:23:45:67:89:ab
 		 */
-		dev_printk(KERN_ERR, &pci_dev->dev,
-			"Invalid Mac address detected: %pM\n",
+		dev_err(&pci_dev->dev,
+			"Invalid MAC address detected: %pM\n",
 			dev->dev_addr);
-		dev_printk(KERN_ERR, &pci_dev->dev,
-			"Please complain to your hardware vendor. Switching to a random MAC.\n");
+		dev_err(&pci_dev->dev,
+			"Please complain to your hardware vendor. Switched to a random MAC address.\n");
 		random_ether_addr(dev->dev_addr);
 	}
 
@@ -5752,8 +5751,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		break;
 	}
 	if (i == 33) {
-		dev_printk(KERN_INFO, &pci_dev->dev,
-			"open: Could not find a valid PHY.\n");
+		dev_info(&pci_dev->dev, "open: Could not find a valid PHY\n");
 		goto out_error;
 	}
 
@@ -5774,37 +5772,27 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 
 	err = register_netdev(dev);
 	if (err) {
-		dev_printk(KERN_INFO, &pci_dev->dev,
-			   "unable to register netdev: %d\n", err);
+		dev_info(&pci_dev->dev, "unable to register netdev: %d\n", err);
 		goto out_error;
 	}
 
-	dev_printk(KERN_INFO, &pci_dev->dev, "ifname %s, PHY OUI 0x%x @ %d, "
-		   "addr %2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x\n",
-		   dev->name,
-		   np->phy_oui,
-		   np->phyaddr,
-		   dev->dev_addr[0],
-		   dev->dev_addr[1],
-		   dev->dev_addr[2],
-		   dev->dev_addr[3],
-		   dev->dev_addr[4],
-		   dev->dev_addr[5]);
-
-	dev_printk(KERN_INFO, &pci_dev->dev, "%s%s%s%s%s%s%s%s%s%sdesc-v%u\n",
-		dev->features & NETIF_F_HIGHDMA ? "highdma " : "",
-		dev->features & (NETIF_F_IP_CSUM | NETIF_F_SG) ?
+	dev_info(&pci_dev->dev, "ifname %s, PHY OUI 0x%x @ %d, addr %pM\n",
+		 dev->name, np->phy_oui, np->phyaddr, dev->dev_addr);
+
+	dev_info(&pci_dev->dev, "%s%s%s%s%s%s%s%s%s%sdesc-v%u\n",
+		 dev->features & NETIF_F_HIGHDMA ? "highdma " : "",
+		 dev->features & (NETIF_F_IP_CSUM | NETIF_F_SG) ?
 			"csum " : "",
-		dev->features & (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX) ?
+		 dev->features & (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX) ?
 			"vlan " : "",
-		id->driver_data & DEV_HAS_POWER_CNTRL ? "pwrctl " : "",
-		id->driver_data & DEV_HAS_MGMT_UNIT ? "mgmt " : "",
-		id->driver_data & DEV_NEED_TIMERIRQ ? "timirq " : "",
-		np->gigabit == PHY_GIGABIT ? "gbit " : "",
-		np->need_linktimer ? "lnktim " : "",
-		np->msi_flags & NV_MSI_CAPABLE ? "msi " : "",
-		np->msi_flags & NV_MSI_X_CAPABLE ? "msi-x " : "",
-		np->desc_ver);
+		 id->driver_data & DEV_HAS_POWER_CNTRL ? "pwrctl " : "",
+		 id->driver_data & DEV_HAS_MGMT_UNIT ? "mgmt " : "",
+		 id->driver_data & DEV_NEED_TIMERIRQ ? "timirq " : "",
+		 np->gigabit == PHY_GIGABIT ? "gbit " : "",
+		 np->need_linktimer ? "lnktim " : "",
+		 np->msi_flags & NV_MSI_CAPABLE ? "msi " : "",
+		 np->msi_flags & NV_MSI_X_CAPABLE ? "msi-x " : "",
+		 np->desc_ver);
 
 	return 0;
 
-- 
1.7.3.2.245.g03276.dirty
