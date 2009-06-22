From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] sh_eth: remove redundant test on unsigned
Date: Mon, 22 Jun 2009 19:38:00 +0200
Message-ID: <4A3FC178.7050505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:33134 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261AbZFVPhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 11:37:25 -0400
Received: by ewy6 with SMTP id 6so4796243ewy.37
        for <netdev@vger.kernel.org>; Mon, 22 Jun 2009 08:37:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unsigned boguscnt cannot be less than 0.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
or should I make boguscnt int?

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 341882f..a2d82dd 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -865,8 +865,7 @@ static irqreturn_t sh_eth_interrupt(int irq, void *netdev)
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	struct sh_eth_cpu_data *cd = mdp->cd;
 	irqreturn_t ret = IRQ_NONE;
-	u32 ioaddr, boguscnt = RX_RING_SIZE;
-	u32 intr_status = 0;
+	u32 ioaddr, intr_status = 0;
 
 	ioaddr = ndev->base_addr;
 	spin_lock(&mdp->lock);
@@ -901,12 +900,6 @@ static irqreturn_t sh_eth_interrupt(int irq, void *netdev)
 	if (intr_status & cd->eesr_err_check)
 		sh_eth_error(ndev, intr_status);
 
-	if (--boguscnt < 0) {
-		printk(KERN_WARNING
-		       "%s: Too much work at interrupt, status=0x%4.4x.\n",
-		       ndev->name, intr_status);
-	}
-
 other_irq:
 	spin_unlock(&mdp->lock);
 
