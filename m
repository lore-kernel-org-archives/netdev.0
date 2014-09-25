From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 1/3] defxx: Correct DEFEA's ESIC port I/O accesses
Date: Thu, 25 Sep 2014 11:06:39 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1409251028070.6148@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1409242337420.6148@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([148.251.95.138]:51423 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496AbaIYK3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 06:29:41 -0400
Received: from localhost.localdomain ([127.0.0.1]:35306 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S27008971AbaIYKGjDpPCF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 12:06:39 +0200
In-Reply-To: <alpine.LFD.2.11.1409242337420.6148@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reverse the order of arguments to `outb', data to write comes first.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 Brown paperbag time.  Dave, please apply.

  Maciej

linux-defea-esic-outb.patch
Index: linux-20140924-dolch/drivers/net/fddi/defxx.c
===================================================================
--- linux-20140924-dolch.orig/drivers/net/fddi/defxx.c
+++ linux-20140924-dolch/drivers/net/fddi/defxx.c
@@ -719,28 +719,28 @@ static void dfx_bus_init(struct net_devi
 
 		/* Set the decode range of the board.  */
 		val = ((bp->base.port >> 12) << PI_IO_CMP_V_SLOT);
-		outb(base_addr + PI_ESIC_K_IO_ADD_CMP_0_1, val);
-		outb(base_addr + PI_ESIC_K_IO_ADD_CMP_0_0, 0);
-		outb(base_addr + PI_ESIC_K_IO_ADD_CMP_1_1, val);
-		outb(base_addr + PI_ESIC_K_IO_ADD_CMP_1_0, 0);
+		outb(val, base_addr + PI_ESIC_K_IO_ADD_CMP_0_1);
+		outb(0, base_addr + PI_ESIC_K_IO_ADD_CMP_0_0);
+		outb(val, base_addr + PI_ESIC_K_IO_ADD_CMP_1_1);
+		outb(0, base_addr + PI_ESIC_K_IO_ADD_CMP_1_0);
 		val = PI_ESIC_K_CSR_IO_LEN - 1;
-		outb(base_addr + PI_ESIC_K_IO_ADD_MASK_0_1, (val >> 8) & 0xff);
-		outb(base_addr + PI_ESIC_K_IO_ADD_MASK_0_0, val & 0xff);
-		outb(base_addr + PI_ESIC_K_IO_ADD_MASK_1_1, (val >> 8) & 0xff);
-		outb(base_addr + PI_ESIC_K_IO_ADD_MASK_1_0, val & 0xff);
+		outb(val, base_addr + PI_ESIC_K_IO_ADD_MASK_0_1);
+		outb(0, base_addr + PI_ESIC_K_IO_ADD_MASK_0_0);
+		outb(val, base_addr + PI_ESIC_K_IO_ADD_MASK_1_1);
+		outb(0, base_addr + PI_ESIC_K_IO_ADD_MASK_1_0);
 
 		/* Enable the decoders.  */
 		val = PI_FUNCTION_CNTRL_M_IOCS1 | PI_FUNCTION_CNTRL_M_IOCS0;
 		if (dfx_use_mmio)
 			val |= PI_FUNCTION_CNTRL_M_MEMCS0;
-		outb(base_addr + PI_ESIC_K_FUNCTION_CNTRL, val);
+		outb(val, base_addr + PI_ESIC_K_FUNCTION_CNTRL);
 
 		/*
 		 * Enable access to the rest of the module
 		 * (including PDQ and packet memory).
 		 */
 		val = PI_SLOT_CNTRL_M_ENB;
-		outb(base_addr + PI_ESIC_K_SLOT_CNTRL, val);
+		outb(val, base_addr + PI_ESIC_K_SLOT_CNTRL);
 
 		/*
 		 * Map PDQ registers into memory or port space.  This is
@@ -751,12 +751,12 @@ static void dfx_bus_init(struct net_devi
 			val |= PI_BURST_HOLDOFF_V_MEM_MAP;
 		else
 			val &= ~PI_BURST_HOLDOFF_V_MEM_MAP;
-		outb(base_addr + PI_DEFEA_K_BURST_HOLDOFF, val);
+		outb(val, base_addr + PI_DEFEA_K_BURST_HOLDOFF);
 
 		/* Enable interrupts at EISA bus interface chip (ESIC) */
 		val = inb(base_addr + PI_ESIC_K_IO_CONFIG_STAT_0);
 		val |= PI_CONFIG_STAT_0_M_INT_ENB;
-		outb(base_addr + PI_ESIC_K_IO_CONFIG_STAT_0, val);
+		outb(val, base_addr + PI_ESIC_K_IO_CONFIG_STAT_0);
 	}
 	if (dfx_bus_pci) {
 		struct pci_dev *pdev = to_pci_dev(bdev);
@@ -825,7 +825,7 @@ static void dfx_bus_uninit(struct net_de
 		/* Disable interrupts at EISA bus interface chip (ESIC) */
 		val = inb(base_addr + PI_ESIC_K_IO_CONFIG_STAT_0);
 		val &= ~PI_CONFIG_STAT_0_M_INT_ENB;
-		outb(base_addr + PI_ESIC_K_IO_CONFIG_STAT_0, val);
+		outb(val, base_addr + PI_ESIC_K_IO_CONFIG_STAT_0);
 	}
 	if (dfx_bus_pci) {
 		/* Disable interrupts at PCI bus interface chip (PFI) */
@@ -1917,7 +1917,7 @@ static irqreturn_t dfx_interrupt(int irq
 
 		/* Disable interrupts at the ESIC */
 		status &= ~PI_CONFIG_STAT_0_M_INT_ENB;
-		outb(base_addr + PI_ESIC_K_IO_CONFIG_STAT_0, status);
+		outb(status, base_addr + PI_ESIC_K_IO_CONFIG_STAT_0);
 
 		/* Call interrupt service routine for this adapter */
 		dfx_int_common(dev);
@@ -1925,7 +1925,7 @@ static irqreturn_t dfx_interrupt(int irq
 		/* Reenable interrupts at the ESIC */
 		status = inb(base_addr + PI_ESIC_K_IO_CONFIG_STAT_0);
 		status |= PI_CONFIG_STAT_0_M_INT_ENB;
-		outb(base_addr + PI_ESIC_K_IO_CONFIG_STAT_0, status);
+		outb(status, base_addr + PI_ESIC_K_IO_CONFIG_STAT_0);
 
 		spin_unlock(&bp->lock);
 	}
