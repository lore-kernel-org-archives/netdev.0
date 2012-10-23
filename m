From: Paolo Pisati <p.pisati@gmail.com>
Subject: [PATCH 2/6] stmmac: remove mac address handling as a module parameter
Date: Tue, 23 Oct 2012 19:15:29 +0200
Message-ID: <1351012533-3524-3-git-send-email-p.pisati@gmail.com>
References: <1351012533-3524-1-git-send-email-p.pisati@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:59411 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756995Ab2JWRQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 13:16:22 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so3293692wgb.1
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 10:16:21 -0700 (PDT)
In-Reply-To: <1351012533-3524-1-git-send-email-p.pisati@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Paolo Pisati <p.pisati@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   13 -------------
 1 file changed, 13 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index d4d2bc1..cd8bda7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -93,10 +93,6 @@ static int debug = -1;		/* -1: default, 0: no output, 16:  all */
 module_param(debug, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(debug, "Message Level (0: no output, 16: all)");
 
-static int phyaddr = -1;
-module_param(phyaddr, int, S_IRUGO);
-MODULE_PARM_DESC(phyaddr, "Physical device address");
-
 #define DMA_TX_SIZE 256
 static int dma_txsize = DMA_TX_SIZE;
 module_param(dma_txsize, int, S_IRUGO | S_IWUSR);
@@ -1925,11 +1921,6 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	if (ret < 0)
 		goto out_plat_exit;
 
-	/* Override with kernel parameters if supplied XXX CRS XXX
-	 * this needs to have multiple instances */
-	if ((phyaddr >= 0) && (phyaddr <= 31))
-		priv->plat->phy_addr = phyaddr;
-
 	pr_info("\t%s - (dev. name: %s - id: %d, IRQ #%d\n"
 	       "\tIO base addr: 0x%p)\n", ndev->name, pdev->name,
 	       pdev->id, ndev->irq, addr);
@@ -2165,10 +2156,6 @@ static int __init stmmac_cmdline_opt(char *str)
 		if (!strncmp(opt, "debug:", 6)) {
 			if (strict_strtoul(opt + 6, 0, (unsigned long *)&debug))
 				goto err;
-		} else if (!strncmp(opt, "phyaddr:", 8)) {
-			if (strict_strtoul(opt + 8, 0,
-					   (unsigned long *)&phyaddr))
-				goto err;
 		} else if (!strncmp(opt, "dma_txsize:", 11)) {
 			if (strict_strtoul(opt + 11, 0,
 					   (unsigned long *)&dma_txsize))
-- 
1.7.9.5
