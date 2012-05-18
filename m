From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2/5] cirrus: cs89x0: Convert printks to pr_<level>
Date: Fri, 18 May 2012 15:56:28 -0700
Message-ID: <228c9a0f562302738f1bd9ff7867d1925c9648a6.1337381533.git.joe@perches.com>
References: <cover.1337381533.git.joe@perches.com>
Cc: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1337381533.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use more current logging styles.

Add pr_fmt.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/cirrus/cs89x0.c |  116 ++++++++++++++++++----------------
 1 files changed, 61 insertions(+), 55 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index 41c8ac9..b612040 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -46,6 +46,8 @@
  *	Crystal Semiconductor data sheets.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/printk.h>
 #include <linux/errno.h>
@@ -385,15 +387,15 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 #endif
 	}
 
-	printk(KERN_DEBUG "PP_addr at %p[%x]: 0x%x\n",
-	       ioaddr, ADD_PORT, ioread16(ioaddr + ADD_PORT));
+	pr_debug("PP_addr at %p[%x]: 0x%x\n",
+		 ioaddr, ADD_PORT, ioread16(ioaddr + ADD_PORT));
 	iowrite16(PP_ChipID, ioaddr + ADD_PORT);
 
 	tmp = ioread16(ioaddr + DATA_PORT);
 	if (tmp != CHIP_EISA_ID_SIG) {
-		printk(KERN_DEBUG "%s: incorrect signature at %p[%x]: 0x%x!="
-		       CHIP_EISA_ID_SIG_STR "\n",
-		       dev->name, ioaddr, DATA_PORT, tmp);
+		pr_debug("%s: incorrect signature at %p[%x]: 0x%x!="
+			 CHIP_EISA_ID_SIG_STR "\n",
+			 dev->name, ioaddr, DATA_PORT, tmp);
 		retval = -ENODEV;
 		goto out1;
 	}
@@ -416,12 +418,12 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 	if (net_debug  &&  version_printed++ == 0)
 		printk(version);
 
-	printk(KERN_INFO "%s: cs89%c0%s rev %c found at %p ",
-	       dev->name,
-	       lp->chip_type == CS8900  ? '0' : '2',
-	       lp->chip_type == CS8920M ? "M" : "",
-	       lp->chip_revision,
-	       lp->virt_addr);
+	pr_info("%s: cs89%c0%s rev %c found at %p ",
+		dev->name,
+		lp->chip_type == CS8900  ? '0' : '2',
+		lp->chip_type == CS8920M ? "M" : "",
+		lp->chip_revision,
+		lp->virt_addr);
 
 	reset_chip(dev);
 
@@ -474,8 +476,8 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 				A_CNF_MEDIA_AUI | A_CNF_MEDIA_10B_T | A_CNF_MEDIA_AUTO;
 
 		if (net_debug > 1)
-			printk(KERN_INFO "%s: PP_LineCTL=0x%x, adapter_cnf=0x%x\n",
-			       dev->name, i, lp->adapter_cnf);
+			pr_info("%s: PP_LineCTL=0x%x, adapter_cnf=0x%x\n",
+				dev->name, i, lp->adapter_cnf);
 
 		/* IRQ. Other chips already probe, see below. */
 		if (lp->chip_type == CS8900)
@@ -489,15 +491,15 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 	/* First check to see if an EEPROM is attached. */
 
 	if ((readreg(dev, PP_SelfST) & EEPROM_PRESENT) == 0)
-		printk(KERN_WARNING "cs89x0: No EEPROM, relying on command line....\n");
+		pr_warn("No EEPROM, relying on command line....\n");
 	else if (get_eeprom_data(dev, START_EEPROM_DATA, CHKSUM_LEN, eeprom_buff) < 0) {
-		printk(KERN_WARNING "\ncs89x0: EEPROM read failed, relying on command line.\n");
+		pr_warn("EEPROM read failed, relying on command line\n");
 	} else if (get_eeprom_cksum(START_EEPROM_DATA, CHKSUM_LEN, eeprom_buff) < 0) {
 		/* Check if the chip was able to read its own configuration starting
 		   at 0 in the EEPROM*/
 		if ((readreg(dev, PP_SelfST) & (EEPROM_OK | EEPROM_PRESENT)) !=
 		    (EEPROM_OK | EEPROM_PRESENT))
-			printk(KERN_WARNING "cs89x0: Extended EEPROM checksum bad and no Cirrus EEPROM, relying on command line\n");
+			pr_warn("Extended EEPROM checksum bad and no Cirrus EEPROM, relying on command line\n");
 
 	} else {
 		/* This reads an extended EEPROM that is not documented
@@ -519,8 +521,8 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 			dev->dev_addr[i * 2 + 1] = eeprom_buff[i] >> 8;
 		}
 		if (net_debug > 1)
-			printk(KERN_DEBUG "%s: new adapter_cnf: 0x%x\n",
-			       dev->name, lp->adapter_cnf);
+			pr_debug("%s: new adapter_cnf: 0x%x\n",
+				 dev->name, lp->adapter_cnf);
 	}
 
 	/* allow them to force multiple transceivers.  If they force multiple, autosense */
@@ -536,8 +538,8 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 	}
 
 	if (net_debug > 1)
