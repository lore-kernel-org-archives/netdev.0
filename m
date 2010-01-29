From: Joe Perches <joe@perches.com>
Subject: [PATCH 07/13] tulip/media.c: Use dev_<level> and pr_<level>
Date: Thu, 28 Jan 2010 22:59:23 -0800
Message-ID: <aab6c11897296a3f92adb95b8fa10741698cce3d.1264747118.git.joe@perches.com>
References: <cover.1264747118.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1592 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754022Ab0A2G7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 01:59:31 -0500
In-Reply-To: <cover.1264747118.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert printks to dev_<level> where a dev is available
Convert printks to pr_<level> where not
Coalesce format strings
Change print formats with %d.dx to %0dx

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tulip/media.c |   74 ++++++++++++++++++++++-----------------------
 1 files changed, 36 insertions(+), 38 deletions(-)

diff --git a/drivers/net/tulip/media.c b/drivers/net/tulip/media.c
index d8fda83..68b170a 100644
--- a/drivers/net/tulip/media.c
+++ b/drivers/net/tulip/media.c
@@ -182,9 +182,8 @@ void tulip_select_media(struct net_device *dev, int startup)
 		switch (mleaf->type) {
 		case 0:					/* 21140 non-MII xcvr. */
 			if (tulip_debug > 1)
-				printk(KERN_DEBUG "%s: Using a 21140 non-MII transceiver"
-					   " with control setting %2.2x.\n",
-					   dev->name, p[1]);
+				printk(KERN_DEBUG "%s: Using a 21140 non-MII transceiver with control setting %02x\n",
+				       dev->name, p[1]);
 			dev->if_port = p[0];
 			if (startup)
 				iowrite32(mtable->csr12dir | 0x100, ioaddr + CSR12);
@@ -205,15 +204,15 @@ void tulip_select_media(struct net_device *dev, int startup)
 				struct medialeaf *rleaf = &mtable->mleaf[mtable->has_reset];
 				unsigned char *rst = rleaf->leafdata;
 				if (tulip_debug > 1)
-					printk(KERN_DEBUG "%s: Resetting the transceiver.\n",
-						   dev->name);
+					printk(KERN_DEBUG "%s: Resetting the transceiver\n",
+					       dev->name);
 				for (i = 0; i < rst[0]; i++)
 					iowrite32(get_u16(rst + 1 + (i<<1)) << 16, ioaddr + CSR15);
 			}
 			if (tulip_debug > 1)
-				printk(KERN_DEBUG "%s: 21143 non-MII %s transceiver control "
-					   "%4.4x/%4.4x.\n",
-					   dev->name, medianame[dev->if_port], setup[0], setup[1]);
+				printk(KERN_DEBUG "%s: 21143 non-MII %s transceiver control %04x/%04x\n",
+				       dev->name, medianame[dev->if_port],
+				       setup[0], setup[1]);
 			if (p[0] & 0x40) {	/* SIA (CSR13-15) setup values are provided. */
 				csr13val = setup[0];
 				csr14val = setup[1];
@@ -240,8 +239,8 @@ void tulip_select_media(struct net_device *dev, int startup)
 				if (startup) iowrite32(csr13val, ioaddr + CSR13);
 			}
 			if (tulip_debug > 1)
-				printk(KERN_DEBUG "%s:  Setting CSR15 to %8.8x/%8.8x.\n",
-					   dev->name, csr15dir, csr15val);
+				printk(KERN_DEBUG "%s:  Setting CSR15 to %08x/%08x\n",
+				       dev->name, csr15dir, csr15val);
 			if (mleaf->type == 4)
 				new_csr6 = 0x82020000 | ((setup[2] & 0x71) << 18);
 			else
@@ -317,8 +316,9 @@ void tulip_select_media(struct net_device *dev, int startup)
 				if (tp->mii_advertise == 0)
 					tp->mii_advertise = tp->advertising[phy_num];
 				if (tulip_debug > 1)
-					printk(KERN_DEBUG "%s:  Advertising %4.4x on MII %d.\n",
-					       dev->name, tp->mii_advertise, tp->phys[phy_num]);
+					printk(KERN_DEBUG "%s:  Advertising %04x on MII %d\n",
+					       dev->name, tp->mii_advertise,
+					       tp->phys[phy_num]);
 				tulip_mdio_write(dev, tp->phys[phy_num], 4, tp->mii_advertise);
 			}
 			break;
@@ -335,8 +335,8 @@ void tulip_select_media(struct net_device *dev, int startup)
 				struct medialeaf *rleaf = &mtable->mleaf[mtable->has_reset];
 				unsigned char *rst = rleaf->leafdata;
 				if (tulip_debug > 1)
-					printk(KERN_DEBUG "%s: Resetting the transceiver.\n",
-						   dev->name);
+					printk(KERN_DEBUG "%s: Resetting the transceiver\n",
+					       dev->name);
 				for (i = 0; i < rst[0]; i++)
 					iowrite32(get_u16(rst + 1 + (i<<1)) << 16, ioaddr + CSR15);
 			}
@@ -344,20 +344,20 @@ void tulip_select_media(struct net_device *dev, int startup)
 			break;
 		}
 		default:
-			printk(KERN_DEBUG "%s:  Invalid media table selection %d.\n",
-					   dev->name, mleaf->type);
+			printk(KERN_DEBUG "%s:  Invalid media table selection %d\n",
+			       dev->name, mleaf->type);
 			new_csr6 = 0x020E0000;
 		}
 		if (tulip_debug > 1)
