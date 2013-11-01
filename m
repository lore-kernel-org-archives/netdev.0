From: Ben Boeckel <mathstuf@gmail.com>
Subject: [PATCHv2 net-next 6/7] smc91c92_cs: replace printk with netdev_ calls
Date: Fri,  1 Nov 2013 00:27:22 -0400
Message-ID: <1383280043-13552-7-git-send-email-mathstuf@gmail.com>
References: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
 <1383280043-13552-1-git-send-email-mathstuf@gmail.com>
Cc: Ben Boeckel <mathstuf@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:43629 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731Ab3KAE1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 00:27:47 -0400
Received: by mail-qc0-f177.google.com with SMTP id u18so2203259qcx.36
        for <netdev@vger.kernel.org>; Thu, 31 Oct 2013 21:27:46 -0700 (PDT)
In-Reply-To: <1383280043-13552-1-git-send-email-mathstuf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Boeckel <mathstuf@gmail.com>
---
 drivers/net/ethernet/smsc/smc91c92_cs.c | 43 ++++++++++++++++-----------------
 1 file changed, 21 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91c92_cs.c b/drivers/net/ethernet/smsc/smc91c92_cs.c
index 656d2e2..8ef70d9 100644
--- a/drivers/net/ethernet/smsc/smc91c92_cs.c
+++ b/drivers/net/ethernet/smsc/smc91c92_cs.c
@@ -740,7 +740,7 @@ static int smc91c92_resume(struct pcmcia_device *link)
 	     (smc->cardid == PRODID_PSION_NET100))) {
 		i = osi_load_firmware(link);
 		if (i) {
-			pr_err("smc91c92_cs: Failed to load firmware\n");
+			netdev_err(dev, "Failed to load firmware\n");
 			return i;
 		}
 	}
