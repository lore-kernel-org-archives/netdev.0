From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/9] ax88796: fix codingstyle and checkpatch warnings
Date: Mon, 21 Feb 2011 14:03:12 +0100
Message-ID: <1298293400-21570-2-git-send-email-mkl@pengutronix.de>
References: <1298293400-21570-1-git-send-email-mkl@pengutronix.de>
Cc: Ben Dooks <ben@fluff.org>, Daniel Mack <daniel@caiaq.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35843 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755782Ab1BUND3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 08:03:29 -0500
In-Reply-To: <1298293400-21570-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/ax88796.c |  262 +++++++++++++++++++++++++------------------------
 1 files changed, 134 insertions(+), 128 deletions(-)

diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index 4bebff3..6d1d5ca 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -9,7 +9,7 @@
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
-*/
+ */
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -17,6 +17,7 @@
 #include <linux/isapnp.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
+#include <linux/io.h>
 #include <linux/platform_device.h>
 #include <linux/delay.h>
 #include <linux/timer.h>
@@ -30,33 +31,32 @@
 #include <net/ax88796.h>
 
 #include <asm/system.h>
-#include <asm/io.h>
 
-static int phy_debug = 0;
+static int phy_debug;
 
 /* Rename the lib8390.c functions to show that they are in this driver */
-#define __ei_open       ax_ei_open
-#define __ei_close      ax_ei_close
-#define __ei_poll	ax_ei_poll
+#define __ei_open ax_ei_open
+#define __ei_close ax_ei_close
+#define __ei_poll ax_ei_poll
 #define __ei_start_xmit ax_ei_start_xmit
 #define __ei_tx_timeout ax_ei_tx_timeout
-#define __ei_get_stats  ax_ei_get_stats
+#define __ei_get_stats ax_ei_get_stats
 #define __ei_set_multicast_list ax_ei_set_multicast_list
-#define __ei_interrupt  ax_ei_interrupt
+#define __ei_interrupt ax_ei_interrupt
 #define ____alloc_ei_netdev ax__alloc_ei_netdev
-#define __NS8390_init   ax_NS8390_init
+#define __NS8390_init ax_NS8390_init
 
 /* force unsigned long back to 'void __iomem *' */
 #define ax_convert_addr(_a) ((void __force __iomem *)(_a))
 
-#define ei_inb(_a)	readb(ax_convert_addr(_a))
+#define ei_inb(_a) readb(ax_convert_addr(_a))
 #define ei_outb(_v, _a) writeb(_v, ax_convert_addr(_a))
 
-#define ei_inb_p(_a)	ei_inb(_a)
+#define ei_inb_p(_a) ei_inb(_a)
 #define ei_outb_p(_v, _a) ei_outb(_v, _a)
 
 /* define EI_SHIFT() to take into account our register offsets */
-#define EI_SHIFT(x)     (ei_local->reg_offset[(x)])
+#define EI_SHIFT(x) (ei_local->reg_offset[(x)])
 
 /* Ensure we have our RCR base value */
 #define AX88796_PLATFORM
@@ -74,43 +74,43 @@ static unsigned char version[] = "ax88796.c: Copyright 2005,2007 Simtec Electron
 #define NE_DATAPORT	EI_SHIFT(0x10)
 
 #define NE1SM_START_PG	0x20	/* First page of TX buffer */
