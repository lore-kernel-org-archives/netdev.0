From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/8] irda: w83977af_ir: whitespace neatening
Date: Thu, 24 Nov 2016 11:10:28 -0800
Message-ID: <b75250741ff441e848311cec135b7412a3184264.1480014088.git.joe@perches.com>
References: <cover.1480014088.git.joe@perches.com>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1480014088.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove leading and trailing whitespace.
git diff -w shows no differences.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/irda/w83977af_ir.c | 392 ++++++++++++++++++++---------------------
 1 file changed, 196 insertions(+), 196 deletions(-)

diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index e8c3a8c32534..98333aba7404 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -1,5 +1,5 @@
 /*********************************************************************
- *                
+ *
  * Filename:      w83977af_ir.c
  * Version:       1.0
  * Description:   FIR driver for the Winbond W83977AF Super I/O chip
@@ -8,31 +8,31 @@
  * Created at:    Wed Nov  4 11:46:16 1998
  * Modified at:   Fri Jan 28 12:10:59 2000
  * Modified by:   Dag Brattli <dagb@cs.uit.no>
- * 
+ *
  *     Copyright (c) 1998-2000 Dag Brattli <dagb@cs.uit.no>
  *     Copyright (c) 1998-1999 Rebel.com
- *      
- *     This program is free software; you can redistribute it and/or 
- *     modify it under the terms of the GNU General Public License as 
- *     published by the Free Software Foundation; either version 2 of 
+ *
+ *     This program is free software; you can redistribute it and/or
+ *     modify it under the terms of the GNU General Public License as
+ *     published by the Free Software Foundation; either version 2 of
  *     the License, or (at your option) any later version.
- *  
+ *
  *     Neither Paul VanderSpek nor Rebel.com admit liability nor provide
  *     warranty for any of this software. This material is provided "AS-IS"
  *     and at no charge.
- *     
+ *
  *     If you find bugs in this file, its very likely that the same bug
  *     will also be in pc87108.c since the implementations are quite
  *     similar.
  *
  *     Notice that all functions that needs to access the chip in _any_
- *     way, must save BSR register on entry, and restore it on exit. 
+ *     way, must save BSR register on entry, and restore it on exit.
  *     It is _very_ important to follow this policy!
  *
  *         __u8 bank;
- *     
+ *
  *         bank = inb( iobase+BSR);
- *  
+ *
  *         do_your_stuff_here();
  *
  *         outb( bank, iobase+BSR);
@@ -63,7 +63,7 @@
 #include "w83977af_ir.h"
 
 #define CONFIG_USE_W977_PNP        /* Currently needed */
-#define PIO_MAX_SPEED       115200 
+#define PIO_MAX_SPEED       115200
 
 static char *driver_name = "w83977af_ir";
 static int  qos_mtt_bits = 0x07;   /* 1 ms or more */
@@ -83,11 +83,11 @@ static unsigned int efio = W977_EFIO_BASE;
 static struct w83977af_ir *dev_self[] = { NULL, NULL, NULL, NULL};
 
 /* Some prototypes */
-static int  w83977af_open(int i, unsigned int iobase, unsigned int irq, 
-                          unsigned int dma);
+static int  w83977af_open(int i, unsigned int iobase, unsigned int irq,
+			  unsigned int dma);
 static int  w83977af_close(struct w83977af_ir *self);
 static int  w83977af_probe(int iobase, int irq, int dma);
-static int  w83977af_dma_receive(struct w83977af_ir *self); 
+static int  w83977af_dma_receive(struct w83977af_ir *self);
 static int  w83977af_dma_receive_complete(struct w83977af_ir *self);
 static netdev_tx_t  w83977af_hard_xmit(struct sk_buff *skb,
 					     struct net_device *dev);
