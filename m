From: Alexander Kurz <akurz@blala.de>
Subject: [PATCH] net/pcmcia 3com: replacements of printk() with dev_info()
 and friends (fwd)
Date: Tue, 30 Mar 2010 21:01:41 +0400 (MSD)
Message-ID: <alpine.DEB.1.10.1003302019200.11637@blala.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Ken Kawasaki <ken_kawasaki@spring.nifty.jp>,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	Magnus Damm <damm@opensource.se>,
	Ben Hutchings
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
  I wrote a patch as suggested by kernel-janitors.
  It is my first patch, so I highly welcome comments and hints,
  thanks, Alexander Kurz

---------- Forwarded message ----------
Date: Tue, 30 Mar 2010 18:55:33 +0400 (MSD)
From: Alexander Kurz <akurz@blala.de>
To: kernel-janitors@vger.kernel.org
Subject: [PATCH] net/pcmcia 3com: replacements of printk() with dev_info() and
     friends

Hello List,
  I wrote a patch replacing some printk() with dev_info() and friends
  for 3com 16-bit PCMCIA cards.
  As this is my first linux patch, comments are welcome,
  thanks, Alexander Kurz

---------- Forwarded message ----------
Date: Tue, 30 Mar 2010 18:51:43 +0400
From: Alexander Kurz <akurz@blala.de>
To: akurz@blala.de

> From 84616314b126b730528ca10e704d80eabad96ff8 Mon Sep 17 00:00:00 2001
From: Alexander Kurz <akurz@kbdbabel.org>
Date: Tue, 30 Mar 2010 12:08:54 +0200
Subject: [PATCH] net/pcmcia 3com: replacements of printk() with dev_info() and 
friends
  as suggested by kernel-janitors for 3com 16-bit PCMCIA cards

---
  drivers/net/pcmcia/3c574_cs.c |   37 +++++++++++++++++--------------------
  drivers/net/pcmcia/3c589_cs.c |   41 +++++++++++++++++++----------------------
  2 files changed, 36 insertions(+), 42 deletions(-)

diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 3d1d3a7..639cd21 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -396,7 +396,7 @@ static int tc574_config(struct pcmcia_device *link)
  		outw(2<<11, ioaddr + RunnerRdCtrl);
  		mcr = inb(ioaddr + 2);
  		outw(0<<11, ioaddr + RunnerRdCtrl);
-		printk(KERN_INFO "  ASIC rev %d,", mcr>>3);
+		dev_info(&dev->dev, "  ASIC rev %d,", mcr>>3);
  		EL3WINDOW(3);
  		config = inl(ioaddr + Wn3_Config);
  		lp->default_media = (config & Xcvr) >> Xcvr_shift;
@@ -457,11 +457,11 @@ static int tc574_config(struct pcmcia_device *link)

  	strcpy(lp->node.dev_name, dev->name);