-#define NE1SM_STOP_PG 	0x40	/* Last page +1 of RX ring */
+#define NE1SM_STOP_PG	0x40	/* Last page +1 of RX ring */
 #define NESM_START_PG	0x40	/* First page of TX buffer */
 #define NESM_STOP_PG	0x80	/* Last page +1 of RX ring */
 
 /* device private data */
 
 struct ax_device {
-	struct timer_list	 mii_timer;
-	spinlock_t		 mii_lock;
-	struct mii_if_info	 mii;
-
-	u32			 msg_enable;
-	void __iomem		*map2;
-	struct platform_device	*dev;
-	struct resource		*mem;
-	struct resource		*mem2;
-	struct ax_plat_data	*plat;
-
-	unsigned char		 running;
-	unsigned char		 resume_open;
-	unsigned int		 irqflags;
-
-	u32			 reg_offsets[0x20];
+	struct timer_list mii_timer;
+	spinlock_t mii_lock;
+	struct mii_if_info mii;
+
+	u32 msg_enable;
+	void __iomem *map2;
+	struct platform_device *dev;
+	struct resource *mem;
+	struct resource *mem2;
+	struct ax_plat_data *plat;
+
+	unsigned char running;
+	unsigned char resume_open;
+	unsigned int irqflags;
+
+	u32 reg_offsets[0x20];
 };
 
 static inline struct ax_device *to_ax_dev(struct net_device *dev)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
-	return (struct ax_device *)(ei_local+1);
+	return (struct ax_device *)(ei_local + 1);
 }
 
-/* ax_initial_check
+/*
+ * ax_initial_check
  *
  * do an initial probe for the card to check wether it exists
  * and is functional
  */
-
 static int ax_initial_check(struct net_device *dev)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
@@ -122,10 +122,10 @@ static int ax_initial_check(struct net_device *dev)
 	if (reg0 == 0xFF)
 		return -ENODEV;
 
-	ei_outb(E8390_NODMA+E8390_PAGE1+E8390_STOP, ioaddr + E8390_CMD);
+	ei_outb(E8390_NODMA + E8390_PAGE1 + E8390_STOP, ioaddr + E8390_CMD);
 	regd = ei_inb(ioaddr + 0x0d);
 	ei_outb(0xff, ioaddr + 0x0d);
-	ei_outb(E8390_NODMA+E8390_PAGE0, ioaddr + E8390_CMD);
+	ei_outb(E8390_NODMA + E8390_PAGE0, ioaddr + E8390_CMD);
 	ei_inb(ioaddr + EN0_COUNTER0); /* Clear the counter by reading. */
 	if (ei_inb(ioaddr + EN0_COUNTER0) != 0) {
 		ei_outb(reg0, ioaddr);
@@ -136,13 +136,14 @@ static int ax_initial_check(struct net_device *dev)
 	return 0;
 }
 
-/* Hard reset the card.  This used to pause for the same period that a
-   8390 reset command required, but that shouldn't be necessary. */
-
+/*
+ * Hard reset the card. This used to pause for the same period that a
+ * 8390 reset command required, but that shouldn't be necessary.
+ */
 static void ax_reset_8390(struct net_device *dev)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
-	struct ax_device  *ax = to_ax_dev(dev);
+	struct ax_device *ax = to_ax_dev(dev);
 	unsigned long reset_start_time = jiffies;
 	void __iomem *addr = (void __iomem *)dev->base_addr;
 
@@ -156,7 +157,7 @@ static void ax_reset_8390(struct net_device *dev)
 
 	/* This check _should_not_ be necessary, omit eventually. */
 	while ((ei_inb(addr + EN0_ISR) & ENISR_RESET) == 0) {
-		if (jiffies - reset_start_time > 2*HZ/100) {
+		if (jiffies - reset_start_time > 2 * HZ / 100) {
 			dev_warn(&ax->dev->dev, "%s: %s did not complete.\n",
 			       __func__, dev->name);
 			break;
@@ -171,7 +172,7 @@ static void ax_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr,
 			    int ring_page)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
-	struct ax_device  *ax = to_ax_dev(dev);
+	struct ax_device *ax = to_ax_dev(dev);
 	void __iomem *nic_base = ei_local->mem;
 
 	/* This *shouldn't* happen. If it does, it's the last thing you'll see */
@@ -184,7 +185,7 @@ static void ax_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr,
 	}
 
 	ei_status.dmaing |= 0x01;
-	ei_outb(E8390_NODMA+E8390_PAGE0+E8390_START, nic_base+ NE_CMD);
+	ei_outb(E8390_NODMA + E8390_PAGE0 + E8390_START, nic_base + NE_CMD);
 	ei_outb(sizeof(struct e8390_pkt_hdr), nic_base + EN0_RCNTLO);
 	ei_outb(0, nic_base + EN0_RCNTHI);
 	ei_outb(0, nic_base + EN0_RSARLO);		/* On page boundary */
@@ -192,9 +193,11 @@ static void ax_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr,
 	ei_outb(E8390_RREAD+E8390_START, nic_base + NE_CMD);
 
 	if (ei_status.word16)
-		readsw(nic_base + NE_DATAPORT, hdr, sizeof(struct e8390_pkt_hdr)>>1);
+		readsw(nic_base + NE_DATAPORT, hdr,
+		       sizeof(struct e8390_pkt_hdr) >> 1);
 	else
-		readsb(nic_base + NE_DATAPORT, hdr, sizeof(struct e8390_pkt_hdr));
+		readsb(nic_base + NE_DATAPORT, hdr,
+		       sizeof(struct e8390_pkt_hdr));
 
 	ei_outb(ENISR_RDC, nic_base + EN0_ISR);	/* Ack intr. */
 	ei_status.dmaing &= ~0x01;
@@ -203,16 +206,18 @@ static void ax_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr,
 }
 
 
