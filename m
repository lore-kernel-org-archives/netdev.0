From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 3/5] cirrus: cs89x0: Code neatening
Date: Fri, 18 May 2012 15:56:29 -0700
Message-ID: <d3a5a61653f32b9fec28f48fc5b96a920e866104.1337381533.git.joe@perches.com>
References: <cover.1337381533.git.joe@perches.com>
Cc: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1337381533.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just some stylings.

Use #include <linux... not #include <asm...
Convert a test and print to a printk_once.
Combine an "if (foo) { if (bar) {" to single "if (foo && bar) {"
to save an indent level.
Convert single line "if (foo) bar;" to multiple lines.
Move some braces.
Align some long lines a bit better.

Long lines and printks with KERN_ checkpatch complaints
still exist.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/cirrus/cs89x0.c |  452 ++++++++++++++++++++--------------
 1 files changed, 272 insertions(+), 180 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index b612040..6e5b2c7 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -67,8 +67,8 @@
 #include <linux/bitops.h>
 #include <linux/delay.h>
 #include <linux/gfp.h>
+#include <linux/io.h>
 
-#include <asm/io.h>
 #include <asm/irq.h>
 #include <linux/atomic.h>
 #if ALLOW_DMA
@@ -78,7 +78,7 @@
 #include "cs89x0.h"
 
 static char version[] __initdata =
-	"cs89x0.c: v2.4.3-pre1 Russell Nelson <nelson@crynwr.com>, Andrew Morton\n";
+	"v2.4.3-pre1 Russell Nelson <nelson@crynwr.com>, Andrew Morton\n";
 
 #define DRV_NAME "cs89x0"
 
@@ -97,17 +97,29 @@ static char version[] __initdata =
  */
 #if defined(CONFIG_MACH_IXDP2351)
 #define CS89x0_NONISA_IRQ
-static unsigned int netcard_portlist[] __used __initdata = {IXDP2351_VIRT_CS8900_BASE, 0};
-static unsigned int cs8900_irq_map[] = {IRQ_IXDP2351_CS8900, 0, 0, 0};
+static unsigned int netcard_portlist[] __used __initdata = {
+	IXDP2351_VIRT_CS8900_BASE, 0
+};
+static unsigned int cs8900_irq_map[] = {
+	IRQ_IXDP2351_CS8900, 0, 0, 0
+};
 #elif defined(CONFIG_ARCH_IXDP2X01)
 #define CS89x0_NONISA_IRQ
-static unsigned int netcard_portlist[] __used __initdata = {IXDP2X01_CS8900_VIRT_BASE, 0};
-static unsigned int cs8900_irq_map[] = {IRQ_IXDP2X01_CS8900, 0, 0, 0};
+static unsigned int netcard_portlist[] __used __initdata = {
+	IXDP2X01_CS8900_VIRT_BASE, 0
+};
+static unsigned int cs8900_irq_map[] = {
+	IRQ_IXDP2X01_CS8900, 0, 0, 0
+};
 #else
 #ifndef CONFIG_CS89x0_PLATFORM
-static unsigned int netcard_portlist[] __used __initdata =
-{ 0x300, 0x320, 0x340, 0x360, 0x200, 0x220, 0x240, 0x260, 0x280, 0x2a0, 0x2c0, 0x2e0, 0};
-static unsigned int cs8900_irq_map[] = {10, 11, 12, 5};
+static unsigned int netcard_portlist[] __used __initdata = {
+	0x300, 0x320, 0x340, 0x360, 0x200, 0x220, 0x240,
+	0x260, 0x280, 0x2a0, 0x2c0, 0x2e0, 0
+};
+static unsigned int cs8900_irq_map[] = {
+	10, 11, 12, 5
+};
 #endif
 #endif
 
@@ -201,9 +213,13 @@ static int g_cs89x0_media__force;
 
 static int __init media_fn(char *str)
 {
-	if (!strcmp(str, "rj45")) g_cs89x0_media__force = FORCE_RJ45;
-	else if (!strcmp(str, "aui")) g_cs89x0_media__force = FORCE_AUI;
-	else if (!strcmp(str, "bnc")) g_cs89x0_media__force = FORCE_BNC;
+	if (!strcmp(str, "rj45"))
+		g_cs89x0_media__force = FORCE_RJ45;
+	else if (!strcmp(str, "aui"))
+		g_cs89x0_media__force = FORCE_AUI;
+	else if (!strcmp(str, "bnc"))
+		g_cs89x0_media__force = FORCE_BNC;
+
 	return 1;
 }
 
@@ -299,16 +315,21 @@ get_eeprom_data(struct net_device *dev, int off, int len, int *buffer)
 {
 	int i;
 
-	if (net_debug > 3) printk("EEPROM data from %x for %x:\n", off, len);
+	if (net_debug > 3)
+		printk("EEPROM data from %x for %x:\n", off, len);
 	for (i = 0; i < len; i++) {
-		if (wait_eeprom_ready(dev) < 0) return -1;
+		if (wait_eeprom_ready(dev) < 0)
+			return -1;
 		/* Now send the EEPROM read command and EEPROM location to read */
 		writereg(dev, PP_EECMD, (off + i) | EEPROM_READ_CMD);
-		if (wait_eeprom_ready(dev) < 0) return -1;
+		if (wait_eeprom_ready(dev) < 0)
+			return -1;
 		buffer[i] = readreg(dev, PP_EEData);
-		if (net_debug > 3) printk("%04x ", buffer[i]);
+		if (net_debug > 3)
+			printk("%04x ", buffer[i]);
 	}
-	if (net_debug > 3) printk("\n");
+	if (net_debug > 3)
+		printk("\n");
 	return 0;
 }
 
