From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH] forcedeth: updated phy errata
Date: Mon, 31 Aug 2009 19:08:37 -0400
Message-ID: <4A9C57F5.10800@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040601000403030305000804"
To: "David S. Miller" <davem@davemloft.net>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:4812 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750732AbZIAElC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 00:41:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040601000403030305000804
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch updates the special programming (and/or errata) needed in 
order to setup the phy for various vendor models.

The new models include:
Marvell E1116
Marvell E1111
Marvell E1011
Marvell E3016
Broadcom 9507
Broadcom AC131
Broadcom 50610

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>




--------------040601000403030305000804
Content-Type: text/plain;
 name="patch-forcedeth-phy-errata"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-phy-errata"

--- old/drivers/net/forcedeth.c	2009-08-31 19:01:04.000000000 -0400
+++ new/drivers/net/forcedeth.c	2009-08-31 19:05:49.000000000 -0400
@@ -506,6 +506,7 @@
 #define PHY_OUI_VITESSE		0x01c1
 #define PHY_OUI_REALTEK		0x0732
 #define PHY_OUI_REALTEK2	0x0020
+#define PHY_OUI_BROADCOM	0x50ef
 #define PHYID1_OUI_MASK	0x03ff
 #define PHYID1_OUI_SHFT	6
 #define PHYID2_OUI_MASK	0xfc00
@@ -517,7 +518,18 @@
 #define PHY_REV_REALTEK_8211C		0x0001
 #define PHY_MODEL_REALTEK_8201		0x0200
 #define PHY_MODEL_MARVELL_E3016		0x0220
-#define PHY_MARVELL_E3016_INITMASK	0x0300
+#define PHY_MODEL_MARVELL_E1116		0x0210
+#define PHY_MODEL_MARVELL_E1111		0x00c0
+#define PHY_MODEL_MARVELL_E1011		0x00b0
+#define PHY_MODEL_BROADCOM_9507		0x00a0
+#define PHY_MODEL_BROADCOM_AC131	0x0070
+#define PHY_MODEL_BROADCOM_50610	0x0160
+#define PHY_MARVELL_INIT_REG1	0x16
+#define PHY_MARVELL_INIT_REG2	0x10
+#define PHY_MARVELL_INIT1	0x0300
+#define PHY_MARVELL_INIT2	0x4000
+#define PHY_MARVELL_INIT_MSK1	0x0300
+#define PHY_MARVELL_INIT_MSK2	0x00ff
 #define PHY_CICADA_INIT1	0x0f000
 #define PHY_CICADA_INIT2	0x0e00
 #define PHY_CICADA_INIT3	0x01000
@@ -559,6 +571,19 @@
 #define PHY_REALTEK_INIT10	0x0005
 #define PHY_REALTEK_INIT11	0x0200
 #define PHY_REALTEK_INIT_MSK1	0x0003
+#define PHY_BROADCOM_INIT_REG1	0x1c
+#define PHY_BROADCOM_INIT_REG2	0x1f
+#define PHY_BROADCOM_INIT_REG3	0x1b
+#define PHY_BROADCOM_INIT_REG4	0x17
+#define PHY_BROADCOM_INIT_REG5	0x15
+#define PHY_BROADCOM_INIT1	0x2820
+#define PHY_BROADCOM_INIT2	0x0080
+#define PHY_BROADCOM_INIT3	0x0020
+#define PHY_BROADCOM_INIT4	0x8c00
+#define PHY_BROADCOM_INIT5	0x0f08
+#define PHY_BROADCOM_INIT6	0x0001
+#define PHY_BROADCOM_INIT7	0x0f00
+#define PHY_BROADCOM_INIT_MSK1	0x7c20
 
 #define PHY_GIGABIT	0x0100
 
@@ -1198,13 +1223,14 @@
 	u8 __iomem *base = get_hwbase(dev);
 	u32 phyinterface, phy_reserved, mii_status, mii_control, mii_control_1000,reg;
 
