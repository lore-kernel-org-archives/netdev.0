From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch v3 04/12] DM9000: Cleanups after the resource changes
Date: Tue, 24 Jun 2008 22:16:00 +0100
Message-ID: <20080624211904.612057644@fluff.org.uk>
References: <20080624211556.566149406@fluff.org.uk>
Cc: jeff@garzik.org, laurentp@cse-semaphore.com,
	Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:63990 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753627AbYFXVTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 17:19:07 -0400
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-cleanups0.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the now extraneous checks in dm9000_release_board()
now that the two-resource case is removed. Also remove the
check on pdev->num_resources, as we check the return data
from platform_get_resource() to ensure we have not only
the right number but the right type of resources as well.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.26-rc6-quilt1/drivers/net/dm9000.c
===================================================================
--- linux-2.6.26-rc6-quilt1.orig/drivers/net/dm9000.c	2008-06-15 22:52:31.000000000 +0100
+++ linux-2.6.26-rc6-quilt1/drivers/net/dm9000.c	2008-06-15 23:14:39.000000000 +0100
@@ -505,12 +502,6 @@ dm9000_poll_work(struct work_struct *w)
 static void
 dm9000_release_board(struct platform_device *pdev, struct board_info *db)
 {
-	if (db->data_res == NULL) {
-		if (db->addr_res != NULL)
-			release_mem_region((unsigned long)db->io_addr, 4);
-		return;
-	}
-
 	/* unmap our resources */
 
 	iounmap(db->io_addr);
@@ -518,15 +509,11 @@ dm9000_release_board(struct platform_dev
 
 	/* release the resources */
 
-	if (db->data_req != NULL) {
-		release_resource(db->data_req);
-		kfree(db->data_req);
-	}
+	release_resource(db->data_req);
+	kfree(db->data_req);
 
-	if (db->addr_req != NULL) {
-		release_resource(db->addr_req);
-		kfree(db->addr_req);
-	}
+	release_resource(db->addr_req);
+	kfree(db->addr_req);
 }
 
 static unsigned char dm9000_type_to_char(enum dm9000_type type)
@@ -580,12 +567,6 @@ dm9000_probe(struct platform_device *pde
 
 	INIT_DELAYED_WORK(&db->phy_poll, dm9000_poll_work);
 
-
-	if (pdev->num_resources < 3) {
-		ret = -ENODEV;
-		goto out;
-	}
-
 	db->addr_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	db->data_res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
 	db->irq_res  = platform_get_resource(pdev, IORESOURCE_IRQ, 0);

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