@@ -364,7 +385,6 @@ static int __init
 cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 {
 	struct net_local *lp = netdev_priv(dev);
-	static unsigned version_printed;
 	int i;
 	int tmp;
 	unsigned rev_type = 0;
@@ -415,8 +435,8 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 	if (lp->chip_type != CS8900 && lp->chip_revision >= 'C')
 		lp->send_cmd = TX_NOW;
 
-	if (net_debug  &&  version_printed++ == 0)
-		printk(version);
+	if (net_debug)
+		printk_once(version);
 
 	pr_info("%s: cs89%c0%s rev %c found at %p ",
 		dev->name,
@@ -436,7 +456,7 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 	 */
 
 	if ((readreg(dev, PP_SelfST) & (EEPROM_OK | EEPROM_PRESENT)) ==
-	    (EEPROM_OK|EEPROM_PRESENT)) {
+	    (EEPROM_OK | EEPROM_PRESENT)) {
 		/* Load the MAC. */
 		for (i = 0; i < ETH_ALEN / 2; i++) {
 			unsigned int Addr;
@@ -507,12 +527,14 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 		 */
 
 		/* get transmission control word  but keep the autonegotiation bits */
-		if (!lp->auto_neg_cnf) lp->auto_neg_cnf = eeprom_buff[AUTO_NEG_CNF_OFFSET/2];
+		if (!lp->auto_neg_cnf)
+			lp->auto_neg_cnf = eeprom_buff[AUTO_NEG_CNF_OFFSET / 2];
 		/* Store adapter configuration */
-		if (!lp->adapter_cnf) lp->adapter_cnf = eeprom_buff[ADAPTER_CNF_OFFSET/2];
+		if (!lp->adapter_cnf)
+			lp->adapter_cnf = eeprom_buff[ADAPTER_CNF_OFFSET / 2];
 		/* Store ISA configuration */
-		lp->isa_config = eeprom_buff[ISA_CNF_OFFSET/2];
-		dev->mem_start = eeprom_buff[PACKET_PAGE_OFFSET/2] << 8;
+		lp->isa_config = eeprom_buff[ISA_CNF_OFFSET / 2];
+		dev->mem_start = eeprom_buff[PACKET_PAGE_OFFSET / 2] << 8;
 
 		/* eeprom_buff has 32-bit ints, so we can't just memcpy it */
 		/* store the initial memory base address */
@@ -528,13 +550,26 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 	/* allow them to force multiple transceivers.  If they force multiple, autosense */
 	{
 		int count = 0;
-		if (lp->force & FORCE_RJ45)	{lp->adapter_cnf |= A_CNF_10B_T; count++; }
-		if (lp->force & FORCE_AUI)	{lp->adapter_cnf |= A_CNF_AUI; count++; }
-		if (lp->force & FORCE_BNC)	{lp->adapter_cnf |= A_CNF_10B_2; count++; }
-		if (count > 1)			{lp->adapter_cnf |= A_CNF_MEDIA_AUTO; }
-		else if (lp->force & FORCE_RJ45){lp->adapter_cnf |= A_CNF_MEDIA_10B_T; }
-		else if (lp->force & FORCE_AUI)	{lp->adapter_cnf |= A_CNF_MEDIA_AUI; }
-		else if (lp->force & FORCE_BNC)	{lp->adapter_cnf |= A_CNF_MEDIA_10B_2; }
+		if (lp->force & FORCE_RJ45) {
+			lp->adapter_cnf |= A_CNF_10B_T;
+			count++;
+		}
+		if (lp->force & FORCE_AUI) {
+			lp->adapter_cnf |= A_CNF_AUI;
+			count++;
+		}
+		if (lp->force & FORCE_BNC) {
+			lp->adapter_cnf |= A_CNF_10B_2;
+			count++;
+		}
+		if (count > 1)
+			lp->adapter_cnf |= A_CNF_MEDIA_AUTO;
+		else if (lp->force & FORCE_RJ45)
+			lp->adapter_cnf |= A_CNF_MEDIA_10B_T;
+		else if (lp->force & FORCE_AUI)
+			lp->adapter_cnf |= A_CNF_MEDIA_AUI;
+		else if (lp->force & FORCE_BNC)
+			lp->adapter_cnf |= A_CNF_MEDIA_10B_2;
 	}
 
 	if (net_debug > 1)
@@ -584,7 +619,8 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 					    IRQ_MAP_LEN / 2,
 					    irq_map_buff) >= 0) {
 				if ((irq_map_buff[0] & 0xff) == PNP_IRQ_FRMT)
-					lp->irq_map = (irq_map_buff[0] >> 8) | (irq_map_buff[1] << 8);
+					lp->irq_map = ((irq_map_buff[0] >> 8) |
+						       (irq_map_buff[1] << 8));
 			}
 #endif
 		}
@@ -599,20 +635,16 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 	if (lp->use_dma) {
 		get_dma_channel(dev);
 		printk(", DMA %d", dev->dma);
-	}
-	else
+	} else
 #endif
-	{
 		printk(", programmed I/O");
-	}
 
 	/* print the ethernet address. */
-	printk(", MAC %pM", dev->dev_addr);
+	printk(", MAC %pM\n", dev->dev_addr);
 
 	dev->netdev_ops	= &net_ops;
 	dev->watchdog_timeo = HZ;
 
-	printk("\n");
 	if (net_debug)
 		printk("cs89x0_probe1() successful\n");
 