-		printk(KERN_DEBUG "%s: after force 0x%x, adapter_cnf=0x%x\n",
-		       dev->name, lp->force, lp->adapter_cnf);
+		pr_debug("%s: after force 0x%x, adapter_cnf=0x%x\n",
+			 dev->name, lp->force, lp->adapter_cnf);
 
 	/* FIXME: We don't let you set dc-dc polarity or low RX squelch from the command line: add it here */
 
@@ -547,10 +549,10 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 	 * ifconfig IFACE hw ether AABBCCDDEEFF
 	 */
 
-	printk(KERN_INFO "cs89x0 media %s%s%s",
-	       (lp->adapter_cnf & A_CNF_10B_T) ? "RJ-45," : "",
-	       (lp->adapter_cnf & A_CNF_AUI) ? "AUI," : "",
-	       (lp->adapter_cnf & A_CNF_10B_2) ? "BNC," : "");
+	pr_info("media %s%s%s",
+		(lp->adapter_cnf & A_CNF_10B_T) ? "RJ-45," : "",
+		(lp->adapter_cnf & A_CNF_AUI) ? "AUI," : "",
+		(lp->adapter_cnf & A_CNF_10B_2) ? "BNC," : "");
 
 	lp->irq_map = 0xffff;
 
@@ -570,7 +572,7 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 #else
 			/* Translate the IRQ using the IRQ mapping table. */
 			if (i >= ARRAY_SIZE(cs8900_irq_map))
-				printk("\ncs89x0: invalid ISA interrupt number %d\n", i);
+				pr_err("invalid ISA interrupt number %d\n", i);
 			else
 				i = cs8900_irq_map[i];
 
