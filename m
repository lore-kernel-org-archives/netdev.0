From: domen@coderock.org
Subject: [patch 1/1] printk : drivers/net/hp100.c
Date: Sun, 29 May 2005 01:16:47 +0200
Message-ID: <20050528231647.466278000@nd47.coderock.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com,
        Christophe Lucas <clucas@rotomalug.org>, domen@coderock.org
Return-path: <netdev-bounce@oss.sgi.com>
To: perex@suse.cz
Content-Disposition: inline; filename=printk-drivers_net_hp100
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Christophe Lucas <clucas@rotomalug.org>



printk() calls should include appropriate KERN_* constant.

Signed-off-by: Christophe Lucas <clucas@rotomalug.org>
Signed-off-by: Domen Puncer <domen@coderock.org>


---
 hp100.c |  266 ++++++++++++++++++++++++++++++++--------------------------------
 1 files changed, 133 insertions(+), 133 deletions(-)

Index: quilt/drivers/net/hp100.c
===================================================================
--- quilt.orig/drivers/net/hp100.c
+++ quilt/drivers/net/hp100.c
@@ -406,7 +406,7 @@ struct net_device * __init hp100_probe(i
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4200, TRACE);
-	printk("hp100: %s: probe\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: probe\n", dev->name);
 #endif
 
 	if (unit >= 0) {
@@ -447,7 +447,7 @@ static int __devinit hp100_probe1(struct
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4201, TRACE);
-	printk("hp100: %s: probe1\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: probe1\n", dev->name);
 #endif
 
 	/* memory region for programmed i/o */
@@ -460,13 +460,13 @@ static int __devinit hp100_probe1(struct
 	chip = hp100_inw(PAGING) & HP100_CHIPID_MASK;
 #ifdef HP100_DEBUG
 	if (chip == HP100_CHIPID_SHASTA)
-		printk("hp100: %s: Shasta Chip detected. (This is a pre 802.12 chip)\n", dev->name);
+		printk(KERN_DEBUG "hp100: %s: Shasta Chip detected. (This is a pre 802.12 chip)\n", dev->name);
 	else if (chip == HP100_CHIPID_RAINIER)
-		printk("hp100: %s: Rainier Chip detected. (This is a pre 802.12 chip)\n", dev->name);
+		printk(KERN_DEBUG "hp100: %s: Rainier Chip detected. (This is a pre 802.12 chip)\n", dev->name);
 	else if (chip == HP100_CHIPID_LASSEN)
-		printk("hp100: %s: Lassen Chip detected.\n", dev->name);
+		printk(KERN_DEBUG "hp100: %s: Lassen Chip detected.\n", dev->name);
 	else
-		printk("hp100: %s: Warning: Unknown CASCADE chip (id=0x%.4x).\n", dev->name, chip);
+		printk(KERN_DEBUG "hp100: %s: Warning: Unknown CASCADE chip (id=0x%.4x).\n", dev->name, chip);
 #endif
 
 	dev->base_addr = ioaddr;
@@ -523,7 +523,7 @@ static int __devinit hp100_probe1(struct
 	if (local_mode < 1 || local_mode > 4)
 		local_mode = 1;	/* default */
 #ifdef HP100_DEBUG
-	printk("hp100: %s: original LSW = 0x%x\n", dev->name,
+	printk(KERN_DEBUG "hp100: %s: original LSW = 0x%x\n", dev->name,
 	       hp100_inw(OPTION_LSW));
 #endif
 
@@ -531,17 +531,17 @@ static int __devinit hp100_probe1(struct
 		hp100_outw(HP100_MEM_EN | HP100_RESET_LB, OPTION_LSW);
 		hp100_outw(HP100_IO_EN | HP100_SET_LB, OPTION_LSW);
 		hp100_outw(HP100_BM_WRITE | HP100_BM_READ | HP100_RESET_HB, OPTION_LSW);
-		printk("hp100: IO mapped mode forced.\n");
+		printk(KERN_INFO "hp100: IO mapped mode forced.\n");
 	} else if (local_mode == 2) {
 		hp100_outw(HP100_MEM_EN | HP100_SET_LB, OPTION_LSW);
 		hp100_outw(HP100_IO_EN | HP100_SET_LB, OPTION_LSW);
 		hp100_outw(HP100_BM_WRITE | HP100_BM_READ | HP100_RESET_HB, OPTION_LSW);
-		printk("hp100: Shared memory mode requested.\n");
+		printk(KERN_INFO "hp100: Shared memory mode requested.\n");
 	} else if (local_mode == 4) {
 		if (chip == HP100_CHIPID_LASSEN) {
 			hp100_outw(HP100_BM_WRITE | HP100_BM_READ | HP100_SET_HB, OPTION_LSW);
 			hp100_outw(HP100_IO_EN | HP100_MEM_EN | HP100_RESET_LB, OPTION_LSW);
-			printk("hp100: Busmaster mode requested.\n");
+			printk(KERN_INFO "hp100: Busmaster mode requested.\n");
 		}
 		local_mode = 1;
 	}
@@ -552,7 +552,7 @@ static int __devinit hp100_probe1(struct
 		if ((lsw & HP100_IO_EN) && (~lsw & HP100_MEM_EN) &&
 		    (~lsw & (HP100_BM_WRITE | HP100_BM_READ))) {
 #ifdef HP100_DEBUG
-			printk("hp100: %s: IO_EN bit is set on card.\n", dev->name);
+			printk(KERN_DEBUG "hp100: %s: IO_EN bit is set on card.\n", dev->name);
 #endif
 			local_mode = 3;
 		} else if (chip == HP100_CHIPID_LASSEN &&
@@ -567,13 +567,13 @@ static int __devinit hp100_probe1(struct
 				/* Gracefully fallback to shared memory */
 				goto busmasterfail;
 			}
-			printk("hp100: Busmaster mode enabled.\n");
+			printk(KERN_INFO "hp100: Busmaster mode enabled.\n");
 			hp100_outw(HP100_MEM_EN | HP100_IO_EN | HP100_RESET_LB, OPTION_LSW);
 		} else {
 		busmasterfail:
 #ifdef HP100_DEBUG
-			printk("hp100: %s: Card not configured for BM or BM not supported with this card.\n", dev->name);
-			printk("hp100: %s: Trying shared memory mode.\n", dev->name);
+			printk(KERN_DEBUG "hp100: %s: Card not configured for BM or BM not supported with this card.\n", dev->name);
+			printk(KERN_DEBUG "hp100: %s: Trying shared memory mode.\n", dev->name);
 #endif
 			/* In this case, try shared memory mode */
 			local_mode = 2;
@@ -582,7 +582,7 @@ static int __devinit hp100_probe1(struct
 		}
 	}
 #ifdef HP100_DEBUG
-	printk("hp100: %s: new LSW = 0x%x\n", dev->name, hp100_inw(OPTION_LSW));
+	printk(KERN_DEBUG "hp100: %s: new LSW = 0x%x\n", dev->name, hp100_inw(OPTION_LSW));
 #endif
 
 	/* Check for shared memory on the card, eventually remap it */
@@ -599,7 +599,7 @@ static int __devinit hp100_probe1(struct
 		mem_ptr_phys &= ~0x1fff;	/* 8k alignment */
 
 		if (bus == HP100_BUS_ISA && (mem_ptr_phys & ~0xfffff) != 0) {
-			printk("hp100: Can only use programmed i/o mode.\n");
+			printk(KERN_INFO "hp100: Can only use programmed i/o mode.\n");
 			mem_ptr_phys = 0;
 			mem_mapped = 0;
 			local_mode = 3;	/* Use programmed i/o */
@@ -612,18 +612,18 @@ static int __devinit hp100_probe1(struct
 			for (virt_memory_size = memory_size; virt_memory_size > 16383; virt_memory_size >>= 1) {
 				if ((mem_ptr_virt = ioremap((u_long) mem_ptr_phys, virt_memory_size)) == NULL) {
 #ifdef HP100_DEBUG
-					printk("hp100: %s: ioremap for 0x%x bytes high PCI memory at 0x%lx failed\n", dev->name, virt_memory_size, mem_ptr_phys);
+					printk(KERN_DEBUG "hp100: %s: ioremap for 0x%x bytes high PCI memory at 0x%lx failed\n", dev->name, virt_memory_size, mem_ptr_phys);
 #endif
 				} else {
 #ifdef HP100_DEBUG
-					printk("hp100: %s: remapped 0x%x bytes high PCI memory at 0x%lx to %p.\n", dev->name, virt_memory_size, mem_ptr_phys, mem_ptr_virt);
+					printk(KERN_DEBUG "hp100: %s: remapped 0x%x bytes high PCI memory at 0x%lx to %p.\n", dev->name, virt_memory_size, mem_ptr_phys, mem_ptr_virt);
 #endif
 					break;
 				}
 			}
 
 			if (mem_ptr_virt == NULL) {	/* all ioremap tries failed */
-				printk("hp100: Failed to ioremap the PCI card memory. Will have to use i/o mapped mode.\n");
+				printk(KERN_WARNING "hp100: Failed to ioremap the PCI card memory. Will have to use i/o mapped mode.\n");
 				local_mode = 3;
 				virt_memory_size = 0;
 			}
@@ -634,7 +634,7 @@ static int __devinit hp100_probe1(struct
 		mem_mapped = 0;
 		mem_ptr_phys = 0;
 		mem_ptr_virt = NULL;
-		printk("hp100: Using (slow) programmed i/o mode.\n");
+		printk(KERN_INFO "hp100: Using (slow) programmed i/o mode.\n");
 	}
 
 	/* Initialise the "private" data structure for this card. */
@@ -716,7 +716,7 @@ static int __devinit hp100_probe1(struct
 		lp->whatever_offset = ((u_long) page_baddr) - ((u_long) lp->page_vaddr_algn);
 
 #ifdef HP100_DEBUG_BM
-		printk("hp100: %s: Reserved DMA memory from 0x%x to 0x%x\n", dev->name, (u_int) lp->page_vaddr_algn, (u_int) lp->page_vaddr_algn + MAX_RINGSIZE);
+		printk(KERN_DEBUG "hp100: %s: Reserved DMA memory from 0x%x to 0x%x\n", dev->name, (u_int) lp->page_vaddr_algn, (u_int) lp->page_vaddr_algn + MAX_RINGSIZE);
 #endif
 		lp->rxrcommit = lp->txrcommit = 0;
 		lp->rxrhead = lp->rxrtail = &(lp->rxring[0]);
@@ -734,7 +734,7 @@ static int __devinit hp100_probe1(struct
 	lp->lan_type = hp100_sense_lan(dev);
 
 	/* Print out a message what about what we think we have probed. */
-	printk("hp100: at 0x%x, IRQ %d, ", ioaddr, dev->irq);
+	printk(KERN_INFO "hp100: at 0x%x, IRQ %d, ", ioaddr, dev->irq);
 	switch (bus) {
 	case HP100_BUS_EISA:
 		printk("EISA");
@@ -749,7 +749,7 @@ static int __devinit hp100_probe1(struct
 	printk(" bus, %dk SRAM (rx/tx %d%%).\n", lp->memory_size >> 10, lp->rx_ratio);
 
 	if (lp->mode == 2) {	/* memory mapped */
-		printk("hp100: Memory area at 0x%lx-0x%lx", mem_ptr_phys,
+		printk(KERN_INFO "hp100: Memory area at 0x%lx-0x%lx", mem_ptr_phys,
 				(mem_ptr_phys + (mem_ptr_phys > 0x100000 ? (u_long) lp->memory_size : 16 * 1024)) - 1);
 		if (mem_ptr_virt)
 			printk(" (virtual base %p)", mem_ptr_virt);
@@ -760,7 +760,7 @@ static int __devinit hp100_probe1(struct
 		dev->mem_end = mem_ptr_phys + lp->memory_size;
 	}
 
-	printk("hp100: ");
+	printk(KERN_INFO "hp100: ");
 	if (lp->lan_type != HP100_LAN_ERR)
 		printk("Adapter is attached to ");
 	switch (lp->lan_type) {
@@ -792,7 +792,7 @@ static void hp100_hwinit(struct net_devi
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4202, TRACE);
-	printk("hp100: %s: hwinit\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: hwinit\n", dev->name);
 #endif
 
 	/* Initialise the card. -------------------------------------------- */
@@ -887,12 +887,12 @@ static void hp100_mmuinit(struct net_dev
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4203, TRACE);
-	printk("hp100: %s: mmuinit\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: mmuinit\n", dev->name);
 #endif
 
 #ifdef HP100_DEBUG
 	if (0 != (hp100_inw(OPTION_LSW) & HP100_HW_RST)) {
-		printk("hp100: %s: Not in reset when entering mmuinit. Fix me.\n", dev->name);
+		printk(KERN_DEBUG "hp100: %s: Not in reset when entering mmuinit. Fix me.\n", dev->name);
 		return;
 	}
 #endif
@@ -985,7 +985,7 @@ static void hp100_mmuinit(struct net_dev
 			recv_stop = (xmit_stop * (lp->rx_ratio) / 100) & ~(0x03ff);
 			hp100_outw((pdl_stop >> 4) - 1, PDL_MEM_STOP);
 #ifdef HP100_DEBUG_BM
-			printk("hp100: %s: PDL_STOP = 0x%x\n", dev->name, pdl_stop);
+			printk(KERN_DEBUG "hp100: %s: PDL_STOP = 0x%x\n", dev->name, pdl_stop);
 #endif
 		} else {
 			/* ETR chip (Lassen) in busmaster mode */
@@ -996,16 +996,16 @@ static void hp100_mmuinit(struct net_dev
 		hp100_outw(xmit_stop >> 4, TX_MEM_STOP);
 		hp100_outw(recv_stop >> 4, RX_MEM_STOP);
 #ifdef HP100_DEBUG_BM
-		printk("hp100: %s: TX_STOP  = 0x%x\n", dev->name, xmit_stop >> 4);
-		printk("hp100: %s: RX_STOP  = 0x%x\n", dev->name, recv_stop >> 4);
+		printk(KERN_DEBUG "hp100: %s: TX_STOP  = 0x%x\n", dev->name, xmit_stop >> 4);
+		printk(KERN_DEBUG "hp100: %s: RX_STOP  = 0x%x\n", dev->name, recv_stop >> 4);
 #endif
 	} else {
 		/* Slave modes (memory mapped and programmed io)  */
 		hp100_outw((((lp->memory_size * lp->rx_ratio) / 100) >> 4), RX_MEM_STOP);
 		hp100_outw(((lp->memory_size - 1) >> 4), TX_MEM_STOP);
 #ifdef HP100_DEBUG
-		printk("hp100: %s: TX_MEM_STOP: 0x%x\n", dev->name, hp100_inw(TX_MEM_STOP));
-		printk("hp100: %s: RX_MEM_STOP: 0x%x\n", dev->name, hp100_inw(RX_MEM_STOP));
+		printk(KERN_DEBUG "hp100: %s: TX_MEM_STOP: 0x%x\n", dev->name, hp100_inw(TX_MEM_STOP));
+		printk(KERN_DEBUG "hp100: %s: RX_MEM_STOP: 0x%x\n", dev->name, hp100_inw(RX_MEM_STOP));
 #endif
 	}
 
@@ -1067,7 +1067,7 @@ static int hp100_open(struct net_device 
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4204, TRACE);
-	printk("hp100: %s: open\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: open\n", dev->name);
 #endif
 
 	/* New: if bus is PCI or EISA, interrupts might be shared interrupts */
@@ -1075,7 +1075,7 @@ static int hp100_open(struct net_device 
 			lp->bus == HP100_BUS_PCI || lp->bus ==
 			HP100_BUS_EISA ? SA_SHIRQ : SA_INTERRUPT,
 			"hp100", dev)) {
-		printk("hp100: %s: unable to get IRQ %d\n", dev->name, dev->irq);
+		printk(KERN_WARNING "hp100: %s: unable to get IRQ %d\n", dev->name, dev->irq);
 		return -EAGAIN;
 	}
 
@@ -1104,7 +1104,7 @@ static int hp100_close(struct net_device
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4205, TRACE);
-	printk("hp100: %s: close\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: close\n", dev->name);
 #endif
 
 	hp100_page(PERFORMANCE);
@@ -1120,7 +1120,7 @@ static int hp100_close(struct net_device
 	free_irq(dev->irq, dev);
 
 #ifdef HP100_DEBUG
-	printk("hp100: %s: close LSW = 0x%x\n", dev->name,
+	printk(KERN_DEBUG "hp100: %s: close LSW = 0x%x\n", dev->name,
 	       hp100_inw(OPTION_LSW));
 #endif
 
@@ -1144,11 +1144,11 @@ static void hp100_init_pdls(struct net_d
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4206, TRACE);
-	printk("hp100: %s: init pdls\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: init pdls\n", dev->name);
 #endif
 
 	if (0 == lp->page_vaddr_algn)
-		printk("hp100: %s: Warning: lp->page_vaddr_algn not initialised!\n", dev->name);
+		printk(KERN_WARNING "hp100: %s: Warning: lp->page_vaddr_algn not initialised!\n", dev->name);
 	else {
 		/* pageptr shall point into the DMA accessible memory region  */
 		/* we use this pointer to status the upper limit of allocated */
@@ -1188,7 +1188,7 @@ static int hp100_init_rxpdl(struct net_d
 	/* pdlptr is starting address for this pdl */
 
 	if (0 != (((unsigned long) pdlptr) & 0xf))
-		printk("hp100: %s: Init rxpdl: Unaligned pdlptr 0x%lx.\n",
+		printk(KERN_INFO "hp100: %s: Init rxpdl: Unaligned pdlptr 0x%lx.\n",
 		       dev->name, (unsigned long) pdlptr);
 
 	ringptr->pdl = pdlptr + 1;
@@ -1215,7 +1215,7 @@ static int hp100_init_txpdl(struct net_d
 			    register u32 * pdlptr)
 {
 	if (0 != (((unsigned long) pdlptr) & 0xf))
-		printk("hp100: %s: Init txpdl: Unaligned pdlptr 0x%lx.\n", dev->name, (unsigned long) pdlptr);
+		printk(KERN_INFO "hp100: %s: Init txpdl: Unaligned pdlptr 0x%lx.\n", dev->name, (unsigned long) pdlptr);
 
 	ringptr->pdl = pdlptr;	/* +1; */
 	ringptr->pdl_paddr = virt_to_whatever(dev, pdlptr);	/* +1 */
@@ -1243,7 +1243,7 @@ static int hp100_build_rx_pdl(hp100_ring
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4207, TRACE);
-	printk("hp100: %s: build rx pdl\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: build rx pdl\n", dev->name);
 #endif
 
 	/* Allocate skb buffer of maximum size */
@@ -1271,7 +1271,7 @@ static int hp100_build_rx_pdl(hp100_ring
 		 * directly before the PDL. 
 		 */
 #ifdef HP100_DEBUG_BM
-		printk("hp100: %s: build_rx_pdl: PDH@0x%x, skb->data (len %d) at 0x%x\n",
+		printk(KERN_DEBUG "hp100: %s: build_rx_pdl: PDH@0x%x, skb->data (len %d) at 0x%x\n",
 				     dev->name, (u_int) ringptr->pdl,
 				     ((MAX_ETHER_SIZE + 2 + 3) / 4) * 4,
 				     (unsigned int) ringptr->skb->data);
@@ -1286,7 +1286,7 @@ static int hp100_build_rx_pdl(hp100_ring
 
 #ifdef HP100_DEBUG_BM
 		for (p = (ringptr->pdl); p < (ringptr->pdl + 5); p++)
-			printk("hp100: %s: Adr 0x%.8x = 0x%.8x\n", dev->name, (u_int) p, (u_int) * p);
+			printk(KERN_DEBUG "hp100: %s: Adr 0x%.8x = 0x%.8x\n", dev->name, (u_int) p, (u_int) * p);
 #endif
 		return (1);
 	}
@@ -1296,7 +1296,7 @@ static int hp100_build_rx_pdl(hp100_ring
 	 * making the PDL only 1 fragment (i.e. the 4 byte packet status)
 	 */
 #ifdef HP100_DEBUG_BM
-	printk("hp100: %s: build_rx_pdl: PDH@0x%x, No space for skb.\n", dev->name, (u_int) ringptr->pdl);
+	printk(KERN_DEBUG "hp100: %s: build_rx_pdl: PDH@0x%x, No space for skb.\n", dev->name, (u_int) ringptr->pdl);
 #endif
 
 	ringptr->pdl[0] = 0x00010000;	/* PDH: Count=1 Fragment */
@@ -1323,7 +1323,7 @@ static void hp100_rxfill(struct net_devi
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4208, TRACE);
-	printk("hp100: %s: rxfill\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: rxfill\n", dev->name);
 #endif
 
 	hp100_page(PERFORMANCE);
@@ -1340,7 +1340,7 @@ static void hp100_rxfill(struct net_devi
 		/* Hand this PDL over to the card */
 		/* Note: This needs performance page selected! */
 #ifdef HP100_DEBUG_BM
-		printk("hp100: %s: rxfill: Hand to card: pdl #%d @0x%x phys:0x%x, buffer: 0x%x\n",
+		printk(KERN_DEBUG "hp100: %s: rxfill: Hand to card: pdl #%d @0x%x phys:0x%x, buffer: 0x%x\n",
 				     dev->name, lp->rxrcommit, (u_int) ringptr->pdl,
 				     (u_int) ringptr->pdl_paddr, (u_int) ringptr->pdl[3]);
 #endif
@@ -1364,7 +1364,7 @@ static void hp100_BM_shutdown(struct net
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4209, TRACE);
-	printk("hp100: %s: bm shutdown\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: bm shutdown\n", dev->name);
 #endif
 
 	hp100_page(PERFORMANCE);
@@ -1413,7 +1413,7 @@ static void hp100_BM_shutdown(struct net
 			}
 
 			if (time >= 10000)
-				printk("hp100: %s: BM shutdown error.\n", dev->name);
+				printk(KERN_INFO "hp100: %s: BM shutdown error.\n", dev->name);
 
 			/* To ensure all bus master outloading activity has ceased,
 			 * wait until the Tx PDA count goes to zero or no more Tx space
@@ -1445,7 +1445,7 @@ static int hp100_check_lan(struct net_de
 	if (lp->lan_type < 0) {	/* no LAN type detected yet? */
 		hp100_stop_interface(dev);
 		if ((lp->lan_type = hp100_sense_lan(dev)) < 0) {
-			printk("hp100: %s: no connection found - check wire\n", dev->name);
+			printk(KERN_INFO "hp100: %s: no connection found - check wire\n", dev->name);
 			hp100_start_interface(dev);	/* 10Mb/s RX packets maybe handled */
 			return -EIO;
 		}
@@ -1471,7 +1471,7 @@ static int hp100_start_xmit_bm(struct sk
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4210, TRACE);
-	printk("hp100: %s: start_xmit_bm\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: start_xmit_bm\n", dev->name);
 #endif
 
 	if (skb == NULL) {
@@ -1491,7 +1491,7 @@ static int hp100_start_xmit_bm(struct sk
 	if (lp->txrtail->next == lp->txrhead) {
 		/* No memory. */
 #ifdef HP100_DEBUG
-		printk("hp100: %s: start_xmit_bm: No TX PDL available.\n", dev->name);
+		printk(KERN_DEBUG "hp100: %s: start_xmit_bm: No TX PDL available.\n", dev->name);
 #endif
 		/* not waited long enough since last tx? */
 		if (jiffies - dev->trans_start < HZ)
@@ -1502,7 +1502,7 @@ static int hp100_start_xmit_bm(struct sk
 
 		if (lp->lan_type == HP100_LAN_100 && lp->hub_status < 0) {
 			/* we have a 100Mb/s adapter but it isn't connected to hub */
-			printk("hp100: %s: login to 100Mb/s hub retry\n", dev->name);
+			printk(KERN_INFO "hp100: %s: login to 100Mb/s hub retry\n", dev->name);
 			hp100_stop_interface(dev);
 			lp->hub_status = hp100_login_to_vg_hub(dev, 0);
 			hp100_start_interface(dev);
@@ -1513,17 +1513,17 @@ static int hp100_start_xmit_bm(struct sk
 			hp100_ints_on();
 			spin_unlock_irqrestore(&lp->lock, flags);
 			if (i == HP100_LAN_ERR)
-				printk("hp100: %s: link down detected\n", dev->name);
+				printk(KERN_INFO "hp100: %s: link down detected\n", dev->name);
 			else if (lp->lan_type != i) {	/* cable change! */
 				/* it's very hard - all network settings must be changed!!! */
-				printk("hp100: %s: cable change 10Mb/s <-> 100Mb/s detected\n", dev->name);
+				printk(KERN_INFO "hp100: %s: cable change 10Mb/s <-> 100Mb/s detected\n", dev->name);
 				lp->lan_type = i;
 				hp100_stop_interface(dev);
 				if (lp->lan_type == HP100_LAN_100)
 					lp->hub_status = hp100_login_to_vg_hub(dev, 0);
 				hp100_start_interface(dev);
 			} else {
-				printk("hp100: %s: interface reset\n", dev->name);
+				printk(KERN_INFO "hp100: %s: interface reset\n", dev->name);
 				hp100_stop_interface(dev);
 				if (lp->lan_type == HP100_LAN_100)
 					lp->hub_status = hp100_login_to_vg_hub(dev, 0);
@@ -1590,7 +1590,7 @@ static void hp100_clean_txring(struct ne
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4211, TRACE);
-	printk("hp100: %s: clean txring\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: clean txring\n", dev->name);
 #endif
 
 	/* How many PDLs have been transmitted? */
@@ -1598,12 +1598,12 @@ static void hp100_clean_txring(struct ne
 
 #ifdef HP100_DEBUG
 	if (donecount > MAX_TX_PDL)
-		printk("hp100: %s: Warning: More PDLs transmitted than commited to card???\n", dev->name);
+		printk(KERN_DEBUG "hp100: %s: Warning: More PDLs transmitted than commited to card???\n", dev->name);
 #endif
 
 	for (; 0 != donecount; donecount--) {
 #ifdef HP100_DEBUG_BM
-		printk("hp100: %s: Free skb: data @0x%.8x txrcommit=0x%x TXPDL=0x%x, done=0x%x\n",
+		printk(KERN_DEBUG "hp100: %s: Free skb: data @0x%.8x txrcommit=0x%x TXPDL=0x%x, done=0x%x\n",
 				dev->name, (u_int) lp->txrhead->skb->data,
 				lp->txrcommit, hp100_inb(TX_PDL), donecount);
 #endif
@@ -1627,7 +1627,7 @@ static int hp100_start_xmit(struct sk_bu
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4212, TRACE);
-	printk("hp100: %s: start_xmit\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: start_xmit\n", dev->name);
 #endif
 
 	if (skb == NULL) {
@@ -1644,19 +1644,19 @@ static int hp100_start_xmit(struct sk_bu
 	i = hp100_inl(TX_MEM_FREE) & 0x7fffffff;
 	if (!(((i / 2) - 539) > (skb->len + 16) && (hp100_inb(TX_PKT_CNT) < 255))) {
 #ifdef HP100_DEBUG
-		printk("hp100: %s: start_xmit: tx free mem = 0x%x\n", dev->name, i);
+		printk(KERN_DEBUG "hp100: %s: start_xmit: tx free mem = 0x%x\n", dev->name, i);
 #endif
 		/* not waited long enough since last failed tx try? */
 		if (jiffies - dev->trans_start < HZ) {
 #ifdef HP100_DEBUG
-			printk("hp100: %s: trans_start timing problem\n",
+			printk(KERN_DEBUG "hp100: %s: trans_start timing problem\n",
 			       dev->name);
 #endif
 			return -EAGAIN;
 		}
 		if (lp->lan_type == HP100_LAN_100 && lp->hub_status < 0) {
 			/* we have a 100Mb/s adapter but it isn't connected to hub */
-			printk("hp100: %s: login to 100Mb/s hub retry\n", dev->name);
+			printk(KERN_DEBUG "hp100: %s: login to 100Mb/s hub retry\n", dev->name);
 			hp100_stop_interface(dev);
 			lp->hub_status = hp100_login_to_vg_hub(dev, 0);
 			hp100_start_interface(dev);
@@ -1667,17 +1667,17 @@ static int hp100_start_xmit(struct sk_bu
 			hp100_ints_on();
 			spin_unlock_irqrestore(&lp->lock, flags);
 			if (i == HP100_LAN_ERR)
-				printk("hp100: %s: link down detected\n", dev->name);
+				printk(KERN_DEBUG "hp100: %s: link down detected\n", dev->name);
 			else if (lp->lan_type != i) {	/* cable change! */
 				/* it's very hard - all network setting must be changed!!! */
-				printk("hp100: %s: cable change 10Mb/s <-> 100Mb/s detected\n", dev->name);
+				printk(KERN_INFO "hp100: %s: cable change 10Mb/s <-> 100Mb/s detected\n", dev->name);
 				lp->lan_type = i;
 				hp100_stop_interface(dev);
 				if (lp->lan_type == HP100_LAN_100)
 					lp->hub_status = hp100_login_to_vg_hub(dev, 0);
 				hp100_start_interface(dev);
 			} else {
-				printk("hp100: %s: interface reset\n", dev->name);
+				printk(KERN_INFO "hp100: %s: interface reset\n", dev->name);
 				hp100_stop_interface(dev);
 				if (lp->lan_type == HP100_LAN_100)
 					lp->hub_status = hp100_login_to_vg_hub(dev, 0);
@@ -1691,7 +1691,7 @@ static int hp100_start_xmit(struct sk_bu
 
 	for (i = 0; i < 6000 && (hp100_inb(OPTION_MSW) & HP100_TX_CMD); i++) {
 #ifdef HP100_DEBUG_TX
-		printk("hp100: %s: start_xmit: busy\n", dev->name);
+		printk(KERN_DEBUG "hp100: %s: start_xmit: busy\n", dev->name);
 #endif
 	}
 
@@ -1702,7 +1702,7 @@ static int hp100_start_xmit(struct sk_bu
 	 * when the current packet being transmitted on the wire is completed. */
 	hp100_outw(HP100_TX_COMPLETE, IRQ_STATUS);
 #ifdef HP100_DEBUG_TX
-	printk("hp100: %s: start_xmit: irq_status=0x%.4x, irqmask=0x%.4x, len=%d\n",
+	printk(KERN_DEBUG "hp100: %s: start_xmit: irq_status=0x%.4x, irqmask=0x%.4x, len=%d\n",
 			dev->name, val, hp100_inw(IRQ_MASK), (int) skb->len);
 #endif
 
@@ -1743,7 +1743,7 @@ static int hp100_start_xmit(struct sk_bu
 	dev_kfree_skb_any(skb);
 
 #ifdef HP100_DEBUG_TX
-	printk("hp100: %s: start_xmit: end\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: start_xmit: end\n", dev->name);
 #endif
 
 	return 0;
@@ -1769,7 +1769,7 @@ static void hp100_rx(struct net_device *
 
 #ifdef DEBUG_B
 	hp100_outw(0x4213, TRACE);
-	printk("hp100: %s: rx\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: rx\n", dev->name);
 #endif
 
 	/* First get indication of received lan packet */
@@ -1778,7 +1778,7 @@ static void hp100_rx(struct net_device *
 	packets = hp100_inb(RX_PKT_CNT);
 #ifdef HP100_DEBUG_RX
 	if (packets > 1)
-		printk("hp100: %s: rx: waiting packets = %d\n", dev->name, packets);
+		printk(KERN_DEBUG "hp100: %s: rx: waiting packets = %d\n", dev->name, packets);
 #endif
 
 	while (packets-- > 0) {
@@ -1786,7 +1786,7 @@ static void hp100_rx(struct net_device *
 		/* really advanced to the next packet. */
 		for (pkt_len = 0; pkt_len < 6000 && (hp100_inb(OPTION_MSW) & HP100_ADV_NXT_PKT); pkt_len++) {
 #ifdef HP100_DEBUG_RX
-			printk ("hp100: %s: rx: busy, remaining packets = %d\n", dev->name, packets);
+			printk (KERN_DEBUG "hp100: %s: rx: busy, remaining packets = %d\n", dev->name, packets);
 #endif
 		}
 
@@ -1803,7 +1803,7 @@ static void hp100_rx(struct net_device *
 		pkt_len = ((header & HP100_PKT_LEN_MASK) + 3) & ~3;
 
 #ifdef HP100_DEBUG_RX
-		printk("hp100: %s: rx: new packet - length=%d, errors=0x%x, dest=0x%x\n",
+		printk(KERN_DEBUG "hp100: %s: rx: new packet - length=%d, errors=0x%x, dest=0x%x\n",
 				     dev->name, header & HP100_PKT_LEN_MASK,
 				     (header >> 16) & 0xfff8, (header >> 16) & 7);
 #endif
@@ -1812,7 +1812,7 @@ static void hp100_rx(struct net_device *
 		skb = dev_alloc_skb(pkt_len+2);
 		if (skb == NULL) {	/* Not enough memory->drop packet */
 #ifdef HP100_DEBUG
-			printk("hp100: %s: rx: couldn't allocate a sk_buff of size %d\n",
+			printk(KERN_DEBUG "hp100: %s: rx: couldn't allocate a sk_buff of size %d\n",
 					     dev->name, pkt_len);
 #endif
 			lp->stats.rx_dropped++;
@@ -1840,7 +1840,7 @@ static void hp100_rx(struct net_device *
 			skb->protocol = eth_type_trans(skb, dev);
 
 #ifdef HP100_DEBUG_RX
-			printk("hp100: %s: rx: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x\n",
+			printk(KERN_DEBUG "hp100: %s: rx: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x\n",
 					dev->name, ptr[0], ptr[1], ptr[2], ptr[3],
 		 			ptr[4], ptr[5], ptr[6], ptr[7], ptr[8],
 					ptr[9], ptr[10], ptr[11]);
@@ -1862,7 +1862,7 @@ static void hp100_rx(struct net_device *
 		}
 	}			/* end of while(there are packets) loop */
 #ifdef HP100_DEBUG_RX
-	printk("hp100_rx: %s: end\n", dev->name);
+	printk(KERN_DEBUG "hp100_rx: %s: end\n", dev->name);
 #endif
 }
 
@@ -1879,18 +1879,18 @@ static void hp100_rx_bm(struct net_devic
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4214, TRACE);
-	printk("hp100: %s: rx_bm\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: rx_bm\n", dev->name);
 #endif
 
 #ifdef HP100_DEBUG
 	if (0 == lp->rxrcommit) {
-		printk("hp100: %s: rx_bm called although no PDLs were committed to adapter?\n", dev->name);
+		printk(KERN_DEBUG "hp100: %s: rx_bm called although no PDLs were committed to adapter?\n", dev->name);
 		return;
 	} else
 		/* RX_PKT_CNT states how many PDLs are currently formatted and available to 
 		 * the cards BM engine */
 	if ((hp100_inw(RX_PKT_CNT) & 0x00ff) >= lp->rxrcommit) {
-		printk("hp100: %s: More packets received than commited? RX_PKT_CNT=0x%x, commit=0x%x\n",
+		printk(KERN_DEBUG "hp100: %s: More packets received than commited? RX_PKT_CNT=0x%x, commit=0x%x\n",
 				     dev->name, hp100_inw(RX_PKT_CNT) & 0x00ff,
 				     lp->rxrcommit);
 		return;
@@ -1915,10 +1915,10 @@ static void hp100_rx_bm(struct net_devic
 		pci_unmap_single(lp->pci_dev, (dma_addr_t) ptr->pdl[3], MAX_ETHER_SIZE, PCI_DMA_FROMDEVICE);
 
 #ifdef HP100_DEBUG_BM
-		printk("hp100: %s: rx_bm: header@0x%x=0x%x length=%d, errors=0x%x, dest=0x%x\n",
+		printk(KERN_DEBUG "hp100: %s: rx_bm: header@0x%x=0x%x length=%d, errors=0x%x, dest=0x%x\n",
 				dev->name, (u_int) (ptr->pdl - 1), (u_int) header,
 				pkt_len, (header >> 16) & 0xfff8, (header >> 16) & 7);
-		printk("hp100: %s: RX_PDL_COUNT:0x%x TX_PDL_COUNT:0x%x, RX_PKT_CNT=0x%x PDH=0x%x, Data@0x%x len=0x%x\n",
+		printk(KERN_DEBUG "hp100: %s: RX_PDL_COUNT:0x%x TX_PDL_COUNT:0x%x, RX_PKT_CNT=0x%x PDH=0x%x, Data@0x%x len=0x%x\n",
 		   		dev->name, hp100_inb(RX_PDL), hp100_inb(TX_PDL),
 				hp100_inb(RX_PKT_CNT), (u_int) * (ptr->pdl),
 				(u_int) * (ptr->pdl + 3), (u_int) * (ptr->pdl + 4));
@@ -1927,7 +1927,7 @@ static void hp100_rx_bm(struct net_devic
 		if ((pkt_len >= MIN_ETHER_SIZE) &&
 		    (pkt_len <= MAX_ETHER_SIZE)) {
 			if (ptr->skb == NULL) {
-				printk("hp100: %s: rx_bm: skb null\n", dev->name);
+				printk(KERN_DEBUG "hp100: %s: rx_bm: skb null\n", dev->name);
 				/* can happen if we only allocated room for the pdh due to memory shortage. */
 				lp->stats.rx_dropped++;
 			} else {
@@ -1950,7 +1950,7 @@ static void hp100_rx_bm(struct net_devic
 			}
 		} else {
 #ifdef HP100_DEBUG
-			printk("hp100: %s: rx_bm: Received bad packet (length=%d)\n", dev->name, pkt_len);
+			printk(KERN_DEBUG "hp100: %s: rx_bm: Received bad packet (length=%d)\n", dev->name, pkt_len);
 #endif
 			if (ptr->skb != NULL)
 				dev_kfree_skb_any(ptr->skb);
@@ -1963,7 +1963,7 @@ static void hp100_rx_bm(struct net_devic
 		if (0 == hp100_build_rx_pdl(lp->rxrtail, dev)) {
 			/* No space for skb, header can still be received. */
 #ifdef HP100_DEBUG
-			printk("hp100: %s: rx_bm: No space for new PDL.\n", dev->name);
+			printk(KERN_DEBUG "hp100: %s: rx_bm: No space for new PDL.\n", dev->name);
 #endif
 			return;
 		} else {	/* successfully allocated new PDL - put it in ringlist at tail. */
@@ -2003,7 +2003,7 @@ static void hp100_update_stats(struct ne
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4216, TRACE);
-	printk("hp100: %s: update-stats\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: update-stats\n", dev->name);
 #endif
 
 	/* Note: Statistics counters clear when read. */
@@ -2030,7 +2030,7 @@ static void hp100_misc_interrupt(struct 
 #ifdef HP100_DEBUG_B
 	int ioaddr = dev->base_addr;
 	hp100_outw(0x4216, TRACE);
-	printk("hp100: %s: misc_interrupt\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: misc_interrupt\n", dev->name);
 #endif
 
 	/* Note: Statistics counters clear when read. */
@@ -2044,7 +2044,7 @@ static void hp100_clear_stats(struct hp1
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4217, TRACE);
-	printk("hp100: %s: clear_stats\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: clear_stats\n", dev->name);
 #endif
 
 	spin_lock_irqsave(&lp->lock, flags);
@@ -2073,7 +2073,7 @@ static void hp100_set_multicast_list(str
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4218, TRACE);
-	printk("hp100: %s: set_mc_list\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: set_mc_list\n", dev->name);
 #endif
 
 	spin_lock_irqsave(&lp->lock, flags);
@@ -2099,13 +2099,13 @@ static void hp100_set_multicast_list(str
 
 			memset(&lp->hash_bytes, 0x00, 8);
 #ifdef HP100_DEBUG
-			printk("hp100: %s: computing hash filter - mc_count = %i\n", dev->name, dev->mc_count);
+			printk(KERN_DEBUG "hp100: %s: computing hash filter - mc_count = %i\n", dev->name, dev->mc_count);
 #endif
 			for (i = 0, dmi = dev->mc_list; i < dev->mc_count; i++, dmi = dmi->next) {
 				addrs = dmi->dmi_addr;
 				if ((*addrs & 0x01) == 0x01) {	/* multicast address? */
 #ifdef HP100_DEBUG
-					printk("hp100: %s: multicast = %02x:%02x:%02x:%02x:%02x:%02x, ",
+					printk(KERN_DEBUG "hp100: %s: multicast = %02x:%02x:%02x:%02x:%02x:%02x, ",
 						     dev->name, addrs[0], addrs[1], addrs[2],
 						     addrs[3], addrs[4], addrs[5]);
 #endif
@@ -2114,7 +2114,7 @@ static void hp100_set_multicast_list(str
 						printk(":%02x:", idx);
 					}
 #ifdef HP100_DEBUG
-					printk("idx = %i\n", idx);
+					printk(KERN_DEBUG "idx = %i\n", idx);
 #endif
 					lp->hash_bytes[idx >> 3] |= (1 << (idx & 7));
 				}
@@ -2141,7 +2141,7 @@ static void hp100_set_multicast_list(str
 		for (i = 0; i < 8; i++)
 			hp100_outb(lp->hash_bytes[i], HASH_BYTE0 + i);
 #ifdef HP100_DEBUG
-		printk("hp100: %s: mac1 = 0x%x, mac2 = 0x%x, multicast hash = %02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x\n",
+		printk(KERN_DEBUG "hp100: %s: mac1 = 0x%x, mac2 = 0x%x, multicast hash = %02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x\n",
 				     dev->name, lp->mac1_mode, lp->mac2_mode,
 				     lp->hash_bytes[0], lp->hash_bytes[1],
 				     lp->hash_bytes[2], lp->hash_bytes[3],
@@ -2151,7 +2151,7 @@ static void hp100_set_multicast_list(str
 
 		if (lp->lan_type == HP100_LAN_100) {
 #ifdef HP100_DEBUG
-			printk("hp100: %s: 100VG MAC settings have changed - relogin.\n", dev->name);
+			printk(KERN_DEBUG "hp100: %s: 100VG MAC settings have changed - relogin.\n", dev->name);
 #endif
 			lp->hub_status = hp100_login_to_vg_hub(dev, 1);	/* force a relogin to the hub */
 		}
@@ -2166,7 +2166,7 @@ static void hp100_set_multicast_list(str
 			for (i = 0; i < 8; i++)
 				hp100_outb(lp->hash_bytes[i], HASH_BYTE0 + i);
 #ifdef HP100_DEBUG
-			printk("hp100: %s: multicast hash = %02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x\n",
+			printk(KERN_DEBUG "hp100: %s: multicast hash = %02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x\n",
 					dev->name, lp->hash_bytes[0],
 					lp->hash_bytes[1], lp->hash_bytes[2],
 					lp->hash_bytes[3], lp->hash_bytes[4],
@@ -2176,7 +2176,7 @@ static void hp100_set_multicast_list(str
 
 			if (lp->lan_type == HP100_LAN_100) {
 #ifdef HP100_DEBUG
-				printk("hp100: %s: 100VG MAC settings have changed - relogin.\n", dev->name);
+				printk(KERN_DEBUG "hp100: %s: 100VG MAC settings have changed - relogin.\n", dev->name);
 #endif
 				lp->hub_status = hp100_login_to_vg_hub(dev, 1);	/* force a relogin to the hub */
 			}
@@ -2219,7 +2219,7 @@ static irqreturn_t hp100_interrupt(int i
 	/*  hp100_page( PERFORMANCE ); */
 	val = hp100_inw(IRQ_STATUS);
 #ifdef HP100_DEBUG_IRQ
-	printk("hp100: %s: mode=%x,IRQ_STAT=0x%.4x,RXPKTCNT=0x%.2x RXPDL=0x%.2x TXPKTCNT=0x%.2x TXPDL=0x%.2x\n",
+	printk(KERN_DEBUG "hp100: %s: mode=%x,IRQ_STAT=0x%.4x,RXPKTCNT=0x%.2x RXPDL=0x%.2x TXPKTCNT=0x%.2x TXPDL=0x%.2x\n",
 			     dev->name, lp->mode, (u_int) val, hp100_inb(RX_PKT_CNT),
 			     hp100_inb(RX_PDL), hp100_inb(TX_PKT_CNT), hp100_inb(TX_PDL));
 #endif
@@ -2241,7 +2241,7 @@ static irqreturn_t hp100_interrupt(int i
 		if (lp->mode == 1)
 			hp100_rx_bm(dev);
 		else {
-			printk("hp100: %s: rx_pdl_fill_compl interrupt although not busmaster?\n", dev->name);
+			printk(KERN_INFO "hp100: %s: rx_pdl_fill_compl interrupt although not busmaster?\n", dev->name);
 		}
 	}
 
@@ -2278,7 +2278,7 @@ static irqreturn_t hp100_interrupt(int i
 	 */
 	if (val & (HP100_TX_ERROR | HP100_RX_ERROR)) {
 #ifdef HP100_DEBUG_IRQ
-		printk("hp100: %s: TX/RX Error IRQ\n", dev->name);
+		printk(KERN_DEBUG "hp100: %s: TX/RX Error IRQ\n", dev->name);
 #endif
 		hp100_update_stats(dev);
 		if (lp->mode == 1) {
@@ -2307,7 +2307,7 @@ static irqreturn_t hp100_interrupt(int i
 	if (val & HP100_MISC_ERROR) {	/* New for J2585B */
 #ifdef HP100_DEBUG_IRQ
 		printk
-		    ("hp100: %s: Misc. Error Interrupt - Check cabling.\n",
+		    (KERN_DEBUG "hp100: %s: Misc. Error Interrupt - Check cabling.\n",
 		     dev->name);
 #endif
 		if (lp->mode == 1) {
@@ -2334,7 +2334,7 @@ static void hp100_start_interface(struct
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4220, TRACE);
-	printk("hp100: %s: hp100_start_interface\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: hp100_start_interface\n", dev->name);
 #endif
 
 	spin_lock_irqsave(&lp->lock, flags);
@@ -2394,7 +2394,7 @@ static void hp100_stop_interface(struct 
 	u_int val;
 
 #ifdef HP100_DEBUG_B
-	printk("hp100: %s: hp100_stop_interface\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: hp100_stop_interface\n", dev->name);
 	hp100_outw(0x4221, TRACE);
 #endif
 
@@ -2418,7 +2418,7 @@ static void hp100_stop_interface(struct 
 				hp100_page(PERFORMANCE);
 				return;
 			}
-		printk("hp100: %s: hp100_stop_interface - timeout\n", dev->name);
+		printk(KERN_INFO "hp100: %s: hp100_stop_interface - timeout\n", dev->name);
 		hp100_page(PERFORMANCE);
 	}
 }
@@ -2438,7 +2438,7 @@ static void hp100_load_eeprom(struct net
 	for (i = 0; i < 10000; i++)
 		if (!(hp100_inb(OPTION_MSW) & HP100_EE_LOAD))
 			return;
-	printk("hp100: %s: hp100_load_eeprom - timeout\n", dev->name);
+	printk(KERN_INFO "hp100: %s: hp100_load_eeprom - timeout\n", dev->name);
 }
 
 /*  Sense connection status.
@@ -2461,7 +2461,7 @@ static int hp100_sense_lan(struct net_de
 	val_VG = hp100_inb(VG_LAN_CFG_1);
 	hp100_page(PERFORMANCE);
 #ifdef HP100_DEBUG
-	printk("hp100: %s: sense_lan: val_VG = 0x%04x, val_10 = 0x%04x\n",
+	printk(KERN_DEBUG "hp100: %s: sense_lan: val_VG = 0x%04x, val_10 = 0x%04x\n",
 	       dev->name, val_VG, val_10);
 #endif
 
@@ -2503,7 +2503,7 @@ static int hp100_down_vg_link(struct net
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4224, TRACE);
-	printk("hp100: %s: down_vg_link\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: down_vg_link\n", dev->name);
 #endif
 
 	hp100_page(MAC_CTRL);
@@ -2538,7 +2538,7 @@ static int hp100_down_vg_link(struct net
 
 #ifdef HP100_DEBUG
 	if (time_after_eq(jiffies, time))
-		printk("hp100: %s: down_vg_link: Link does not go down?\n", dev->name);
+		printk(KERN_DEBUG "hp100: %s: down_vg_link: Link does not go down?\n", dev->name);
 #endif
 
 	/* To prevent condition where Rev 1 VG MAC and old hubs do not complete */
@@ -2593,7 +2593,7 @@ static int hp100_down_vg_link(struct net
 
 	if (time_before_eq(time, jiffies)) {
 #ifdef HP100_DEBUG
-		printk("hp100: %s: down_vg_link: timeout\n", dev->name);
+		printk(KERN_DEBUG "hp100: %s: down_vg_link: timeout\n", dev->name);
 #endif
 		return -EIO;
 	}
@@ -2619,7 +2619,7 @@ static int hp100_login_to_vg_hub(struct 
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4225, TRACE);
-	printk("hp100: %s: login_to_vg_hub\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: login_to_vg_hub\n", dev->name);
 #endif
 
 	/* Initiate a login sequence iff VG MAC is enabled and either Load Address
@@ -2630,7 +2630,7 @@ static int hp100_login_to_vg_hub(struct 
 	startst = hp100_inb(VG_LAN_CFG_1);
 	if ((force_relogin == 1) || (hp100_inb(MAC_CFG_4) & HP100_MAC_SEL_ST)) {
 #ifdef HP100_DEBUG_TRAINING
-		printk("hp100: %s: Start training\n", dev->name);
+		printk(KERN_DEBUG "hp100: %s: Start training\n", dev->name);
 #endif
 
 		/* Ensure VG Reset bit is 1 (i.e., do not reset) */
@@ -2645,7 +2645,7 @@ static int hp100_login_to_vg_hub(struct 
 		hp100_andb(~(HP100_LINK_CMD /* |HP100_LOAD_ADDR */ ), VG_LAN_CFG_1);
 
 #ifdef HP100_DEBUG_TRAINING
-		printk("hp100: %s: Bring down the link\n", dev->name);
+		printk(KERN_DEBUG "hp100: %s: Bring down the link\n", dev->name);
 #endif
 
 		/* Wait for link to drop */
@@ -2699,12 +2699,12 @@ static int hp100_login_to_vg_hub(struct 
 
 		if (time_after_eq(jiffies, time)) {
 #ifdef HP100_DEBUG_TRAINING
-			printk("hp100: %s: Link cable status not ok? Training aborted.\n", dev->name);
+			printk(KERN_DEBUG "hp100: %s: Link cable status not ok? Training aborted.\n", dev->name);
 #endif
 		} else {
 #ifdef HP100_DEBUG_TRAINING
 			printk
-			    ("hp100: %s: HUB tones detected. Trying to train.\n",
+			    (KERN_DEBUG "hp100: %s: HUB tones detected. Trying to train.\n",
 			     dev->name);
 #endif
 
@@ -2713,7 +2713,7 @@ static int hp100_login_to_vg_hub(struct 
 				val = hp100_inb(VG_LAN_CFG_1);
 				if ((val & (HP100_LINK_UP_ST))) {
 #ifdef HP100_DEBUG_TRAINING
-					printk("hp100: %s: Passed training.\n", dev->name);
+					printk(KERN_DEBUG "hp100: %s: Passed training.\n", dev->name);
 #endif
 					break;
 				}
@@ -2727,30 +2727,30 @@ static int hp100_login_to_vg_hub(struct 
 		/* If LINK_UP_ST is set, then we are logged into the hub. */
 		if (time_before_eq(jiffies, time) && (val & HP100_LINK_UP_ST)) {
 #ifdef HP100_DEBUG_TRAINING
-			printk("hp100: %s: Successfully logged into the HUB.\n", dev->name);
+			printk(KERN_DEBUG "hp100: %s: Successfully logged into the HUB.\n", dev->name);
 			if (lp->chip == HP100_CHIPID_LASSEN) {
 				val = hp100_inw(TRAIN_ALLOW);
-				printk("hp100: %s: Card supports 100VG MAC Version \"%s\" ",
+				printk(KERN_DEBUG "hp100: %s: Card supports 100VG MAC Version \"%s\" ",
 					     dev->name, (hp100_inw(TRAIN_REQUEST) & HP100_CARD_MACVER) ? "802.12" : "Pre");
 				printk("Driver will use MAC Version \"%s\"\n", (val & HP100_HUB_MACVER) ? "802.12" : "Pre");
-				printk("hp100: %s: Frame format is %s.\n", dev->name, (val & HP100_MALLOW_FRAMEFMT) ? "802.5" : "802.3");
+				printk(KERN_DEBUG "hp100: %s: Frame format is %s.\n", dev->name, (val & HP100_MALLOW_FRAMEFMT) ? "802.5" : "802.3");
 			}
 #endif
 		} else {
 			/* If LINK_UP_ST is not set, login was not successful */
-			printk("hp100: %s: Problem logging into the HUB.\n", dev->name);
+			printk(KERN_INFO "hp100: %s: Problem logging into the HUB.\n", dev->name);
 			if (lp->chip == HP100_CHIPID_LASSEN) {
 				/* Check allowed Register to find out why there is a problem. */
 				val = hp100_inw(TRAIN_ALLOW);	/* won't work on non-ETR card */
 #ifdef HP100_DEBUG_TRAINING
-				printk("hp100: %s: MAC Configuration requested: 0x%04x, HUB allowed: 0x%04x\n", dev->name, hp100_inw(TRAIN_REQUEST), val);
+				printk(KERN_DEBUG "hp100: %s: MAC Configuration requested: 0x%04x, HUB allowed: 0x%04x\n", dev->name, hp100_inw(TRAIN_REQUEST), val);
 #endif
 				if (val & HP100_MALLOW_ACCDENIED)
-					printk("hp100: %s: HUB access denied.\n", dev->name);
+					printk(KERN_INFO "hp100: %s: HUB access denied.\n", dev->name);
 				if (val & HP100_MALLOW_CONFIGURE)
-					printk("hp100: %s: MAC Configuration is incompatible with the Network.\n", dev->name);
+					printk(KERN_INFO "hp100: %s: MAC Configuration is incompatible with the Network.\n", dev->name);
 				if (val & HP100_MALLOW_DUPADDR)
-					printk("hp100: %s: Duplicate MAC Address on the Network.\n", dev->name);
+					printk(KERN_INFO "hp100: %s: Duplicate MAC Address on the Network.\n", dev->name);
 			}
 		}
 
@@ -2771,7 +2771,7 @@ static int hp100_login_to_vg_hub(struct 
 		if (val & HP100_LINK_UP_ST)
 			return (0);	/* login was ok */
 		else {
-			printk("hp100: %s: Training failed.\n", dev->name);
+			printk(KERN_INFO "hp100: %s: Training failed.\n", dev->name);
 			hp100_down_vg_link(dev);
 			return -EIO;
 		}
@@ -2787,7 +2787,7 @@ static void hp100_cascade_reset(struct n
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4226, TRACE);
-	printk("hp100: %s: cascade_reset\n", dev->name);
+	printk(KERN_DEBUG "hp100: %s: cascade_reset\n", dev->name);
 #endif
 
 	if (enable) {
@@ -2819,21 +2819,21 @@ void hp100_RegisterDump(struct net_devic
 	int Register;
 
 	/* Dump common registers */
-	printk("hp100: %s: Cascade Register Dump\n", dev->name);
-	printk("hardware id #1: 0x%.2x\n", hp100_inb(HW_ID));
-	printk("hardware id #2/paging: 0x%.2x\n", hp100_inb(PAGING));
-	printk("option #1: 0x%.4x\n", hp100_inw(OPTION_LSW));
-	printk("option #2: 0x%.4x\n", hp100_inw(OPTION_MSW));
+	printk(KERN_INFO "hp100: %s: Cascade Register Dump\n", dev->name);
+	printk(KERN_INFO "hardware id #1: 0x%.2x\n", hp100_inb(HW_ID));
+	printk(KERN_INFO "hardware id #2/paging: 0x%.2x\n", hp100_inb(PAGING));
+	printk(KERN_INFO "option #1: 0x%.4x\n", hp100_inw(OPTION_LSW));
+	printk(KERN_INFO "option #2: 0x%.4x\n", hp100_inw(OPTION_MSW));
 
 	/* Dump paged registers */
 	for (Page = 0; Page < 8; Page++) {
 		/* Dump registers */
-		printk("page: 0x%.2x\n", Page);
+		printk(KERN_INFO "page: 0x%.2x\n", Page);
 		outw(Page, ioaddr + 0x02);
 		for (Register = 0x8; Register < 0x22; Register += 2) {
 			/* Display Register contents except data port */
 			if (((Register != 0x10) && (Register != 0x12)) || (Page > 0)) {
-				printk("0x%.2x = 0x%.4x\n", Register, inw(ioaddr + Register));
+				printk(KERN_INFO "0x%.2x = 0x%.4x\n", Register, inw(ioaddr + Register));
 			}
 		}
 	}
@@ -2881,7 +2881,7 @@ static int __init hp100_eisa_probe (stru
 		goto out2;
 	
 #ifdef HP100_DEBUG
-	printk("hp100: %s: EISA adapter found at 0x%x\n", dev->name, 
+	printk(KERN_DEBUG "hp100: %s: EISA adapter found at 0x%x\n", dev->name,
 	       dev->base_addr);
 #endif
 	gendev->driver_data = dev;
@@ -2934,7 +2934,7 @@ static int __devinit hp100_pci_probe (st
 	pci_read_config_word(pdev, PCI_COMMAND, &pci_command);
 	if (!(pci_command & PCI_COMMAND_IO)) {
 #ifdef HP100_DEBUG
-		printk("hp100: %s: PCI I/O Bit has not been set. Setting...\n", dev->name);
+		printk(KERN_DEBUG "hp100: %s: PCI I/O Bit has not been set. Setting...\n", dev->name);
 #endif
 		pci_command |= PCI_COMMAND_IO;
 		pci_write_config_word(pdev, PCI_COMMAND, pci_command);
@@ -2942,7 +2942,7 @@ static int __devinit hp100_pci_probe (st
 
 	if (!(pci_command & PCI_COMMAND_MASTER)) {
 #ifdef HP100_DEBUG
-		printk("hp100: %s: PCI Master Bit has not been set. Setting...\n", dev->name);
+		printk(KERN_DEBUG "hp100: %s: PCI Master Bit has not been set. Setting...\n", dev->name);
 #endif
 		pci_command |= PCI_COMMAND_MASTER;
 		pci_write_config_word(pdev, PCI_COMMAND, pci_command);
@@ -2957,7 +2957,7 @@ static int __devinit hp100_pci_probe (st
 		goto out2;
 	
 #ifdef HP100_DEBUG
-	printk("hp100: %s: PCI adapter found at 0x%x\n", dev->name, ioaddr);
+	printk(KERN_DEBUG "hp100: %s: PCI adapter found at 0x%x\n", dev->name, ioaddr);
 #endif
 	pci_set_drvdata(pdev, dev);
 	return 0;

--
