From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 22/22] NET: DM9000: Show the MAC address source after printing MAC
Date: Mon, 19 Nov 2007 20:39:32 +0000
Message-ID: <20071119204016.482292667@fluff.org>
References: <20071119203910.687238131@fluff.org>
Cc: vince@simtec.co.uk, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:61659 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751746AbXKSVOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 16:14:23 -0500
Content-Disposition: inline; filename=simtec/drivers-net-dm9000-showmacsource.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Show whether the MAC address was read from the EEPROM or
the onboard PAR registers.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.23-quilt5/drivers/net/dm9000.c
===================================================================
--- linux-2.6.23-quilt5.orig/drivers/net/dm9000.c
+++ linux-2.6.23-quilt5/drivers/net/dm9000.c
@@ -515,6 +515,7 @@ dm9000_probe(struct platform_device *pde
 	struct dm9000_plat_data *pdata = pdev->dev.platform_data;
 	struct board_info *db;	/* Point a board information structure */
 	struct net_device *ndev;
+	const unsigned char *mac_src;
 	unsigned long base;
 	int ret = 0;
 	int iosize;
@@ -696,13 +697,16 @@ dm9000_probe(struct platform_device *pde
 	db->mii.mdio_read    = dm9000_phy_read;
 	db->mii.mdio_write   = dm9000_phy_write;
 
+	mac_src = "eeprom";
+
 	/* try reading the node address from the attached EEPROM */
 	for (i = 0; i < 6; i += 2)
 		dm9000_read_eeprom(db, i / 2, ndev->dev_addr+i);
 
 	if (!is_valid_ether_addr(ndev->dev_addr)) {
 		/* try reading from mac */
-
+		
+		mac_src = "chip";
 		for (i = 0; i < 6; i++)
 			ndev->dev_addr[i] = ior(db, i+DM9000_PAR);
 	}
@@ -719,7 +723,7 @@ dm9000_probe(struct platform_device *pde
 		       ndev->name,  db->io_addr, db->io_data, ndev->irq);
 		for (i = 0; i < 5; i++)
 			printk("%02x:", ndev->dev_addr[i]);
-		printk("%02x\n", ndev->dev_addr[5]);
+		printk("%02x (%s)\n", ndev->dev_addr[5], mac_src);
 	}
 	return 0;
 

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
