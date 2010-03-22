From: Dan Carpenter <error27@gmail.com>
Subject: [patch] korina: use resource_size()
Date: Mon, 22 Mar 2010 15:11:45 +0300
Message-ID: <20100322121145.GK21571@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Phil Sutter <n0-1@freewrt.org>, Jiri Pirko <jpirko@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Joe Perches <joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:59996 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014Ab0CVMLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 08:11:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This size calculation is wrong.  It should be end - start + 1.
Use resource_size() to calculate it correctly.

Signed-off-by: Dan Carpenter <error27@gmail.com>
---
I don't have a way to test this, or even to compile it.  :/

diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index 300c224..edaedc7 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -1135,7 +1135,7 @@ static int korina_probe(struct platform_device *pdev)
 
 	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "korina_regs");
 	dev->base_addr = r->start;
-	lp->eth_regs = ioremap_nocache(r->start, r->end - r->start);
+	lp->eth_regs = ioremap_nocache(r->start, resource_size(r));
 	if (!lp->eth_regs) {
 		printk(KERN_ERR DRV_NAME ": cannot remap registers\n");
 		rc = -ENXIO;
@@ -1143,7 +1143,7 @@ static int korina_probe(struct platform_device *pdev)
 	}
 
 	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "korina_dma_rx");
-	lp->rx_dma_regs = ioremap_nocache(r->start, r->end - r->start);
+	lp->rx_dma_regs = ioremap_nocache(r->start, resource_size(r));
 	if (!lp->rx_dma_regs) {
 		printk(KERN_ERR DRV_NAME ": cannot remap Rx DMA registers\n");
 		rc = -ENXIO;
@@ -1151,7 +1151,7 @@ static int korina_probe(struct platform_device *pdev)
 	}
 
 	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "korina_dma_tx");
-	lp->tx_dma_regs = ioremap_nocache(r->start, r->end - r->start);
+	lp->tx_dma_regs = ioremap_nocache(r->start, resource_size(r));
 	if (!lp->tx_dma_regs) {
 		printk(KERN_ERR DRV_NAME ": cannot remap Tx DMA registers\n");
 		rc = -ENXIO;
