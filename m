From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 1/8 2.4.26-bk1] pcnet32 whitespace only changes
Date: Tue, 20 Apr 2004 13:13:02 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404202013.i3KKD7213578@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This modifies the whitespace only.  consistent indentation, deletes
trailing tabs, trailing spaces, etc.

--- linux-2.4.26-bk1/drivers/net/new.pcnet32.c	Tue Apr 20 12:38:46 2004
+++ linux-2.4.26-bk1/drivers/net/pcnet32.c	Tue Apr 20 12:39:02 2004
@@ -1,12 +1,12 @@
 /* pcnet32.c: An AMD PCnet32 ethernet driver for linux. */
 /*
  *	Copyright 1996-1999 Thomas Bogendoerfer
- * 
+ *
  *	Derived from the lance driver written 1993,1994,1995 by Donald Becker.
- * 
+ *
  *	Copyright 1993 United States Government as represented by the
  *	Director, National Security Agency.
- * 
+ *
  *	This software may be used and distributed according to the terms
  *	of the GNU General Public License, incorporated herein by reference.
  *
@@ -48,9 +48,10 @@
 #include <linux/spinlock.h>
 
 #include <asm/bitops.h>
-#include <asm/io.h>
 #include <asm/dma.h>
+#include <asm/io.h>
 #include <asm/uaccess.h>
+#include <asm/irq.h>
 
 /*
  * PCI device identifiers for "new style" Linux PCI Device Drivers
@@ -71,10 +72,10 @@
 
 static int cards_found __devinitdata;
 
-/* 
- * VLB I/O addresses 
+/*
+ * VLB I/O addresses
  */
-static unsigned int pcnet32_portlist[] __initdata = 
+static unsigned int pcnet32_portlist[] __initdata =
 	{ 0x300, 0x320, 0x340, 0x360, 0 };
 
 
@@ -109,7 +110,7 @@
 static unsigned char options_mapping[] = {
     PCNET32_PORT_ASEL,			   /*  0 Auto-select	  */
     PCNET32_PORT_AUI,			   /*  1 BNC/AUI	  */
-    PCNET32_PORT_AUI,			   /*  2 AUI/BNC	  */ 
+    PCNET32_PORT_AUI,			   /*  2 AUI/BNC	  */
     PCNET32_PORT_ASEL,			   /*  3 not supported	  */
     PCNET32_PORT_10BT | PCNET32_PORT_FD,   /*  4 10baseT-FD	  */
     PCNET32_PORT_ASEL,			   /*  5 not supported	  */
@@ -136,14 +137,14 @@
 
 /*
  *				Theory of Operation
- * 
+ *
  * This driver uses the same software structure as the normal lance
  * driver. So look for a verbose description in lance.c. The differences
  * to the normal lance driver is the use of the 32bit mode of PCnet32
  * and PCnetPCI chips. Because these chips are 32bit chips, there is no
  * 16MB limitation and we don't need bounce buffers.
  */
- 
+
 /*
  * History:
  * v0.01:  Initial version
@@ -197,7 +198,7 @@
  * v1.22:  changed pci scanning code to make PPC people happy
  *	   fixed switching to 32bit mode in pcnet32_open() (thanks
  *	   to Michael Richard <mcr@solidum.com> for noticing this one)
- *	   added sub vendor/device id matching (thanks again to 
+ *	   added sub vendor/device id matching (thanks again to
  *	   Michael Richard <mcr@solidum.com>)
  *	   added chip id for 79c973/975 (thanks to Zach Brown <zab@zabbo.net>)
  * v1.23   fixed small bug, when manual selecting MII speed/duplex
@@ -215,7 +216,7 @@
  * v1.26p  Fix oops on rmmod+insmod; plug i/o resource leak - Paul Gortmaker
  * v1.27   improved CSR/PROM address detection, lots of cleanups,
  * 	   new pcnet32vlb module option, HP-PARISC support,
- * 	   added module parameter descriptions, 
+ * 	   added module parameter descriptions,
  * 	   initial ethtool support - Helge Deller <deller@gmx.de>
  * v1.27a  Sun Feb 10 2002 Go Taniguchi <go@turbolinux.co.jp>
  *	   use alloc_etherdev and register_netdev
@@ -223,7 +224,7 @@
  *	   FD auto negotiate error workaround for xSeries250
  *	   clean up and using new mii module
  * v1.27b  Sep 30 2002 Kent Yoder <yoder1@us.ibm.com>
- *	   Added timer for cable connection state changes.
+ * 	   Added timer for cable connection state changes.
  * v1.28   20 Feb 2004 Don Fry <brazilnut@us.ibm.com>
  *	   Jon Mason <jonmason@us.ibm.com>, Chinmay Albal <albal@in.ibm.com>
  *	   Now uses ethtool_ops, netif_msg_* and generic_mii_ioctl.
@@ -271,11 +272,11 @@
 struct pcnet32_rx_head {
     u32 base;
     s16 buf_length;
-    s16 status;	   
+    s16 status;
     u32 msg_length;
     u32 reserved;
 };
-	
+
 struct pcnet32_tx_head {
     u32 base;
     s16 length;
@@ -291,7 +292,7 @@
     u8	phys_addr[6];
     u16 reserved;
     u32 filter[2];
-    /* Receive and transmit ring base, along with extra bits. */    
+    /* Receive and transmit ring base, along with extra bits. */
     u32 rx_ring;
     u32 tx_ring;
 };
@@ -308,7 +309,7 @@
 };
 
 /*
- * The first three fields of pcnet32_private are read by the ethernet device 
+ * The first three fields of pcnet32_private are read by the ethernet device
  * so we allocate the structure should be allocated by pci_alloc_consistent().
  */
 struct pcnet32_private {
@@ -316,16 +317,18 @@
     struct pcnet32_rx_head    rx_ring[RX_RING_SIZE];
     struct pcnet32_tx_head    tx_ring[TX_RING_SIZE];
     struct pcnet32_init_block init_block;
-    dma_addr_t 		dma_addr;	/* DMA address of beginning of this object, 
-					   returned by pci_alloc_consistent */
-    struct pci_dev	*pci_dev;	/* Pointer to the associated pci device structure */
+    dma_addr_t		dma_addr;	/* DMA address of beginning of this
+					   object, returned by
+					   pci_alloc_consistent */
+    struct pci_dev	*pci_dev;	/* Pointer to the associated pci device
+					   structure */
     const char		*name;
     /* The saved address of a sent-in-place packet/buffer, for skfree(). */
     struct sk_buff	*tx_skbuff[TX_RING_SIZE];
     struct sk_buff	*rx_skbuff[RX_RING_SIZE];
     dma_addr_t		tx_dma_addr[TX_RING_SIZE];
     dma_addr_t		rx_dma_addr[RX_RING_SIZE];
-    struct pcnet32_access a;
+    struct pcnet32_access	a;
     spinlock_t		lock;		/* Guard lock */
     unsigned int	cur_rx, cur_tx;	/* The next free ring entry */
     unsigned int	dirty_rx, dirty_tx; /* The ring entries to be free()ed. */
@@ -337,7 +340,7 @@
 	dxsuflo:1,			/* disable transmit stop on uflo */
 	mii:1;				/* mii port available */
     struct net_device	*next;
-    struct mii_if_info mii_if;
+    struct mii_if_info	mii_if;
     struct timer_list	watchdog_timer;
     u32			msg_enable;	/* debug message level */
 };