@@ -660,15 +662,12 @@ cs89x0_ioport_probe(struct net_device *dev, unsigned long ioport, int modular)
 	 */
 	if (ioport & 1) {
 		if (net_debug > 1)
-			printk(KERN_INFO "%s: odd ioaddr 0x%lx\n",
-			       dev->name,
-			       ioport);
+			pr_info("%s: odd ioaddr 0x%lx\n", dev->name, ioport);
 		if ((ioport & 2) != 2)
 			if ((ioread16(io_mem + ADD_PORT) & ADD_MASK) !=
 			    ADD_SIG) {
-				printk(KERN_ERR "%s: bad signature 0x%x\n",
-				       dev->name,
-				       ioread16(io_mem + ADD_PORT));
+				pr_err("%s: bad signature 0x%x\n",
+				       dev->name, ioread16(io_mem + ADD_PORT));
 				ret = -ENODEV;
 				goto unmap;
 			}
@@ -711,7 +710,7 @@ struct net_device * __init cs89x0_probe(int unit)
 	irq = dev->irq;
 
 	if (net_debug)
-		printk(KERN_INFO "cs89x0:cs89x0_probe(0x%x)\n", io);
+		pr_info("cs89x0_probe(0x%x)\n", io);
 
 	if (io > 0x1ff)	{	/* Check a single specified location. */
 		err = cs89x0_ioport_probe(dev, io, 0);
@@ -731,7 +730,7 @@ struct net_device * __init cs89x0_probe(int unit)
 	return dev;
 out:
 	free_netdev(dev);
-	printk(KERN_WARNING "cs89x0: no cs8900 or cs8920 detected.  Be sure to disable PnP with SETUP\n");
+	pr_warn("no cs8900 or cs8920 detected.  Be sure to disable PnP with SETUP\n");
 	return ERR_PTR(err);
 }
 #endif
@@ -1012,10 +1011,10 @@ detect_tp(struct net_device *dev)
 		writereg(dev, PP_AutoNegCTL, lp->auto_neg_cnf & AUTO_NEG_MASK);
 
 		if ((lp->auto_neg_cnf & AUTO_NEG_BITS) == AUTO_NEG_ENABLE) {
-			printk(KERN_INFO "%s: negotiating duplex...\n", dev->name);
+			pr_info("%s: negotiating duplex...\n", dev->name);
 			while (readreg(dev, PP_AutoNegST) & AUTO_NEG_BUSY) {
 				if (jiffies - timenow > 4000) {
-					printk(KERN_ERR "**** Full / half duplex auto-negotiation timed out ****\n");
+					pr_err("**** Full / half duplex auto-negotiation timed out ****\n");
 					break;
 				}
 			}
@@ -1167,7 +1166,7 @@ net_open(struct net_device *dev)
 
 		if (i >= CS8920_NO_INTS) {
 			writereg(dev, PP_BusCTL, 0);	/* disable interrupts. */
-			printk(KERN_ERR "cs89x0: can't get an interrupt\n");
+			pr_err("can't get an interrupt\n");
 			ret = -EAGAIN;
 			goto bad_out;
 		}
@@ -1176,7 +1175,7 @@ net_open(struct net_device *dev)
 	{
 #if !defined(CS89x0_NONISA_IRQ) && !defined(CONFIG_CS89x0_PLATFORM)
 		if (((1 << dev->irq) & lp->irq_map) == 0) {
-			printk(KERN_ERR "%s: IRQ %d is not in our map of allowable IRQs, which is %x\n",
+			pr_err("%s: IRQ %d is not in our map of allowable IRQs, which is %x\n",
 			       dev->name, dev->irq, lp->irq_map);
 			ret = -EAGAIN;
 			goto bad_out;
@@ -1191,7 +1190,7 @@ net_open(struct net_device *dev)
 		write_irq(dev, lp->chip_type, dev->irq);
 		ret = request_irq(dev->irq, net_interrupt, 0, dev->name, dev);
 		if (ret) {
-			printk(KERN_ERR "cs89x0: request_irq(%d) failed\n", dev->irq);
+			pr_err("request_irq(%d) failed\n", dev->irq);
 			goto bad_out;
 		}
 	}
@@ -1204,7 +1203,8 @@ net_open(struct net_device *dev)
 									get_order(lp->dmasize * 1024));
 
 			if (!lp->dma_buff) {
-				printk(KERN_ERR "%s: cannot get %dK memory for DMA\n", dev->name, lp->dmasize);
+				pr_err("%s: cannot get %dK memory for DMA\n",
+				       dev->name, lp->dmasize);
 				goto release_irq;
 			}
 			if (net_debug > 1) {
@@ -1215,12 +1215,14 @@ net_open(struct net_device *dev)
 			}
 			if ((unsigned long) lp->dma_buff >= MAX_DMA_ADDRESS ||
 			    !dma_page_eq(lp->dma_buff, lp->dma_buff+lp->dmasize*1024-1)) {
-				printk(KERN_ERR "%s: not usable as DMA buffer\n", dev->name);
+				pr_err("%s: not usable as DMA buffer\n",
+				       dev->name);
 				goto release_irq;
 			}
 			memset(lp->dma_buff, 0, lp->dmasize * 1024);	/* Why? */
 			if (request_dma(dev->dma, dev->name)) {
-				printk(KERN_ERR "%s: cannot get dma channel %d\n", dev->name, dev->dma);
+				pr_err("%s: cannot get dma channel %d\n",
+				       dev->name, dev->dma);
 				goto release_irq;
 			}
 			write_dma(dev, lp->chip_type, dev->dma);
@@ -1259,7 +1261,8 @@ net_open(struct net_device *dev)
 	default: result = lp->adapter_cnf & (A_CNF_10B_T | A_CNF_AUI | A_CNF_10B_2);
 	}
 	if (!result) {
-		printk(KERN_ERR "%s: EEPROM is configured for unavailable media\n", dev->name);
+		pr_err("%s: EEPROM is configured for unavailable media\n",
+		       dev->name);
 release_dma:
 #if ALLOW_DMA
 		free_dma(dev->dma);
@@ -1277,7 +1280,8 @@ release_irq:
 	case A_CNF_MEDIA_10B_T:
 		result = detect_tp(dev);
 		if (result == DETECTED_NONE) {
-			printk(KERN_WARNING "%s: 10Base-T (RJ-45) has no cable\n", dev->name);
+			pr_warn("%s: 10Base-T (RJ-45) has no cable\n",
+				dev->name);
 			if (lp->auto_neg_cnf & IMM_BIT) /* check "ignore missing media" bit */
 				result = DETECTED_RJ45H; /* Yes! I don't care if I see a link pulse */
 		}
@@ -1285,7 +1289,7 @@ release_irq:
 	case A_CNF_MEDIA_AUI:
 		result = detect_aui(dev);
 		if (result == DETECTED_NONE) {
-			printk(KERN_WARNING "%s: 10Base-5 (AUI) has no cable\n", dev->name);
+			pr_warn("%s: 10Base-5 (AUI) has no cable\n", dev->name);
 			if (lp->auto_neg_cnf & IMM_BIT) /* check "ignore missing media" bit */
 				result = DETECTED_AUI; /* Yes! I don't care if I see a carrrier */
 		}
@@ -1293,7 +1297,7 @@ release_irq:
 	case A_CNF_MEDIA_10B_2:
 		result = detect_bnc(dev);
 		if (result == DETECTED_NONE) {
-			printk(KERN_WARNING "%s: 10Base-2 (BNC) has no cable\n", dev->name);
+			pr_warn("%s: 10Base-2 (BNC) has no cable\n", dev->name);
 			if (lp->auto_neg_cnf & IMM_BIT) /* check "ignore missing media" bit */
 				result = DETECTED_BNC; /* Yes! I don't care if I can xmit a packet */
 		}
@@ -1309,24 +1313,25 @@ release_irq:
 		if (lp->adapter_cnf & A_CNF_10B_2)
 			if ((result = detect_bnc(dev)) != DETECTED_NONE)
 				break;
-		printk(KERN_ERR "%s: no media detected\n", dev->name);
+		pr_err("%s: no media detected\n", dev->name);
 		goto release_dma;
 	}
 	switch (result) {
 	case DETECTED_NONE:
-		printk(KERN_ERR "%s: no network cable attached to configured media\n", dev->name);
+		pr_err("%s: no network cable attached to configured media\n",
+		       dev->name);
 		goto release_dma;
 	case DETECTED_RJ45H:
-		printk(KERN_INFO "%s: using half-duplex 10Base-T (RJ-45)\n", dev->name);
+		pr_info("%s: using half-duplex 10Base-T (RJ-45)\n", dev->name);
 		break;
 	case DETECTED_RJ45F:
-		printk(KERN_INFO "%s: using full-duplex 10Base-T (RJ-45)\n", dev->name);
+		pr_info("%s: using full-duplex 10Base-T (RJ-45)\n", dev->name);
 		break;
 	case DETECTED_AUI:
-		printk(KERN_INFO "%s: using 10Base-5 (AUI)\n", dev->name);
+		pr_info("%s: using 10Base-5 (AUI)\n", dev->name);
 		break;
 	case DETECTED_BNC:
-		printk(KERN_INFO "%s: using 10Base-2 (BNC)\n", dev->name);
+		pr_info("%s: using 10Base-2 (BNC)\n", dev->name);
 		break;
 	}
 
@@ -1566,7 +1571,7 @@ net_rx(struct net_device *dev)
 	skb = netdev_alloc_skb(dev, length + 2);
 	if (skb == NULL) {
 #if 0		/* Again, this seems a cruel thing to do */
-		printk(KERN_WARNING "%s: Memory squeeze, dropping packet.\n", dev->name);
+		pr_warn("%s: Memory squeeze, dropping packet\n", dev->name);
 #endif
 		dev->stats.rx_dropped++;
 		return;
@@ -1808,8 +1813,8 @@ int __init init_module(void)
 		lp->auto_neg_cnf = AUTO_NEG_ENABLE;
 
 	if (io == 0) {
-		printk(KERN_ERR "cs89x0.c: Module autoprobing not allowed.\n");
-		printk(KERN_ERR "cs89x0.c: Append io=0xNNN\n");
+		pr_err("Module autoprobing not allowed\n");
+		pr_err("Append io=0xNNN\n");
 		ret = -EPERM;
 		goto out;
 	} else if (io <= 0x1ff) {
@@ -1819,7 +1824,8 @@ int __init init_module(void)
 
 #if ALLOW_DMA
 	if (use_dma && dmasize != 16 && dmasize != 64) {
-		printk(KERN_ERR "cs89x0.c: dma size must be either 16K or 64K, not %dK\n", dmasize);
+		pr_err("dma size must be either 16K or 64K, not %dK\n",
+		       dmasize);
 		ret = -EPERM;
 		goto out;
 	}
-- 
1.7.8.111.gad25c.dirty
