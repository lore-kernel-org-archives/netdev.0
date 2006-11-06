From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] spider_net: access class_device to find irq
Date: Mon, 6 Nov 2006 13:18:01 -0800
Message-ID: <20061106131801.31242512@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:22708 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1753817AbWKFVTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 16:19:15 -0500
To: Jens Osterkamp <jens@de.ibm.com>, Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Spider net should be using netdev->irq to find irq not "dumpster diving"
off into the PCI device.  This code breaks in -mm when class_device
is eliminated.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- a/drivers/net/spider_net.c	2006-11-06 13:11:48.000000000 -0800
+++ b/drivers/net/spider_net.c	2006-11-06 13:12:50.000000000 -0800
@@ -1919,8 +1919,7 @@
 	spider_net_write_reg(card, SPIDER_NET_GHIINT1MSK, 0);
 	spider_net_write_reg(card, SPIDER_NET_GHIINT2MSK, 0);
 
-	/* free_irq(netdev->irq, netdev);*/
-	free_irq(to_pci_dev(netdev->class_dev.dev)->irq, netdev);
+	free_irq(netdev->irq, netdev);
 
 	spider_net_write_reg(card, SPIDER_NET_GDTDMACCNTR,
 			     SPIDER_NET_DMA_TX_FEND_VALUE);