@@ -482,11 +485,11 @@
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void pcnet32_poll_controller(struct net_device *dev)
-{ 
-	disable_irq(dev->irq);
-	pcnet32_interrupt(0, dev, NULL);
-	enable_irq(dev->irq);
-} 
+{
+    disable_irq(dev->irq);
+    pcnet32_interrupt(0, dev, NULL);
+    enable_irq(dev->irq);
+}
 #endif
 
 
@@ -521,14 +524,14 @@
 
 static void pcnet32_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct pcnet32_private *lp = dev->priv;
-  
-	strcpy (info->driver, DRV_NAME);
-	strcpy (info->version, DRV_VERSION);
-	if (lp->pci_dev)
-		strcpy (info->bus_info, pci_name(lp->pci_dev));
-	else
-		sprintf(info->bus_info, "VLB 0x%lx", dev->base_addr);
+    struct pcnet32_private *lp = dev->priv;
+
+    strcpy (info->driver, DRV_NAME);
+    strcpy (info->version, DRV_VERSION);
+    if (lp->pci_dev)
+	strcpy (info->bus_info, pci_name(lp->pci_dev));
+    else
+	sprintf(info->bus_info, "VLB 0x%lx", dev->base_addr);
 }
 
 static u32 pcnet32_get_link(struct net_device *dev)
@@ -551,16 +554,16 @@
 
 static u32 pcnet32_get_msglevel(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
-	return lp->msg_enable;
+    struct pcnet32_private *lp = dev->priv;
+    return lp->msg_enable;
 }
-  
+
 static void pcnet32_set_msglevel(struct net_device *dev, u32 value)
 {
-	struct pcnet32_private *lp = dev->priv;
-	lp->msg_enable = value;
+    struct pcnet32_private *lp = dev->priv;
+    lp->msg_enable = value;
 }
-  
+
 static int pcnet32_nway_reset(struct net_device *dev)
 {
     struct pcnet32_private *lp = dev->priv;
@@ -577,12 +580,12 @@
 
 static void pcnet32_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
 {
-	struct pcnet32_private *lp = dev->priv;
+    struct pcnet32_private *lp = dev->priv;
 
-	ering->tx_max_pending = TX_RING_SIZE - 1;
-	ering->tx_pending = lp->cur_tx - lp->dirty_tx;
-	ering->rx_max_pending = RX_RING_SIZE - 1;
-	ering->rx_pending = lp->cur_rx & RX_RING_MOD_MASK;
+    ering->tx_max_pending = TX_RING_SIZE - 1;
+    ering->tx_pending = lp->cur_tx - lp->dirty_tx;
+    ering->rx_max_pending = RX_RING_SIZE - 1;
+    ering->rx_pending = lp->cur_rx & RX_RING_MOD_MASK;
 }
 
 static void pcnet32_get_strings(struct net_device *dev, u32 stringset, u8 *data)
@@ -672,7 +675,7 @@
 	    for (i=0; i<6; i++)
 		*packet++ = dev->dev_addr[i];
 	    for (i=0; i<6; i++)
-		*packet++ = dev->dev_addr[i]; 
+		*packet++ = dev->dev_addr[i];
 	    /* type */
 	    *packet++ = 0x08;
 	    *packet++ = 0x06;
@@ -787,14 +790,14 @@
     .self_test		= pcnet32_ethtool_test,
 };
 
-/* only probes for non-PCI devices, the rest are handled by 
+/* only probes for non-PCI devices, the rest are handled by
  * pci_register_driver via pcnet32_probe_pci */
 
 static void __devinit
 pcnet32_probe_vlbus(void)
 {
     unsigned int *port, ioaddr;
-    
+
     /* search for PCnet32 VLB cards at known addresses */
     for (port = pcnet32_portlist; (ioaddr = *port); port++) {
 	if (request_region(ioaddr, PCNET32_TOTAL_SIZE, "pcnet32_probe_vlbus")) {
@@ -824,10 +827,10 @@
 
     ioaddr = pci_resource_start (pdev, 0);
     if (!ioaddr) {
-        printk (KERN_ERR PFX "card has no PCI IO resources, aborting\n");
-        return -ENODEV;
+	printk (KERN_ERR PFX "card has no PCI IO resources, aborting\n");
+	return -ENODEV;
     }
-    
+
     if (!pci_dma_supported(pdev, PCNET32_DMA_MASK)) {
 	printk(KERN_ERR PFX "architecture does not support 32bit PCI busmaster DMA\n");
 	return -ENODEV;
@@ -841,8 +844,8 @@
 }
 
 
-/* pcnet32_probe1 
- *  Called from both pcnet32_probe_vlbus and pcnet_probe_pci.  
+/* pcnet32_probe1
+ *  Called from both pcnet32_probe_vlbus and pcnet_probe_pci.
  *  pdev will be NULL when called from pcnet32_probe_vlbus.
  */
 static int __devinit
@@ -881,7 +884,7 @@
 	printk(KERN_INFO PFX "Unsupported chip version.\n");
 	goto err_release_region;
     }
-    
+
     /* initialize variables */
     fdx = mii = fset = dxsuflo = ltint = 0;
     chip_version = (chip_version >> 12) & 0xffff;
@@ -916,7 +919,7 @@
     case 0x2626:
 	chipname = "PCnet/Home 79C978"; /* PCI */
 	fdx = 1;
-	/* 
+	/*
 	 * This is based on specs published at www.amd.com.  This section
 	 * assumes that a card with a 79C978 wants to go into 1Mb HomePNA
 	 * mode.  The 79C978 can also go into standard ethernet, and there
@@ -925,12 +928,6 @@
 	 */
 	/* switch to home wiring mode */
 	media = a->read_bcr(ioaddr, 49);
-#if 0
-	if (pcnet32_debug > 2)
-	    printk(KERN_DEBUG PFX "media value %#x.\n",  media);
-	media &= ~3;
-	media |= 1;
-#endif
 	if (pcnet32_debug & NETIF_MSG_PROBE)
 	    printk(KERN_DEBUG PFX "media reset to %#x.\n",  media);
 	a->write_bcr(ioaddr, 49, media);
@@ -941,25 +938,24 @@
 	break;
     default:
 	printk(KERN_INFO PFX "PCnet version %#x, no PCnet32 chip.\n",
-			chip_version);
+		chip_version);
 	goto err_release_region;
     }
 
     /*
      *	On selected chips turn on the BCR18:NOUFLO bit. This stops transmit
      *	starting until the packet is loaded. Strike one for reliability, lose
-     *	one for latency - although on PCI this isnt a big loss. Older chips 
+     *	one for latency - although on PCI this isnt a big loss. Older chips
      *	have FIFO's smaller than a packet, so you can't do this.
      */
