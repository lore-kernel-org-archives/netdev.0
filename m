From: Ben Dooks <ben-linux@fluff.org>
Subject: [PATCH 14/24 for-2.6.25] DM9000: Remove EEPROM initialisation code.
Date: Tue, 05 Feb 2008 00:02:13 +0000
Message-ID: <20080205000817.332722350@fluff.org.uk>
References: <20080205000159.432081941@fluff.org.uk>
Cc: jeff@garzik.org, akpm@linux-foundation.org, daniel@caiaq.de,
	laurentp@cse-semaphore.com, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:58717 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758825AbYBEAIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 19:08:23 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-remove-eeprom-program.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the old hack to program an initial EEPROM setting
into the DM9000 as we now have ethtool support for reading
and writing the EEPROM.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.24-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.24-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.24-quilt3/drivers/net/dm9000.c
@@ -191,10 +191,6 @@ static void dm9000_write_eeprom(board_in
 static void dm9000_rx(struct net_device *);
 static void dm9000_hash_table(struct net_device *);
 
-//#define DM9000_PROGRAM_EEPROM
-#ifdef DM9000_PROGRAM_EEPROM
-static void program_eeprom(board_info_t * db);
-#endif
 /* DM9000 network board routine ---------------------------- */
 
 static void
@@ -699,9 +695,6 @@ dm9000_probe(struct platform_device *pde
 	ndev->poll_controller	 = &dm9000_poll_controller;
 #endif
 
-#ifdef DM9000_PROGRAM_EEPROM
-	program_eeprom(db);
-#endif
 	db->msg_enable       = NETIF_MSG_LINK;
 	db->mii.phy_id_mask  = 0x1f;
 	db->mii.reg_num_mask = 0x1f;
@@ -1115,28 +1108,6 @@ dm9000_write_eeprom(board_info_t *db, in
 	mutex_unlock(&db->addr_lock);
 }
 
-#ifdef DM9000_PROGRAM_EEPROM
-/*
- * Only for development:
- * Here we write static data to the eeprom in case
- * we don't have valid content on a new board
- */
-static void
-program_eeprom(board_info_t * db)
-{
-	u16 eeprom[] = { 0x0c00, 0x007f, 0x1300,	/* MAC Address */
-		0x0000,		/* Autoload: accept nothing */
-		0x0a46, 0x9000,	/* Vendor / Product ID */
-		0x0000,		/* pin control */
-		0x0000,
-	};			/* Wake-up mode control */
-	int i;
-	for (i = 0; i < 8; i++)
-		write_srom_word(db, i, eeprom[i]);
-}
-#endif
-
-
 /*
  *  Calculate the CRC valude of the Rx packet
  *  flag = 1 : return the reverse CRC (for the received packet CRC)

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
