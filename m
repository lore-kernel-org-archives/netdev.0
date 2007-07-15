From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 3/3] forcedeth bug fix: realtek phy
Date: Sun, 15 Jul 2007 06:51:03 -0400
Message-ID: <4699FC17.7020409@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030704010209000201000800"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:6178 "EHLO
	HQEMGATE01.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281AbXGOTnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 15:43:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030704010209000201000800
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch contains errata fixes for the realtek phy.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>



--------------030704010209000201000800
Content-Type: text/plain;
 name="patch-forcedeth-realtek"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-realtek"

--- old/drivers/net/forcedeth.c	2007-07-15 06:31:00.000000000 -0400
+++ new/drivers/net/forcedeth.c	2007-07-15 06:40:29.000000000 -0400
@@ -551,6 +551,7 @@
 #define PHY_OUI_MARVELL	0x5043
 #define PHY_OUI_CICADA	0x03f1
 #define PHY_OUI_VITESSE	0x01c1
+#define PHY_OUI_REALTEK	0x01c1
 #define PHYID1_OUI_MASK	0x03ff
 #define PHYID1_OUI_SHFT	6
 #define PHYID2_OUI_MASK	0xfc00
@@ -580,6 +581,13 @@
 #define PHY_VITESSE_INIT8	0x0100
 #define PHY_VITESSE_INIT9	0x8f82
 #define PHY_VITESSE_INIT10	0x0
+#define PHY_REALTEK_INIT_REG1	0x1f
+#define PHY_REALTEK_INIT_REG2	0x19
+#define PHY_REALTEK_INIT_REG3	0x13
+#define PHY_REALTEK_INIT1	0x0000
+#define PHY_REALTEK_INIT2	0x8e00
+#define PHY_REALTEK_INIT3	0x0001
+#define PHY_REALTEK_INIT4	0xad17
 
 #define PHY_GIGABIT	0x0100
 
@@ -1114,6 +1122,28 @@
 			return PHY_ERROR;
 		}
 	}
+	if (np->phy_oui == PHY_OUI_REALTEK) {
+		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, PHY_REALTEK_INIT2)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT3)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG3, PHY_REALTEK_INIT4)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+	}
 
 	/* set advertise register */
 	reg = mii_rw(dev, np->phyaddr, MII_ADVERTISE, MII_READ);
@@ -1250,6 +1280,30 @@
 			return PHY_ERROR;
 		}
 	}
+	if (np->phy_oui == PHY_OUI_REALTEK) {
+		/* reset could have cleared these out, set them back */
+		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, PHY_REALTEK_INIT2)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT3)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG3, PHY_REALTEK_INIT4)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
+			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+	}
+
 	/* some phys clear out pause advertisment on reset, set it back */
 	mii_rw(dev, np->phyaddr, MII_ADVERTISE, reg);
 

--------------030704010209000201000800--
