From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2.6.37?] drivers/net/pcmcia: Use pr_<level> and
	netdev_<level>
Date: Thu, 12 Aug 2010 15:22:51 -0700
Message-ID: <1281651771.15486.55.camel@Joe-Laptop>
References: <20100809153410.GA27238@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	Wolfram Sang <w.sang@pengutronix.de>, David Miller <davem@davemloft.net>
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org>
In-Reply-To: <20100809153410.GA27238@comet.dominikbrodowski.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-pcmcia>,
	<mailto:linux-pcmcia-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-pcmcia/>
List-Post: <mailto:linux-pcmcia@lists.infradead.org>
List-Help: <mailto:linux-pcmcia-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-pcmcia>,
	<mailto:linux-pcmcia-request@lists.infradead.org?subject=subscribe>
Sender: linux-pcmcia-bounces@lists.infradead.org
Errors-To: linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-08-09 at 17:34 +0200, Dominik Brodowski wrote:
> look good from a PCMCIA point of view, therefore:
> Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>

If PCMCIA is still being looked after, then here's
another for you, maybe for 2.6.37.

Use the more descriptive logging message styles.

There are whitespace/indentation errors in the original
sources that these changes do not modify, so checkpatch
errors were cheerfully ignored.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/pcmcia/3c574_cs.c    |   73 ++++++++---------
 drivers/net/pcmcia/3c589_cs.c    |   13 ++--
 drivers/net/pcmcia/axnet_cs.c    |  164 ++++++++++++++++++++------------------
 drivers/net/pcmcia/com20020_cs.c |   32 +++----
 drivers/net/pcmcia/fmvj18x_cs.c  |   60 +++++++-------
 drivers/net/pcmcia/ibmtr_cs.c    |   13 ++--
 drivers/net/pcmcia/nmclan_cs.c   |   54 ++++++-------
 drivers/net/pcmcia/smc91c92_cs.c |   99 ++++++++++-------------
 drivers/net/pcmcia/xirc2ps_cs.c  |  104 +++++++++++-------------
 9 files changed, 298 insertions(+), 314 deletions(-)

diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 10ee106..0e5a50e 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -69,6 +69,8 @@ earlier 3Com products.
 
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
@@ -376,8 +378,8 @@ static int tc574_config(struct pcmcia_device *link)
 		for (i = 0; i < 3; i++)
 			phys_addr[i] = htons(read_eeprom(ioaddr, i + 10));
 		if (phys_addr[0] == htons(0x6060)) {
-			printk(KERN_NOTICE "3c574_cs: IO port conflict at 0x%03lx"
-				   "-0x%03lx\n", dev->base_addr, dev->base_addr+15);
+			pr_notice("IO port conflict at 0x%03lx-0x%03lx\n",
+				  dev->base_addr, dev->base_addr+15);
 			goto failed;
 		}
 	}
@@ -391,7 +393,7 @@ static int tc574_config(struct pcmcia_device *link)
 		outw(2<<11, ioaddr + RunnerRdCtrl);
 		mcr = inb(ioaddr + 2);
 		outw(0<<11, ioaddr + RunnerRdCtrl);
-		printk(KERN_INFO "  ASIC rev %d,", mcr>>3);
+		pr_info("  ASIC rev %d,", mcr>>3);
 		EL3WINDOW(3);
 		config = inl(ioaddr + Wn3_Config);
 		lp->default_media = (config & Xcvr) >> Xcvr_shift;
@@ -428,7 +430,7 @@ static int tc574_config(struct pcmcia_device *link)
 			}
 		}
 		if (phy > 32) {
-			printk(KERN_NOTICE "  No MII transceivers found!\n");
+			pr_notice("  No MII transceivers found!\n");
 			goto failed;
 		}
 		i = mdio_read(ioaddr, lp->phys, 16) | 0x40;
@@ -444,18 +446,16 @@ static int tc574_config(struct pcmcia_device *link)
 	SET_NETDEV_DEV(dev, &link->dev);
 
 	if (register_netdev(dev) != 0) {
-		printk(KERN_NOTICE "3c574_cs: register_netdev() failed\n");
+		pr_notice("register_netdev() failed\n");
 		goto failed;
 	}
 
-	printk(KERN_INFO "%s: %s at io %#3lx, irq %d, "
-	       "hw_addr %pM.\n",
-	       dev->name, cardname, dev->base_addr, dev->irq,
-	       dev->dev_addr);
-	printk(" %dK FIFO split %s Rx:Tx, %sMII interface.\n",
-		   8 << config & Ram_size,
-		   ram_split[(config & Ram_split) >> Ram_split_shift],
-		   config & Autoselect ? "autoselect " : "");
+	netdev_info(dev, "%s at io %#3lx, irq %d, hw_addr %pM\n",
+		    cardname, dev->base_addr, dev->irq, dev->dev_addr);
+	netdev_info(dev, " %dK FIFO split %s Rx:Tx, %sMII interface.\n",
+		    8 << config & Ram_size,
+		    ram_split[(config & Ram_split) >> Ram_split_shift],
+		    config & Autoselect ? "autoselect " : "");
 
 	return 0;
 
@@ -502,14 +502,14 @@ static void dump_status(struct net_device *dev)
 {
 	unsigned int ioaddr = dev->base_addr;
 	EL3WINDOW(1);
-	printk(KERN_INFO "  irq status %04x, rx status %04x, tx status "
-		   "%02x, tx free %04x\n", inw(ioaddr+EL3_STATUS),
-		   inw(ioaddr+RxStatus), inb(ioaddr+TxStatus),
-		   inw(ioaddr+TxFree));
+	netdev_info(dev, "  irq status %04x, rx status %04x, tx status %02x, tx free %04x\n",
+		    inw(ioaddr+EL3_STATUS),
+		    inw(ioaddr+RxStatus), inb(ioaddr+TxStatus),
+		    inw(ioaddr+TxFree));
 	EL3WINDOW(4);
-	printk(KERN_INFO "  diagnostics: fifo %04x net %04x ethernet %04x"
-		   " media %04x\n", inw(ioaddr+0x04), inw(ioaddr+0x06),
-		   inw(ioaddr+0x08), inw(ioaddr+0x0a));
+	netdev_info(dev, "  diagnostics: fifo %04x net %04x ethernet %04x media %04x\n",
+		    inw(ioaddr+0x04), inw(ioaddr+0x06),
+		    inw(ioaddr+0x08), inw(ioaddr+0x0a));
 	EL3WINDOW(1);
 }
 
@@ -523,7 +523,7 @@ static void tc574_wait_for_completion(struct net_device *dev, int cmd)
 	while (--i > 0)
 		if (!(inw(dev->base_addr + EL3_STATUS) & 0x1000)) break;
 	if (i == 0)
-		printk(KERN_NOTICE "%s: command 0x%04x did not complete!\n", dev->name, cmd);
+		netdev_notice(dev, "command 0x%04x did not complete!\n", cmd);
 }
 
 /* Read a word from the EEPROM using the regular EEPROM access register.
@@ -725,7 +725,7 @@ static void el3_tx_timeout(struct net_device *dev)
 {
 	unsigned int ioaddr = dev->base_addr;
 	
-	printk(KERN_NOTICE "%s: Transmit timed out!\n", dev->name);
+	netdev_notice(dev, "Transmit timed out!\n");
 	dump_status(dev);
 	dev->stats.tx_errors++;
 	dev->trans_start = jiffies; /* prevent tx timeout */
@@ -848,8 +848,8 @@ static irqreturn_t el3_interrupt(int irq, void *dev_id)
 				EL3WINDOW(4);
 				fifo_diag = inw(ioaddr + Wn4_FIFODiag);
 				EL3WINDOW(1);