-			printk(KERN_DEBUG "%s: Using media type %s, CSR12 is %2.2x.\n",
-				   dev->name, medianame[dev->if_port],
+			printk(KERN_DEBUG "%s: Using media type %s, CSR12 is %02x\n",
+			       dev->name, medianame[dev->if_port],
 				   ioread32(ioaddr + CSR12) & 0xff);
 	} else if (tp->chip_id == LC82C168) {
 		if (startup && ! tp->medialock)
 			dev->if_port = tp->mii_cnt ? 11 : 0;
 		if (tulip_debug > 1)
-			printk(KERN_DEBUG "%s: PNIC PHY status is %3.3x, media %s.\n",
-				   dev->name, ioread32(ioaddr + 0xB8), medianame[dev->if_port]);
+			printk(KERN_DEBUG "%s: PNIC PHY status is %3.3x, media %s\n",
+			       dev->name, ioread32(ioaddr + 0xB8), medianame[dev->if_port]);
 		if (tp->mii_cnt) {
 			new_csr6 = 0x810C0000;
 			iowrite32(0x0001, ioaddr + CSR15);
@@ -388,10 +388,9 @@ void tulip_select_media(struct net_device *dev, int startup)
 		} else
 			new_csr6 = 0x03860000;
 		if (tulip_debug > 1)
-			printk(KERN_DEBUG "%s: No media description table, assuming "
-				   "%s transceiver, CSR12 %2.2x.\n",
-				   dev->name, medianame[dev->if_port],
-				   ioread32(ioaddr + CSR12));
+			printk(KERN_DEBUG "%s: No media description table, assuming %s transceiver, CSR12 %02x\n",
+			       dev->name, medianame[dev->if_port],
+			       ioread32(ioaddr + CSR12));
 	}
 
 	tp->csr6 = new_csr6 | (tp->csr6 & 0xfdff) | (tp->full_duplex ? 0x0200 : 0);
@@ -415,16 +414,17 @@ int tulip_check_duplex(struct net_device *dev)
 	bmsr = tulip_mdio_read(dev, tp->phys[0], MII_BMSR);
 	lpa = tulip_mdio_read(dev, tp->phys[0], MII_LPA);
 	if (tulip_debug > 1)
-		printk(KERN_INFO "%s: MII status %4.4x, Link partner report "
-			   "%4.4x.\n", dev->name, bmsr, lpa);
+		dev_info(&dev->dev, "MII status %04x, Link partner report %04x\n",
+			 bmsr, lpa);
 	if (bmsr == 0xffff)
 		return -2;
 	if ((bmsr & BMSR_LSTATUS) == 0) {
 		int new_bmsr = tulip_mdio_read(dev, tp->phys[0], MII_BMSR);
 		if ((new_bmsr & BMSR_LSTATUS) == 0) {
 			if (tulip_debug  > 1)
-				printk(KERN_INFO "%s: No link beat on the MII interface,"
-					   " status %4.4x.\n", dev->name, new_bmsr);
+				dev_info(&dev->dev,
+					 "No link beat on the MII interface, status %04x\n",
+					 new_bmsr);
 			return -1;
 		}
 	}
@@ -443,10 +443,10 @@ int tulip_check_duplex(struct net_device *dev)
 		tulip_restart_rxtx(tp);
 
 		if (tulip_debug > 0)
-			printk(KERN_INFO "%s: Setting %s-duplex based on MII"
-				   "#%d link partner capability of %4.4x.\n",
-				   dev->name, tp->full_duplex ? "full" : "half",
-				   tp->phys[0], lpa);
+			dev_info(&dev->dev,
+				 "Setting %s-duplex based on MII#%d link partner capability of %04x\n",
+				 tp->full_duplex ? "full" : "half",
+				 tp->phys[0], lpa);
 		return 1;
 	}
 
@@ -501,15 +501,13 @@ void __devinit tulip_find_mii (struct net_device *dev, int board_idx)
 
 		tp->phys[phy_idx++] = phy;
 
-		printk (KERN_INFO "tulip%d:  MII transceiver #%d "
-			"config %4.4x status %4.4x advertising %4.4x.\n",
+		pr_info("tulip%d:  MII transceiver #%d config %04x status %04x advertising %04x\n",
 			board_idx, phy, mii_reg0, mii_status, mii_advert);
 
 		/* Fixup for DLink with miswired PHY. */
 		if (mii_advert != to_advert) {
-			printk (KERN_DEBUG "tulip%d:  Advertising %4.4x on PHY %d,"
-				" previously advertising %4.4x.\n",
-				board_idx, to_advert, phy, mii_advert);
+			printk(KERN_DEBUG "tulip%d:  Advertising %04x on PHY %d, previously advertising %04x\n",
+			       board_idx, to_advert, phy, mii_advert);
 			tulip_mdio_write (dev, phy, 4, to_advert);
 		}
 
@@ -554,7 +552,7 @@ void __devinit tulip_find_mii (struct net_device *dev, int board_idx)
 	}
 	tp->mii_cnt = phy_idx;
 	if (tp->mtable && tp->mtable->has_mii && phy_idx == 0) {
-		printk (KERN_INFO "tulip%d: ***WARNING***: No MII transceiver found!\n",
+		pr_info("tulip%d: ***WARNING***: No MII transceiver found!\n",
 			board_idx);
 		tp->phys[0] = 1;
 	}
-- 
1.6.6.rc0.57.gad7a