-	/* phy errata for E3016 phy */
-	if (np->phy_model == PHY_MODEL_MARVELL_E3016) {
-		reg = mii_rw(dev, np->phyaddr, MII_NCONFIG, MII_READ);
-		reg &= ~PHY_MARVELL_E3016_INITMASK;
-		if (mii_rw(dev, np->phyaddr, MII_NCONFIG, reg)) {
-			printk(KERN_INFO "%s: phy write to errata reg failed.\n", pci_name(np->pci_dev));
-			return PHY_ERROR;
+	if (np->phy_oui == PHY_OUI_MARVELL) {
+		if (np->phy_model == PHY_MODEL_MARVELL_E3016) {
+			reg = mii_rw(dev, np->phyaddr, MII_NCONFIG, MII_READ);
+			reg &= ~PHY_MARVELL_INIT_MSK1;
+			if (mii_rw(dev, np->phyaddr, MII_NCONFIG, reg)) {
+				printk(KERN_INFO "%s: phy write to errata reg failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
 		}
 	}
 	if (np->phy_oui == PHY_OUI_REALTEK) {
@@ -1340,6 +1366,89 @@
 	}
 
 	/* phy vendor specific configuration */
+	if (np->phy_oui == PHY_OUI_MARVELL) {
+		if (np->driver_data & DEV_NEED_PHY_INIT_FIX) {
+			if (np->phy_model == PHY_MODEL_MARVELL_E1116) {
+				phy_reserved = mii_rw(dev, np->phyaddr, PHY_MARVELL_INIT_REG1, MII_READ);
+				phy_reserved &= ~PHY_MARVELL_INIT_MSK2;
+				if (mii_rw(dev, np->phyaddr, PHY_MARVELL_INIT_REG1,phy_reserved)) {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					return PHY_ERROR;
+				}
+
+				phy_reserved = mii_rw(dev, np->phyaddr, PHY_MARVELL_INIT_REG2, MII_READ);
+				phy_reserved |= PHY_MARVELL_INIT1;
+				if (mii_rw(dev, np->phyaddr, PHY_MARVELL_INIT_REG2 ,phy_reserved)) {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					return PHY_ERROR;
+				}
+			}
+			if (np->phy_model == PHY_MODEL_MARVELL_E1111) {
+				phy_reserved = mii_rw(dev, np->phyaddr, PHY_MARVELL_INIT_REG2, MII_READ);
+				phy_reserved |= PHY_MARVELL_INIT1;
+				if (mii_rw(dev, np->phyaddr, PHY_MARVELL_INIT_REG2 ,phy_reserved)) {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					return PHY_ERROR;
+				}
+			}
+			if (np->phy_model == PHY_MODEL_MARVELL_E3016) {
+				phy_reserved = mii_rw(dev, np->phyaddr, PHY_MARVELL_INIT_REG2, MII_READ);
+				phy_reserved |= PHY_MARVELL_INIT2;
+				if (mii_rw(dev, np->phyaddr, PHY_MARVELL_INIT_REG2 ,phy_reserved)) {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					return PHY_ERROR;
+				}
+			}
+		}
+	}
+
+	if (np->phy_oui == PHY_OUI_BROADCOM) {
+		if (np->driver_data & DEV_NEED_PHY_INIT_FIX) {
+			if (np->phy_model == PHY_MODEL_BROADCOM_9507) {
+				phy_reserved = mii_rw(dev, np->phyaddr, PHY_BROADCOM_INIT_REG1, MII_READ);
+				phy_reserved &= ~PHY_BROADCOM_INIT_MSK1;
+				phy_reserved |= PHY_BROADCOM_INIT1;
+				if (mii_rw(dev, np->phyaddr, PHY_BROADCOM_INIT_REG1 ,phy_reserved)) {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					return PHY_ERROR;
+				}
+			}
+			if (np->phy_model == PHY_MODEL_BROADCOM_AC131) {
+				phy_reserved = mii_rw(dev, np->phyaddr, PHY_BROADCOM_INIT_REG2, MII_READ);
+				phy_reserved |= PHY_BROADCOM_INIT2;
+				if (mii_rw(dev, np->phyaddr, PHY_BROADCOM_INIT_REG2 ,phy_reserved)) {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					return PHY_ERROR;
+				}
+
+				phy_reserved = mii_rw(dev, np->phyaddr, PHY_BROADCOM_INIT_REG3, MII_READ);
+				phy_reserved |= PHY_BROADCOM_INIT3;
+				if (mii_rw(dev, np->phyaddr, PHY_BROADCOM_INIT_REG3 ,phy_reserved)) {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					return PHY_ERROR;
+				}
+			}
+		}
+		if (np->phy_model == PHY_MODEL_BROADCOM_50610) {
+			if (mii_rw(dev, np->phyaddr, PHY_BROADCOM_INIT_REG1, PHY_BROADCOM_INIT4)) {
+ 				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+ 				return PHY_ERROR;
+ 			}
+			if (mii_rw(dev, np->phyaddr, PHY_BROADCOM_INIT_REG4, PHY_BROADCOM_INIT5)) {
+ 				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+ 				return PHY_ERROR;
+   			}
+			if (mii_rw(dev, np->phyaddr, PHY_BROADCOM_INIT_REG5, PHY_BROADCOM_INIT6)) {
+ 				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+ 				return PHY_ERROR;
+ 			}
+			if (mii_rw(dev, np->phyaddr, PHY_BROADCOM_INIT_REG4, PHY_BROADCOM_INIT7)) {
+ 				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+ 				return PHY_ERROR;
+ 			}
+		}
+	}
+
 	if ((np->phy_oui == PHY_OUI_CICADA) && (phyinterface & PHY_RGMII) ) {
 		phy_reserved = mii_rw(dev, np->phyaddr, MII_RESV1, MII_READ);
 		phy_reserved &= ~(PHY_CICADA_INIT1 | PHY_CICADA_INIT2);

--------------040601000403030305000804--
