From: Ben Dooks <ben-linux@fluff.org>
Subject: [PATCH 24/24 for-2.6.25] DM9000: Show the MAC address source after printing MAC
Date: Tue, 05 Feb 2008 00:02:23 +0000
Message-ID: <20080205000819.315754327@fluff.org.uk>
References: <20080205000159.432081941@fluff.org.uk>
Cc: jeff@garzik.org, akpm@linux-foundation.org, daniel@caiaq.de,
	laurentp@cse-semaphore.com, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:58742 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758853AbYBEAIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 19:08:25 -0500
Content-Disposition: inline; filename=simtec/drivers-net-dm9000-showmacsource.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Show whether the MAC address was read from the EEPROM or
the onboard PAR registers.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.24-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.24-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.24-quilt3/drivers/net/dm9000.c
@@ -509,6 +509,7 @@ dm9000_probe(struct platform_device *pde
 	struct dm9000_plat_data *pdata = pdev->dev.platform_data;
 	struct board_info *db;	/* Point a board information structure */
 	struct net_device *ndev;
+	const unsigned char *mac_src;
 	unsigned long base;
 	int ret = 0;
 	int iosize;
@@ -687,13 +688,16 @@ dm9000_probe(struct platform_device *pde
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
@@ -707,9 +711,9 @@ dm9000_probe(struct platform_device *pde
 
 	if (ret == 0) {
 		DECLARE_MAC_BUF(mac);
-		printk("%s: dm9000 at %p,%p IRQ %d MAC: %s\n",
+		printk("%s: dm9000 at %p,%p IRQ %d MAC: %s (%s)\n",
 		       ndev->name,  db->io_addr, db->io_data, ndev->irq,
-		       print_mac(mac, ndev->dev_addr));
+		       print_mac(mac, ndev->dev_addr), mac_src);
 	}
 	return 0;
 

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