@@ -663,7 +695,7 @@ cs89x0_ioport_probe(struct net_device *dev, unsigned long ioport, int modular)
 	if (ioport & 1) {
 		if (net_debug > 1)
 			pr_info("%s: odd ioaddr 0x%lx\n", dev->name, ioport);
-		if ((ioport & 2) != 2)
+		if ((ioport & 2) != 2) {
 			if ((ioread16(io_mem + ADD_PORT) & ADD_MASK) !=
 			    ADD_SIG) {
 				pr_err("%s: bad signature 0x%x\n",
@@ -671,6 +703,7 @@ cs89x0_ioport_probe(struct net_device *dev, unsigned long ioport, int modular)
 				ret = -ENODEV;
 				goto unmap;
 			}
+		}
 	}
 
 	ret = cs89x0_probe1(dev, io_mem, modular);
@@ -742,7 +775,7 @@ out:
 
 #if ALLOW_DMA
 
-#define dma_page_eq(ptr1, ptr2) ((long)(ptr1)>>17 == (long)(ptr2)>>17)
+#define dma_page_eq(ptr1, ptr2) ((long)(ptr1) >> 17 == (long)(ptr2) >> 17)
 
 static void
 get_dma_channel(struct net_device *dev)
@@ -771,11 +804,10 @@ write_dma(struct net_device *dev, int chip_type, int dma)
 	struct net_local *lp = netdev_priv(dev);
 	if ((lp->isa_config & ANY_ISA_DMA) == 0)
 		return;
-	if (chip_type == CS8900) {
-		writereg(dev, PP_CS8900_ISADMA, dma-5);
-	} else {
+	if (chip_type == CS8900)
+		writereg(dev, PP_CS8900_ISADMA, dma - 5);
+	else
 		writereg(dev, PP_CS8920_ISADMA, dma);
-	}
 }
 
 static void
@@ -836,8 +868,8 @@ dma_rx(struct net_device *dev)
 	int status, length;
 	unsigned char *bp = lp->rx_dma_ptr;
 
-	status = bp[0] + (bp[1]<<8);
-	length = bp[2] + (bp[3]<<8);
+	status = bp[0] + (bp[1] << 8);
+	length = bp[2] + (bp[3] << 8);
 	bp += 4;
 	if (net_debug > 5) {
 		printk("%s: receiving DMA packet at %lx, status %x, length %x\n",
@@ -852,13 +884,15 @@ dma_rx(struct net_device *dev)
 	skb = netdev_alloc_skb(dev, length + 2);
 	if (skb == NULL) {
 		if (net_debug)	/* I don't think we want to do this to a stressed system */
-			printk("%s: Memory squeeze, dropping packet.\n", dev->name);
+			printk("%s: Memory squeeze, dropping packet\n",
+			       dev->name);
 		dev->stats.rx_dropped++;
 
 		/* AKPM: advance bp to the next frame */
 skip_this_frame:
 		bp += (length + 3) & ~3;
-		if (bp >= lp->end_dma_buff) bp -= lp->dmasize*1024;
+		if (bp >= lp->end_dma_buff)
+			bp -= lp->dmasize * 1024;
 		lp->rx_dma_ptr = bp;
 		return;
 	}
@@ -873,13 +907,15 @@ skip_this_frame:
 		memcpy(skb_put(skb, length), bp, length);
 	}
 	bp += (length + 3) & ~3;
-	if (bp >= lp->end_dma_buff) bp -= lp->dmasize*1024;
+	if (bp >= lp->end_dma_buff)
+		bp -= lp->dmasize*1024;
 	lp->rx_dma_ptr = bp;
 
 	if (net_debug > 3) {
 		printk("%s: received %d byte DMA packet of type %x\n",
 		       dev->name, length,
-		       (skb->data[ETH_ALEN + ETH_ALEN] << 8) | skb->data[ETH_ALEN + ETH_ALEN + 1]);
+		       ((skb->data[ETH_ALEN + ETH_ALEN] << 8) |
+			skb->data[ETH_ALEN + ETH_ALEN + 1]));
 	}
 	skb->protocol = eth_type_trans(skb, dev);
 	netif_rx(skb);
@@ -919,7 +955,8 @@ static void __init reset_chip(struct net_device *dev)
 
 	/* Wait until the chip is reset */
 	reset_start_time = jiffies;
-	while ((readreg(dev, PP_SelfST) & INIT_DONE) == 0 && jiffies - reset_start_time < 2)
+	while ((readreg(dev, PP_SelfST) & INIT_DONE) == 0 &&
+	       jiffies - reset_start_time < 2)
 		;
 #endif /* !CONFIG_MACH_MX31ADS */
 }
@@ -932,8 +969,9 @@ control_dc_dc(struct net_device *dev, int on_not_off)
 	unsigned int selfcontrol;
 	int timenow = jiffies;
 	/* control the DC to DC convertor in the SelfControl register.
-	   Note: This is hooked up to a general purpose pin, might not
-	   always be a DC to DC convertor. */
+	 * Note: This is hooked up to a general purpose pin, might not
+	 * always be a DC to DC convertor.
+	 */
 
 	selfcontrol = HCB1_ENBL; /* Enable the HCB1 bit as an output */
 	if (((lp->adapter_cnf & A_CNF_DC_DC_POLARITY) != 0) ^ on_not_off)
@@ -960,18 +998,23 @@ detect_tp(struct net_device *dev)
 	int timenow = jiffies;
 	int fdx;
 