-				printk(KERN_NOTICE "%s: adapter failure, FIFO diagnostic"
-					   " register %04x.\n", dev->name, fifo_diag);
+				netdev_notice(dev, "adapter failure, FIFO diagnostic register %04x\n",
+					      fifo_diag);
 				if (fifo_diag & 0x0400) {
 					/* Tx overrun */
 					tc574_wait_for_completion(dev, TxReset);
@@ -903,7 +903,7 @@ static void media_check(unsigned long arg)
 	   this, we can limp along even if the interrupt is blocked */
 	if ((inw(ioaddr + EL3_STATUS) & IntLatch) && (inb(ioaddr + Timer) == 0xff)) {
 		if (!lp->fast_poll)
-			printk(KERN_INFO "%s: interrupt(s) dropped!\n", dev->name);
+			netdev_info(dev, "interrupt(s) dropped!\n");
 
 		local_irq_save(flags);
 		el3_interrupt(dev->irq, dev);
@@ -926,23 +926,21 @@ static void media_check(unsigned long arg)
 	
 	if (media != lp->media_status) {
 		if ((media ^ lp->media_status) & 0x0004)
-			printk(KERN_INFO "%s: %s link beat\n", dev->name,
-				   (lp->media_status & 0x0004) ? "lost" : "found");
+			netdev_info(dev, "%s link beat\n",
+				    (lp->media_status & 0x0004) ? "lost" : "found");
 		if ((media ^ lp->media_status) & 0x0020) {
 			lp->partner = 0;
 			if (lp->media_status & 0x0020) {
-				printk(KERN_INFO "%s: autonegotiation restarted\n",
-					   dev->name);
+				netdev_info(dev, "autonegotiation restarted\n");
 			} else if (partner) {
 				partner &= lp->advertising;
 				lp->partner = partner;
-				printk(KERN_INFO "%s: autonegotiation complete: "
-					   "%sbaseT-%cD selected\n", dev->name,
-					   ((partner & 0x0180) ? "100" : "10"),
-					   ((partner & 0x0140) ? 'F' : 'H'));
+				netdev_info(dev, "autonegotiation complete: "
+					    "%dbaseT-%cD selected\n",
+					    (partner & 0x0180) ? 100 : 10,
+					    (partner & 0x0140) ? 'F' : 'H');
 			} else {
-				printk(KERN_INFO "%s: link partner did not autonegotiate\n",
-					   dev->name);
+				netdev_info(dev, "link partner did not autonegotiate\n");
 			}
 
 			EL3WINDOW(3);
@@ -952,10 +950,9 @@ static void media_check(unsigned long arg)
 
 		}
 		if (media & 0x0010)
-			printk(KERN_INFO "%s: remote fault detected\n",
-				   dev->name);
+			netdev_info(dev, "remote fault detected\n");
 		if (media & 0x0002)
-			printk(KERN_INFO "%s: jabber detected\n", dev->name);
+			netdev_info(dev, "jabber detected\n");
 		lp->media_status = media;
 	}
 	spin_unlock_irqrestore(&lp->window_lock, flags);
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index ce63c37..0b01c85 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -19,6 +19,8 @@
 
 ======================================================================*/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define DRV_NAME	"3c589_cs"
 #define DRV_VERSION	"1.162-ac"
 
@@ -274,8 +276,7 @@ static int tc589_config(struct pcmcia_device *link)
     phys_addr = (__be16 *)dev->dev_addr;
     /* Is this a 3c562? */
     if (link->manf_id != MANFID_3COM)
-	    printk(KERN_INFO "3c589_cs: hmmm, is this really a "
-		   "3Com card??\n");
+	    dev_info(&link->dev, "hmmm, is this really a 3Com card??\n");
     multi = (link->card_id == PRODID_3COM_3C562);
 
     /* For the 3c562, the base address must be xx00-xx7f */
@@ -315,8 +316,8 @@ static int tc589_config(struct pcmcia_device *link)
 	for (i = 0; i < 3; i++)
 	    phys_addr[i] = htons(read_eeprom(ioaddr, i));
 	if (phys_addr[0] == htons(0x6060)) {
-	    printk(KERN_ERR "3c589_cs: IO port conflict at 0x%03lx"
-		   "-0x%03lx\n", dev->base_addr, dev->base_addr+15);
+	    dev_err(&link->dev, "IO port conflict at 0x%03lx-0x%03lx\n",
+		    dev->base_addr, dev->base_addr+15);
 	    goto failed;
 	}
     }
@@ -330,12 +331,12 @@ static int tc589_config(struct pcmcia_device *link)
     if ((if_port >= 0) && (if_port <= 3))
 	dev->if_port = if_port;
     else
-	printk(KERN_ERR "3c589_cs: invalid if_port requested\n");
+	dev_err(&link->dev, "invalid if_port requested\n");
 
     SET_NETDEV_DEV(dev, &link->dev);
 
     if (register_netdev(dev) != 0) {
-	printk(KERN_ERR "3c589_cs: register_netdev() failed\n");
+	    dev_err(&link->dev, "register_netdev() failed\n");
 	goto failed;
     }
 
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 33525bf..13e9ec8 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -24,6 +24,8 @@
 
 ======================================================================*/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/init.h>
@@ -346,8 +348,8 @@ static int axnet_config(struct pcmcia_device *link)
     dev->base_addr = link->io.BasePort1;
 
     if (!get_prom(link)) {
-	printk(KERN_NOTICE "axnet_cs: this is not an AX88190 card!\n");
-	printk(KERN_NOTICE "axnet_cs: use pcnet_cs instead.\n");
+	pr_notice("this is not an AX88190 card!\n");
+	pr_notice("use pcnet_cs instead.\n");
 	goto failed;
     }
 
@@ -393,19 +395,18 @@ static int axnet_config(struct pcmcia_device *link)
     SET_NETDEV_DEV(dev, &link->dev);
 
     if (register_netdev(dev) != 0) {
-	printk(KERN_NOTICE "axnet_cs: register_netdev() failed\n");
+	pr_notice("register_netdev() failed\n");
 	goto failed;
     }
 
-    printk(KERN_INFO "%s: Asix AX88%d90: io %#3lx, irq %d, "
-	   "hw_addr %pM\n",
-	   dev->name, ((info->flags & IS_AX88790) ? 7 : 1),
-	   dev->base_addr, dev->irq,
-	   dev->dev_addr);
+    netdev_info(dev, "Asix AX88%d90: io %#3lx, irq %d, hw_addr %pM\n",
+		((info->flags & IS_AX88790) ? 7 : 1),
+		dev->base_addr, dev->irq, dev->dev_addr);
     if (info->phy_id != -1) {
-	dev_dbg(&link->dev, "  MII transceiver at index %d, status %x.\n", info->phy_id, j);
+	netdev_dbg(dev, "  MII transceiver at index %d, status %x\n",
+		   info->phy_id, j);
     } else {
-	printk(KERN_NOTICE "  No MII transceivers found!\n");
+	netdev_notice(dev, "  No MII transceivers found!\n");
     }
     return 0;
 
@@ -585,8 +586,7 @@ static void axnet_reset_8390(struct net_device *dev)
     outb_p(ENISR_RESET, nic_base + EN0_ISR); /* Ack intr. */
     
     if (i == 100)
-	printk(KERN_ERR "%s: axnet_reset_8390() did not complete.\n",
-	       dev->name);
+	netdev_err(dev, "axnet_reset_8390() did not complete\n");
     
 } /* axnet_reset_8390 */
 
@@ -613,7 +613,7 @@ static void ei_watchdog(u_long arg)
        this, we can limp along even if the interrupt is blocked */
     if (info->stale++ && (inb_p(nic_base + EN0_ISR) & ENISR_ALL)) {
 	if (!info->fast_poll)
-	    printk(KERN_INFO "%s: interrupt(s) dropped!\n", dev->name);
+	    netdev_info(dev, "interrupt(s) dropped!\n");
 	ei_irq_wrapper(dev->irq, dev);
 	info->fast_poll = HZ;
     }
@@ -628,7 +628,7 @@ static void ei_watchdog(u_long arg)
 	goto reschedule;
     link = mdio_read(mii_addr, info->phy_id, 1);
     if (!link || (link == 0xffff)) {
-	printk(KERN_INFO "%s: MII is missing!\n", dev->name);
+	netdev_info(dev, "MII is missing!\n");
 	info->phy_id = -1;
 	goto reschedule;
     }