@@ -793,7 +793,7 @@ static int check_sig(struct pcmcia_device *link)
     }
 
     if (width) {
-	    pr_info("using 8-bit IO window\n");
+	    netdev_info(dev, "using 8-bit IO window\n");
 
 	    smc91c92_suspend(link);
 	    pcmcia_fixup_iowidth(link);
@@ -1036,7 +1036,7 @@ static void smc_dump(struct net_device *dev)
     save = inw(ioaddr + BANK_SELECT);
     for (w = 0; w < 4; w++) {
 	SMC_SELECT_BANK(w);
-	netdev_printk(KERN_DEBUG, dev, "bank %d: ", w);
+	netdev_dbg(dev, "bank %d: ", w);
 	for (i = 0; i < 14; i += 2)
 	    pr_cont(" %04x", inw(ioaddr + i));
 	pr_cont("\n");
@@ -1213,8 +1213,7 @@ static netdev_tx_t smc_start_xmit(struct sk_buff *skb,
     if (smc->saved_skb) {
 	/* THIS SHOULD NEVER HAPPEN. */
 	dev->stats.tx_aborted_errors++;
-	netdev_printk(KERN_DEBUG, dev,
-		      "Internal error -- sent packet while busy\n");
+	netdev_dbg(dev, "Internal error -- sent packet while busy\n");
 	return NETDEV_TX_BUSY;
     }
     smc->saved_skb = skb;
@@ -1254,7 +1253,7 @@ static netdev_tx_t smc_start_xmit(struct sk_buff *skb,
     }
 
     /* Otherwise defer until the Tx-space-allocated interrupt. */
-    pr_debug("%s: memory allocation deferred.\n", dev->name);
+    netdev_dbg(dev, "memory allocation deferred.\n");
     outw((IM_ALLOC_INT << 8) | (ir & 0xff00), ioaddr + INTERRUPT);
     spin_unlock_irqrestore(&smc->lock, flags);
 
@@ -1317,8 +1316,8 @@ static void smc_eph_irq(struct net_device *dev)
 
     SMC_SELECT_BANK(0);
     ephs = inw(ioaddr + EPH);
-    pr_debug("%s: Ethernet protocol handler interrupt, status"
-	  " %4.4x.\n", dev->name, ephs);
+    netdev_dbg(dev, "Ethernet protocol handler interrupt, status %4.4x.\n",
+	       ephs);
     /* Could be a counter roll-over warning: update stats. */
     card_stats = inw(ioaddr + COUNTER);
     /* single collisions */
@@ -1357,8 +1356,8 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
 
     ioaddr = dev->base_addr;
 
-    pr_debug("%s: SMC91c92 interrupt %d at %#x.\n", dev->name,
-	  irq, ioaddr);
+    netdev_dbg(dev, "SMC91c92 interrupt %d at %#x.\n",
+	       irq, ioaddr);
 
     spin_lock(&smc->lock);
     smc->watchdog = 0;
@@ -1366,8 +1365,8 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
     if ((saved_bank & 0xff00) != 0x3300) {
 	/* The device does not exist -- the card could be off-line, or
 	   maybe it has been ejected. */
-	pr_debug("%s: SMC91c92 interrupt %d for non-existent"
-	      "/ejected device.\n", dev->name, irq);
+	netdev_dbg(dev, "SMC91c92 interrupt %d for non-existent/ejected device.\n",
+		   irq);
 	handled = 0;
 	goto irq_done;
     }
@@ -1380,8 +1379,8 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
 
     do { /* read the status flag, and mask it */
 	status = inw(ioaddr + INTERRUPT) & 0xff;
-	pr_debug("%s: Status is %#2.2x (mask %#2.2x).\n", dev->name,
-	      status, mask);
+	netdev_dbg(dev, "Status is %#2.2x (mask %#2.2x).\n",
+		   status, mask);
 	if ((status & mask) == 0) {
 	    if (bogus_cnt == INTR_WORK)
 		handled = 0;
@@ -1425,15 +1424,15 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
 	    smc_eph_irq(dev);
     } while (--bogus_cnt);
 
-    pr_debug("  Restoring saved registers mask %2.2x bank %4.4x"
-	  " pointer %4.4x.\n", mask, saved_bank, saved_pointer);
+    netdev_dbg(dev, "  Restoring saved registers mask %2.2x bank %4.4x pointer %4.4x.\n",
+	       mask, saved_bank, saved_pointer);
 
     /* restore state register */
     outw((mask<<8), ioaddr + INTERRUPT);
     outw(saved_pointer, ioaddr + POINTER);
     SMC_SELECT_BANK(saved_bank);
 
-    pr_debug("%s: Exiting interrupt IRQ%d.\n", dev->name, irq);
+    netdev_dbg(dev, "Exiting interrupt IRQ%d.\n", irq);
 
 irq_done:
 
@@ -1491,10 +1490,10 @@ static void smc_rx(struct net_device *dev)
     rx_status = inw(ioaddr + DATA_1);
     packet_length = inw(ioaddr + DATA_1) & 0x07ff;
 
-    pr_debug("%s: Receive status %4.4x length %d.\n",
-	  dev->name, rx_status, packet_length);
+    netdev_dbg(dev, "Receive status %4.4x length %d.\n",
+	       rx_status, packet_length);
 
-    if (!(rx_status & RS_ERRORS)) {		
+    if (!(rx_status & RS_ERRORS)) {
 	/* do stuff to make a new packet */
 	struct sk_buff *skb;
 	
@@ -1502,7 +1501,7 @@ static void smc_rx(struct net_device *dev)
 	skb = netdev_alloc_skb(dev, packet_length+2);
 	
 	if (skb == NULL) {
-	    pr_debug("%s: Low memory, packet dropped.\n", dev->name);
+	    netdev_dbg(dev, "Low memory, packet dropped.\n");
 	    dev->stats.rx_dropped++;
 	    outw(MC_RELEASE, ioaddr + MMU_CMD);
 	    return;
@@ -1643,7 +1642,7 @@ static void smc_reset(struct net_device *dev)
     struct smc_private *smc = netdev_priv(dev);
     int i;
 
-    pr_debug("%s: smc91c92 reset called.\n", dev->name);
+    netdev_dbg(dev, "smc91c92 reset called.\n");
 
     /* The first interaction must be a write to bring the chip out
        of sleep mode. */
-- 
1.8.4.2