-	if (net_debug > 1) printk("%s: Attempting TP\n", dev->name);
-
-	/* If connected to another full duplex capable 10-Base-T card the link pulses
-	   seem to be lost when the auto detect bit in the LineCTL is set.
-	   To overcome this the auto detect bit will be cleared whilst testing the
-	   10-Base-T interface.  This would not be necessary for the sparrow chip but
-	   is simpler to do it anyway. */
+	if (net_debug > 1)
+		printk("%s: Attempting TP\n", dev->name);
+
+	/* If connected to another full duplex capable 10-Base-T card
+	 * the link pulses seem to be lost when the auto detect bit in
+	 * the LineCTL is set.  To overcome this the auto detect bit will
+	 * be cleared whilst testing the 10-Base-T interface.  This would
+	 * not be necessary for the sparrow chip but is simpler to do it
+	 * anyway.
+	 */
 	writereg(dev, PP_LineCTL, lp->linectl & ~AUI_ONLY);
 	control_dc_dc(dev, 0);
 
-	/* Delay for the hardware to work out if the TP cable is present - 150ms */
-	for (timenow = jiffies; jiffies - timenow < 15; )
+	/* Delay for the hardware to work out if the TP cable is present
+	 * - 150ms
+	 */
+	for (timenow = jiffies; jiffies - timenow < 15;)
 		;
 	if ((readreg(dev, PP_LineST) & LINK_OK) == 0)
 		return DETECTED_NONE;
@@ -991,7 +1034,8 @@ detect_tp(struct net_device *dev)
 		case FORCE_HALF:
 			break;
 		case FORCE_FULL:
-			writereg(dev, PP_TestCTL, readreg(dev, PP_TestCTL) | FDX_8900);
+			writereg(dev, PP_TestCTL,
+				 readreg(dev, PP_TestCTL) | FDX_8900);
 			break;
 		}
 		fdx = readreg(dev, PP_TestCTL) & FDX_8900;
@@ -1032,10 +1076,12 @@ static int
 send_test_pkt(struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
-	char test_packet[] = { 0,0,0,0,0,0, 0,0,0,0,0,0,
-			       0, 46, /* A 46 in network order */
-			       0, 0, /* DSAP=0 & SSAP=0 fields */
-			       0xf3, 0 /* Control (Test Req + P bit set) */ };
+	char test_packet[] = {
+		0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,
+		0, 46,		/* A 46 in network order */
+		0, 0,		/* DSAP=0 & SSAP=0 fields */
+		0xf3, 0		/* Control (Test Req + P bit set) */
+	};
 	long timenow = jiffies;
 
 	writereg(dev, PP_LineCTL, readreg(dev, PP_LineCTL) | SERIAL_TX_ON);
@@ -1054,17 +1100,20 @@ send_test_pkt(struct net_device *dev)
 		return 0;	/* this shouldn't happen */
 
 	/* Write the contents of the packet */
-	writewords(lp, TX_FRAME_PORT, test_packet, (ETH_ZLEN+1) >> 1);
+	writewords(lp, TX_FRAME_PORT, test_packet, (ETH_ZLEN + 1) >> 1);
 
-	if (net_debug > 1) printk("Sending test packet ");
+	if (net_debug > 1)
+		printk("Sending test packet ");
 	/* wait a couple of jiffies for packet to be received */
-	for (timenow = jiffies; jiffies - timenow < 3; )
+	for (timenow = jiffies; jiffies - timenow < 3;)
 		;
 	if ((readreg(dev, PP_TxEvent) & TX_SEND_OK_BITS) == TX_OK) {
-		if (net_debug > 1) printk("succeeded\n");
+		if (net_debug > 1)
+			printk("succeeded\n");
 		return 1;
 	}
-	if (net_debug > 1) printk("failed\n");
+	if (net_debug > 1)
+		printk("failed\n");
 	return 0;
 }
 
