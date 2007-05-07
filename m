From: Ben Dooks <ben-linux@fluff.org>
Subject: [PATCH] DM9000: fix use of kfree() on net device
Date: Mon, 7 May 2007 11:13:25 +0000
Message-ID: <20070507111325.GA32546@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:56208 "EHLO
	aeryn.fluff.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932997AbXEGLk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2007 07:40:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The DM9000 network driver is calling kfree() on an netdev
causing the system to oops if the probe fails. The right
thing to do is call free_netdev().

Thanks to Russell King for spotting this.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

diff -urpN -X ../dontdiff linux-2.6.20/drivers/net/dm9000.c linux-2.6.20-dmfix/drivers/net/dm9000.c
--- linux-2.6.20/drivers/net/dm9000.c	2007-02-04 18:44:54.000000000 +0000
+++ linux-2.6.20-dmfix/drivers/net/dm9000.c	2007-02-12 12:01:22.000000000 +0000
@@ -601,7 +601,7 @@ dm9000_probe(struct platform_device *pde
 	printk("%s: not found (%d).\n", CARDNAME, ret);
 
 	dm9000_release_board(pdev, db);
-	kfree(ndev);
+	free_netdev(ndev);
 
 	return ret;
 }
@@ -1194,7 +1194,7 @@ dm9000_drv_remove(struct platform_device
 
 	unregister_netdev(ndev);
 	dm9000_release_board(pdev, (board_info_t *) ndev->priv);
-	kfree(ndev);		/* free device structure */
+	free_netdev(ndev);		/* free device structure */
 
 	PRINTK1("clean_module() exit\n");
 
-
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