-	printk(KERN_INFO "%s: %s at io %#3lx, irq %d, "
+	dev_info(&dev->dev, "%s: %s at io %#3lx, irq %d, "
  	       "hw_addr %pM.\n",
  	       dev->name, cardname, dev->base_addr, dev->irq,
  	       dev->dev_addr);
-	printk(" %dK FIFO split %s Rx:Tx, %sMII interface.\n",
+	dev_info(&dev->dev, " %dK FIFO split %s Rx:Tx, %sMII interface.\n",
  		   8 << config & Ram_size,
  		   ram_split[(config & Ram_split) >> Ram_split_shift],
  		   config & Autoselect ? "autoselect " : "");
@@ -511,12 +511,12 @@ static void dump_status(struct net_device *dev)
  {
  	unsigned int ioaddr = dev->base_addr;
  	EL3WINDOW(1);
-	printk(KERN_INFO "  irq status %04x, rx status %04x, tx status "
+	dev_info(&dev->dev, "  irq status %04x, rx status %04x, tx status "
  		   "%02x, tx free %04x\n", inw(ioaddr+EL3_STATUS),
  		   inw(ioaddr+RxStatus), inb(ioaddr+TxStatus),
  		   inw(ioaddr+TxFree));
  	EL3WINDOW(4);
-	printk(KERN_INFO "  diagnostics: fifo %04x net %04x ethernet %04x"
+	dev_info(&dev->dev, "  diagnostics: fifo %04x net %04x ethernet %04x"
  		   " media %04x\n", inw(ioaddr+0x04), inw(ioaddr+0x06),
  		   inw(ioaddr+0x08), inw(ioaddr+0x0a));
  	EL3WINDOW(1);
@@ -532,7 +532,7 @@ static void tc574_wait_for_completion(struct net_device 
*dev, int cmd)
  	while (--i > 0)
  		if (!(inw(dev->base_addr + EL3_STATUS) & 0x1000)) break;
  	if (i == 0)
-		printk(KERN_NOTICE "%s: command 0x%04x did not complete!\n", 
dev->name, cmd);
+		dev_notice(&dev->dev, "command 0x%04x did not complete!\n", 
cmd);
  }

  /* Read a word from the EEPROM using the regular EEPROM access register.
@@ -736,7 +736,7 @@ static void el3_tx_timeout(struct net_device *dev)
  {
  	unsigned int ioaddr = dev->base_addr;

-	printk(KERN_NOTICE "%s: Transmit timed out!\n", dev->name);
+	dev_notice(&dev->dev, "Transmit timed out!\n");
  	dump_status(dev);
  	dev->stats.tx_errors++;
  	dev->trans_start = jiffies;
@@ -856,8 +856,8 @@ static irqreturn_t el3_interrupt(int irq, void *dev_id)
  				EL3WINDOW(4);
  				fifo_diag = inw(ioaddr + Wn4_FIFODiag);
  				EL3WINDOW(1);
-				printk(KERN_NOTICE "%s: adapter failure, FIFO 
diagnostic"
-					   " register %04x.\n", dev->name, 
fifo_diag);
+				dev_notice(&dev->dev, "adapter failure, FIFO 
diagnostic"
+					   " register %04x.\n", fifo_diag);
  				if (fifo_diag & 0x0400) {
  					/* Tx overrun */
  					tc574_wait_for_completion(dev, 
TxReset);
@@ -911,7 +911,7 @@ static void media_check(unsigned long arg)
  	   this, we can limp along even if the interrupt is blocked */
  	if ((inw(ioaddr + EL3_STATUS) & IntLatch) && (inb(ioaddr + Timer) == 
0xff)) {
  		if (!lp->fast_poll)
-			printk(KERN_INFO "%s: interrupt(s) dropped!\n", 
dev->name);
+			dev_info(&dev->dev, "interrupt(s) dropped!\n");

  		local_irq_save(flags);
  		el3_interrupt(dev->irq, dev);
@@ -934,23 +934,21 @@ static void media_check(unsigned long arg)

  	if (media != lp->media_status) {
  		if ((media ^ lp->media_status) & 0x0004)
-			printk(KERN_INFO "%s: %s link beat\n", dev->name,
+			dev_info(&dev->dev, "%s link beat\n",
  				   (lp->media_status & 0x0004) ? "lost" : 
"found");
  		if ((media ^ lp->media_status) & 0x0020) {
  			lp->partner = 0;
  			if (lp->media_status & 0x0020) {
-				printk(KERN_INFO "%s: autonegotiation 
restarted\n",
-					   dev->name);
+				dev_info(&dev->dev, "autonegotiation 
restarted\n");
  			} else if (partner) {
  				partner &= lp->advertising;
  				lp->partner = partner;
-				printk(KERN_INFO "%s: autonegotiation complete: 
"
-					   "%sbaseT-%cD selected\n", dev->name,
+				dev_info(&dev->dev, "autonegotiation complete: 
"
+					   "%sbaseT-%cD selected\n",
  					   ((partner & 0x0180) ? "100" : "10"),
  					   ((partner & 0x0140) ? 'F' : 'H'));
  			} else {
-				printk(KERN_INFO "%s: link partner did not 
autonegotiate\n",
-					   dev->name);
+				dev_info(&dev->dev, "link partner did not 
autonegotiate\n");
  			}

  			EL3WINDOW(3);
@@ -960,10 +958,9 @@ static void media_check(unsigned long arg)

  		}
  		if (media & 0x0010)
-			printk(KERN_INFO "%s: remote fault detected\n",
-				   dev->name);
+			dev_info(&dev->dev, "remote fault detected\n");
  		if (media & 0x0002)
-			printk(KERN_INFO "%s: jabber detected\n", dev->name);
+			dev_info(&dev->dev, "jabber detected\n");
  		lp->media_status = media;
  	}
  	spin_unlock_irqrestore(&lp->window_lock, flags);
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 091e0b0..9f6736b 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -324,11 +324,11 @@ static int tc589_config(struct pcmcia_device *link)

      strcpy(lp->node.dev_name, dev->name);

-    printk(KERN_INFO "%s: 3Com 3c%s, io %#3lx, irq %d, "
+    dev_info(&dev->dev, "3Com 3c%s, io %#3lx, irq %d, "
  	   "hw_addr %pM\n",
-	   dev->name, (multi ? "562" : "589"), dev->base_addr, dev->irq,
+	   (multi ? "562" : "589"), dev->base_addr, dev->irq,
  	   dev->dev_addr);
-    printk(KERN_INFO "  %dK FIFO split %s Rx:Tx, %s xcvr\n",
+    dev_info(&dev->dev, "  %dK FIFO split %s Rx:Tx, %s xcvr\n",
  	   (fifo & 7) ? 32 : 8, ram_split[(fifo >> 16) & 3],
  	   if_names[dev->if_port]);
      return 0;
@@ -385,8 +385,7 @@ static void tc589_wait_for_completion(struct net_device 
*dev, int cmd)
      while (--i > 0)
  	if (!(inw(dev->base_addr + EL3_STATUS) & 0x1000)) break;
      if (i == 0)
-	printk(KERN_WARNING "%s: command 0x%04x did not complete!\n",
-	       dev->name, cmd);
+	dev_warn(&dev->dev, "command 0x%04x did not complete!\n", cmd);
  }

  /*
@@ -435,12 +434,12 @@ static void dump_status(struct net_device *dev)
  {
      unsigned int ioaddr = dev->base_addr;
      EL3WINDOW(1);
-    printk(KERN_INFO "  irq status %04x, rx status %04x, tx status "
+    dev_info(&dev->dev, "  irq status %04x, rx status %04x, tx status "
  	   "%02x  tx free %04x\n", inw(ioaddr+EL3_STATUS),
  	   inw(ioaddr+RX_STATUS), inb(ioaddr+TX_STATUS),
  	   inw(ioaddr+TX_FREE));
      EL3WINDOW(4);
-    printk(KERN_INFO "  diagnostics: fifo %04x net %04x ethernet %04x"
+    dev_info(&dev->dev, "  diagnostics: fifo %04x net %04x ethernet %04x"
  	   " media %04x\n", inw(ioaddr+0x04), inw(ioaddr+0x06),
  	   inw(ioaddr+0x08), inw(ioaddr+0x0a));
      EL3WINDOW(1);
@@ -504,8 +503,8 @@ static int el3_config(struct net_device *dev, struct ifmap 
*map)
      if ((map->port != (u_char)(-1)) && (map->port != dev->if_port)) {
  	if (map->port <= 3) {
  	    dev->if_port = map->port;
-	    printk(KERN_INFO "%s: switched to %s port\n",
-		   dev->name, if_names[dev->if_port]);
+	    dev_info(&dev->dev, "switched to %s port\n",
+		   if_names[dev->if_port]);
  	    tc589_set_xcvr(dev, dev->if_port);
  	} else
  	    return -EINVAL;
@@ -541,7 +540,7 @@ static void el3_tx_timeout(struct net_device *dev)
  {
      unsigned int ioaddr = dev->base_addr;

-    printk(KERN_WARNING "%s: Transmit timed out!\n", dev->name);
+    dev_warn(&dev->dev, "Transmit timed out!\n");
      dump_status(dev);
      dev->stats.tx_errors++;
      dev->trans_start = jiffies;
@@ -660,8 +659,8 @@ static irqreturn_t el3_interrupt(int irq, void *dev_id)
  		EL3WINDOW(4);
  		fifo_diag = inw(ioaddr + 4);
  		EL3WINDOW(1);
-		printk(KERN_WARNING "%s: adapter failure, FIFO diagnostic"
-		       " register %04x.\n", dev->name, fifo_diag);
+		dev_warn(&dev->dev, "adapter failure, FIFO diagnostic"
+		       " register %04x.\n", fifo_diag);
  		if (fifo_diag & 0x0400) {
  		    /* Tx overrun */
  		    tc589_wait_for_completion(dev, TxReset);
@@ -678,8 +677,8 @@ static irqreturn_t el3_interrupt(int irq, void *dev_id)
  	}

  	if (++i > 10) {
-	    printk(KERN_ERR "%s: infinite loop in interrupt, "
-		   "status %4.4x.\n", dev->name, status);
+	    dev_err(&dev->dev, "infinite loop in interrupt, "
+		   "status %4.4x.\n", status);
  	    /* Clear all interrupts */
  	    outw(AckIntr | 0xFF, ioaddr + EL3_CMD);
  	    break;
@@ -710,7 +709,7 @@ static void media_check(unsigned long arg)
      if ((inw(ioaddr + EL3_STATUS) & IntLatch) &&
  	(inb(ioaddr + EL3_TIMER) == 0xff)) {
  	if (!lp->fast_poll)
-	    printk(KERN_WARNING "%s: interrupt(s) dropped!\n", dev->name);
+	    dev_warn(&dev->dev, "interrupt(s) dropped!\n");

  	local_irq_save(flags);
  	el3_interrupt(dev->irq, dev);
@@ -747,25 +746,23 @@ static void media_check(unsigned long arg)
      if (media != lp->media_status) {
  	if ((media & lp->media_status & 0x8000) &&
  	    ((lp->media_status ^ media) & 0x0800))
-	    printk(KERN_INFO "%s: %s link beat\n", dev->name,
+	    dev_info(&dev->dev, "%s link beat\n",
  		   (lp->media_status & 0x0800 ? "lost" : "found"));
  	else if ((media & lp->media_status & 0x4000) &&
  		 ((lp->media_status ^ media) & 0x0010))
-	    printk(KERN_INFO "%s: coax cable %s\n", dev->name,
+	    dev_info(&dev->dev, "coax cable %s\n",
  		   (lp->media_status & 0x0010 ? "ok" : "problem"));
  	if (dev->if_port == 0) {
  	    if (media & 0x8000) {
  		if (media & 0x0800)
-		    printk(KERN_INFO "%s: flipped to 10baseT\n",
-			   dev->name);
+		    dev_info(&dev->dev, "flipped to 10baseT\n");
  		else
  		    tc589_set_xcvr(dev, 2);
  	    } else if (media & 0x4000) {
  		if (media & 0x0010)
  		    tc589_set_xcvr(dev, 1);
  		else
-		    printk(KERN_INFO "%s: flipped to 10base2\n",
-			   dev->name);
+		    dev_info(&dev->dev, "flipped to 10base2\n");
  	    }
  	}
  	lp->media_status = media;
@@ -875,7 +872,7 @@ static int el3_rx(struct net_device *dev)
  	tc589_wait_for_completion(dev, RxDiscard);
      }
      if (worklimit == 0)
-	printk(KERN_WARNING "%s: too much work in el3_rx!\n", dev->name);
+	dev_warn(&dev->dev, "too much work in el3_rx!\n");
      return 0;
  }

-- 
1.7.0