@@ -1074,7 +1123,8 @@ detect_aui(struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
 
-	if (net_debug > 1) printk("%s: Attempting AUI\n", dev->name);
+	if (net_debug > 1)
+		printk("%s: Attempting AUI\n", dev->name);
 	control_dc_dc(dev, 0);
 
 	writereg(dev, PP_LineCTL, (lp->linectl & ~AUTO_AUI_10BASET) | AUI_ONLY);
@@ -1090,7 +1140,8 @@ detect_bnc(struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
 
-	if (net_debug > 1) printk("%s: Attempting BNC\n", dev->name);
+	if (net_debug > 1)
+		printk("%s: Attempting BNC\n", dev->name);
 	control_dc_dc(dev, 1);
 
 	writereg(dev, PP_LineCTL, (lp->linectl & ~AUTO_AUI_10BASET) | AUI_ONLY);
@@ -1155,7 +1206,8 @@ net_open(struct net_device *dev)
 
 		for (i = 2; i < CS8920_NO_INTS; i++) {
 			if ((1 << i) & lp->irq_map) {
-				if (request_irq(i, net_interrupt, 0, dev->name, dev) == 0) {
+				if (request_irq(i, net_interrupt, 0, dev->name,
+						dev) == 0) {
 					dev->irq = i;
 					write_irq(dev, lp->chip_type, i);
 					/* writereg(dev, PP_BufCFG, GENERATE_SW_INTERRUPT); */
@@ -1170,9 +1222,7 @@ net_open(struct net_device *dev)
 			ret = -EAGAIN;
 			goto bad_out;
 		}
-	}
-	else
-	{
+	} else {
 #if !defined(CS89x0_NONISA_IRQ) && !defined(CONFIG_CS89x0_PLATFORM)
 		if (((1 << dev->irq) & lp->irq_map) == 0) {
 			pr_err("%s: IRQ %d is not in our map of allowable IRQs, which is %x\n",
@@ -1196,69 +1246,78 @@ net_open(struct net_device *dev)
 	}
 
 #if ALLOW_DMA
-	if (lp->use_dma) {
-		if (lp->isa_config & ANY_ISA_DMA) {
-			unsigned long flags;
-			lp->dma_buff = (unsigned char *)__get_dma_pages(GFP_KERNEL,
-									get_order(lp->dmasize * 1024));
-
-			if (!lp->dma_buff) {
-				pr_err("%s: cannot get %dK memory for DMA\n",
-				       dev->name, lp->dmasize);
-				goto release_irq;
-			}
-			if (net_debug > 1) {
-				printk("%s: dma %lx %lx\n",
-				       dev->name,
-				       (unsigned long)lp->dma_buff,
-				       (unsigned long)isa_virt_to_bus(lp->dma_buff));
-			}
-			if ((unsigned long) lp->dma_buff >= MAX_DMA_ADDRESS ||
-			    !dma_page_eq(lp->dma_buff, lp->dma_buff+lp->dmasize*1024-1)) {
-				pr_err("%s: not usable as DMA buffer\n",
-				       dev->name);
-				goto release_irq;
-			}
-			memset(lp->dma_buff, 0, lp->dmasize * 1024);	/* Why? */
-			if (request_dma(dev->dma, dev->name)) {
-				pr_err("%s: cannot get dma channel %d\n",
-				       dev->name, dev->dma);
-				goto release_irq;
-			}
-			write_dma(dev, lp->chip_type, dev->dma);
-			lp->rx_dma_ptr = lp->dma_buff;
-			lp->end_dma_buff = lp->dma_buff + lp->dmasize*1024;
-			spin_lock_irqsave(&lp->lock, flags);
-			disable_dma(dev->dma);
-			clear_dma_ff(dev->dma);
-			set_dma_mode(dev->dma, DMA_RX_MODE); /* auto_init as well */
-			set_dma_addr(dev->dma, isa_virt_to_bus(lp->dma_buff));
-			set_dma_count(dev->dma, lp->dmasize*1024);
-			enable_dma(dev->dma);
-			spin_unlock_irqrestore(&lp->lock, flags);
+	if (lp->use_dma && (lp->isa_config & ANY_ISA_DMA)) {
+		unsigned long flags;
+		lp->dma_buff = (unsigned char *)__get_dma_pages(GFP_KERNEL,
+								get_order(lp->dmasize * 1024));
+		if (!lp->dma_buff) {
+			pr_err("%s: cannot get %dK memory for DMA\n",
+			       dev->name, lp->dmasize);
+			goto release_irq;
+		}
+		if (net_debug > 1) {
+			printk("%s: dma %lx %lx\n",
+			       dev->name,
+			       (unsigned long)lp->dma_buff,
+			       (unsigned long)isa_virt_to_bus(lp->dma_buff));
+		}
+		if ((unsigned long)lp->dma_buff >= MAX_DMA_ADDRESS ||
+		    !dma_page_eq(lp->dma_buff,
+				 lp->dma_buff + lp->dmasize * 1024 - 1)) {
+			pr_err("%s: not usable as DMA buffer\n", dev->name);
+			goto release_irq;
 		}
+		memset(lp->dma_buff, 0, lp->dmasize * 1024);	/* Why? */
+		if (request_dma(dev->dma, dev->name)) {
+			pr_err("%s: cannot get dma channel %d\n",
+			       dev->name, dev->dma);
+			goto release_irq;
+		}
+		write_dma(dev, lp->chip_type, dev->dma);
+		lp->rx_dma_ptr = lp->dma_buff;
+		lp->end_dma_buff = lp->dma_buff + lp->dmasize * 1024;
+		spin_lock_irqsave(&lp->lock, flags);
+		disable_dma(dev->dma);
+		clear_dma_ff(dev->dma);
+		set_dma_mode(dev->dma, DMA_RX_MODE); /* auto_init as well */
+		set_dma_addr(dev->dma, isa_virt_to_bus(lp->dma_buff));
+		set_dma_count(dev->dma, lp->dmasize * 1024);
+		enable_dma(dev->dma);
+		spin_unlock_irqrestore(&lp->lock, flags);
 	}
 #endif	/* ALLOW_DMA */
 
 	/* set the Ethernet address */
 	for (i = 0; i < ETH_ALEN / 2; i++)
-		writereg(dev, PP_IA + i * 2, dev->dev_addr[i * 2] | (dev->dev_addr[i * 2 + 1] << 8));
+		writereg(dev, PP_IA + i * 2,
+			 (dev->dev_addr[i * 2] |
+			  (dev->dev_addr[i * 2 + 1] << 8)));
 
 	/* while we're testing the interface, leave interrupts disabled */
 	writereg(dev, PP_BusCTL, MEMORY_ON);
 
 	/* Set the LineCTL quintuplet based on adapter configuration read from EEPROM */
-	if ((lp->adapter_cnf & A_CNF_EXTND_10B_2) && (lp->adapter_cnf & A_CNF_LOW_RX_SQUELCH))
+	if ((lp->adapter_cnf & A_CNF_EXTND_10B_2) &&
+	    (lp->adapter_cnf & A_CNF_LOW_RX_SQUELCH))
 		lp->linectl = LOW_RX_SQUELCH;
 	else
 		lp->linectl = 0;
 
 	/* check to make sure that they have the "right" hardware available */
 	switch (lp->adapter_cnf & A_CNF_MEDIA_TYPE) {
-	case A_CNF_MEDIA_10B_T: result = lp->adapter_cnf & A_CNF_10B_T; break;
-	case A_CNF_MEDIA_AUI:   result = lp->adapter_cnf & A_CNF_AUI; break;
-	case A_CNF_MEDIA_10B_2: result = lp->adapter_cnf & A_CNF_10B_2; break;
-	default: result = lp->adapter_cnf & (A_CNF_10B_T | A_CNF_AUI | A_CNF_10B_2);
+	case A_CNF_MEDIA_10B_T:
+		result = lp->adapter_cnf & A_CNF_10B_T;
+		break;
+	case A_CNF_MEDIA_AUI:
+		result = lp->adapter_cnf & A_CNF_AUI;
+		break;
+	case A_CNF_MEDIA_10B_2:
+		result = lp->adapter_cnf & A_CNF_10B_2;
+		break;
+	default:
+		result = lp->adapter_cnf & (A_CNF_10B_T |
+					    A_CNF_AUI |
+					    A_CNF_10B_2);
 	}
 	if (!result) {
 		pr_err("%s: EEPROM is configured for unavailable media\n",
@@ -1269,7 +1328,8 @@ release_dma:
 release_irq:
 		release_dma_buff(lp);
 #endif
-		writereg(dev, PP_LineCTL, readreg(dev, PP_LineCTL) & ~(SERIAL_TX_ON | SERIAL_RX_ON));
+		writereg(dev, PP_LineCTL,
+			 readreg(dev, PP_LineCTL) & ~(SERIAL_TX_ON | SERIAL_RX_ON));
 		free_irq(dev->irq, dev);
 		ret = -EAGAIN;
 		goto bad_out;
@@ -1304,15 +1364,21 @@ release_irq:
 		break;
 	case A_CNF_MEDIA_AUTO:
 		writereg(dev, PP_LineCTL, lp->linectl | AUTO_AUI_10BASET);
-		if (lp->adapter_cnf & A_CNF_10B_T)
-			if ((result = detect_tp(dev)) != DETECTED_NONE)
+		if (lp->adapter_cnf & A_CNF_10B_T) {
+			result = detect_tp(dev);
+			if (result != DETECTED_NONE)
 				break;
-		if (lp->adapter_cnf & A_CNF_AUI)
-			if ((result = detect_aui(dev)) != DETECTED_NONE)
+		}
+		if (lp->adapter_cnf & A_CNF_AUI) {
+			result = detect_aui(dev);
+			if (result != DETECTED_NONE)
 				break;
-		if (lp->adapter_cnf & A_CNF_10B_2)
-			if ((result = detect_bnc(dev)) != DETECTED_NONE)
+		}
+		if (lp->adapter_cnf & A_CNF_10B_2) {
+			result = detect_bnc(dev);
+			if (result != DETECTED_NONE)
 				break;
+		}
 		pr_err("%s: no media detected\n", dev->name);
 		goto release_dma;
 	}
@@ -1336,7 +1402,8 @@ release_irq:
 	}
 
 	/* Turn on both receive and transmit operations */
-	writereg(dev, PP_LineCTL, readreg(dev, PP_LineCTL) | SERIAL_RX_ON | SERIAL_TX_ON);
+	writereg(dev, PP_LineCTL,
+		 readreg(dev, PP_LineCTL) | SERIAL_RX_ON | SERIAL_TX_ON);
 
 	/* Receive only error free packets addressed to this card */
 	lp->rx_mode = 0;
@@ -1351,22 +1418,29 @@ release_irq:
 #endif
 	writereg(dev, PP_RxCFG, lp->curr_rx_cfg);
 
-	writereg(dev, PP_TxCFG, TX_LOST_CRS_ENBL | TX_SQE_ERROR_ENBL | TX_OK_ENBL |
-		 TX_LATE_COL_ENBL | TX_JBR_ENBL | TX_ANY_COL_ENBL | TX_16_COL_ENBL);
+	writereg(dev, PP_TxCFG, (TX_LOST_CRS_ENBL |
+				 TX_SQE_ERROR_ENBL |
+				 TX_OK_ENBL |
+				 TX_LATE_COL_ENBL |
+				 TX_JBR_ENBL |
+				 TX_ANY_COL_ENBL |
+				 TX_16_COL_ENBL));
 
-	writereg(dev, PP_BufCFG, READY_FOR_TX_ENBL | RX_MISS_COUNT_OVRFLOW_ENBL |
+	writereg(dev, PP_BufCFG, (READY_FOR_TX_ENBL |
+				  RX_MISS_COUNT_OVRFLOW_ENBL |
 #if ALLOW_DMA
-		 dma_bufcfg(dev) |
+				  dma_bufcfg(dev) |
 #endif
-		 TX_COL_COUNT_OVRFLOW_ENBL | TX_UNDERRUN_ENBL);
+				  TX_COL_COUNT_OVRFLOW_ENBL |
+				  TX_UNDERRUN_ENBL));
 
 	/* now that we've got our act together, enable everything */
-	writereg(dev, PP_BusCTL, ENABLE_IRQ
-		 | (dev->mem_start ? MEMORY_ON : 0) /* turn memory on */
+	writereg(dev, PP_BusCTL, (ENABLE_IRQ
+				  | (dev->mem_start ? MEMORY_ON : 0) /* turn memory on */
 #if ALLOW_DMA
-		 | dma_busctl(dev)
+				  | dma_busctl(dev)
 #endif
-		);
+			 ));
 	netif_start_queue(dev);
 	if (net_debug > 1)
 		printk("cs89x0: net_open() succeeded\n");
@@ -1379,8 +1453,10 @@ static void net_timeout(struct net_device *dev)
 {
 	/* If we get here, some higher level has decided we are broken.
 	   There should really be a "kick me" function call instead. */
-	if (net_debug > 0) printk("%s: transmit timed out, %s?\n", dev->name,
-				  tx_done(dev) ? "IRQ conflict ?" : "network cable problem");
+	if (net_debug > 0)
+		printk("%s: transmit timed out, %s?\n",
+		       dev->name,
+		       tx_done(dev) ? "IRQ conflict" : "network cable problem");
 	/* Try to restart the adaptor. */
 	netif_wake_queue(dev);
 }
@@ -1393,12 +1469,14 @@ static netdev_tx_t net_send_packet(struct sk_buff *skb, struct net_device *dev)
 	if (net_debug > 3) {
 		printk("%s: sent %d byte packet of type %x\n",
 		       dev->name, skb->len,
-		       (skb->data[ETH_ALEN + ETH_ALEN] << 8) | skb->data[ETH_ALEN + ETH_ALEN + 1]);
+		       ((skb->data[ETH_ALEN + ETH_ALEN] << 8) |
+			skb->data[ETH_ALEN + ETH_ALEN + 1]));
 	}
 
 	/* keep the upload from being interrupted, since we
-	   ask the chip to start transmitting before the
-	   whole packet has been completely uploaded. */
+	 * ask the chip to start transmitting before the
+	 * whole packet has been completely uploaded.
+	 */
 
 	spin_lock_irqsave(&lp->lock, flags);
 	netif_stop_queue(dev);
@@ -1414,11 +1492,12 @@ static netdev_tx_t net_send_packet(struct sk_buff *skb, struct net_device *dev)
 		 */
 
 		spin_unlock_irqrestore(&lp->lock, flags);
-		if (net_debug) printk("cs89x0: Tx buffer not free!\n");
+		if (net_debug)
+			printk("cs89x0: Tx buffer not free!\n");
 		return NETDEV_TX_BUSY;
 	}
 	/* Write the contents of the packet */
-	writewords(lp, TX_FRAME_PORT, skb->data, (skb->len+1) >> 1);
+	writewords(lp, TX_FRAME_PORT, skb->data, (skb->len + 1) >> 1);
 	spin_unlock_irqrestore(&lp->lock, flags);
 	dev->stats.tx_bytes += skb->len;
 	dev_kfree_skb(skb);
@@ -1427,10 +1506,10 @@ static netdev_tx_t net_send_packet(struct sk_buff *skb, struct net_device *dev)
 	 * We also DO NOT call netif_start_queue().
 	 *
 	 * Either of these would cause another bottom half run through
-	 * net_send_packet() before this packet has fully gone out.  That causes
-	 * us to hit the "Gasp!" above and the send is rescheduled.  it runs like
-	 * a dog.  We just return and wait for the Tx completion interrupt handler
-	 * to restart the netdevice layer
+	 * net_send_packet() before this packet has fully gone out.
+	 * That causes us to hit the "Gasp!" above and the send is rescheduled.
+	 * it runs like a dog.  We just return and wait for the Tx completion
+	 * interrupt handler to restart the netdevice layer
 	 */
 
 	return NETDEV_TX_OK;
@@ -1458,7 +1537,8 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
 	 * vista, baby!
 	 */
 	while ((status = ioread16(lp->virt_addr + ISQ_PORT))) {
-		if (net_debug > 4)printk("%s: event=%04x\n", dev->name, status);
+		if (net_debug > 4)
+			printk("%s: event=%04x\n", dev->name, status);
 		handled = 1;
 		switch (status & ISQ_EVENT_MASK) {
 		case ISQ_RECEIVER_EVENT:
@@ -1496,10 +1576,14 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
 				netif_wake_queue(dev);	/* Inform upper layers. */
 			}
 			if (status & TX_UNDERRUN) {
-				if (net_debug > 0) printk("%s: transmit underrun\n", dev->name);
+				if (net_debug > 0)
+					printk("%s: transmit underrun\n",
+					       dev->name);
 				lp->send_underrun++;
-				if (lp->send_underrun == 3) lp->send_cmd = TX_AFTER_381;
-				else if (lp->send_underrun == 6) lp->send_cmd = TX_AFTER_ALL;
+				if (lp->send_underrun == 3)
+					lp->send_cmd = TX_AFTER_381;
+				else if (lp->send_underrun == 6)
+					lp->send_cmd = TX_AFTER_ALL;
 				/* transmit cycle is done, although
 				 * frame wasn't transmitted - this
 				 * avoids having to wait for the upper
@@ -1513,14 +1597,17 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
 				int count = readreg(dev, PP_DmaFrameCnt);
 				while (count) {
 					if (net_debug > 5)
-						printk("%s: receiving %d DMA frames\n", dev->name, count);
+						printk("%s: receiving %d DMA frames\n",
+						       dev->name, count);
 					if (net_debug > 2 && count > 1)
-						printk("%s: receiving %d DMA frames\n", dev->name, count);
+						printk("%s: receiving %d DMA frames\n",
+						       dev->name, count);
 					dma_rx(dev);
 					if (--count == 0)
 						count = readreg(dev, PP_DmaFrameCnt);
 					if (net_debug > 2 && count > 0)
-						printk("%s: continuing with %d DMA frames\n", dev->name, count);
+						printk("%s: continuing with %d DMA frames\n",
+						       dev->name, count);
 				}
 			}
 #endif
@@ -1544,7 +1631,7 @@ count_rx_errors(int status, struct net_device *dev)
 		dev->stats.rx_length_errors++;
 	if (status & RX_EXTRA_DATA)
 		dev->stats.rx_length_errors++;
-	if ((status & RX_CRC_ERROR) && !(status & (RX_EXTRA_DATA|RX_RUNT)))
+	if ((status & RX_CRC_ERROR) && !(status & (RX_EXTRA_DATA | RX_RUNT)))
 		/* per str 172 */
 		dev->stats.rx_crc_errors++;
 	if (status & RX_DRIBBLE)
@@ -1585,7 +1672,8 @@ net_rx(struct net_device *dev)
 	if (net_debug > 3) {
 		printk("%s: received %d byte packet of type %x\n",
 		       dev->name, length,
-		       (skb->data[ETH_ALEN + ETH_ALEN] << 8) | skb->data[ETH_ALEN + ETH_ALEN + 1]);
+		       (skb->data[ETH_ALEN + ETH_ALEN] << 8) |
+		       skb->data[ETH_ALEN + ETH_ALEN + 1]);
 	}
 
 	skb->protocol = eth_type_trans(skb, dev);
@@ -1598,7 +1686,8 @@ net_rx(struct net_device *dev)
 static void release_dma_buff(struct net_local *lp)
 {
 	if (lp->dma_buff) {
-		free_pages((unsigned long)(lp->dma_buff), get_order(lp->dmasize * 1024));
+		free_pages((unsigned long)(lp->dma_buff),
+			   get_order(lp->dmasize * 1024));
 		lp->dma_buff = NULL;
 	}
 }
@@ -1656,28 +1745,29 @@ static void set_multicast_list(struct net_device *dev)
 	unsigned long flags;
 
 	spin_lock_irqsave(&lp->lock, flags);
-	if (dev->flags&IFF_PROMISC)
-	{
+	if (dev->flags & IFF_PROMISC)
 		lp->rx_mode = RX_ALL_ACCEPT;
-	}
 	else if ((dev->flags & IFF_ALLMULTI) || !netdev_mc_empty(dev))
-	{
-		/* The multicast-accept list is initialized to accept-all, and we
-		   rely on higher-level filtering for now. */
+		/* The multicast-accept list is initialized to accept-all,
+		 * and we rely on higher-level filtering for now.
+		 */
 		lp->rx_mode = RX_MULTCAST_ACCEPT;
-	}
 	else
 		lp->rx_mode = 0;
 
 	writereg(dev, PP_RxCTL, DEF_RX_ACCEPT | lp->rx_mode);
 
-	/* in promiscuous mode, we accept errored packets, so we have to enable interrupts on them also */
-	writereg(dev, PP_RxCFG, lp->curr_rx_cfg |
-		 (lp->rx_mode == RX_ALL_ACCEPT ? (RX_CRC_ERROR_ENBL|RX_RUNT_ENBL|RX_EXTRA_DATA_ENBL) : 0));
+	/* in promiscuous mode, we accept errored packets,
+	 * so we have to enable interrupts on them also
+	 */
+	writereg(dev, PP_RxCFG,
+		 (lp->curr_rx_cfg |
+		  (lp->rx_mode == RX_ALL_ACCEPT)
+		  ? (RX_CRC_ERROR_ENBL | RX_RUNT_ENBL | RX_EXTRA_DATA_ENBL)
+		  : 0));
 	spin_unlock_irqrestore(&lp->lock, flags);
 }
 
-
 static int set_mac_address(struct net_device *dev, void *p)
 {
 	int i;
@@ -1689,12 +1779,14 @@ static int set_mac_address(struct net_device *dev, void *p)
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 
 	if (net_debug)
-		printk("%s: Setting MAC address to %pM.\n",
+		printk("%s: Setting MAC address to %pM\n",
 		       dev->name, dev->dev_addr);
 
 	/* set the Ethernet address */
 	for (i = 0; i < ETH_ALEN / 2; i++)
-		writereg(dev, PP_IA + i * 2, dev->dev_addr[i * 2] | (dev->dev_addr[i * 2 + 1] << 8));
+		writereg(dev, PP_IA + i * 2,
+			 (dev->dev_addr[i * 2] |
+			  (dev->dev_addr[i * 2 + 1] << 8)));
 
 	return 0;
 }
@@ -1871,28 +1963,28 @@ static int __init cs89x0_platform_probe(struct platform_device *pdev)
 	mem_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	dev->irq = platform_get_irq(pdev, 0);
 	if (mem_res == NULL || dev->irq <= 0) {
-		dev_warn(&dev->dev, "memory/interrupt resource missing.\n");
+		dev_warn(&dev->dev, "memory/interrupt resource missing\n");
 		err = -ENXIO;
 		goto free;
 	}
 
 	lp->size = resource_size(mem_res);
 	if (!request_mem_region(mem_res->start, lp->size, DRV_NAME)) {
-		dev_warn(&dev->dev, "request_mem_region() failed.\n");
+		dev_warn(&dev->dev, "request_mem_region() failed\n");
 		err = -EBUSY;
 		goto free;
 	}
 
 	virt_addr = ioremap(mem_res->start, lp->size);
 	if (!virt_addr) {
-		dev_warn(&dev->dev, "ioremap() failed.\n");
+		dev_warn(&dev->dev, "ioremap() failed\n");
 		err = -ENOMEM;
 		goto release;
 	}
 
 	err = cs89x0_probe1(dev, virt_addr, 0);
 	if (err) {
-		dev_warn(&dev->dev, "no cs8900 or cs8920 detected.\n");
+		dev_warn(&dev->dev, "no cs8900 or cs8920 detected\n");
 		goto unmap;
 	}
 
-- 
1.7.8.111.gad25c.dirty