-/* Block input and output, similar to the Crynwr packet driver.  If you
-   are porting to a new ethercard, look at the packet driver source for hints.
-   The NEx000 doesn't share the on-board packet memory -- you have to put
-   the packet out through the "remote DMA" dataport using ei_outb. */
-
+/*
+ * Block input and output, similar to the Crynwr packet driver. If
+ * you are porting to a new ethercard, look at the packet driver
+ * source for hints. The NEx000 doesn't share the on-board packet
+ * memory -- you have to put the packet out through the "remote DMA"
+ * dataport using ei_outb.
+ */
 static void ax_block_input(struct net_device *dev, int count,
 			   struct sk_buff *skb, int ring_offset)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
-	struct ax_device  *ax = to_ax_dev(dev);
+	struct ax_device *ax = to_ax_dev(dev);
 	void __iomem *nic_base = ei_local->mem;
 	char *buf = skb->data;
 
@@ -227,7 +232,7 @@ static void ax_block_input(struct net_device *dev, int count,
 
 	ei_status.dmaing |= 0x01;
 
-	ei_outb(E8390_NODMA+E8390_PAGE0+E8390_START, nic_base+ NE_CMD);
+	ei_outb(E8390_NODMA+E8390_PAGE0+E8390_START, nic_base + NE_CMD);
 	ei_outb(count & 0xff, nic_base + EN0_RCNTLO);
 	ei_outb(count >> 8, nic_base + EN0_RCNTHI);
 	ei_outb(ring_offset & 0xff, nic_base + EN0_RSARLO);
@@ -250,14 +255,15 @@ static void ax_block_output(struct net_device *dev, int count,
 			    const unsigned char *buf, const int start_page)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
-	struct ax_device  *ax = to_ax_dev(dev);
+	struct ax_device *ax = to_ax_dev(dev);
 	void __iomem *nic_base = ei_local->mem;
 	unsigned long dma_start;
 
-	/* Round the count up for word writes.  Do we need to do this?
-	   What effect will an odd byte count have on the 8390?
-	   I should check someday. */
-
+	/*
+	 * Round the count up for word writes. Do we need to do this?
+	 * What effect will an odd byte count have on the 8390?  I
+	 * should check someday.
+	 */
 	if (ei_status.word16 && (count & 0x01))
 		count++;
 
@@ -278,25 +284,24 @@ static void ax_block_output(struct net_device *dev, int count,
 
 	/* Now the normal output. */
 	ei_outb(count & 0xff, nic_base + EN0_RCNTLO);
-	ei_outb(count >> 8,   nic_base + EN0_RCNTHI);
+	ei_outb(count >> 8, nic_base + EN0_RCNTHI);
 	ei_outb(0x00, nic_base + EN0_RSARLO);
 	ei_outb(start_page, nic_base + EN0_RSARHI);
 
 	ei_outb(E8390_RWRITE+E8390_START, nic_base + NE_CMD);
-	if (ei_status.word16) {
-		writesw(nic_base + NE_DATAPORT, buf, count>>1);
-	} else {
+	if (ei_status.word16)
+		writesw(nic_base + NE_DATAPORT, buf, count >> 1);
+	else
 		writesb(nic_base + NE_DATAPORT, buf, count);
-	}
 
 	dma_start = jiffies;
 
 	while ((ei_inb(nic_base + EN0_ISR) & ENISR_RDC) == 0) {
-		if (jiffies - dma_start > 2*HZ/100) {		/* 20ms */
+		if (jiffies - dma_start > 2 * HZ / 100) {		/* 20ms */
 			dev_warn(&ax->dev->dev,
 				 "%s: timeout waiting for Tx RDC.\n", dev->name);
 			ax_reset_8390(dev);
-			ax_NS8390_init(dev,1);
+			ax_NS8390_init(dev, 1);
 			break;
 		}
 	}
@@ -308,20 +313,20 @@ static void ax_block_output(struct net_device *dev, int count,
 /* definitions for accessing MII/EEPROM interface */
 
 #define AX_MEMR			EI_SHIFT(0x14)
-#define AX_MEMR_MDC		(1<<0)
-#define AX_MEMR_MDIR		(1<<1)
-#define AX_MEMR_MDI		(1<<2)
-#define AX_MEMR_MDO		(1<<3)
-#define AX_MEMR_EECS		(1<<4)
-#define AX_MEMR_EEI		(1<<5)
-#define AX_MEMR_EEO		(1<<6)
-#define AX_MEMR_EECLK		(1<<7)
-
-/* ax_mii_ei_outbits
+#define AX_MEMR_MDC		BIT(0)
+#define AX_MEMR_MDIR		BIT(1)
+#define AX_MEMR_MDI		BIT(2)
+#define AX_MEMR_MDO		BIT(3)
+#define AX_MEMR_EECS		BIT(4)
+#define AX_MEMR_EEI		BIT(5)
+#define AX_MEMR_EEO		BIT(6)
+#define AX_MEMR_EECLK		BIT(7)
+
+/*
+ * ax_mii_ei_outbits
  *
  * write the specified set of bits to the phy
-*/
-
+ */
 static void
 ax_mii_ei_outbits(struct net_device *dev, unsigned int bits, int len)
 {
@@ -356,11 +361,11 @@ ax_mii_ei_outbits(struct net_device *dev, unsigned int bits, int len)
 	ei_outb(memr, (void __iomem *)dev->base_addr + AX_MEMR);
 }
 
-/* ax_phy_ei_inbits
+/*
+ * ax_phy_ei_inbits
  *
  * read a specified number of bits from the phy
-*/
-
+ */
 static unsigned int
 ax_phy_ei_inbits(struct net_device *dev, int no)
 {
@@ -381,7 +386,7 @@ ax_phy_ei_inbits(struct net_device *dev, int no)
 		udelay(1);
 
 		if (ei_inb(memr_addr) & AX_MEMR_MDI)
-			result |= (1<<no);
+			result |= (1 << no);
 
 		ei_outb(memr, memr_addr);
 	}
@@ -389,12 +394,12 @@ ax_phy_ei_inbits(struct net_device *dev, int no)
 	return result;
 }
 
-/* ax_phy_issueaddr
+/*
+ * ax_phy_issueaddr
  *
  * use the low level bit shifting routines to send the address
  * and command to the specified phy
-*/
-
+ */
 static void
 ax_phy_issueaddr(struct net_device *dev, int phy_addr, int reg, int opc)
 {
@@ -414,16 +419,16 @@ ax_phy_read(struct net_device *dev, int phy_addr, int reg)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
 	unsigned long flags;
- 	unsigned int result;
+	unsigned int result;
 
-      	spin_lock_irqsave(&ei_local->page_lock, flags);
+	spin_lock_irqsave(&ei_local->page_lock, flags);
 
 	ax_phy_issueaddr(dev, phy_addr, reg, 2);
 
 	result = ax_phy_ei_inbits(dev, 17);
-	result &= ~(3<<16);
+	result &= ~(3 << 16);
 
-      	spin_unlock_irqrestore(&ei_local->page_lock, flags);
+	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 
 	if (phy_debug)
 		pr_debug("%s: %04x.%04x => read %04x\n", __func__,
@@ -436,25 +441,25 @@ static void
 ax_phy_write(struct net_device *dev, int phy_addr, int reg, int value)
 {
 	struct ei_device *ei = netdev_priv(dev);
-	struct ax_device  *ax = to_ax_dev(dev);
+	struct ax_device *ax = to_ax_dev(dev);
 	unsigned long flags;
 
 	dev_dbg(&ax->dev->dev, "%s: %p, %04x, %04x %04x\n",
 		__func__, dev, phy_addr, reg, value);
 
-      	spin_lock_irqsave(&ei->page_lock, flags);
+	spin_lock_irqsave(&ei->page_lock, flags);
 
 	ax_phy_issueaddr(dev, phy_addr, reg, 1);
 	ax_mii_ei_outbits(dev, 2, 2);		/* send TA */
 	ax_mii_ei_outbits(dev, value, 16);
 
-      	spin_unlock_irqrestore(&ei->page_lock, flags);
+	spin_unlock_irqrestore(&ei->page_lock, flags);
 }
 
 static void ax_mii_expiry(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct ax_device  *ax = to_ax_dev(dev);
+	struct ax_device *ax = to_ax_dev(dev);
 	unsigned long flags;
 
 	spin_lock_irqsave(&ax->mii_lock, flags);
@@ -469,7 +474,7 @@ static void ax_mii_expiry(unsigned long data)
 
 static int ax_open(struct net_device *dev)
 {
-	struct ax_device  *ax = to_ax_dev(dev);
+	struct ax_device *ax = to_ax_dev(dev);
 	struct ei_device *ei_local = netdev_priv(dev);
 	int ret;
 
@@ -495,8 +500,8 @@ static int ax_open(struct net_device *dev)
 
 	init_timer(&ax->mii_timer);
 
-	ax->mii_timer.expires  = jiffies+1;
-	ax->mii_timer.data     = (unsigned long) dev;
+	ax->mii_timer.expires = jiffies + 1;
+	ax->mii_timer.data = (unsigned long) dev;
 	ax->mii_timer.function = ax_mii_expiry;
 
 	add_timer(&ax->mii_timer);
@@ -513,7 +518,7 @@ static int ax_close(struct net_device *dev)
 
 	/* turn the phy off */
 
-	ei_outb(ax->plat->gpoc_val | (1<<6),
+	ei_outb(ax->plat->gpoc_val | (1 << 6),
 	       ei_local->mem + EI_SHIFT(0x17));
 
 	ax->running = 0;
@@ -640,7 +645,7 @@ static const struct net_device_ops ax_netdev_ops = {
 	.ndo_get_stats		= ax_ei_get_stats,
 	.ndo_set_multicast_list = ax_ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ax_ei_poll,
@@ -654,22 +659,22 @@ static void ax_initial_setup(struct net_device *dev, struct ei_device *ei_local)
 	void __iomem *ioaddr = ei_local->mem;
 	struct ax_device *ax = to_ax_dev(dev);
 
-	/* Select page 0*/
-	ei_outb(E8390_NODMA+E8390_PAGE0+E8390_STOP, ioaddr + E8390_CMD);
+	/* Select page 0 */
+	ei_outb(E8390_NODMA + E8390_PAGE0 + E8390_STOP, ioaddr + E8390_CMD);
 
 	/* set to byte access */
 	ei_outb(ax->plat->dcr_val & ~1, ioaddr + EN0_DCFG);
 	ei_outb(ax->plat->gpoc_val, ioaddr + EI_SHIFT(0x17));
 }
 
-/* ax_init_dev
+/*
+ * ax_init_dev
  *
  * initialise the specified device, taking care to note the MAC
  * address it may already have (if configured), ensure
  * the device is ready to be used by lib8390.c and registerd with
  * the network layer.
  */
-
 static int ax_init_dev(struct net_device *dev, int first_init)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
@@ -693,16 +698,16 @@ static int ax_init_dev(struct net_device *dev, int first_init)
 	if (first_init && ax->plat->flags & AXFLG_HAS_EEPROM) {
 		unsigned char SA_prom[32];
 
-		for(i = 0; i < sizeof(SA_prom); i+=2) {
+		for (i = 0; i < sizeof(SA_prom); i += 2) {
 			SA_prom[i] = ei_inb(ioaddr + NE_DATAPORT);
-			SA_prom[i+1] = ei_inb(ioaddr + NE_DATAPORT);
+			SA_prom[i + 1] = ei_inb(ioaddr + NE_DATAPORT);
 		}
 
 		if (ax->plat->wordlength == 2)
 			for (i = 0; i < 16; i++)
 				SA_prom[i] = SA_prom[i+i];
 
-		memcpy(dev->dev_addr,  SA_prom, 6);
+		memcpy(dev->dev_addr, SA_prom, 6);
 	}
 
 #ifdef CONFIG_AX88796_93CX6
@@ -719,7 +724,7 @@ static int ax_init_dev(struct net_device *dev, int first_init)
 				       (__le16 __force *)mac_addr,
 				       sizeof(mac_addr) >> 1);
 
-		memcpy(dev->dev_addr,  mac_addr, 6);
+		memcpy(dev->dev_addr, mac_addr, 6);
 	}
 #endif
 	if (ax->plat->wordlength == 2) {
@@ -732,9 +737,10 @@ static int ax_init_dev(struct net_device *dev, int first_init)
 		stop_page = NE1SM_STOP_PG;
 	}
 
-	/* load the mac-address from the device if this is the
-	 * first time we've initialised */
-
+	/*
+	 * load the mac-address from the device if this is the first
+	 * time we've initialised
+	 */
 	if (first_init) {
 		if (ax->plat->flags & AXFLG_MAC_FROMDEV) {
 			ei_outb(E8390_NODMA + E8390_PAGE1 + E8390_STOP,
@@ -759,7 +765,7 @@ static int ax_init_dev(struct net_device *dev, int first_init)
 	ei_status.rx_start_page = start_page + TX_PAGES;
 
 #ifdef PACKETBUF_MEMSIZE
-	 /* Allow the packet buffer size to be overridden by know-it-alls. */
+	/* Allow the packet buffer size to be overridden by know-it-alls. */
 	ei_status.stop_page = ei_status.tx_start_page + PACKETBUF_MEMSIZE;
 #endif
 
@@ -769,8 +775,8 @@ static int ax_init_dev(struct net_device *dev, int first_init)
 	ei_status.get_8390_hdr	= &ax_get_8390_hdr;
 	ei_status.priv = 0;
 
-	dev->netdev_ops		= &ax_netdev_ops;
-	dev->ethtool_ops	= &ax_ethtool_ops;
+	dev->netdev_ops = &ax_netdev_ops;
+	dev->ethtool_ops = &ax_ethtool_ops;
 
 	ax->msg_enable		= NETIF_MSG_LINK;
 	ax->mii.phy_id_mask	= 0x1f;
@@ -786,7 +792,7 @@ static int ax_init_dev(struct net_device *dev, int first_init)
 
 	if (first_init)
 		dev_info(&ax->dev->dev, "%dbit, irq %d, %lx, MAC: %pM\n",
-			 ei_status.word16 ? 16:8, dev->irq, dev->base_addr,
+			 ei_status.word16 ? 16 : 8, dev->irq, dev->base_addr,
 			 dev->dev_addr);
 
 	ret = register_netdev(dev);
@@ -805,7 +811,7 @@ static int ax_init_dev(struct net_device *dev, int first_init)
 static int ax_remove(struct platform_device *_dev)
 {
 	struct net_device *dev = platform_get_drvdata(_dev);
-	struct ax_device  *ax;
+	struct ax_device *ax;
 
 	ax = to_ax_dev(dev);
 
@@ -827,18 +833,18 @@ static int ax_remove(struct platform_device *_dev)
 	return 0;
 }
 
-/* ax_probe
+/*
+ * ax_probe
  *
  * This is the entry point when the platform device system uses to
- * notify us of a new device to attach to. Allocate memory, find
- * the resources and information passed, and map the necessary registers.
-*/
-
+ * notify us of a new device to attach to. Allocate memory, find the
+ * resources and information passed, and map the necessary registers.
+ */
 static int ax_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
-	struct ax_device  *ax;
-	struct resource   *res;
+	struct ax_device *ax;
+	struct resource *res;
 	size_t size;
 	int ret = 0;
 
@@ -857,10 +863,9 @@ static int ax_probe(struct platform_device *pdev)
 	ax->plat = pdev->dev.platform_data;
 	platform_set_drvdata(pdev, dev);
 
-	ei_status.rxcr_base  = ax->plat->rcr_val;
+	ei_status.rxcr_base = ax->plat->rcr_val;
 
 	/* find the platform resources */
-
 	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
 	if (res == NULL) {
 		dev_err(&pdev->dev, "no IRQ specified\n");
@@ -880,9 +885,10 @@ static int ax_probe(struct platform_device *pdev)
 
 	size = (res->end - res->start) + 1;
 
-	/* setup the register offsets from either the platform data
-	 * or by using the size of the resource provided */
-
+	/*
+	 * setup the register offsets from either the platform data or
+	 * by using the size of the resource provided
+	 */
 	if (ax->plat->reg_offsets)
 		ei_status.reg_offset = ax->plat->reg_offsets;
 	else {
@@ -894,7 +900,7 @@ static int ax_probe(struct platform_device *pdev)
 	ax->mem = request_mem_region(res->start, size, pdev->name);
 	if (ax->mem == NULL) {
 		dev_err(&pdev->dev, "cannot reserve registers\n");
- 		ret = -ENXIO;
+		ret = -ENXIO;
 		goto exit_mem;
 	}
 
@@ -906,7 +912,7 @@ static int ax_probe(struct platform_device *pdev)
 			(unsigned long long)res->start,
 			(unsigned long long)res->end);
 
- 		ret = -ENXIO;
+		ret = -ENXIO;
 		goto exit_req;
 	}
 
@@ -921,7 +927,7 @@ static int ax_probe(struct platform_device *pdev)
 
 		ax->map2 = NULL;
 	} else {
- 		size = (res->end - res->start) + 1;
+		size = (res->end - res->start) + 1;
 
 		ax->mem2 = request_mem_region(res->start, size, pdev->name);
 		if (ax->mem2 == NULL) {
@@ -974,7 +980,7 @@ static int ax_probe(struct platform_device *pdev)
 static int ax_suspend(struct platform_device *dev, pm_message_t state)
 {
 	struct net_device *ndev = platform_get_drvdata(dev);
-	struct ax_device  *ax = to_ax_dev(ndev);
+	struct ax_device *ax = to_ax_dev(ndev);
 
 	ax->resume_open = ax->running;
 
@@ -987,7 +993,7 @@ static int ax_suspend(struct platform_device *dev, pm_message_t state)
 static int ax_resume(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
-	struct ax_device  *ax = to_ax_dev(ndev);
+	struct ax_device *ax = to_ax_dev(ndev);
 
 	ax_initial_setup(ndev, netdev_priv(ndev));
 	ax_NS8390_init(ndev, ax->resume_open);
@@ -1001,7 +1007,7 @@ static int ax_resume(struct platform_device *pdev)
 
 #else
 #define ax_suspend NULL
-#define ax_resume  NULL
+#define ax_resume NULL
 #endif
 
 static struct platform_driver axdrv = {
-- 
1.7.2.3