@@ -108,7 +108,7 @@ static int  w83977af_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd
  */
 static int __init w83977af_init(void)
 {
-        int i;
+	int i;
 
 	for (i=0; i < ARRAY_SIZE(dev_self) && io[i] < 2000; i++) {
 		if (w83977af_open(i, io[i], irq[i], dma[i]) == 0)
@@ -150,7 +150,7 @@ static int w83977af_open(int i, unsigned int iobase, unsigned int irq,
 			 unsigned int dma)
 {
 	struct net_device *dev;
-        struct w83977af_ir *self;
+	struct w83977af_ir *self;
 	int err;
 
 	/* Lock the port that we need */
@@ -177,18 +177,18 @@ static int w83977af_open(int i, unsigned int iobase, unsigned int irq,
 
 	self = netdev_priv(dev);
 	spin_lock_init(&self->lock);
-   
+
 
 	/* Initialize IO */
 	self->io.fir_base   = iobase;
-        self->io.irq       = irq;
-        self->io.fir_ext   = CHIP_IO_EXTENT;
-        self->io.dma       = dma;
-        self->io.fifo_size = 32;
+	self->io.irq       = irq;
+	self->io.fir_ext   = CHIP_IO_EXTENT;
+	self->io.dma       = dma;
+	self->io.fifo_size = 32;
 
 	/* Initialize QoS for this device */
 	irda_init_max_qos_capabilies(&self->qos);
-	
+
 	/* The only value we must override it the baudrate */
 
 	/* FIXME: The HP HDLS-1100 does not support 1152000! */
@@ -198,11 +198,11 @@ static int w83977af_open(int i, unsigned int iobase, unsigned int irq,
 	/* The HP HDLS-1100 needs 1 ms according to the specs */
 	self->qos.min_turn_time.bits = qos_mtt_bits;
 	irda_qos_bits_to_value(&self->qos);
-	
+
 	/* Max DMA buffer size needed = (data_size + 6) * (window_size) + 6; */
-	self->rx_buff.truesize = 14384; 
+	self->rx_buff.truesize = 14384;
 	self->tx_buff.truesize = 4000;
-	
+
 	/* Allocate memory if needed */
 	self->rx_buff.head =
 		dma_zalloc_coherent(NULL, self->rx_buff.truesize,
@@ -238,12 +238,12 @@ static int w83977af_open(int i, unsigned int iobase, unsigned int irq,
 
 	/* Need to store self somewhere */
 	dev_self[i] = self;
-	
+
 	return 0;
 err_out3:
 	dma_free_coherent(NULL, self->tx_buff.truesize,
 			  self->tx_buff.head, self->tx_buff_dma);
-err_out2:	
+err_out2:
 	dma_free_coherent(NULL, self->rx_buff.truesize,
 			  self->rx_buff.head, self->rx_buff_dma);
 err_out1:
@@ -263,7 +263,7 @@ static int w83977af_close(struct w83977af_ir *self)
 {
 	int iobase;
 
-        iobase = self->io.fir_base;
+	iobase = self->io.fir_base;
 
 #ifdef CONFIG_USE_W977_PNP
 	/* enter PnP configuration mode */
@@ -288,7 +288,7 @@ static int w83977af_close(struct w83977af_ir *self)
 	if (self->tx_buff.head)
 		dma_free_coherent(NULL, self->tx_buff.truesize,
 				  self->tx_buff.head, self->tx_buff_dma);
-	
+
 	if (self->rx_buff.head)
 		dma_free_coherent(NULL, self->rx_buff.truesize,
 				  self->rx_buff.head, self->rx_buff_dma);
@@ -300,106 +300,106 @@ static int w83977af_close(struct w83977af_ir *self)
 
 static int w83977af_probe(int iobase, int irq, int dma)
 {
-  	int version;
+	int version;
 	int i;
-  	
- 	for (i=0; i < 2; i++) {
+
+	for (i=0; i < 2; i++) {
 #ifdef CONFIG_USE_W977_PNP
- 		/* Enter PnP configuration mode */
+		/* Enter PnP configuration mode */
 		w977_efm_enter(efbase[i]);
-  
- 		w977_select_device(W977_DEVICE_IR, efbase[i]);
-  
- 		/* Configure PnP port, IRQ, and DMA channel */
- 		w977_write_reg(0x60, (iobase >> 8) & 0xff, efbase[i]);
- 		w977_write_reg(0x61, (iobase) & 0xff, efbase[i]);
-  
- 		w977_write_reg(0x70, irq, efbase[i]);
+
+		w977_select_device(W977_DEVICE_IR, efbase[i]);
+
+		/* Configure PnP port, IRQ, and DMA channel */
+		w977_write_reg(0x60, (iobase >> 8) & 0xff, efbase[i]);
+		w977_write_reg(0x61, (iobase) & 0xff, efbase[i]);
+
+		w977_write_reg(0x70, irq, efbase[i]);
 #ifdef CONFIG_ARCH_NETWINDER
 		/* Netwinder uses 1 higher than Linux */
- 		w977_write_reg(0x74, dma+1, efbase[i]);
+		w977_write_reg(0x74, dma+1, efbase[i]);
 #else
- 		w977_write_reg(0x74, dma, efbase[i]);   
+		w977_write_reg(0x74, dma, efbase[i]);
 #endif /* CONFIG_ARCH_NETWINDER */
- 		w977_write_reg(0x75, 0x04, efbase[i]);  /* Disable Tx DMA */
-  	
- 		/* Set append hardware CRC, enable IR bank selection */	
- 		w977_write_reg(0xf0, APEDCRC|ENBNKSEL, efbase[i]);
-  
- 		/* Activate device */
- 		w977_write_reg(0x30, 0x01, efbase[i]);
-  
- 		w977_efm_exit(efbase[i]);
+		w977_write_reg(0x75, 0x04, efbase[i]);  /* Disable Tx DMA */
+
+		/* Set append hardware CRC, enable IR bank selection */
+		w977_write_reg(0xf0, APEDCRC|ENBNKSEL, efbase[i]);
+
+		/* Activate device */
+		w977_write_reg(0x30, 0x01, efbase[i]);
+
+		w977_efm_exit(efbase[i]);
 #endif /* CONFIG_USE_W977_PNP */
-  		/* Disable Advanced mode */
-  		switch_bank(iobase, SET2);
-  		outb(iobase+2, 0x00);  
- 
- 		/* Turn on UART (global) interrupts */
- 		switch_bank(iobase, SET0);
-  		outb(HCR_EN_IRQ, iobase+HCR);
-  	
-  		/* Switch to advanced mode */
-  		switch_bank(iobase, SET2);
-  		outb(inb(iobase+ADCR1) | ADCR1_ADV_SL, iobase+ADCR1);
-  
-  		/* Set default IR-mode */
-  		switch_bank(iobase, SET0);
-  		outb(HCR_SIR, iobase+HCR);
-  
-  		/* Read the Advanced IR ID */
-  		switch_bank(iobase, SET3);
-  		version = inb(iobase+AUID);
-  	
-  		/* Should be 0x1? */
-  		if (0x10 == (version & 0xf0)) {
- 			efio = efbase[i];
- 
- 			/* Set FIFO size to 32 */
- 			switch_bank(iobase, SET2);
- 			outb(ADCR2_RXFS32|ADCR2_TXFS32, iobase+ADCR2);	
- 	
- 			/* Set FIFO threshold to TX17, RX16 */
- 			switch_bank(iobase, SET0);	
- 			outb(UFR_RXTL|UFR_TXTL|UFR_TXF_RST|UFR_RXF_RST|
+		/* Disable Advanced mode */
+		switch_bank(iobase, SET2);
+		outb(iobase+2, 0x00);
+
+		/* Turn on UART (global) interrupts */
+		switch_bank(iobase, SET0);
+		outb(HCR_EN_IRQ, iobase+HCR);
+
+		/* Switch to advanced mode */
+		switch_bank(iobase, SET2);
+		outb(inb(iobase+ADCR1) | ADCR1_ADV_SL, iobase+ADCR1);
+
+		/* Set default IR-mode */
+		switch_bank(iobase, SET0);
+		outb(HCR_SIR, iobase+HCR);
+
+		/* Read the Advanced IR ID */
+		switch_bank(iobase, SET3);
+		version = inb(iobase+AUID);
+
+		/* Should be 0x1? */
+		if (0x10 == (version & 0xf0)) {
+			efio = efbase[i];
+
+			/* Set FIFO size to 32 */
+			switch_bank(iobase, SET2);
+			outb(ADCR2_RXFS32|ADCR2_TXFS32, iobase+ADCR2);
+
+			/* Set FIFO threshold to TX17, RX16 */
+			switch_bank(iobase, SET0);
+			outb(UFR_RXTL|UFR_TXTL|UFR_TXF_RST|UFR_RXF_RST|
 			     UFR_EN_FIFO,iobase+UFR);
- 
- 			/* Receiver frame length */
- 			switch_bank(iobase, SET4);
+
+			/* Receiver frame length */
+			switch_bank(iobase, SET4);
 			outb(2048 & 0xff, iobase+6);
 			outb((2048 >> 8) & 0x1f, iobase+7);
 
-			/* 
-			 * Init HP HSDL-1100 transceiver. 
-			 * 
-			 * Set IRX_MSL since we have 2 * receive paths IRRX, 
-			 * and IRRXH. Clear IRSL0D since we want IRSL0 * to 
-			 * be a input pin used for IRRXH 
+			/*
+			 * Init HP HSDL-1100 transceiver.
+			 *
+			 * Set IRX_MSL since we have 2 * receive paths IRRX,
+			 * and IRRXH. Clear IRSL0D since we want IRSL0 * to
+			 * be a input pin used for IRRXH
 			 *
-			 *   IRRX  pin 37 connected to receiver 
+			 *   IRRX  pin 37 connected to receiver
 			 *   IRTX  pin 38 connected to transmitter
-			 *   FIRRX pin 39 connected to receiver      (IRSL0) 
+			 *   FIRRX pin 39 connected to receiver      (IRSL0)
 			 *   CIRRX pin 40 connected to pin 37
 			 */
 			switch_bank(iobase, SET7);
 			outb(0x40, iobase+7);
-			
+
 			net_info_ratelimited("W83977AF (IR) driver loaded. Version: 0x%02x\n",
 					     version);
-			
+
 			return 0;
 		} else {
 			/* Try next extented function register address */
 			pr_debug("%s(), Wrong chip version", __func__);
 		}
-  	}   	
+	}
 	return -1;
 }
 
 static void w83977af_change_speed(struct w83977af_ir *self, __u32 speed)
 {
 	int ir_mode = HCR_SIR;
-	int iobase; 
+	int iobase;
 	__u8 set;
 
 	iobase = self->io.fir_base;
@@ -448,8 +448,8 @@ static void w83977af_change_speed(struct w83977af_ir *self, __u32 speed)
 
 	/* set FIFO size to 32 */
 	switch_bank(iobase, SET2);
-	outb(ADCR2_RXFS32|ADCR2_TXFS32, iobase+ADCR2);	
-	
+	outb(ADCR2_RXFS32|ADCR2_TXFS32, iobase+ADCR2);
+
 	/* set FIFO threshold to TX17, RX16 */
 	switch_bank(iobase, SET0);
 	outb(0x00, iobase+UFR);        /* Reset */
@@ -457,7 +457,7 @@ static void w83977af_change_speed(struct w83977af_ir *self, __u32 speed)
 	outb(0xa7, iobase+UFR);
 
 	netif_wake_queue(self->netdev);
-		
+
 	/* Enable some interrupts so we can receive frames */
 	switch_bank(iobase, SET0);
 	if (speed > PIO_MAX_SPEED) {
@@ -465,7 +465,7 @@ static void w83977af_change_speed(struct w83977af_ir *self, __u32 speed)
 		w83977af_dma_receive(self);
 	} else
 		outb(ICR_ERBRI, iobase+ICR);
-    	
+
 	/* Restore SSR */
 	outb(set, iobase+SSR);
 }
@@ -484,23 +484,23 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 	int iobase;
 	__u8 set;
 	int mtt;
-	
+
 	self = netdev_priv(dev);
 
 	iobase = self->io.fir_base;
 
 	pr_debug("%s(%ld), skb->len=%d\n", __func__ , jiffies,
 		 (int)skb->len);
-	
+
 	/* Lock transmit buffer */
 	netif_stop_queue(dev);
-	
+
 	/* Check if we need to change the speed */
 	speed = irda_get_next_speed(skb);
 	if ((speed != self->io.speed) && (speed != -1)) {
 		/* Check for empty frame */
 		if (!skb->len) {
-			w83977af_change_speed(self, speed); 
+			w83977af_change_speed(self, speed);
 			dev_kfree_skb(skb);
 			return NETDEV_TX_OK;
 		} else
@@ -509,13 +509,13 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 
 	/* Save current set */
 	set = inb(iobase+SSR);
-	
+
 	/* Decide if we should use PIO or DMA transfer */
 	if (self->io.speed > PIO_MAX_SPEED) {
 		self->tx_buff.data = self->tx_buff.head;
 		skb_copy_from_linear_data(skb, self->tx_buff.data, skb->len);
 		self->tx_buff.len = skb->len;
-		
+
 		mtt = irda_get_mtt(skb);
 		pr_debug("%s(%ld), mtt=%d\n", __func__ , jiffies, mtt);
 			if (mtt > 1000)
@@ -525,13 +525,13 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 
 			/* Enable DMA interrupt */
 			switch_bank(iobase, SET0);
-	 		outb(ICR_EDMAI, iobase+ICR);
-	     		w83977af_dma_write(self, iobase);
+			outb(ICR_EDMAI, iobase+ICR);
+			w83977af_dma_write(self, iobase);
 	} else {
 		self->tx_buff.data = self->tx_buff.head;
-		self->tx_buff.len = async_wrap_skb(skb, self->tx_buff.data, 
+		self->tx_buff.len = async_wrap_skb(skb, self->tx_buff.data,
 						   self->tx_buff.truesize);
-		
+
 		/* Add interrupt on tx low level (will fire immediately) */
 		switch_bank(iobase, SET0);
 		outb(ICR_ETXTHI, iobase+ICR);
@@ -562,15 +562,15 @@ static void w83977af_dma_write(struct w83977af_ir *self, int iobase)
 	switch_bank(iobase, SET0);
 	outb(inb(iobase+HCR) & ~HCR_EN_DMA, iobase+HCR);
 
-	/* Choose transmit DMA channel  */ 
+	/* Choose transmit DMA channel  */
 	switch_bank(iobase, SET2);
 	outb(ADCR1_D_CHSW|/*ADCR1_DMA_F|*/ADCR1_ADV_SL, iobase+ADCR1);
 	irda_setup_dma(self->io.dma, self->tx_buff_dma, self->tx_buff.len,
-		       DMA_MODE_WRITE);	
+		       DMA_MODE_WRITE);
 	self->io.direction = IO_XMIT;
-	
+
 	/* Enable DMA */
- 	switch_bank(iobase, SET0);
+	switch_bank(iobase, SET0);
 	outb(inb(iobase+HCR) | HCR_EN_DMA | HCR_TX_WT, iobase+HCR);
 
 	/* Restore set register */
@@ -580,14 +580,14 @@ static void w83977af_dma_write(struct w83977af_ir *self, int iobase)
 /*
  * Function w83977af_pio_write (iobase, buf, len, fifo_size)
  *
- *    
+ *
  *
  */
 static int w83977af_pio_write(int iobase, __u8 *buf, int len, int fifo_size)
 {
 	int actual = 0;
 	__u8 set;
-	
+
 	/* Save current bank */
 	set = inb(iobase+SSR);
 
@@ -605,7 +605,7 @@ static int w83977af_pio_write(int iobase, __u8 *buf, int len, int fifo_size)
 		/* Transmit next byte */
 		outb(buf[actual++], iobase+TBR);
 	}
-        
+
 	pr_debug("%s(), fifo_size %d ; %d sent of %d\n",
 		 __func__ , fifo_size, actual, len);
 
@@ -620,7 +620,7 @@ static int w83977af_pio_write(int iobase, __u8 *buf, int len, int fifo_size)
  *
  *    The transfer of a frame in finished. So do the necessary things
  *
- *    
+ *
  */
 static void w83977af_dma_xmit_complete(struct w83977af_ir *self)
 {
@@ -639,11 +639,11 @@ static void w83977af_dma_xmit_complete(struct w83977af_ir *self)
 	/* Disable DMA */
 	switch_bank(iobase, SET0);
 	outb(inb(iobase+HCR) & ~HCR_EN_DMA, iobase+HCR);
-	
+
 	/* Check for underrun! */
 	if (inb(iobase+AUDR) & AUDR_UNDR) {
 		pr_debug("%s(), Transmit underrun!\n", __func__);
-		
+
 		self->netdev->stats.tx_errors++;
 		self->netdev->stats.tx_fifo_errors++;
 
@@ -652,7 +652,7 @@ static void w83977af_dma_xmit_complete(struct w83977af_ir *self)
 	} else
 		self->netdev->stats.tx_packets++;
 
-	
+
 	if (self->new_speed) {
 		w83977af_change_speed(self, self->new_speed);
 		self->new_speed = 0;
@@ -661,7 +661,7 @@ static void w83977af_dma_xmit_complete(struct w83977af_ir *self)
 	/* Unlock tx_buff and request another frame */
 	/* Tell the network layer, that we want more frames */
 	netif_wake_queue(self->netdev);
-	
+
 	/* Restore set */
 	outb(set, iobase+SSR);
 }
@@ -714,15 +714,15 @@ static int w83977af_dma_receive(struct w83977af_ir *self)
 	irda_setup_dma(self->io.dma, self->rx_buff_dma, self->rx_buff.truesize,
 		       DMA_MODE_READ);
 #endif
-	/* 
-	 * Reset Rx FIFO. This will also flush the ST_FIFO, it's very 
+	/*
+	 * Reset Rx FIFO. This will also flush the ST_FIFO, it's very
 	 * important that we don't reset the Tx FIFO since it might not
 	 * be finished transmitting yet
 	 */
 	switch_bank(iobase, SET0);
 	outb(UFR_RXTL|UFR_TXTL|UFR_RXF_RST|UFR_EN_FIFO, iobase+UFR);
 	self->st_fifo.len = self->st_fifo.tail = self->st_fifo.head = 0;
-	
+
 	/* Enable DMA */
 	switch_bank(iobase, SET0);
 #ifdef CONFIG_ARCH_NETWINDER
@@ -730,7 +730,7 @@ static int w83977af_dma_receive(struct w83977af_ir *self)
 	outb(hcr | HCR_EN_DMA, iobase+HCR);
 	enable_dma(self->io.dma);
 	spin_unlock_irqrestore(&self->lock, flags);
-#else	
+#else
 	outb(inb(iobase+HCR) | HCR_EN_DMA, iobase+HCR);
 #endif
 	/* Restore set */
@@ -762,21 +762,21 @@ static int w83977af_dma_receive_complete(struct w83977af_ir *self)
 
 	/* Save current set */
 	set = inb(iobase+SSR);
-	
+
 	iobase = self->io.fir_base;
 
 	/* Read status FIFO */
 	switch_bank(iobase, SET5);
 	while ((status = inb(iobase+FS_FO)) & FS_FO_FSFDR) {
 		st_fifo->entries[st_fifo->tail].status = status;
-		
+
 		st_fifo->entries[st_fifo->tail].len  = inb(iobase+RFLFL);
 		st_fifo->entries[st_fifo->tail].len |= inb(iobase+RFLFH) << 8;
-		
+
 		st_fifo->tail++;
 		st_fifo->len++;
 	}
-	
+
 	while (st_fifo->len) {
 		/* Get first entry */
 		status = st_fifo->entries[st_fifo->head].status;
@@ -792,32 +792,32 @@ static int w83977af_dma_receive_complete(struct w83977af_ir *self)
 			} else {
 				/* Skip frame */
 				self->netdev->stats.rx_errors++;
-				
+
 				self->rx_buff.data += len;
-				
+
 				if (status & FS_FO_MX_LEX)
 					self->netdev->stats.rx_length_errors++;
-				
-				if (status & FS_FO_PHY_ERR) 
+
+				if (status & FS_FO_PHY_ERR)
 					self->netdev->stats.rx_frame_errors++;
-				
-				if (status & FS_FO_CRC_ERR) 
+
+				if (status & FS_FO_CRC_ERR)
 					self->netdev->stats.rx_crc_errors++;
 			}
 			/* The errors below can be reported in both cases */
 			if (status & FS_FO_RX_OV)
 				self->netdev->stats.rx_fifo_errors++;
-			
+
 			if (status & FS_FO_FSF_OV)
 				self->netdev->stats.rx_fifo_errors++;
-			
+
 		} else {
 			/* Check if we have transferred all data to memory */
 			switch_bank(iobase, SET0);
 			if (inb(iobase+USR) & USR_RDR) {
 				udelay(80); /* Should be enough!? */
 			}
-						
+
 			skb = dev_alloc_skb(len+1);
 			if (skb == NULL)  {
 				printk(KERN_INFO
@@ -827,10 +827,10 @@ static int w83977af_dma_receive_complete(struct w83977af_ir *self)
 
 				return FALSE;
 			}
-			
+
 			/*  Align to 20 bytes */
-			skb_reserve(skb, 1); 
-			
+			skb_reserve(skb, 1);
+
 			/* Copy frame without CRC */
 			if (self->io.speed < 4000000) {
 				skb_put(skb, len-2);
@@ -847,7 +847,7 @@ static int w83977af_dma_receive_complete(struct w83977af_ir *self)
 			/* Move to next frame */
 			self->rx_buff.data += len;
 			self->netdev->stats.rx_packets++;
-			
+
 			skb->dev = self->netdev;
 			skb_reset_mac_header(skb);
 			skb->protocol = htons(ETH_P_IRDA);
@@ -866,21 +866,21 @@ static int w83977af_dma_receive_complete(struct w83977af_ir *self)
  *    Receive all data in receiver FIFO
  *
  */
-static void w83977af_pio_receive(struct w83977af_ir *self) 
+static void w83977af_pio_receive(struct w83977af_ir *self)
 {
 	__u8 byte = 0x00;
 	int iobase;
 
 	IRDA_ASSERT(self != NULL, return;);
-	
+
 	iobase = self->io.fir_base;
-	
+
 	/*  Receive all characters in Rx FIFO */
 	do {
 		byte = inb(iobase+RBR);
 		async_unwrap_char(self->netdev, &self->netdev->stats, &self->rx_buff,
 				  byte);
-	} while (inb(iobase+USR) & USR_RDR); /* Data available */	
+	} while (inb(iobase+USR) & USR_RDR); /* Data available */
 }
 
 /*
@@ -897,19 +897,19 @@ static __u8 w83977af_sir_interrupt(struct w83977af_ir *self, int isr)
 	int iobase;
 
 	pr_debug("%s(), isr=%#x\n", __func__ , isr);
-	
+
 	iobase = self->io.fir_base;
 	/* Transmit FIFO low on data */
 	if (isr & ISR_TXTH_I) {
 		/* Write data left in transmit buffer */
-		actual = w83977af_pio_write(self->io.fir_base, 
-					    self->tx_buff.data, 
-					    self->tx_buff.len, 
+		actual = w83977af_pio_write(self->io.fir_base,
+					    self->tx_buff.data,
+					    self->tx_buff.len,
 					    self->io.fifo_size);
 
 		self->tx_buff.data += actual;
 		self->tx_buff.len  -= actual;
-		
+
 		self->io.direction = IO_XMIT;
 
 		/* Check if finished */
@@ -919,7 +919,7 @@ static __u8 w83977af_sir_interrupt(struct w83977af_ir *self, int isr)
 			set = inb(iobase+SSR);
 			switch_bank(iobase, SET0);
 			outb(AUDR_SFEND, iobase+AUDR);
-			outb(set, iobase+SSR); 
+			outb(set, iobase+SSR);
 
 			self->netdev->stats.tx_packets++;
 
@@ -929,7 +929,7 @@ static __u8 w83977af_sir_interrupt(struct w83977af_ir *self, int isr)
 		}
 	}
 	/* Check if transmission has completed */
-	if (isr & ISR_TXEMP_I) {		
+	if (isr & ISR_TXEMP_I) {
 		/* Check if we need to change the speed? */
 		if (self->new_speed) {
 			pr_debug("%s(), Changing speed!\n", __func__);
@@ -966,11 +966,11 @@ static __u8 w83977af_fir_interrupt(struct w83977af_ir *self, int isr)
 
 	iobase = self->io.fir_base;
 	set = inb(iobase+SSR);
-	
+
 	/* End of frame detected in FIFO */
 	if (isr & (ISR_FEND_I|ISR_FSF_I)) {
 		if (w83977af_dma_receive_complete(self)) {
-			
+
 			/* Wait for next status FIFO interrupt */
 			new_icr |= ICR_EFSFI;
 		} else {
@@ -995,7 +995,7 @@ static __u8 w83977af_fir_interrupt(struct w83977af_ir *self, int isr)
 
 		/* Clear timer event */
 		/* switch_bank(iobase, SET0); */
-/* 		outb(ASCR_CTE, iobase+ASCR); */
+/*		outb(ASCR_CTE, iobase+ASCR); */
 
 		/* Check if this is a TX timer interrupt */
 		if (self->io.direction == IO_XMIT) {
@@ -1008,23 +1008,23 @@ static __u8 w83977af_fir_interrupt(struct w83977af_ir *self, int isr)
 
 			new_icr |= ICR_EFSFI;
 		}
-	}	
+	}
 	/* Finished with DMA */
 	if (isr & ISR_DMA_I) {
 		w83977af_dma_xmit_complete(self);
 
 		/* Check if there are more frames to be transmitted */
 		/* if (irda_device_txqueue_empty(self)) { */
-		
-		/* Prepare for receive 
-		 * 
+
+		/* Prepare for receive
+		 *
 		 * ** Netwinder Tx DMA likes that we do this anyway **
 		 */
 		w83977af_dma_receive(self);
 		new_icr = ICR_EFSFI;
 	       /* } */
 	}
-	
+
 	/* Restore set */
 	outb(set, iobase+SSR);
 
@@ -1051,12 +1051,12 @@ static irqreturn_t w83977af_interrupt(int irq, void *dev_id)
 	/* Save current bank */
 	set = inb(iobase+SSR);
 	switch_bank(iobase, SET0);
-	
-	icr = inb(iobase+ICR); 
-	isr = inb(iobase+ISR) & icr; /* Mask out the interesting ones */ 
+
+	icr = inb(iobase+ICR);
+	isr = inb(iobase+ISR) & icr; /* Mask out the interesting ones */
 
 	outb(0, iobase+ICR); /* Disable interrupts */
-	
+
 	if (isr) {
 		/* Dispatch interrupt handler for the current speed */
 		if (self->io.speed > PIO_MAX_SPEED )
@@ -1095,9 +1095,9 @@ static int w83977af_is_receiving(struct w83977af_ir *self)
 			status =  TRUE;
 		}
 		outb(set, iobase+SSR);
-	} else 
+	} else
 		status = (self->rx_buff.state != OUTSIDE_FRAME);
-	
+
 	return status;
 }
 
@@ -1113,16 +1113,16 @@ static int w83977af_net_open(struct net_device *dev)
 	int iobase;
 	char hwname[32];
 	__u8 set;
-	
-	
+
+
 	IRDA_ASSERT(dev != NULL, return -1;);
 	self = netdev_priv(dev);
-	
+
 	IRDA_ASSERT(self != NULL, return 0;);
-	
+
 	iobase = self->io.fir_base;
 
-	if (request_irq(self->io.irq, w83977af_interrupt, 0, dev->name, 
+	if (request_irq(self->io.irq, w83977af_interrupt, 0, dev->name,
 			(void *) dev)) {
 		return -EAGAIN;
 	}
@@ -1134,30 +1134,30 @@ static int w83977af_net_open(struct net_device *dev)
 		free_irq(self->io.irq, dev);
 		return -EAGAIN;
 	}
-		
+
 	/* Save current set */
 	set = inb(iobase+SSR);
 
- 	/* Enable some interrupts so we can receive frames again */
- 	switch_bank(iobase, SET0);
- 	if (self->io.speed > 115200) {
- 		outb(ICR_EFSFI, iobase+ICR);
- 		w83977af_dma_receive(self);
- 	} else
- 		outb(ICR_ERBRI, iobase+ICR);
+	/* Enable some interrupts so we can receive frames again */
+	switch_bank(iobase, SET0);
+	if (self->io.speed > 115200) {
+		outb(ICR_EFSFI, iobase+ICR);
+		w83977af_dma_receive(self);
+	} else
+		outb(ICR_ERBRI, iobase+ICR);
 
 	/* Restore bank register */
 	outb(set, iobase+SSR);
 
 	/* Ready to play! */
 	netif_start_queue(dev);
-	
+
 	/* Give self a hardware name */
 	sprintf(hwname, "w83977af @ 0x%03x", self->io.fir_base);
 
-	/* 
+	/*
 	 * Open new IrLAP layer instance, now that everything should be
-	 * initialized properly 
+	 * initialized properly
 	 */
 	self->irlap = irlap_open(dev, &self->qos, hwname);
 
@@ -1177,16 +1177,16 @@ static int w83977af_net_close(struct net_device *dev)
 	__u8 set;
 
 	IRDA_ASSERT(dev != NULL, return -1;);
-	
+
 	self = netdev_priv(dev);
-	
+
 	IRDA_ASSERT(self != NULL, return 0;);
-	
+
 	iobase = self->io.fir_base;
 
 	/* Stop device */
 	netif_stop_queue(dev);
-	
+
 	/* Stop and remove instance of IrLAP */
 	if (self->irlap)
 		irlap_close(self->irlap);
@@ -1196,10 +1196,10 @@ static int w83977af_net_close(struct net_device *dev)
 
 	/* Save current set */
 	set = inb(iobase+SSR);
-	
+
 	/* Disable interrupts */
 	switch_bank(iobase, SET0);
-	outb(0, iobase+ICR); 
+	outb(0, iobase+ICR);
 
 	free_irq(self->io.irq, dev);
 	free_dma(self->io.dma);
@@ -1230,7 +1230,7 @@ static int w83977af_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	IRDA_ASSERT(self != NULL, return -1;);
 
 	pr_debug("%s(), %s, (cmd=0x%X)\n", __func__ , dev->name, cmd);
-	
+
 	spin_lock_irqsave(&self->lock, flags);
 
 	switch (cmd) {
@@ -1274,7 +1274,7 @@ MODULE_PARM_DESC(irq, "IRQ lines");
 /*
  * Function init_module (void)
  *
- *    
+ *
  *
  */
 module_init(w83977af_init);
@@ -1282,7 +1282,7 @@ module_init(w83977af_init);
 /*
  * Function cleanup_module (void)
  *
- *    
+ *
  *
  */
 module_exit(w83977af_cleanup);
-- 
2.10.0.rc2.1.g053435c
