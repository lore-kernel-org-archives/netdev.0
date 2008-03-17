From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 5/7][MV643XX_ETH] only print banner once
Date: Mon, 17 Mar 2008 20:18:53 +0100
Message-ID: <20080317191853.GF17828@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Saeed Bishara <saeed@marvell.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:37957 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752947AbYCQTSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 15:18:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When there are multiple mv643xx_eth silicon blocks in the system,
don't print an initialisation message for each and every one of
them.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Index: linux-2.6.25-rc6/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6.25-rc6.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6.25-rc6/drivers/net/mv643xx_eth.c
@@ -1983,9 +1983,11 @@ static int mv643xx_eth_remove(struct pla
 
 static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 {
+	static int mv643xx_version_printed = 0;
 	struct resource *res;
 
-	printk(KERN_NOTICE "MV-643xx 10/100/1000 Ethernet Driver\n");
+	if (!mv643xx_version_printed++)
+		printk(KERN_NOTICE "MV-643xx 10/100/1000 Ethernet Driver\n");
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (res == NULL)