-	 
-    if(fset)
-    {
+
+    if (fset) {
 	a->write_bcr(ioaddr, 18, (a->read_bcr(ioaddr, 18) | 0x0800));
 	a->write_csr(ioaddr, 80, (a->read_csr(ioaddr, 80) & 0x0C00) | 0x0c00);
 	dxsuflo = 1;
 	ltint = 1;
     }
-    
+
     dev = alloc_etherdev(0);
     if (!dev) {
 	printk(KERN_ERR PFX "Memory allocation failed.\n");
@@ -988,13 +984,13 @@
     /* read PROM address and compare with CSR address */
     for (i = 0; i < 6; i++)
 	promaddr[i] = inb(ioaddr + i);
-    
-    if( memcmp( promaddr, dev->dev_addr, 6)
-	|| !is_valid_ether_addr(dev->dev_addr) ) {
+
+    if (memcmp(promaddr, dev->dev_addr, 6)
+	|| !is_valid_ether_addr(dev->dev_addr)) {
 #ifndef __powerpc__
-	if( is_valid_ether_addr(promaddr) ){
+	if (is_valid_ether_addr(promaddr)) {
 #else
-	if( !is_valid_ether_addr(dev->dev_addr)
+	if (!is_valid_ether_addr(dev->dev_addr)
 	    && is_valid_ether_addr(promaddr)) {
 #endif
 	    printk(" warning: CSR address invalid,\n");
@@ -1004,13 +1000,13 @@
     }
 
     /* if the ethernet address is not valid, force to 00:00:00:00:00:00 */
-    if( !is_valid_ether_addr(dev->dev_addr) )
+    if (!is_valid_ether_addr(dev->dev_addr))
 	memset(dev->dev_addr, 0, sizeof(dev->dev_addr));
 
     for (i = 0; i < 6; i++)
 	printk(" %2.2x", dev->dev_addr[i]);
 
-    if (((chip_version + 1) & 0xfffe) == 0x2624) { /* Version 0x2623 or 0x2624 */
+    if (((chip_version + 1) & 0xfffe) == 0x2624) { /* Version 0x2623 - 0x2624 */
 	i = a->read_csr(ioaddr, 80) & 0x0C00;  /* Check tx_start_pt */
 	printk("\n" KERN_INFO "    tx_start_pt(0x%04x):",i);
 	switch(i>>10) {
@@ -1034,7 +1030,6 @@
     }
 
     dev->base_addr = ioaddr;
-    
     /* pci_alloc_consistent returns page-aligned memory, so we do not have to check the alignment */
     if ((lp = pci_alloc_consistent(pdev, sizeof(*lp), &lp_dma_addr)) == NULL) {
 	printk(KERN_ERR PFX "Consistent memory allocation failed.\n");
@@ -1047,7 +1042,7 @@
     lp->pci_dev = pdev;
 
     spin_lock_init(&lp->lock);
-    
+
     SET_MODULE_OWNER(dev);
     SET_NETDEV_DEV(dev, &pdev->dev);
     dev->priv = lp;
@@ -1067,46 +1062,51 @@
     lp->mii_if.dev = dev;
     lp->mii_if.mdio_read = mdio_read;
     lp->mii_if.mdio_write = mdio_write;
-    
-    if (fdx && !(lp->options & PCNET32_PORT_ASEL) && 
+
+    if (fdx && !(lp->options & PCNET32_PORT_ASEL) &&
 		((cards_found>=MAX_UNITS) || full_duplex[cards_found]))
 	lp->options |= PCNET32_PORT_FD;
-    
+
     if (!a) {
 	printk(KERN_ERR PFX "No access methods\n");
 	ret = -ENODEV;
 	goto err_free_consistent;
     }
     lp->a = *a;
-    
+
     /* detect special T1/E1 WAN card by checking for MAC address */
-    if (dev->dev_addr[0] == 0x00 && dev->dev_addr[1] == 0xe0 && dev->dev_addr[2] == 0x75)
+    if (dev->dev_addr[0] == 0x00 && dev->dev_addr[1] == 0xe0
+	    && dev->dev_addr[2] == 0x75)
 	lp->options = PCNET32_PORT_FD | PCNET32_PORT_GPSI;
 
     lp->init_block.mode = le16_to_cpu(0x0003);	/* Disable Rx and Tx. */
-    lp->init_block.tlen_rlen = le16_to_cpu(TX_RING_LEN_BITS | RX_RING_LEN_BITS); 
+    lp->init_block.tlen_rlen = le16_to_cpu(TX_RING_LEN_BITS | RX_RING_LEN_BITS);
     for (i = 0; i < 6; i++)
 	lp->init_block.phys_addr[i] = dev->dev_addr[i];
     lp->init_block.filter[0] = 0x00000000;
     lp->init_block.filter[1] = 0x00000000;
-    lp->init_block.rx_ring = (u32)le32_to_cpu(lp->dma_addr + offsetof(struct pcnet32_private, rx_ring));
-    lp->init_block.tx_ring = (u32)le32_to_cpu(lp->dma_addr + offsetof(struct pcnet32_private, tx_ring));
-    
+    lp->init_block.rx_ring = (u32)le32_to_cpu(lp->dma_addr +
+	    offsetof(struct pcnet32_private, rx_ring));
+    lp->init_block.tx_ring = (u32)le32_to_cpu(lp->dma_addr +
+	    offsetof(struct pcnet32_private, tx_ring));
+
     /* switch pcnet32 to 32bit mode */
-    a->write_bcr (ioaddr, 20, 2);
+    a->write_bcr(ioaddr, 20, 2);
+
+    a->write_csr(ioaddr, 1, (lp->dma_addr + offsetof(struct pcnet32_private,
+		    init_block)) & 0xffff);
+    a->write_csr(ioaddr, 2, (lp->dma_addr + offsetof(struct pcnet32_private,
+		    init_block)) >> 16);
 
-    a->write_csr (ioaddr, 1, (lp->dma_addr + offsetof(struct pcnet32_private, init_block)) & 0xffff);
-    a->write_csr (ioaddr, 2, (lp->dma_addr + offsetof(struct pcnet32_private, init_block)) >> 16);
-    
     if (irq_line) {
 	dev->irq = irq_line;
     }
-    
+
     if (dev->irq >= 2)
 	printk(" assigned IRQ %d.\n", dev->irq);
     else {
 	unsigned long irq_mask = probe_irq_on();
-	
+
 	/*
 	 * To auto-IRQ we enable the initialization-done and DMA error
 	 * interrupts. For ISA boards we get a DMA error, but VLB and PCI
@@ -1115,7 +1115,7 @@
 	/* Trigger an initialization just for the interrupt. */
 	a->write_csr (ioaddr, 0, 0x41);
 	mdelay (1);
-	
+
 	dev->irq = probe_irq_off (irq_mask);
 	if (!dev->irq) {
 	    printk(", failed to detect IRQ line.\n");
@@ -1128,7 +1128,7 @@
     /* Set the mii phy_id so that we can query the link state */
     if (lp->mii)
 	lp->mii_if.phy_id = ((lp->a.read_bcr (ioaddr, 33)) >> 5) & 0x1f;
-    
+
     init_timer (&lp->watchdog_timer);
     lp->watchdog_timer.data = (unsigned long) dev;
     lp->watchdog_timer.function = (void *) &pcnet32_watchdog;
@@ -1146,7 +1146,7 @@
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
     dev->poll_controller = pcnet32_poll_controller;
-#endif    
+#endif
 
     /* Fill in the generic fields of the device structure. */
     if (register_netdev(dev))
@@ -1208,13 +1208,13 @@
 	       (u32) (lp->dma_addr + offsetof(struct pcnet32_private, tx_ring)),
 	       (u32) (lp->dma_addr + offsetof(struct pcnet32_private, rx_ring)),
 	       (u32) (lp->dma_addr + offsetof(struct pcnet32_private, init_block)));
-    
+
     /* set/reset autoselect bit */
     val = lp->a.read_bcr (ioaddr, 2) & ~2;
     if (lp->options & PCNET32_PORT_ASEL)
 	val |= 2;
     lp->a.write_bcr (ioaddr, 2, val);
-    
+
     /* handle full duplex setting */
     if (lp->mii_if.full_duplex) {
 	val = lp->a.read_bcr (ioaddr, 9) & ~3;
@@ -1224,34 +1224,38 @@
 		val |= 2;
 	} else if (lp->options & PCNET32_PORT_ASEL) {
 	/* workaround of xSeries250, turn on for 79C975 only */
-	    i = ((lp->a.read_csr(ioaddr, 88) | (lp->a.read_csr(ioaddr,89) << 16)) >> 12) & 0xffff;
-	    if (i == 0x2627) val |= 3;
+	    i = ((lp->a.read_csr(ioaddr, 88) |
+			(lp->a.read_csr(ioaddr,89) << 16)) >> 12) & 0xffff;
+	    if (i == 0x2627)
+		val |= 3;
 	}
 	lp->a.write_bcr (ioaddr, 9, val);
     }
-    
+
     /* set/reset GPSI bit in test register */
     val = lp->a.read_csr (ioaddr, 124) & ~0x10;
     if ((lp->options & PCNET32_PORT_PORTSEL) == PCNET32_PORT_GPSI)
 	val |= 0x10;
     lp->a.write_csr (ioaddr, 124, val);
-    
+
     if (lp->mii && !(lp->options & PCNET32_PORT_ASEL)) {
-	val = lp->a.read_bcr (ioaddr, 32) & ~0x38; /* disable Auto Negotiation, set 10Mpbs, HD */
+	/* disable Auto Negotiation, set 10Mpbs, HD */
+	val = lp->a.read_bcr (ioaddr, 32) & ~0x38;
 	if (lp->options & PCNET32_PORT_FD)
 	    val |= 0x10;
 	if (lp->options & PCNET32_PORT_100)
 	    val |= 0x08;
 	lp->a.write_bcr (ioaddr, 32, val);
     } else {
-	if (lp->options & PCNET32_PORT_ASEL) {  /* enable auto negotiate, setup, disable fd */
-		val = lp->a.read_bcr(ioaddr, 32) & ~0x98;
-		val |= 0x20;
-		lp->a.write_bcr(ioaddr, 32, val);
+	if (lp->options & PCNET32_PORT_ASEL) {
+	    /* enable auto negotiate, setup, disable fd */
+	    val = lp->a.read_bcr(ioaddr, 32) & ~0x98;
+	    val |= 0x20;
+	    lp->a.write_bcr(ioaddr, 32, val);
 	}
     }
 
-#ifdef DO_DXSUFLO 
+#ifdef DO_DXSUFLO
     if (lp->dxsuflo) { /* Disable transmit stop on underflow */
 	val = lp->a.read_csr (ioaddr, 3);
 	val |= 0x40;
@@ -1264,7 +1268,7 @@
 	val |= (1<<14);
 	lp->a.write_csr (ioaddr, 5, val);
     }
-   
+
     lp->init_block.mode = le16_to_cpu((lp->options & PCNET32_PORT_PORTSEL) << 7);
     pcnet32_load_multicast(dev);
 
@@ -1272,10 +1276,12 @@
 	rc = -ENOMEM;
 	goto err_free_ring;
     }
-    
+
     /* Re-initialize the PCNET32, and start it when done. */
-    lp->a.write_csr (ioaddr, 1, (lp->dma_addr + offsetof(struct pcnet32_private, init_block)) &0xffff);
-    lp->a.write_csr (ioaddr, 2, (lp->dma_addr + offsetof(struct pcnet32_private, init_block)) >> 16);
+    lp->a.write_csr (ioaddr, 1, (lp->dma_addr +
+		offsetof(struct pcnet32_private, init_block)) &0xffff);
+    lp->a.write_csr (ioaddr, 2, (lp->dma_addr +
+		offsetof(struct pcnet32_private, init_block)) >> 16);
 
     lp->a.write_csr (ioaddr, 4, 0x0915);
     lp->a.write_csr (ioaddr, 0, 0x0001);
@@ -1292,7 +1298,7 @@
     while (i++ < 100)
 	if (lp->a.read_csr (ioaddr, 0) & 0x0100)
 	    break;
-    /* 
+    /*
      * We used to clear the InitDone bit, 0x0100, here but Mark Stockton
      * reports that doing so triggers a bug in the '974.
      */
@@ -1300,8 +1306,9 @@
 
     if (netif_msg_ifup(lp))
 	printk(KERN_DEBUG "%s: pcnet32 open after %d ticks, init block %#x csr0 %4.4x.\n",
-	       dev->name, i, (u32) (lp->dma_addr + offsetof(struct pcnet32_private, init_block)),
-	       lp->a.read_csr(ioaddr, 0));
+		dev->name, i, (u32) (lp->dma_addr +
+		    offsetof(struct pcnet32_private, init_block)),
+		lp->a.read_csr(ioaddr, 0));
 
     spin_unlock_irqrestore(&lp->lock, flags);
 
@@ -1310,17 +1317,17 @@
 err_free_ring:
     /* free any allocated skbuffs */
     for (i = 0; i < RX_RING_SIZE; i++) {
-	lp->rx_ring[i].status = 0;			    
+	lp->rx_ring[i].status = 0;
 	if (lp->rx_skbuff[i]) {
-            pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[i], PKT_BUF_SZ-2,
+	    pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[i], PKT_BUF_SZ-2,
 		    PCI_DMA_FROMDEVICE);
 	    dev_kfree_skb(lp->rx_skbuff[i]);
-        }
+	}
 	lp->rx_skbuff[i] = NULL;
-        lp->rx_dma_addr[i] = 0;
+	lp->rx_dma_addr[i] = 0;
     }
     /*
-     * Switch back to 16bit mode to avoid problems with dumb 
+     * Switch back to 16bit mode to avoid problems with dumb
      * DOS packet driver after a warm reboot
      */
     lp->a.write_bcr (ioaddr, 20, 4);
@@ -1344,7 +1351,7 @@
  * restarting the chip, but I'm too lazy to do so right now.  dplatt@3do.com
  */
 
-static void 
+static void
 pcnet32_purge_tx_ring(struct net_device *dev)
 {
     struct pcnet32_private *lp = dev->priv;
@@ -1352,10 +1359,11 @@
 
     for (i = 0; i < TX_RING_SIZE; i++) {
 	if (lp->tx_skbuff[i]) {
-            pci_unmap_single(lp->pci_dev, lp->tx_dma_addr[i], lp->tx_skbuff[i]->len, PCI_DMA_TODEVICE);
-	    dev_kfree_skb_any(lp->tx_skbuff[i]); 
+	    pci_unmap_single(lp->pci_dev, lp->tx_dma_addr[i],
+		    lp->tx_skbuff[i]->len, PCI_DMA_TODEVICE);
+	    dev_kfree_skb_any(lp->tx_skbuff[i]);
 	    lp->tx_skbuff[i] = NULL;
-            lp->tx_dma_addr[i] = 0;
+	    lp->tx_dma_addr[i] = 0;
 	}
     }
 }
@@ -1373,37 +1381,40 @@
     lp->dirty_rx = lp->dirty_tx = 0;
 
     for (i = 0; i < RX_RING_SIZE; i++) {
-        struct sk_buff *rx_skbuff = lp->rx_skbuff[i];
+	struct sk_buff *rx_skbuff = lp->rx_skbuff[i];
 	if (rx_skbuff == NULL) {
 	    if (!(rx_skbuff = lp->rx_skbuff[i] = dev_alloc_skb (PKT_BUF_SZ))) {
 		/* there is not much, we can do at this point */
-		printk(KERN_ERR "%s: pcnet32_init_ring dev_alloc_skb failed.\n",dev->name);
+		printk(KERN_ERR "%s: pcnet32_init_ring dev_alloc_skb failed.\n",
+			dev->name);
 		return -1;
 	    }
 	    skb_reserve (rx_skbuff, 2);
 	}
 
-	if (lp->rx_dma_addr[i] == 0) 
-		lp->rx_dma_addr[i] = pci_map_single(lp->pci_dev,
-			rx_skbuff->tail, PKT_BUF_SZ-2, PCI_DMA_FROMDEVICE);
+	if (lp->rx_dma_addr[i] == 0)
+	    lp->rx_dma_addr[i] = pci_map_single(lp->pci_dev, rx_skbuff->tail,
+		    PKT_BUF_SZ-2, PCI_DMA_FROMDEVICE);
 	lp->rx_ring[i].base = (u32)le32_to_cpu(lp->rx_dma_addr[i]);
 	lp->rx_ring[i].buf_length = le16_to_cpu(2-PKT_BUF_SZ);
 	lp->rx_ring[i].status = le16_to_cpu(0x8000);
     }
     /* The Tx buffer address is filled in as needed, but we do need to clear
-       the upper ownership bit. */
+     * the upper ownership bit. */
     for (i = 0; i < TX_RING_SIZE; i++) {
 	lp->tx_ring[i].base = 0;
 	lp->tx_ring[i].status = 0;
-        lp->tx_dma_addr[i] = 0;
+	lp->tx_dma_addr[i] = 0;
     }
     wmb(); /* Make sure all changes are visible */
 
     lp->init_block.tlen_rlen = le16_to_cpu(TX_RING_LEN_BITS | RX_RING_LEN_BITS);
     for (i = 0; i < 6; i++)
 	lp->init_block.phys_addr[i] = dev->dev_addr[i];
-    lp->init_block.rx_ring = (u32)le32_to_cpu(lp->dma_addr + offsetof(struct pcnet32_private, rx_ring));
-    lp->init_block.tx_ring = (u32)le32_to_cpu(lp->dma_addr + offsetof(struct pcnet32_private, tx_ring));
+    lp->init_block.rx_ring = (u32)le32_to_cpu(lp->dma_addr +
+	    offsetof(struct pcnet32_private, rx_ring));
+    lp->init_block.tx_ring = (u32)le32_to_cpu(lp->dma_addr +
+	    offsetof(struct pcnet32_private, tx_ring));
     return 0;
 }
 
@@ -1413,11 +1424,11 @@
     struct pcnet32_private *lp = dev->priv;
     unsigned long ioaddr = dev->base_addr;
     int i;
-    
+
     pcnet32_purge_tx_ring(dev);
     if (pcnet32_init_ring(dev))
 	return;
-    
+
     /* ReInit Ring */
     lp->a.write_csr (ioaddr, 0, 1);
     i = 0;
@@ -1437,31 +1448,31 @@
 
     spin_lock_irqsave(&lp->lock, flags);
     /* Transmitter timeout, serious problems. */
-	printk(KERN_ERR "%s: transmit timed out, status %4.4x, resetting.\n",
-	       dev->name, lp->a.read_csr(ioaddr, 0));
-	lp->a.write_csr (ioaddr, 0, 0x0004);
-	lp->stats.tx_errors++;
-	if (netif_msg_tx_err(lp)) {
-	    int i;
-	    printk(KERN_DEBUG " Ring data dump: dirty_tx %d cur_tx %d%s cur_rx %d.",
-	       lp->dirty_tx, lp->cur_tx, lp->tx_full ? " (full)" : "",
-	       lp->cur_rx);
-	    for (i = 0 ; i < RX_RING_SIZE; i++)
-	    printk("%s %08x %04x %08x %04x", i & 1 ? "" : "\n ",
-		   lp->rx_ring[i].base, -lp->rx_ring[i].buf_length,
-		   lp->rx_ring[i].msg_length, (unsigned)lp->rx_ring[i].status);
-	    for (i = 0 ; i < TX_RING_SIZE; i++)
-	    printk("%s %08x %04x %08x %04x", i & 1 ? "" : "\n ",
-		   lp->tx_ring[i].base, -lp->tx_ring[i].length,
-		   lp->tx_ring[i].misc, (unsigned)lp->tx_ring[i].status);
-	    printk("\n");
-	}
-	pcnet32_restart(dev, 0x0042);
+    printk(KERN_ERR "%s: transmit timed out, status %4.4x, resetting.\n",
+	   dev->name, lp->a.read_csr(ioaddr, 0));
+    lp->a.write_csr (ioaddr, 0, 0x0004);
+    lp->stats.tx_errors++;
+    if (netif_msg_tx_err(lp)) {
+	int i;
+	printk(KERN_DEBUG " Ring data dump: dirty_tx %d cur_tx %d%s cur_rx %d.",
+	   lp->dirty_tx, lp->cur_tx, lp->tx_full ? " (full)" : "",
+	   lp->cur_rx);
+	for (i = 0 ; i < RX_RING_SIZE; i++)
+	printk("%s %08x %04x %08x %04x", i & 1 ? "" : "\n ",
+	       lp->rx_ring[i].base, -lp->rx_ring[i].buf_length,
+	       lp->rx_ring[i].msg_length, (unsigned)lp->rx_ring[i].status);
+	for (i = 0 ; i < TX_RING_SIZE; i++)
+	printk("%s %08x %04x %08x %04x", i & 1 ? "" : "\n ",
+	       lp->tx_ring[i].base, -lp->tx_ring[i].length,
+	       lp->tx_ring[i].misc, (unsigned)lp->tx_ring[i].status);
+	printk("\n");
+    }
+    pcnet32_restart(dev, 0x0042);
 
-	dev->trans_start = jiffies;
-	netif_wake_queue(dev);
+    dev->trans_start = jiffies;
+    netif_wake_queue(dev);
 
-	spin_unlock_irqrestore(&lp->lock, flags);
+    spin_unlock_irqrestore(&lp->lock, flags);
 }
 
 
@@ -1498,21 +1509,22 @@
 	 */
 	status = 0x9300;
     }
-  
+
     /* Fill in a Tx ring entry */
-  
+
     /* Mask to ring buffer boundary. */
     entry = lp->cur_tx & TX_RING_MOD_MASK;
-  
+
     /* Caution: the write order is important here, set the status
-       with the "ownership" bits last. */
+     * with the "ownership" bits last. */
 
     lp->tx_ring[entry].length = le16_to_cpu(-skb->len);
 
     lp->tx_ring[entry].misc = 0x00000000;
 
     lp->tx_skbuff[entry] = skb;
-    lp->tx_dma_addr[entry] = pci_map_single(lp->pci_dev, skb->data, skb->len, PCI_DMA_TODEVICE);
+    lp->tx_dma_addr[entry] = pci_map_single(lp->pci_dev, skb->data, skb->len,
+	    PCI_DMA_TODEVICE);
     lp->tx_ring[entry].base = (u32)le32_to_cpu(lp->tx_dma_addr[entry]);
     wmb(); /* Make sure owner changes after all others are visible */
     lp->tx_ring[entry].status = le16_to_cpu(status);
@@ -1552,9 +1564,9 @@
 
     ioaddr = dev->base_addr;
     lp = dev->priv;
-    
+
     spin_lock(&lp->lock);
-    
+
     rap = lp->a.read_rap(ioaddr);
     while ((csr0 = lp->a.read_csr (ioaddr, 0)) & 0x8600 && --boguscnt >= 0) {
 	if (csr0 == 0xffff) {
@@ -1579,7 +1591,7 @@
 	    while (dirty_tx != lp->cur_tx) {
 		int entry = dirty_tx & TX_RING_MOD_MASK;
 		int status = (short)le16_to_cpu(lp->tx_ring[entry].status);
-			
+
 		if (status < 0)
 		    break;		/* It still hasn't been Txed */
 
@@ -1621,11 +1633,11 @@
 
 		/* We must free the original skb */
 		if (lp->tx_skbuff[entry]) {
-                    pci_unmap_single(lp->pci_dev, lp->tx_dma_addr[entry],
+		    pci_unmap_single(lp->pci_dev, lp->tx_dma_addr[entry],
 			lp->tx_skbuff[entry]->len, PCI_DMA_TODEVICE);
 		    dev_kfree_skb_irq(lp->tx_skbuff[entry]);
 		    lp->tx_skbuff[entry] = 0;
-                    lp->tx_dma_addr[entry] = 0;
+		    lp->tx_dma_addr[entry] = 0;
 		}
 		dirty_tx++;
 	    }
@@ -1654,11 +1666,12 @@
 	    /*
 	     * this happens when our receive ring is full. This shouldn't
 	     * be a problem as we will see normal rx interrupts for the frames
-	     * in the receive ring. But there are some PCI chipsets (I can reproduce
-	     * this on SP3G with Intel saturn chipset) which have sometimes problems
-	     * and will fill up the receive ring with error descriptors. In this
-	     * situation we don't get a rx interrupt, but a missed frame interrupt sooner
-	     * or later. So we try to clean up our receive ring here.
+	     * in the receive ring. But there are some PCI chipsets (I can
+	     * reproduce this on SP3G with Intel saturn chipset) which have
+	     * sometimes problems and will fill up the receive ring with
+	     * error descriptors. In this situation we don't get a rx
+	     * interrupt, but a missed frame interrupt sooner or later.
+	     * So we try to clean up our receive ring here.
 	     */
 	    pcnet32_rx(dev);
 	    lp->stats.rx_errors++; /* Missed a Rx frame. */
@@ -1679,7 +1692,7 @@
     /* Clear any other interrupt, and set interrupt enable. */
     lp->a.write_csr (ioaddr, 0, 0x7940);
     lp->a.write_rap (ioaddr,rap);
-    
+
     if (netif_msg_intr(lp))
 	printk(KERN_DEBUG "%s: exiting interrupt, csr0=%#4.4x.\n",
 	       dev->name, lp->a.read_csr (ioaddr, 0));
@@ -1698,7 +1711,7 @@
 	int status = (short)le16_to_cpu(lp->rx_ring[entry].status) >> 8;
 
 	if (status != 0x03) {			/* There was an error. */
-	    /* 
+	    /*
 	     * There is a tricky error noted by John Murphy,
 	     * <murf@perftech.com> to Russ Nelson: Even with full-sized
 	     * buffers it's possible for a jabber packet to use two
@@ -1715,8 +1728,8 @@
 	    /* Malloc up new buffer, compatible with net-2e. */
 	    short pkt_len = (le32_to_cpu(lp->rx_ring[entry].msg_length) & 0xfff)-4;
 	    struct sk_buff *skb;
-			
-	    if(pkt_len < 60) {
+
+	    if (pkt_len < 60) {
 		printk(KERN_ERR "%s: Runt packet!\n",dev->name);
 		lp->stats.rx_errors++;
 	    } else {
@@ -1724,8 +1737,8 @@
 
 		if (pkt_len > rx_copybreak) {
 		    struct sk_buff *newskb;
-				
-		    if ((newskb = dev_alloc_skb (PKT_BUF_SZ))) {
+
+		    if ((newskb = dev_alloc_skb(PKT_BUF_SZ))) {
 			skb_reserve (newskb, 2);
 			skb = lp->rx_skbuff[entry];
 			pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[entry],
@@ -1733,22 +1746,24 @@
 			skb_put (skb, pkt_len);
 			lp->rx_skbuff[entry] = newskb;
 			newskb->dev = dev;
-                        lp->rx_dma_addr[entry] = 
-				pci_map_single(lp->pci_dev, newskb->tail,
-					PKT_BUF_SZ-2, PCI_DMA_FROMDEVICE);
+			lp->rx_dma_addr[entry] =
+			    pci_map_single(lp->pci_dev, newskb->tail,
+				    PKT_BUF_SZ-2, PCI_DMA_FROMDEVICE);
 			lp->rx_ring[entry].base = le32_to_cpu(lp->rx_dma_addr[entry]);
 			rx_in_place = 1;
 		    } else
 			skb = NULL;
 		} else {
 		    skb = dev_alloc_skb(pkt_len+2);
-                }
-			    
+		}
+
 		if (skb == NULL) {
-                    int i;
-		    printk(KERN_ERR "%s: Memory squeeze, deferring packet.\n", dev->name);
+		    int i;
+		    printk(KERN_ERR "%s: Memory squeeze, deferring packet.\n",
+			    dev->name);
 		    for (i = 0; i < RX_RING_SIZE; i++)
-			if ((short)le16_to_cpu(lp->rx_ring[(entry+i) & RX_RING_MOD_MASK].status) < 0)
+			if ((short)le16_to_cpu(lp->rx_ring[(entry+i)
+				    & RX_RING_MOD_MASK].status) < 0)
 			    break;
 
 		    if (i > RX_RING_SIZE -2) {
@@ -1767,8 +1782,8 @@
 		                        PKT_BUF_SZ-2,
 		                        PCI_DMA_FROMDEVICE);
 		    eth_copy_and_sum(skb,
-				     (unsigned char *)(lp->rx_skbuff[entry]->tail),
-				     pkt_len,0);
+			    (unsigned char *)(lp->rx_skbuff[entry]->tail),
+			    pkt_len,0);
 		}
 		lp->stats.rx_bytes += skb->len;
 		skb->protocol=eth_type_trans(skb,dev);
@@ -1814,7 +1829,7 @@
     lp->a.write_csr (ioaddr, 0, 0x0004);
 
     /*
-     * Switch back to 16bit mode to avoid problems with dumb 
+     * Switch back to 16bit mode to avoid problems with dumb
      * DOS packet driver after a warm reboot
      */
     lp->a.write_bcr (ioaddr, 20, 4);
@@ -1822,28 +1837,29 @@
     spin_unlock_irqrestore(&lp->lock, flags);
 
     free_irq(dev->irq, dev);
-    
+
     /* free all allocated skbuffs */
     for (i = 0; i < RX_RING_SIZE; i++) {
-	lp->rx_ring[i].status = 0;			    
+	lp->rx_ring[i].status = 0;
 	if (lp->rx_skbuff[i]) {
-            pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[i], PKT_BUF_SZ-2,
+	    pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[i], PKT_BUF_SZ-2,
 		    PCI_DMA_FROMDEVICE);
 	    dev_kfree_skb(lp->rx_skbuff[i]);
         }
 	lp->rx_skbuff[i] = NULL;
-        lp->rx_dma_addr[i] = 0;
+	lp->rx_dma_addr[i] = 0;
     }
-    
+
     for (i = 0; i < TX_RING_SIZE; i++) {
 	if (lp->tx_skbuff[i]) {
-            pci_unmap_single(lp->pci_dev, lp->tx_dma_addr[i], lp->tx_skbuff[i]->len, PCI_DMA_TODEVICE);
+	    pci_unmap_single(lp->pci_dev, lp->tx_dma_addr[i],
+		    lp->tx_skbuff[i]->len, PCI_DMA_TODEVICE);
 	    dev_kfree_skb(lp->tx_skbuff[i]);
-        }
+	}
 	lp->tx_skbuff[i] = NULL;
-        lp->tx_dma_addr[i] = 0;
+	lp->tx_dma_addr[i] = 0;
     }
-    
+
     return 0;
 }
 
@@ -1874,9 +1890,9 @@
     char *addrs;
     int i;
     u32 crc;
-	
+
     /* set all multicast bits */
-    if (dev->flags & IFF_ALLMULTI){ 
+    if (dev->flags & IFF_ALLMULTI) {
 	ib->filter[0] = 0xffffffff;
 	ib->filter[1] = 0xffffffff;
 	return;
@@ -1886,19 +1902,18 @@
     ib->filter[1] = 0;
 
     /* Add addresses */
-    for (i = 0; i < dev->mc_count; i++){
+    for (i = 0; i < dev->mc_count; i++) {
 	addrs = dmi->dmi_addr;
 	dmi   = dmi->next;
-	
+
 	/* multicast address? */
 	if (!(*addrs & 1))
 	    continue;
-	
+
 	crc = ether_crc_le(6, addrs);
 	crc = crc >> 26;
 	mcast_table [crc >> 4] = le16_to_cpu(
-		le16_to_cpu(mcast_table [crc >> 4]) | (1 << (crc & 0xf))
-	);
+		le16_to_cpu(mcast_table [crc >> 4]) | (1 << (crc & 0xf)));
     }
     return;
 }
@@ -1910,7 +1925,7 @@
 static void pcnet32_set_multicast_list(struct net_device *dev)
 {
     unsigned long ioaddr = dev->base_addr, flags;
-    struct pcnet32_private *lp = dev->priv;	 
+    struct pcnet32_private *lp = dev->priv;
 
     spin_lock_irqsave(&lp->lock, flags);
     if (dev->flags&IFF_PROMISC) {
@@ -1921,7 +1936,7 @@
 	lp->init_block.mode = le16_to_cpu((lp->options & PCNET32_PORT_PORTSEL) << 7);
 	pcnet32_load_multicast (dev);
     }
-    
+
     lp->a.write_csr (ioaddr, 0, 0x0004); /* Temporarily stop the lance. */
 
     pcnet32_restart(dev, 0x0042); /*  Resume normal operation */
@@ -1930,42 +1945,42 @@
 
 static int mdio_read(struct net_device *dev, int phy_id, int reg_num)
 {
-	struct pcnet32_private *lp = dev->priv;
-	unsigned long ioaddr = dev->base_addr;
-	u16 val_out;
-	int phyaddr;
-
-	if (!lp->mii)
-		return 0;
-		
-	phyaddr = lp->a.read_bcr(ioaddr, 33);
-
-	lp->a.write_bcr(ioaddr, 33, ((phy_id & 0x1f) << 5) | (reg_num & 0x1f));
-	val_out = lp->a.read_bcr(ioaddr, 34);
-	lp->a.write_bcr(ioaddr, 33, phyaddr);
-	
-	return val_out;
+    struct pcnet32_private *lp = dev->priv;
+    unsigned long ioaddr = dev->base_addr;
+    u16 val_out;
+    int phyaddr;
+
+    if (!lp->mii)
+	return 0;
+
+    phyaddr = lp->a.read_bcr(ioaddr, 33);
+
+    lp->a.write_bcr(ioaddr, 33, ((phy_id & 0x1f) << 5) | (reg_num & 0x1f));
+    val_out = lp->a.read_bcr(ioaddr, 34);
+    lp->a.write_bcr(ioaddr, 33, phyaddr);
+
+    return val_out;
 }
 
 static void mdio_write(struct net_device *dev, int phy_id, int reg_num, int val)
 {
-	struct pcnet32_private *lp = dev->priv;
-	unsigned long ioaddr = dev->base_addr;
-	int phyaddr;
+    struct pcnet32_private *lp = dev->priv;
+    unsigned long ioaddr = dev->base_addr;
+    int phyaddr;
 
-	if (!lp->mii)
-		return;
-		
-	phyaddr = lp->a.read_bcr(ioaddr, 33);
-
-	lp->a.write_bcr(ioaddr, 33, ((phy_id & 0x1f) << 5) | (reg_num & 0x1f));
-	lp->a.write_bcr(ioaddr, 34, val);
-	lp->a.write_bcr(ioaddr, 33, phyaddr);
+    if (!lp->mii)
+	return;
+
+    phyaddr = lp->a.read_bcr(ioaddr, 33);
+
+    lp->a.write_bcr(ioaddr, 33, ((phy_id & 0x1f) << 5) | (reg_num & 0x1f));
+    lp->a.write_bcr(ioaddr, 34, val);
+    lp->a.write_bcr(ioaddr, 33, phyaddr);
 }
 
 static int pcnet32_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-    struct pcnet32_private *lp = dev->priv;	 
+    struct pcnet32_private *lp = dev->priv;
     struct mii_ioctl_data *data = (struct mii_ioctl_data *)&rq->ifr_data;
     int rc;
     unsigned long flags;
@@ -2022,15 +2037,15 @@
 MODULE_PARM(debug, "i");
 MODULE_PARM_DESC(debug, DRV_NAME " debug level");
 MODULE_PARM(max_interrupt_work, "i");
-MODULE_PARM_DESC(max_interrupt_work, DRV_NAME " maximum events handled per interrupt");  
+MODULE_PARM_DESC(max_interrupt_work, DRV_NAME " maximum events handled per interrupt");
 MODULE_PARM(rx_copybreak, "i");
-MODULE_PARM_DESC(rx_copybreak, DRV_NAME " copy breakpoint for copy-only-tiny-frames"); 
+MODULE_PARM_DESC(rx_copybreak, DRV_NAME " copy breakpoint for copy-only-tiny-frames");
 MODULE_PARM(tx_start_pt, "i");
-MODULE_PARM_DESC(tx_start_pt, DRV_NAME " transmit start point (0-3)"); 
+MODULE_PARM_DESC(tx_start_pt, DRV_NAME " transmit start point (0-3)");
 MODULE_PARM(pcnet32vlb, "i");
-MODULE_PARM_DESC(pcnet32vlb, DRV_NAME " Vesa local bus (VLB) support (0/1)"); 
+MODULE_PARM_DESC(pcnet32vlb, DRV_NAME " Vesa local bus (VLB) support (0/1)");
 MODULE_PARM(options, "1-" __MODULE_STRING(MAX_UNITS) "i");
-MODULE_PARM_DESC(options, DRV_NAME " initial option setting(s) (0-15)"); 
+MODULE_PARM_DESC(options, DRV_NAME " initial option setting(s) (0-15)");
 MODULE_PARM(full_duplex, "1-" __MODULE_STRING(MAX_UNITS) "i");
 MODULE_PARM_DESC(full_duplex, DRV_NAME " full duplex setting(s) (1)");
 
@@ -2063,7 +2078,7 @@
 
     if (cards_found)
 	printk(KERN_INFO PFX "%d cards_found.\n", cards_found);
-    
+
     return (pcnet32_have_pci + cards_found) ? 0 : -ENODEV;
 }
 
@@ -2071,7 +2086,6 @@
 {
     struct net_device *next_dev;
 
-    /* No need to check MOD_IN_USE, as sys_delete_module() checks. */
     while (pcnet32_dev) {
 	struct pcnet32_private *lp = pcnet32_dev->priv;
 	next_dev = lp->next;
@@ -2081,6 +2095,7 @@
 	free_netdev(pcnet32_dev);
 	pcnet32_dev = next_dev;
     }
+
     if (pcnet32_have_pci)
 	pci_unregister_driver(&pcnet32_driver);
 }

-- 
Don Fry
brazilnut@us.ibm.com