@@ -636,18 +636,14 @@ static void ei_watchdog(u_long arg)
     link &= 0x0004;
     if (link != info->link_status) {
 	u_short p = mdio_read(mii_addr, info->phy_id, 5);
-	printk(KERN_INFO "%s: %s link beat\n", dev->name,
-	       (link) ? "found" : "lost");
+	netdev_info(dev, "%s link beat\n", link ? "found" : "lost");
 	if (link) {
 	    info->duplex_flag = (p & 0x0140) ? 0x80 : 0x00;
 	    if (p)
-		printk(KERN_INFO "%s: autonegotiation complete: "
-		       "%sbaseT-%cD selected\n", dev->name,
-		       ((p & 0x0180) ? "100" : "10"),
-		       ((p & 0x0140) ? 'F' : 'H'));
+		netdev_info(dev, "autonegotiation complete: %dbaseT-%cD selected\n",
+			    (p & 0x0180) ? 100 : 10, (p & 0x0140) ? 'F' : 'H');
 	    else
-		printk(KERN_INFO "%s: link partner did not autonegotiate\n",
-		       dev->name);
+		netdev_info(dev, "link partner did not autonegotiate\n");
 	    AX88190_init(dev, 1);
 	}
 	info->link_status = link;
@@ -855,9 +851,6 @@ module_exit(exit_axnet_cs);
 
   */
 
-static const char version_8390[] = KERN_INFO \
-    "8390.c:v1.10cvs 9/23/94 Donald Becker (becker@scyld.com)\n";
-
 #include <linux/bitops.h>
 #include <asm/irq.h>
 #include <linux/fcntl.h>
@@ -1004,9 +997,11 @@ static void axnet_tx_timeout(struct net_device *dev)
 	isr = inb(e8390_base+EN0_ISR);
 	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 
-	printk(KERN_DEBUG "%s: Tx timed out, %s TSR=%#2x, ISR=%#2x, t=%d.\n",
-		dev->name, (txsr & ENTSR_ABT) ? "excess collisions." :
-		(isr) ? "lost interrupt?" : "cable problem?", txsr, isr, tickssofar);
+	netdev_printk(KERN_DEBUG, dev,
+		      "Tx timed out, %s TSR=%#2x, ISR=%#2x, t=%d.\n",
+		      (txsr & ENTSR_ABT) ? "excess collisions." :
+		      (isr) ? "lost interrupt?" : "cable problem?",
+		      txsr, isr, tickssofar);
 
 	if (!isr && !dev->stats.tx_packets) 
 	{
@@ -1076,22 +1071,28 @@ static netdev_tx_t axnet_start_xmit(struct sk_buff *skb,
 		output_page = ei_local->tx_start_page;
 		ei_local->tx1 = send_length;
 		if (ei_debug  &&  ei_local->tx2 > 0)
-			printk(KERN_DEBUG "%s: idle transmitter tx2=%d, lasttx=%d, txing=%d.\n",
-				dev->name, ei_local->tx2, ei_local->lasttx, ei_local->txing);
+			netdev_printk(KERN_DEBUG, dev,
+				      "idle transmitter tx2=%d, lasttx=%d, txing=%d\n",
+				      ei_local->tx2, ei_local->lasttx,
+				      ei_local->txing);
 	}
 	else if (ei_local->tx2 == 0) 
 	{
 		output_page = ei_local->tx_start_page + TX_PAGES/2;
 		ei_local->tx2 = send_length;
 		if (ei_debug  &&  ei_local->tx1 > 0)
-			printk(KERN_DEBUG "%s: idle transmitter, tx1=%d, lasttx=%d, txing=%d.\n",
-				dev->name, ei_local->tx1, ei_local->lasttx, ei_local->txing);
+			netdev_printk(KERN_DEBUG, dev,
+				      "idle transmitter, tx1=%d, lasttx=%d, txing=%d\n",
+				      ei_local->tx1, ei_local->lasttx,
+				      ei_local->txing);
 	}
 	else
 	{	/* We should never get here. */
 		if (ei_debug)
-			printk(KERN_DEBUG "%s: No Tx buffers free! tx1=%d tx2=%d last=%d\n",
-				dev->name, ei_local->tx1, ei_local->tx2, ei_local->lasttx);
+			netdev_printk(KERN_DEBUG, dev,
+				      "No Tx buffers free! tx1=%d tx2=%d last=%d\n",
+				      ei_local->tx1, ei_local->tx2,
+				      ei_local->lasttx);
 		ei_local->irqlock = 0;
 		netif_stop_queue(dev);
 		outb_p(ENISR_ALL, e8390_base + EN0_IMR);
@@ -1179,23 +1180,26 @@ static irqreturn_t ax_interrupt(int irq, void *dev_id)
 	 
 	spin_lock_irqsave(&ei_local->page_lock, flags);
 
-	if (ei_local->irqlock) 
-	{
+	if (ei_local->irqlock) {
 #if 1 /* This might just be an interrupt for a PCI device sharing this line */
+		const char *msg;
 		/* The "irqlock" check is only for testing. */
-		printk(ei_local->irqlock
-			   ? "%s: Interrupted while interrupts are masked! isr=%#2x imr=%#2x.\n"
-			   : "%s: Reentering the interrupt handler! isr=%#2x imr=%#2x.\n",
-			   dev->name, inb_p(e8390_base + EN0_ISR),
-			   inb_p(e8390_base + EN0_IMR));
+		if (ei_local->irqlock)
+			msg = "Interrupted while interrupts are masked!";
+		else
+			msg = "Reentering the interrupt handler!";
+		netdev_info(dev, "%s, isr=%#2x imr=%#2x\n",
+			    msg,
+			    inb_p(e8390_base + EN0_ISR),
+			    inb_p(e8390_base + EN0_IMR));
 #endif
 		spin_unlock_irqrestore(&ei_local->page_lock, flags);
 		return IRQ_NONE;
 	}
     
 	if (ei_debug > 3)
-		printk(KERN_DEBUG "%s: interrupt(isr=%#2.2x).\n", dev->name,
-			   inb_p(e8390_base + EN0_ISR));
+		netdev_printk(KERN_DEBUG, dev, "interrupt(isr=%#2.2x)\n",
+			      inb_p(e8390_base + EN0_ISR));
 
 	outb_p(0x00, e8390_base + EN0_ISR);
 	ei_local->irqlock = 1;
@@ -1206,7 +1210,8 @@ static irqreturn_t ax_interrupt(int irq, void *dev_id)
 	{
 		if (!netif_running(dev) || (interrupts == 0xff)) {
 			if (ei_debug > 1)
-				printk(KERN_WARNING "%s: interrupt from stopped card\n", dev->name);
+				netdev_warn(dev,
+					    "interrupt from stopped card\n");
 			outb_p(interrupts, e8390_base + EN0_ISR);
 			interrupts = 0;
 			break;
@@ -1249,11 +1254,12 @@ static irqreturn_t ax_interrupt(int irq, void *dev_id)
 		{
 			/* 0xFF is valid for a card removal */
 			if(interrupts!=0xFF)
-				printk(KERN_WARNING "%s: Too much work at interrupt, status %#2.2x\n",
-				   dev->name, interrupts);
+				netdev_warn(dev, "Too much work at interrupt, status %#2.2x\n",
+					    interrupts);
 			outb_p(ENISR_ALL, e8390_base + EN0_ISR); /* Ack. most intrs. */
 		} else {
-			printk(KERN_WARNING "%s: unknown interrupt %#2x\n", dev->name, interrupts);
+			netdev_warn(dev, "unknown interrupt %#2x\n",
+				    interrupts);
 			outb_p(0xff, e8390_base + EN0_ISR); /* Ack. all intrs. */
 		}
 	}
@@ -1287,18 +1293,19 @@ static void ei_tx_err(struct net_device *dev)
 	unsigned char tx_was_aborted = txsr & (ENTSR_ABT+ENTSR_FU);
 
 #ifdef VERBOSE_ERROR_DUMP
-	printk(KERN_DEBUG "%s: transmitter error (%#2x): ", dev->name, txsr);
+	netdev_printk(KERN_DEBUG, dev,
+		      "transmitter error (%#2x):", txsr);
 	if (txsr & ENTSR_ABT)
-		printk("excess-collisions ");
+		pr_cont(" excess-collisions");
 	if (txsr & ENTSR_ND)
-		printk("non-deferral ");
+		pr_cont(" non-deferral");
 	if (txsr & ENTSR_CRS)
-		printk("lost-carrier ");
+		pr_cont(" lost-carrier");
 	if (txsr & ENTSR_FU)
-		printk("FIFO-underrun ");
+		pr_cont(" FIFO-underrun");
 	if (txsr & ENTSR_CDH)
-		printk("lost-heartbeat ");
-	printk("\n");
+		pr_cont(" lost-heartbeat");
+	pr_cont("\n");
 #endif
 
 	if (tx_was_aborted)
@@ -1335,8 +1342,9 @@ static void ei_tx_intr(struct net_device *dev)
 	if (ei_local->tx1 < 0) 
 	{
 		if (ei_local->lasttx != 1 && ei_local->lasttx != -1)
-			printk(KERN_ERR "%s: bogus last_tx_buffer %d, tx1=%d.\n",
-				ei_local->name, ei_local->lasttx, ei_local->tx1);
+			netdev_err(dev, "%s: bogus last_tx_buffer %d, tx1=%d\n",
+				   ei_local->name, ei_local->lasttx,
+				   ei_local->tx1);
 		ei_local->tx1 = 0;
 		if (ei_local->tx2 > 0) 
 		{
@@ -1351,8 +1359,9 @@ static void ei_tx_intr(struct net_device *dev)
 	else if (ei_local->tx2 < 0) 
 	{
 		if (ei_local->lasttx != 2  &&  ei_local->lasttx != -2)
-			printk("%s: bogus last_tx_buffer %d, tx2=%d.\n",
-				ei_local->name, ei_local->lasttx, ei_local->tx2);
+			netdev_info(dev, "%s: bogus last_tx_buffer %d, tx2=%d\n",
+				    ei_local->name, ei_local->lasttx,
+				    ei_local->tx2);
 		ei_local->tx2 = 0;
 		if (ei_local->tx1 > 0) 
 		{
@@ -1365,8 +1374,9 @@ static void ei_tx_intr(struct net_device *dev)
 		else
 			ei_local->lasttx = 10, ei_local->txing = 0;
 	}
-//	else printk(KERN_WARNING "%s: unexpected TX-done interrupt, lasttx=%d.\n",
-//			dev->name, ei_local->lasttx);
+//	else
+//		netdev_warn(dev, "unexpected TX-done interrupt, lasttx=%d\n",
+//			    ei_local->lasttx);
 
 	/* Minimize Tx latency: update the statistics after we restart TXing. */
 	if (status & ENTSR_COL)
@@ -1429,8 +1439,8 @@ static void ei_receive(struct net_device *dev)
 		   is that some clones crash in roughly the same way.
 		 */
 		if (ei_debug > 0  &&  this_frame != ei_local->current_page && (this_frame!=0x0 || rxing_page!=0xFF))
-			printk(KERN_ERR "%s: mismatched read page pointers %2x vs %2x.\n",
-				   dev->name, this_frame, ei_local->current_page);
+		    netdev_err(dev, "mismatched read page pointers %2x vs %2x\n",
+			       this_frame, ei_local->current_page);
 		
 		if (this_frame == rxing_page)	/* Read all the frames? */
 			break;				/* Done for now */
@@ -1446,9 +1456,10 @@ static void ei_receive(struct net_device *dev)
 		if (pkt_len < 60  ||  pkt_len > 1518) 
 		{
 			if (ei_debug)
-				printk(KERN_DEBUG "%s: bogus packet size: %d, status=%#2x nxpg=%#2x.\n",
-					   dev->name, rx_frame.count, rx_frame.status,
-					   rx_frame.next);
+				netdev_printk(KERN_DEBUG, dev,
+					      "bogus packet size: %d, status=%#2x nxpg=%#2x\n",
+					      rx_frame.count, rx_frame.status,
+					      rx_frame.next);
 			dev->stats.rx_errors++;
 			dev->stats.rx_length_errors++;
 		}
@@ -1460,8 +1471,9 @@ static void ei_receive(struct net_device *dev)
 			if (skb == NULL) 
 			{
 				if (ei_debug > 1)
-					printk(KERN_DEBUG "%s: Couldn't allocate a sk_buff of size %d.\n",
-						   dev->name, pkt_len);
+					netdev_printk(KERN_DEBUG, dev,
+						      "Couldn't allocate a sk_buff of size %d\n",
+						      pkt_len);
 				dev->stats.rx_dropped++;
 				break;
 			}
@@ -1481,9 +1493,10 @@ static void ei_receive(struct net_device *dev)
 		else 
 		{
 			if (ei_debug)
-				printk(KERN_DEBUG "%s: bogus packet: status=%#2x nxpg=%#2x size=%d\n",
-					   dev->name, rx_frame.status, rx_frame.next,
-					   rx_frame.count);
+				netdev_printk(KERN_DEBUG, dev,
+					      "bogus packet: status=%#2x nxpg=%#2x size=%d\n",
+					      rx_frame.status, rx_frame.next,
+					      rx_frame.count);
 			dev->stats.rx_errors++;
 			/* NB: The NIC counts CRC, frame and missed errors. */
 			if (pkt_stat & ENRSR_FO)
@@ -1493,8 +1506,8 @@ static void ei_receive(struct net_device *dev)
 		
 		/* This _should_ never happen: it's here for avoiding bad clones. */
 		if (next_frame >= ei_local->stop_page) {
-			printk("%s: next frame inconsistency, %#2x\n", dev->name,
-				   next_frame);
+			netdev_info(dev, "next frame inconsistency, %#2x\n",
+				    next_frame);
 			next_frame = ei_local->rx_start_page;
 		}
 		ei_local->current_page = next_frame;
@@ -1529,7 +1542,7 @@ static void ei_rx_overrun(struct net_device *dev)
 	outb_p(E8390_NODMA+E8390_PAGE0+E8390_STOP, e8390_base+E8390_CMD);
     
 	if (ei_debug > 1)
-		printk(KERN_DEBUG "%s: Receiver overrun.\n", dev->name);
+		netdev_printk(KERN_DEBUG, dev, "Receiver overrun\n");
 	dev->stats.rx_over_errors++;
     
 	/* 
@@ -1726,7 +1739,7 @@ static void AX88190_init(struct net_device *dev, int startp)
 	{
 		outb_p(dev->dev_addr[i], e8390_base + EN1_PHYS_SHIFT(i));
 		if(inb_p(e8390_base + EN1_PHYS_SHIFT(i))!=dev->dev_addr[i])
-			printk(KERN_ERR "Hw. address read/write mismap %d\n",i);
+			netdev_err(dev, "Hw. address read/write mismap %d\n", i);
 	}
 
 	outb_p(ei_local->rx_start_page, e8390_base + EN1_CURPAG);
@@ -1763,8 +1776,7 @@ static void NS8390_trigger_send(struct net_device *dev, unsigned int length,
     
 	if (inb_p(e8390_base) & E8390_TRANS) 
 	{
-		printk(KERN_WARNING "%s: trigger_send() called with the transmitter busy.\n",
-			dev->name);
+		netdev_warn(dev, "trigger_send() called with the transmitter busy\n");
 		return;
 	}
 	outb_p(length & 0xff, e8390_base + EN0_TCNTLO);
diff --git a/drivers/net/pcmcia/com20020_cs.c b/drivers/net/pcmcia/com20020_cs.c
index 5643f94..02b9eb2 100644
--- a/drivers/net/pcmcia/com20020_cs.c
+++ b/drivers/net/pcmcia/com20020_cs.c
@@ -53,23 +53,23 @@
 
 #define VERSION "arcnet: COM20020 PCMCIA support loaded.\n"
 
-#ifdef DEBUG
 
 static void regdump(struct net_device *dev)
 {
+#ifdef DEBUG
     int ioaddr = dev->base_addr;
     int count;
     
-    printk("com20020 register dump:\n");
+    netdev_dbg(dev, "register dump:\n");
     for (count = ioaddr; count < ioaddr + 16; count++)
     {
 	if (!(count % 16))
-	    printk("\n%04X: ", count);
-	printk("%02X ", inb(count));
+	    pr_cont("%04X:", count);
+	pr_cont(" %02X", inb(count));
     }
-    printk("\n");
+    pr_cont("\n");
     
-    printk("buffer0 dump:\n");
+    netdev_dbg(dev, "buffer0 dump:\n");
 	/* set up the address register */
         count = 0;
 	outb((count >> 8) | RDDATAflag | AUTOINCflag, _ADDR_HI);
@@ -78,19 +78,15 @@ static void regdump(struct net_device *dev)
     for (count = 0; count < 256+32; count++)
     {
 	if (!(count % 16))
-	    printk("\n%04X: ", count);
+	    pr_cont("%04X:", count);
 	
 	/* copy the data */
-	printk("%02X ", inb(_MEMDATA));
+	pr_cont(" %02X", inb(_MEMDATA));
     }
-    printk("\n");
+    pr_cont("\n");
+#endif
 }
 
-#else
-
-static inline void regdump(struct net_device *dev) { }
-
-#endif
 
 
 /*====================================================================*/
@@ -299,13 +295,13 @@ static int com20020_config(struct pcmcia_device *link)
     i = com20020_found(dev, 0);	/* calls register_netdev */
     
     if (i != 0) {
-	dev_printk(KERN_NOTICE, &link->dev,
-		"com20020_cs: com20020_found() failed\n");
+	dev_notice(&link->dev,
+		   "com20020_found() failed\n");
 	goto failed;
     }
 
-    dev_dbg(&link->dev,KERN_INFO "%s: port %#3lx, irq %d\n",
-           dev->name, dev->base_addr, dev->irq);
+    netdev_dbg(dev, "port %#3lx, irq %d\n",
+	       dev->base_addr, dev->irq);
     return 0;
 
 failed:
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 7c27c50..c8f9cea 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -28,6 +28,8 @@
    
 ======================================================================*/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define DRV_NAME	"fmvj18x_cs"
 #define DRV_VERSION	"2.9"
 
@@ -293,7 +295,7 @@ static int mfc_try_io_port(struct pcmcia_device *link)
 	link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
 	if (link->io.BasePort2 == 0) {
 	    link->io.NumPorts2 = 0;
-	    printk(KERN_NOTICE "fmvj18x_cs: out of resource for serial\n");
+	    pr_notice("out of resource for serial\n");
 	}
 	ret = pcmcia_request_io(link, &link->io);
 	if (ret == 0)
@@ -503,7 +505,7 @@ static int fmvj18x_config(struct pcmcia_device *link)
     case XXX10304:
 	/* Read MACID from Buggy CIS */
 	if (fmvj18x_get_hwinfo(link, buggybuf) == -1) {
-	    printk(KERN_NOTICE "fmvj18x_cs: unable to read hardware net address.\n");
+	    pr_notice("unable to read hardware net address\n");
 	    goto failed;
 	}
 	for (i = 0 ; i < 6; i++) {
@@ -524,15 +526,14 @@ static int fmvj18x_config(struct pcmcia_device *link)
     SET_NETDEV_DEV(dev, &link->dev);
 
     if (register_netdev(dev) != 0) {
-	printk(KERN_NOTICE "fmvj18x_cs: register_netdev() failed\n");
+	pr_notice("register_netdev() failed\n");
 	goto failed;
     }
 
     /* print current configuration */
-    printk(KERN_INFO "%s: %s, sram %s, port %#3lx, irq %d, "
-	   "hw_addr %pM\n",
-	   dev->name, card_name, sram_config == 0 ? "4K TX*2" : "8K TX*2", 
-	   dev->base_addr, dev->irq, dev->dev_addr);
+    netdev_info(dev, "%s, sram %s, port %#3lx, irq %d, hw_addr %pM\n",
+		card_name, sram_config == 0 ? "4K TX*2" : "8K TX*2",
+		dev->base_addr, dev->irq, dev->dev_addr);
 
     return 0;
     
@@ -610,7 +611,7 @@ static int fmvj18x_setup_mfc(struct pcmcia_device *link)
 
     lp->base = ioremap(req.Base, req.Size);
     if (lp->base == NULL) {
-	printk(KERN_NOTICE "fmvj18x_cs: ioremap failed\n");
+	netdev_notice(dev, "ioremap failed\n");
 	return -1;
     }
 
@@ -806,17 +807,16 @@ static void fjn_tx_timeout(struct net_device *dev)
     struct local_info_t *lp = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
 
-    printk(KERN_NOTICE "%s: transmit timed out with status %04x, %s?\n",
-	   dev->name, htons(inw(ioaddr + TX_STATUS)),
-	   inb(ioaddr + TX_STATUS) & F_TMT_RDY
-	   ? "IRQ conflict" : "network cable problem");
-    printk(KERN_NOTICE "%s: timeout registers: %04x %04x %04x "
-	   "%04x %04x %04x %04x %04x.\n",
-	   dev->name, htons(inw(ioaddr + 0)),
-	   htons(inw(ioaddr + 2)), htons(inw(ioaddr + 4)),
-	   htons(inw(ioaddr + 6)), htons(inw(ioaddr + 8)),
-	   htons(inw(ioaddr +10)), htons(inw(ioaddr +12)),
-	   htons(inw(ioaddr +14)));
+    netdev_notice(dev, "transmit timed out with status %04x, %s?\n",
+		  htons(inw(ioaddr + TX_STATUS)),
+		  inb(ioaddr + TX_STATUS) & F_TMT_RDY
+		  ? "IRQ conflict" : "network cable problem");
+    netdev_notice(dev, "timeout registers: %04x %04x %04x "
+		  "%04x %04x %04x %04x %04x.\n",
+		  htons(inw(ioaddr + 0)), htons(inw(ioaddr + 2)),
+		  htons(inw(ioaddr + 4)), htons(inw(ioaddr + 6)),
+		  htons(inw(ioaddr + 8)), htons(inw(ioaddr + 10)),
+		  htons(inw(ioaddr + 12)), htons(inw(ioaddr + 14)));
     dev->stats.tx_errors++;
     /* ToDo: We should try to restart the adaptor... */
     local_irq_disable();
@@ -851,13 +851,13 @@ static netdev_tx_t fjn_start_xmit(struct sk_buff *skb,
 	unsigned char *buf = skb->data;
 
 	if (length > ETH_FRAME_LEN) {
-	    printk(KERN_NOTICE "%s: Attempting to send a large packet"
-		   " (%d bytes).\n", dev->name, length);
+	    netdev_notice(dev, "Attempting to send a large packet (%d bytes)\n",
+			  length);
 	    return NETDEV_TX_BUSY;
 	}
 
-	pr_debug("%s: Transmitting a packet of length %lu.\n",
-	      dev->name, (unsigned long)skb->len);
+	netdev_dbg(dev, "Transmitting a packet of length %lu\n",
+		   (unsigned long)skb->len);
 	dev->stats.tx_bytes += skb->len;
 
 	/* Disable both interrupts. */
@@ -910,7 +910,7 @@ static void fjn_reset(struct net_device *dev)
     unsigned int ioaddr = dev->base_addr;
     int i;
 
-    pr_debug("fjn_reset(%s) called.\n",dev->name);
+    netdev_dbg(dev, "fjn_reset() called\n");
 
     /* Reset controller */
     if( sram_config == 0 ) 
@@ -994,8 +994,8 @@ static void fjn_rx(struct net_device *dev)
     while ((inb(ioaddr + RX_MODE) & F_BUF_EMP) == 0) {
 	u_short status = inw(ioaddr + DATAPORT);
 
-	pr_debug("%s: Rxing packet mode %02x status %04x.\n",
-	      dev->name, inb(ioaddr + RX_MODE), status);
+	netdev_dbg(dev, "Rxing packet mode %02x status %04x.\n",
+		   inb(ioaddr + RX_MODE), status);
 #ifndef final_version
 	if (status == 0) {
 	    outb(F_SKP_PKT, ioaddr + RX_SKIP);
@@ -1014,16 +1014,16 @@ static void fjn_rx(struct net_device *dev)
 	    struct sk_buff *skb;
 
 	    if (pkt_len > 1550) {
-		printk(KERN_NOTICE "%s: The FMV-18x claimed a very "
-		       "large packet, size %d.\n", dev->name, pkt_len);
+		netdev_notice(dev, "The FMV-18x claimed a very large packet, size %d\n",
+			      pkt_len);
 		outb(F_SKP_PKT, ioaddr + RX_SKIP);
 		dev->stats.rx_errors++;
 		break;
 	    }
 	    skb = dev_alloc_skb(pkt_len+2);
 	    if (skb == NULL) {
-		printk(KERN_NOTICE "%s: Memory squeeze, dropping "
-		       "packet (len %d).\n", dev->name, pkt_len);
+		netdev_notice(dev, "Memory squeeze, dropping packet (len %d)\n",
+			      pkt_len);
 		outb(F_SKP_PKT, ioaddr + RX_SKIP);
 		dev->stats.rx_dropped++;
 		break;
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index 67ee985..0e90219 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -45,6 +45,8 @@
 
 ======================================================================*/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/ptrace.h>
@@ -291,15 +293,14 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
 
     i = ibmtr_probe_card(dev);
     if (i != 0) {
-	printk(KERN_NOTICE "ibmtr_cs: register_netdev() failed\n");
+	pr_notice("register_netdev() failed\n");
 	goto failed;
     }
 
-    printk(KERN_INFO
-	   "%s: port %#3lx, irq %d,  mmio %#5lx, sram %#5lx, hwaddr=%pM\n",
-           dev->name, dev->base_addr, dev->irq,
-	   (u_long)ti->mmio, (u_long)(ti->sram_base << 12),
-	   dev->dev_addr);
+    netdev_info(dev, "port %#3lx, irq %d, mmio %#5lx, sram %#5lx, hwaddr=%pM\n",
+		dev->base_addr, dev->irq,
+		(u_long)ti->mmio, (u_long)(ti->sram_base << 12),
+		dev->dev_addr);
     return 0;
 
 failed:
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index 9b63dec..4f92ecc 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -111,6 +111,8 @@ Log: nmclan_cs.c,v
 
 ---------------------------------------------------------------------------- */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define DRV_NAME	"nmclan_cs"
 #define DRV_VERSION	"0.16"
 
@@ -565,7 +567,7 @@ static int mace_init(mace_private *lp, unsigned int ioaddr, char *enet_addr)
     /* Wait for reset bit to be cleared automatically after <= 200ns */;
     if(++ct > 500)
     {
-    	printk(KERN_ERR "mace: reset failed, card removed ?\n");
+	pr_err("reset failed, card removed?\n");
     	return -1;
     }
     udelay(1);
@@ -612,7 +614,7 @@ static int mace_init(mace_private *lp, unsigned int ioaddr, char *enet_addr)
   {
   	if(++ ct > 500)
   	{
-  		printk(KERN_ERR "mace: ADDRCHG timeout, card removed ?\n");
+		pr_err("ADDRCHG timeout, card removed?\n");
   		return -1;
   	}
   }
@@ -679,8 +681,8 @@ static int nmclan_config(struct pcmcia_device *link)
       dev_dbg(&link->dev, "nmclan_cs configured: mace id=%x %x\n",
 	    sig[0], sig[1]);
     } else {
-      printk(KERN_NOTICE "nmclan_cs: mace id not found: %x %x should"
-	     " be 0x40 0x?9\n", sig[0], sig[1]);
+      pr_notice("mace id not found: %x %x should be 0x40 0x?9\n",
+		sig[0], sig[1]);
       return -ENODEV;
     }
   }
@@ -692,20 +694,18 @@ static int nmclan_config(struct pcmcia_device *link)
   if (if_port <= 2)
     dev->if_port = if_port;
   else
-    printk(KERN_NOTICE "nmclan_cs: invalid if_port requested\n");
+    pr_notice("invalid if_port requested\n");
 
   SET_NETDEV_DEV(dev, &link->dev);
 
   i = register_netdev(dev);
   if (i != 0) {
-    printk(KERN_NOTICE "nmclan_cs: register_netdev() failed\n");
+    pr_notice("register_netdev() failed\n");
     goto failed;
   }
 
-  printk(KERN_INFO "%s: nmclan: port %#3lx, irq %d, %s port,"
-	 " hw_addr %pM\n",
-	 dev->name, dev->base_addr, dev->irq, if_names[dev->if_port],
-	 dev->dev_addr);
+  netdev_info(dev, "nmclan: port %#3lx, irq %d, %s port, hw_addr %pM\n",
+	      dev->base_addr, dev->irq, if_names[dev->if_port], dev->dev_addr);
   return 0;
 
 failed:
@@ -808,8 +808,7 @@ static int mace_config(struct net_device *dev, struct ifmap *map)
   if ((map->port != (u_char)(-1)) && (map->port != dev->if_port)) {
     if (map->port <= 2) {
       dev->if_port = map->port;
-      printk(KERN_INFO "%s: switched to %s port\n", dev->name,
-	     if_names[dev->if_port]);
+      netdev_info(dev, "switched to %s port\n", if_names[dev->if_port]);
     } else
       return -EINVAL;
   }
@@ -888,12 +887,12 @@ static void mace_tx_timeout(struct net_device *dev)
   mace_private *lp = netdev_priv(dev);
   struct pcmcia_device *link = lp->p_dev;
 
-  printk(KERN_NOTICE "%s: transmit timed out -- ", dev->name);
+  netdev_notice(dev, "transmit timed out -- ");
 #if RESET_ON_TIMEOUT
-  printk("resetting card\n");
+  pr_cont("resetting card\n");
   pcmcia_reset_card(link->socket);
 #else /* #if RESET_ON_TIMEOUT */
-  printk("NOT resetting card\n");
+  pr_cont("NOT resetting card\n");
 #endif /* #if RESET_ON_TIMEOUT */
   dev->trans_start = jiffies; /* prevent tx timeout */
   netif_wake_queue(dev);
@@ -975,22 +974,21 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
   ioaddr = dev->base_addr;
 
   if (lp->tx_irq_disabled) {
-    printk(
-      (lp->tx_irq_disabled?
-       KERN_NOTICE "%s: Interrupt with tx_irq_disabled "
-       "[isr=%02X, imr=%02X]\n": 
-       KERN_NOTICE "%s: Re-entering the interrupt handler "
-       "[isr=%02X, imr=%02X]\n"),
-      dev->name,
-      inb(ioaddr + AM2150_MACE_BASE + MACE_IR),
-      inb(ioaddr + AM2150_MACE_BASE + MACE_IMR)
-    );
+    const char *msg;
+    if (lp->tx_irq_disabled)
+      msg = "Interrupt with tx_irq_disabled";
+    else
+      msg = "Re-entering the interrupt handler";
+    netdev_notice(dev, "%s [isr=%02X, imr=%02X]\n",
+		  msg,
+		  inb(ioaddr + AM2150_MACE_BASE + MACE_IR),
+		  inb(ioaddr + AM2150_MACE_BASE + MACE_IMR));
     /* WARNING: MACE_IR has been read! */
     return IRQ_NONE;
   }
 
   if (!netif_device_present(dev)) {
-    pr_debug("%s: interrupt from dead card\n", dev->name);
+    netdev_dbg(dev, "interrupt from dead card\n");
     return IRQ_NONE;
   }
 
@@ -1388,8 +1386,8 @@ static void BuildLAF(int *ladrf, int *adr)
     printk(KERN_DEBUG "    adr =%pM\n", adr);
   printk(KERN_DEBUG "    hashcode = %d(decimal), ladrf[0:63] =", hashcode);
   for (i = 0; i < 8; i++)
-    printk(KERN_CONT " %02X", ladrf[i]);
-  printk(KERN_CONT "\n");
+    pr_cont(" %02X", ladrf[i]);
+  pr_cont("\n");
 #endif
 } /* BuildLAF */
 
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 307cd17..dd237a6 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -25,6 +25,8 @@
 
 ======================================================================*/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
@@ -825,7 +827,7 @@ static int check_sig(struct pcmcia_device *link)
 	    modconf_t mod = {
 		    .Attributes = CONF_IO_CHANGE_WIDTH,
 	    };
-	    printk(KERN_INFO "smc91c92_cs: using 8-bit IO window.\n");
+	    pr_info("using 8-bit IO window\n");
 
 	    smc91c92_suspend(link);
 	    pcmcia_modify_configuration(link, &mod);
@@ -886,7 +888,7 @@ static int smc91c92_config(struct pcmcia_device *link)
     if ((if_port >= 0) && (if_port <= 2))
 	dev->if_port = if_port;
     else
-	printk(KERN_NOTICE "smc91c92_cs: invalid if_port requested\n");
+	dev_notice(&link->dev, "invalid if_port requested\n");
 
     switch (smc->manfid) {
     case MANFID_OSITECH:
@@ -904,7 +906,7 @@ static int smc91c92_config(struct pcmcia_device *link)
     }
 
     if (i != 0) {
-	printk(KERN_NOTICE "smc91c92_cs: Unable to find hardware address.\n");
+	dev_notice(&link->dev, "Unable to find hardware address.\n");
 	goto config_failed;
     }
 
@@ -957,30 +959,28 @@ static int smc91c92_config(struct pcmcia_device *link)
     SET_NETDEV_DEV(dev, &link->dev);
 
     if (register_netdev(dev) != 0) {
-	printk(KERN_ERR "smc91c92_cs: register_netdev() failed\n");
+	dev_err(&link->dev, "register_netdev() failed\n");
 	goto config_undo;
     }
 
-    printk(KERN_INFO "%s: smc91c%s rev %d: io %#3lx, irq %d, "
-	   "hw_addr %pM\n",
-	   dev->name, name, (rev & 0x0f), dev->base_addr, dev->irq,
-	   dev->dev_addr);
+    netdev_info(dev, "smc91c%s rev %d: io %#3lx, irq %d, hw_addr %pM\n",
+		name, (rev & 0x0f), dev->base_addr, dev->irq, dev->dev_addr);
 
     if (rev > 0) {
 	if (mir & 0x3ff)
-	    printk(KERN_INFO "  %lu byte", mir);
+	    netdev_info(dev, "  %lu byte", mir);
 	else
-	    printk(KERN_INFO "  %lu kb", mir>>10);
-	printk(" buffer, %s xcvr\n", (smc->cfg & CFG_MII_SELECT) ?
-	       "MII" : if_names[dev->if_port]);
+	    netdev_info(dev, "  %lu kb", mir>>10);
+	pr_cont(" buffer, %s xcvr\n",
+		(smc->cfg & CFG_MII_SELECT) ? "MII" : if_names[dev->if_port]);
     }
 
     if (smc->cfg & CFG_MII_SELECT) {
 	if (smc->mii_if.phy_id != -1) {
-	    dev_dbg(&link->dev, "  MII transceiver at index %d, status %x.\n",
-		  smc->mii_if.phy_id, j);
+	    netdev_dbg(dev, "  MII transceiver at index %d, status %x\n",
+		       smc->mii_if.phy_id, j);
 	} else {
-    	    printk(KERN_NOTICE "  No MII transceivers found!\n");
+	    netdev_notice(dev, "  No MII transceivers found!\n");
 	}
     }
     return 0;
@@ -1086,10 +1086,10 @@ static void smc_dump(struct net_device *dev)
     save = inw(ioaddr + BANK_SELECT);
     for (w = 0; w < 4; w++) {
 	SMC_SELECT_BANK(w);
-	printk(KERN_DEBUG "bank %d: ", w);
+	netdev_printk(KERN_DEBUG, dev, "bank %d: ", w);
 	for (i = 0; i < 14; i += 2)
-	    printk(" %04x", inw(ioaddr + i));
-	printk("\n");
+	    pr_cont(" %04x", inw(ioaddr + i));
+	pr_cont("\n");
     }
     outw(save, ioaddr + BANK_SELECT);
 }
@@ -1111,7 +1111,7 @@ static int smc_open(struct net_device *dev)
 	return -ENODEV;
     /* Physical device present signature. */
     if (check_sig(link) < 0) {
-	printk("smc91c92_cs: Yikes!  Bad chip signature!\n");
+	netdev_info(dev, "Yikes!  Bad chip signature!\n");
 	return -ENODEV;
     }
     link->open++;
@@ -1177,7 +1177,7 @@ static void smc_hardware_send_packet(struct net_device * dev)
     u_char packet_no;
 
     if (!skb) {
-	printk(KERN_ERR "%s: In XMIT with no packet to send.\n", dev->name);
+	netdev_err(dev, "In XMIT with no packet to send\n");
 	return;
     }
 
@@ -1185,8 +1185,8 @@ static void smc_hardware_send_packet(struct net_device * dev)
     packet_no = inw(ioaddr + PNR_ARR) >> 8;
     if (packet_no & 0x80) {
 	/* If not, there is a hardware problem!  Likely an ejected card. */
-	printk(KERN_WARNING "%s: 91c92 hardware Tx buffer allocation"
-	       " failed, status %#2.2x.\n", dev->name, packet_no);
+	netdev_warn(dev, "hardware Tx buffer allocation failed, status %#2.2x\n",
+		    packet_no);
 	dev_kfree_skb_irq(skb);
 	smc->saved_skb = NULL;
 	netif_start_queue(dev);
@@ -1205,8 +1205,7 @@ static void smc_hardware_send_packet(struct net_device * dev)
 	u_char *buf = skb->data;
 	u_int length = skb->len; /* The chip will pad to ethernet min. */
 
-	pr_debug("%s: Trying to xmit packet of length %d.\n",
-	      dev->name, length);
+	netdev_dbg(dev, "Trying to xmit packet of length %d\n", length);
 	
 	/* send the packet length: +6 for status word, length, and ctl */
 	outw(0, ioaddr + DATA_1);
@@ -1238,9 +1237,8 @@ static void smc_tx_timeout(struct net_device *dev)
     struct smc_private *smc = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
 
-    printk(KERN_NOTICE "%s: SMC91c92 transmit timed out, "
-	   "Tx_status %2.2x status %4.4x.\n",
-	   dev->name, inw(ioaddr)&0xff, inw(ioaddr + 2));
+    netdev_notice(dev, "transmit timed out, Tx_status %2.2x status %4.4x.\n",
+		  inw(ioaddr)&0xff, inw(ioaddr + 2));
     dev->stats.tx_errors++;
     smc_reset(dev);
     dev->trans_start = jiffies; /* prevent tx timeout */
@@ -1259,14 +1257,14 @@ static netdev_tx_t smc_start_xmit(struct sk_buff *skb,
 
     netif_stop_queue(dev);
 
-    pr_debug("%s: smc_start_xmit(length = %d) called,"
-	  " status %4.4x.\n", dev->name, skb->len, inw(ioaddr + 2));
+    netdev_dbg(dev, "smc_start_xmit(length = %d) called, status %04x\n",
+	       skb->len, inw(ioaddr + 2));
 
     if (smc->saved_skb) {
 	/* THIS SHOULD NEVER HAPPEN. */
 	dev->stats.tx_aborted_errors++;
-	printk(KERN_DEBUG "%s: Internal error -- sent packet while busy.\n",
-	       dev->name);
+	netdev_printk(KERN_DEBUG, dev,
+		      "Internal error -- sent packet while busy\n");
 	return NETDEV_TX_BUSY;
     }
     smc->saved_skb = skb;
@@ -1274,7 +1272,7 @@ static netdev_tx_t smc_start_xmit(struct sk_buff *skb,
     num_pages = skb->len >> 8;
 
     if (num_pages > 7) {
-	printk(KERN_ERR "%s: Far too big packet error.\n", dev->name);
+	netdev_err(dev, "Far too big packet error: %d pages\n", num_pages);
 	dev_kfree_skb (skb);
 	smc->saved_skb = NULL;
 	dev->stats.tx_dropped++;
@@ -1344,8 +1342,7 @@ static void smc_tx_err(struct net_device * dev)
     }
 
     if (tx_status & TS_SUCCESS) {
-	printk(KERN_NOTICE "%s: Successful packet caused error "
-	       "interrupt?\n", dev->name);
+	netdev_notice(dev, "Successful packet caused error interrupt?\n");
     }
     /* re-enable transmit */
     SMC_SELECT_BANK(0);
@@ -1535,8 +1532,7 @@ static void smc_rx(struct net_device *dev)
     /* Assertion: we are in Window 2. */
 
     if (inw(ioaddr + FIFO_PORTS) & FP_RXEMPTY) {
-	printk(KERN_ERR "%s: smc_rx() with nothing on Rx FIFO.\n",
-	       dev->name);
+	netdev_err(dev, "smc_rx() with nothing on Rx FIFO\n");
 	return;
     }
 
@@ -1651,8 +1647,7 @@ static int s9k_config(struct net_device *dev, struct ifmap *map)
 	else if (map->port > 2)
 	    return -EINVAL;
 	dev->if_port = map->port;
-	printk(KERN_INFO "%s: switched to %s port\n",
-	       dev->name, if_names[dev->if_port]);
+	netdev_info(dev, "switched to %s port\n", if_names[dev->if_port]);
 	smc_reset(dev);
     }
     return 0;
@@ -1803,7 +1798,7 @@ static void media_check(u_long arg)
        this, we can limp along even if the interrupt is blocked */
     if (smc->watchdog++ && ((i>>8) & i)) {
 	if (!smc->fast_poll)
-	    printk(KERN_INFO "%s: interrupt(s) dropped!\n", dev->name);
+	    netdev_info(dev, "interrupt(s) dropped!\n");
 	local_irq_save(flags);
 	smc_interrupt(dev->irq, dev);
 	local_irq_restore(flags);
@@ -1827,7 +1822,7 @@ static void media_check(u_long arg)
 	SMC_SELECT_BANK(3);
 	link = mdio_read(dev, smc->mii_if.phy_id, 1);
 	if (!link || (link == 0xffff)) {
-  	    printk(KERN_INFO "%s: MII is missing!\n", dev->name);
+	    netdev_info(dev, "MII is missing!\n");
 	    smc->mii_if.phy_id = -1;
 	    goto reschedule;
 	}
@@ -1835,15 +1830,13 @@ static void media_check(u_long arg)
 	link &= 0x0004;
 	if (link != smc->link_status) {
 	    u_short p = mdio_read(dev, smc->mii_if.phy_id, 5);
-	    printk(KERN_INFO "%s: %s link beat\n", dev->name,
-		(link) ? "found" : "lost");
+	    netdev_info(dev, "%s link beat\n", link ? "found" : "lost");
 	    smc->duplex = (((p & 0x0100) || ((p & 0x1c0) == 0x40))
 			   ? TCR_FDUPLX : 0);
 	    if (link) {
-	        printk(KERN_INFO "%s: autonegotiation complete: "
-		       "%sbaseT-%cD selected\n", dev->name,
-		       ((p & 0x0180) ? "100" : "10"),
-		       (smc->duplex ? 'F' : 'H'));
+		netdev_info(dev, "autonegotiation complete: "
+			    "%dbaseT-%cD selected\n",
+			    (p & 0x0180) ? 100 : 10, smc->duplex ? 'F' : 'H');
 	    }
 	    SMC_SELECT_BANK(0);
 	    outw(inw(ioaddr + TCR) | smc->duplex, ioaddr + TCR);
@@ -1862,25 +1855,23 @@ static void media_check(u_long arg)
     if (media != smc->media_status) {
 	if ((media & smc->media_status & 1) &&
 	    ((smc->media_status ^ media) & EPH_LINK_OK))
-	    printk(KERN_INFO "%s: %s link beat\n", dev->name,
-		   (smc->media_status & EPH_LINK_OK ? "lost" : "found"));
+	    netdev_info(dev, "%s link beat\n",
+			smc->media_status & EPH_LINK_OK ? "lost" : "found");
 	else if ((media & smc->media_status & 2) &&
 		 ((smc->media_status ^ media) & EPH_16COL))
-	    printk(KERN_INFO "%s: coax cable %s\n", dev->name,
-		   (media & EPH_16COL ? "problem" : "ok"));
+	    netdev_info(dev, "coax cable %s\n",
+			media & EPH_16COL ? "problem" : "ok");
 	if (dev->if_port == 0) {
 	    if (media & 1) {
 		if (media & EPH_LINK_OK)
-		    printk(KERN_INFO "%s: flipped to 10baseT\n",
-			   dev->name);
+		    netdev_info(dev, "flipped to 10baseT\n");
 		else
 		    smc_set_xcvr(dev, 2);
 	    } else {
 		if (media & EPH_16COL)
 		    smc_set_xcvr(dev, 1);
 		else
-		    printk(KERN_INFO "%s: flipped to 10base2\n",
-			   dev->name);
+		    netdev_info(dev, "flipped to 10base2\n");
 	    }
 	}
 	smc->media_status = media;
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index b6c36448..37f2fe0 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -63,6 +63,8 @@
  * OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
@@ -211,13 +213,6 @@ enum xirc_cmd { 	    /* Commands */
 
 static const char *if_names[] = { "Auto", "10BaseT", "10Base2", "AUI", "100BaseT" };
 
-
-#define KDBG_XIRC KERN_DEBUG   "xirc2ps_cs: "
-#define KERR_XIRC KERN_ERR     "xirc2ps_cs: "
-#define KWRN_XIRC KERN_WARNING "xirc2ps_cs: "
-#define KNOT_XIRC KERN_NOTICE  "xirc2ps_cs: "
-#define KINF_XIRC KERN_INFO    "xirc2ps_cs: "
-
 /* card types */
 #define XIR_UNKNOWN  0	/* unknown: not supported */
 #define XIR_CE	     1	/* (prodid 1) different hardware: not supported */
@@ -351,26 +346,26 @@ PrintRegisters(struct net_device *dev)
     if (pc_debug > 1) {
 	int i, page;
 
-	printk(KDBG_XIRC "Register  common: ");
+	printk(KERN_DEBUG pr_fmt("Register  common: "));
 	for (i = 0; i < 8; i++)
-	    printk(" %2.2x", GetByte(i));
-	printk("\n");
+	    pr_cont(" %2.2x", GetByte(i));
+	pr_cont("\n");
 	for (page = 0; page <= 8; page++) {
-	    printk(KDBG_XIRC "Register page %2x: ", page);
+	    printk(KERN_DEBUG pr_fmt("Register page %2x: "), page);
 	    SelectPage(page);
 	    for (i = 8; i < 16; i++)
-		printk(" %2.2x", GetByte(i));
-	    printk("\n");
+		pr_cont(" %2.2x", GetByte(i));
+	    pr_cont("\n");
 	}
 	for (page=0x40 ; page <= 0x5f; page++) {
 		if (page == 0x43 || (page >= 0x46 && page <= 0x4f) ||
 		    (page >= 0x51 && page <=0x5e))
 			continue;
-	    printk(KDBG_XIRC "Register page %2x: ", page);
+	    printk(KERN_DEBUG pr_fmt("Register page %2x: "), page);
 	    SelectPage(page);
 	    for (i = 8; i < 16; i++)
-		printk(" %2.2x", GetByte(i));
-	    printk("\n");
+		pr_cont(" %2.2x", GetByte(i));
+	    pr_cont("\n");
 	}
     }
 }
@@ -609,11 +604,11 @@ set_card_type(struct pcmcia_device *link)
     local->modem = 0;
     local->card_type = XIR_UNKNOWN;
     if (!(prodid & 0x40)) {
-	printk(KNOT_XIRC "Ooops: Not a creditcard\n");
+	pr_notice("Oops: Not a creditcard\n");
 	return 0;
     }
     if (!(mediaid & 0x01)) {
-	printk(KNOT_XIRC "Not an Ethernet card\n");
+	pr_notice("Not an Ethernet card\n");
 	return 0;
     }
     if (mediaid & 0x10) {
@@ -644,12 +639,11 @@ set_card_type(struct pcmcia_device *link)
 	}
     }
     if (local->card_type == XIR_CE || local->card_type == XIR_CEM) {
-	printk(KNOT_XIRC "Sorry, this is an old CE card\n");
+	pr_notice("Sorry, this is an old CE card\n");
 	return 0;
     }
     if (local->card_type == XIR_UNKNOWN)
-	printk(KNOT_XIRC "unknown card (mediaid=%02x prodid=%02x)\n",
-	       mediaid, prodid);
+	pr_notice("unknown card (mediaid=%02x prodid=%02x)\n", mediaid, prodid);
 
     return 1;
 }
@@ -749,7 +743,7 @@ xirc2ps_config(struct pcmcia_device * link)
 
     /* Is this a valid	card */
     if (link->has_manf_id == 0) {
-	printk(KNOT_XIRC "manfid not found in CIS\n");
+	pr_notice("manfid not found in CIS\n");
 	goto failure;
     }
 
@@ -771,14 +765,14 @@ xirc2ps_config(struct pcmcia_device * link)
 	local->manf_str = "Toshiba";
 	break;
       default:
-	printk(KNOT_XIRC "Unknown Card Manufacturer ID: 0x%04x\n",
-	       (unsigned)link->manf_id);
+	pr_notice("Unknown Card Manufacturer ID: 0x%04x\n",
+		  (unsigned)link->manf_id);
 	goto failure;
     }
     dev_dbg(&link->dev, "found %s card\n", local->manf_str);
 
     if (!set_card_type(link)) {
-	printk(KNOT_XIRC "this card is not supported\n");
+	pr_notice("this card is not supported\n");
 	goto failure;
     }
 
@@ -804,7 +798,7 @@ xirc2ps_config(struct pcmcia_device * link)
 	err = pcmcia_loop_tuple(link, CISTPL_FUNCE, pcmcia_get_mac_ce, dev);
 
     if (err) {
-	printk(KNOT_XIRC "node-id not found in CIS\n");
+	pr_notice("node-id not found in CIS\n");
 	goto failure;
     }
 
@@ -839,7 +833,7 @@ xirc2ps_config(struct pcmcia_device * link)
 	     * try to configure as Ethernet only.
 	     * .... */
 	}
-	printk(KNOT_XIRC "no ports available\n");
+	pr_notice("no ports available\n");
     } else {
 	link->io.NumPorts1 = 16;
 	for (ioaddr = 0x300; ioaddr < 0x400; ioaddr += 0x10) {
@@ -917,24 +911,24 @@ xirc2ps_config(struct pcmcia_device * link)
       #if 0
 	{
 	    u_char tmp;
-	    printk(KERN_INFO "ECOR:");
+	    pr_info("ECOR:");
 	    for (i=0; i < 7; i++) {
 		tmp = readb(local->dingo_ccr + i*2);
-		printk(" %02x", tmp);
+		pr_cont(" %02x", tmp);
 	    }
-	    printk("\n");
-	    printk(KERN_INFO "DCOR:");
+	    pr_cont("\n");
+	    pr_info("DCOR:");
 	    for (i=0; i < 4; i++) {
 		tmp = readb(local->dingo_ccr + 0x20 + i*2);
-		printk(" %02x", tmp);
+		pr_cont(" %02x", tmp);
 	    }
-	    printk("\n");
-	    printk(KERN_INFO "SCOR:");
+	    pr_cont("\n");
+	    pr_info("SCOR:");
 	    for (i=0; i < 10; i++) {
 		tmp = readb(local->dingo_ccr + 0x40 + i*2);
-		printk(" %02x", tmp);
+		pr_cont(" %02x", tmp);
 	    }
-	    printk("\n");
+	    pr_cont("\n");
 	}
       #endif
 
@@ -953,7 +947,7 @@ xirc2ps_config(struct pcmcia_device * link)
 	       (local->mohawk && if_port==4))
 	dev->if_port = if_port;
     else
-	printk(KNOT_XIRC "invalid if_port requested\n");
+	pr_notice("invalid if_port requested\n");
 
     /* we can now register the device with the net subsystem */
     dev->irq = link->irq;
@@ -965,14 +959,14 @@ xirc2ps_config(struct pcmcia_device * link)
     SET_NETDEV_DEV(dev, &link->dev);
 
     if ((err=register_netdev(dev))) {
-	printk(KNOT_XIRC "register_netdev() failed\n");
+	pr_notice("register_netdev() failed\n");
 	goto config_error;
     }
 
     /* give some infos about the hardware */
-    printk(KERN_INFO "%s: %s: port %#3lx, irq %d, hwaddr %pM\n",
-	   dev->name, local->manf_str,(u_long)dev->base_addr, (int)dev->irq,
-	   dev->dev_addr);
+    netdev_info(dev, "%s: port %#3lx, irq %d, hwaddr %pM\n",
+		local->manf_str, (u_long)dev->base_addr, (int)dev->irq,
+		dev->dev_addr);
 
     return 0;
 
@@ -1104,8 +1098,7 @@ xirc2ps_interrupt(int irq, void *dev_id)
 
 	    skb = dev_alloc_skb(pktlen+3); /* 1 extra so we can use insw */
 	    if (!skb) {
-		printk(KNOT_XIRC "low memory, packet dropped (size=%u)\n",
-		       pktlen);
+		pr_notice("low memory, packet dropped (size=%u)\n", pktlen);
 		dev->stats.rx_dropped++;
 	    } else { /* okay get the packet */
 		skb_reserve(skb, 2);
@@ -1274,7 +1267,7 @@ xirc_tx_timeout(struct net_device *dev)
 {
     local_info_t *lp = netdev_priv(dev);
     dev->stats.tx_errors++;
-    printk(KERN_NOTICE "%s: transmit timed out\n", dev->name);
+    netdev_notice(dev, "transmit timed out\n");
     schedule_work(&lp->tx_timeout_task);
 }
 
@@ -1441,8 +1434,7 @@ do_config(struct net_device *dev, struct ifmap *map)
 	    local->probe_port = 0;
 	    dev->if_port = map->port;
 	}
-	printk(KERN_INFO "%s: switching to %s port\n",
-	       dev->name, if_names[dev->if_port]);
+	netdev_info(dev, "switching to %s port\n", if_names[dev->if_port]);
 	do_reset(dev,1);  /* not the fine way :-) */
     }
     return 0;
@@ -1582,7 +1574,7 @@ do_reset(struct net_device *dev, int full)
     {
 	SelectPage(0);
 	value = GetByte(XIRCREG_ESR);	 /* read the ESR */
-	printk(KERN_DEBUG "%s: ESR is: %#02x\n", dev->name, value);
+	pr_debug("%s: ESR is: %#02x\n", dev->name, value);
     }
   #endif
 
@@ -1632,13 +1624,12 @@ do_reset(struct net_device *dev, int full)
 
     if (full && local->mohawk && init_mii(dev)) {
 	if (dev->if_port == 4 || local->dingo || local->new_mii) {
-	    printk(KERN_INFO "%s: MII selected\n", dev->name);
+	    netdev_info(dev, "MII selected\n");
 	    SelectPage(2);
 	    PutByte(XIRCREG2_MSR, GetByte(XIRCREG2_MSR) | 0x08);
 	    msleep(20);
 	} else {
-	    printk(KERN_INFO "%s: MII detected; using 10mbs\n",
-		   dev->name);
+	    netdev_info(dev, "MII detected; using 10mbs\n");
 	    SelectPage(0x42);
 	    if (dev->if_port == 2) /* enable 10Base2 */
 		PutByte(XIRCREG42_SWC1, 0xC0);
@@ -1683,8 +1674,8 @@ do_reset(struct net_device *dev, int full)
     }
 
     if (full)
-	printk(KERN_INFO "%s: media %s, silicon revision %d\n",
-	       dev->name, if_names[dev->if_port], local->silicon);
+	netdev_info(dev, "media %s, silicon revision %d\n",
+		    if_names[dev->if_port], local->silicon);
     /* We should switch back to page 0 to avoid a bug in revision 0
      * where regs with offset below 8 can't be read after an access
      * to the MAC registers */
@@ -1726,8 +1717,7 @@ init_mii(struct net_device *dev)
     control = mii_rd(ioaddr, 0, 0);
 
     if (control & 0x0400) {
-	printk(KERN_NOTICE "%s can't take PHY out of isolation mode\n",
-	       dev->name);
+	netdev_notice(dev, "can't take PHY out of isolation mode\n");
 	local->probe_port = 0;
 	return 0;
     }
@@ -1745,8 +1735,7 @@ init_mii(struct net_device *dev)
 	}
 
 	if (!(status & 0x0020)) {
-	    printk(KERN_INFO "%s: autonegotiation failed;"
-		   " using 10mbs\n", dev->name);
+	    netdev_info(dev, "autonegotiation failed; using 10mbs\n");
 	    if (!local->new_mii) {
 		control = 0x0000;
 		mii_wr(ioaddr,  0, 0, control, 16);
@@ -1756,8 +1745,7 @@ init_mii(struct net_device *dev)
 	    }
 	} else {
 	    linkpartner = mii_rd(ioaddr, 0, 5);
-	    printk(KERN_INFO "%s: MII link partner: %04x\n",
-		   dev->name, linkpartner);
+	    netdev_info(dev, "MII link partner: %04x\n", linkpartner);
 	    if (linkpartner & 0x0080) {
 		dev->if_port = 4;
 	    } else
-- 
1.7.2.19.g9a302
