From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/8] irda: w83977af_ir: More whitespace neatening
Date: Thu, 24 Nov 2016 11:10:29 -0800
Message-ID: <6b4c60e593c6739fef8a89350109000c8bea02b9.1480014088.git.joe@perches.com>
References: <cover.1480014088.git.joe@perches.com>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1480014088.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add spaces around operators.
git diff -w shows no differences.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/irda/w83977af_ir.c | 232 ++++++++++++++++++++---------------------
 1 file changed, 116 insertions(+), 116 deletions(-)

diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 98333aba7404..4ad91f4f867f 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -110,7 +110,7 @@ static int __init w83977af_init(void)
 {
 	int i;
 
-	for (i=0; i < ARRAY_SIZE(dev_self) && io[i] < 2000; i++) {
+	for (i = 0; i < ARRAY_SIZE(dev_self) && io[i] < 2000; i++) {
 		if (w83977af_open(i, io[i], irq[i], dma[i]) == 0)
 			return 0;
 	}
@@ -127,7 +127,7 @@ static void __exit w83977af_cleanup(void)
 {
 	int i;
 
-	for (i=0; i < ARRAY_SIZE(dev_self); i++) {
+	for (i = 0; i < ARRAY_SIZE(dev_self); i++) {
 		if (dev_self[i])
 			w83977af_close(dev_self[i]);
 	}
@@ -156,7 +156,7 @@ static int w83977af_open(int i, unsigned int iobase, unsigned int irq,
 	/* Lock the port that we need */
 	if (!request_region(iobase, CHIP_IO_EXTENT, driver_name)) {
 		pr_debug("%s(), can't get iobase of 0x%03x\n",
-			 __func__ , iobase);
+			 __func__, iobase);
 		return -ENODEV;
 	}
 
@@ -169,7 +169,7 @@ static int w83977af_open(int i, unsigned int iobase, unsigned int irq,
 	 */
 	dev = alloc_irdadev(sizeof(struct w83977af_ir));
 	if (dev == NULL) {
-		printk( KERN_ERR "IrDA: Can't allocate memory for "
+		printk(KERN_ERR "IrDA: Can't allocate memory for "
 			"IrDA control block!\n");
 		err = -ENOMEM;
 		goto err_out;
@@ -192,8 +192,8 @@ static int w83977af_open(int i, unsigned int iobase, unsigned int irq,
 	/* The only value we must override it the baudrate */
 
 	/* FIXME: The HP HDLS-1100 does not support 1152000! */
-	self->qos.baud_rate.bits = IR_9600|IR_19200|IR_38400|IR_57600|
-		IR_115200|IR_576000|IR_1152000|(IR_4000000 << 8);
+	self->qos.baud_rate.bits = IR_9600 | IR_19200 | IR_38400 | IR_57600 |
+		IR_115200 | IR_576000 | IR_1152000 | (IR_4000000 << 8);
 
 	/* The HP HDLS-1100 needs 1 ms according to the specs */
 	self->qos.min_turn_time.bits = qos_mtt_bits;
@@ -282,7 +282,7 @@ static int w83977af_close(struct w83977af_ir *self)
 
 	/* Release the PORT that this driver is using */
 	pr_debug("%s(), Releasing Region %03x\n",
-		 __func__ , self->io.fir_base);
+		 __func__, self->io.fir_base);
 	release_region(self->io.fir_base, self->io.fir_ext);
 
 	if (self->tx_buff.head)
@@ -303,7 +303,7 @@ static int w83977af_probe(int iobase, int irq, int dma)
 	int version;
 	int i;
 
-	for (i=0; i < 2; i++) {
+	for (i = 0; i < 2; i++) {
 #ifdef CONFIG_USE_W977_PNP
 		/* Enter PnP configuration mode */
 		w977_efm_enter(efbase[i]);
@@ -317,14 +317,14 @@ static int w83977af_probe(int iobase, int irq, int dma)
 		w977_write_reg(0x70, irq, efbase[i]);
 #ifdef CONFIG_ARCH_NETWINDER
 		/* Netwinder uses 1 higher than Linux */
-		w977_write_reg(0x74, dma+1, efbase[i]);
+		w977_write_reg(0x74, dma + 1, efbase[i]);
 #else
 		w977_write_reg(0x74, dma, efbase[i]);
 #endif /* CONFIG_ARCH_NETWINDER */
 		w977_write_reg(0x75, 0x04, efbase[i]);  /* Disable Tx DMA */
 
 		/* Set append hardware CRC, enable IR bank selection */
-		w977_write_reg(0xf0, APEDCRC|ENBNKSEL, efbase[i]);
+		w977_write_reg(0xf0, APEDCRC | ENBNKSEL, efbase[i]);
 
 		/* Activate device */
 		w977_write_reg(0x30, 0x01, efbase[i]);
@@ -333,23 +333,23 @@ static int w83977af_probe(int iobase, int irq, int dma)
 #endif /* CONFIG_USE_W977_PNP */
 		/* Disable Advanced mode */
 		switch_bank(iobase, SET2);
-		outb(iobase+2, 0x00);
+		outb(iobase + 2, 0x00);
 
 		/* Turn on UART (global) interrupts */
 		switch_bank(iobase, SET0);
-		outb(HCR_EN_IRQ, iobase+HCR);
+		outb(HCR_EN_IRQ, iobase + HCR);
 
 		/* Switch to advanced mode */
 		switch_bank(iobase, SET2);
-		outb(inb(iobase+ADCR1) | ADCR1_ADV_SL, iobase+ADCR1);
+		outb(inb(iobase + ADCR1) | ADCR1_ADV_SL, iobase + ADCR1);
 
 		/* Set default IR-mode */
 		switch_bank(iobase, SET0);
-		outb(HCR_SIR, iobase+HCR);
+		outb(HCR_SIR, iobase + HCR);
 
 		/* Read the Advanced IR ID */
 		switch_bank(iobase, SET3);
-		version = inb(iobase+AUID);
+		version = inb(iobase + AUID);
 
 		/* Should be 0x1? */
 		if (0x10 == (version & 0xf0)) {
@@ -357,17 +357,17 @@ static int w83977af_probe(int iobase, int irq, int dma)
 
 			/* Set FIFO size to 32 */
 			switch_bank(iobase, SET2);
-			outb(ADCR2_RXFS32|ADCR2_TXFS32, iobase+ADCR2);
+			outb(ADCR2_RXFS32 | ADCR2_TXFS32, iobase + ADCR2);
 
 			/* Set FIFO threshold to TX17, RX16 */
 			switch_bank(iobase, SET0);
-			outb(UFR_RXTL|UFR_TXTL|UFR_TXF_RST|UFR_RXF_RST|
-			     UFR_EN_FIFO,iobase+UFR);
+			outb(UFR_RXTL | UFR_TXTL | UFR_TXF_RST | UFR_RXF_RST |
+			     UFR_EN_FIFO, iobase + UFR);
 
 			/* Receiver frame length */
 			switch_bank(iobase, SET4);
-			outb(2048 & 0xff, iobase+6);
-			outb((2048 >> 8) & 0x1f, iobase+7);
+			outb(2048 & 0xff, iobase + 6);
+			outb((2048 >> 8) & 0x1f, iobase + 7);
 
 			/*
 			 * Init HP HSDL-1100 transceiver.
@@ -382,7 +382,7 @@ static int w83977af_probe(int iobase, int irq, int dma)
 			 *   CIRRX pin 40 connected to pin 37
 			 */
 			switch_bank(iobase, SET7);
-			outb(0x40, iobase+7);
+			outb(0x40, iobase + 7);
 
 			net_info_ratelimited("W83977AF (IR) driver loaded. Version: 0x%02x\n",
 					     version);
@@ -408,22 +408,22 @@ static void w83977af_change_speed(struct w83977af_ir *self, __u32 speed)
 	self->io.speed = speed;
 
 	/* Save current bank */
-	set = inb(iobase+SSR);
+	set = inb(iobase + SSR);
 
 	/* Disable interrupts */
 	switch_bank(iobase, SET0);
-	outb(0, iobase+ICR);
+	outb(0, iobase + ICR);
 
 	/* Select Set 2 */
 	switch_bank(iobase, SET2);
-	outb(0x00, iobase+ABHL);
+	outb(0x00, iobase + ABHL);
 
 	switch (speed) {
-	case 9600:   outb(0x0c, iobase+ABLL); break;
-	case 19200:  outb(0x06, iobase+ABLL); break;
-	case 38400:  outb(0x03, iobase+ABLL); break;
-	case 57600:  outb(0x02, iobase+ABLL); break;
-	case 115200: outb(0x01, iobase+ABLL); break;
+	case 9600:   outb(0x0c, iobase + ABLL); break;
+	case 19200:  outb(0x06, iobase + ABLL); break;
+	case 38400:  outb(0x03, iobase + ABLL); break;
+	case 57600:  outb(0x02, iobase + ABLL); break;
+	case 115200: outb(0x01, iobase + ABLL); break;
 	case 576000:
 		ir_mode = HCR_MIR_576;
 		pr_debug("%s(), handling baud of 576000\n", __func__);
@@ -438,36 +438,36 @@ static void w83977af_change_speed(struct w83977af_ir *self, __u32 speed)
 		break;
 	default:
 		ir_mode = HCR_FIR;
-		pr_debug("%s(), unknown baud rate of %d\n", __func__ , speed);
+		pr_debug("%s(), unknown baud rate of %d\n", __func__, speed);
 		break;
 	}
 
 	/* Set speed mode */
 	switch_bank(iobase, SET0);
-	outb(ir_mode, iobase+HCR);
+	outb(ir_mode, iobase + HCR);
 
 	/* set FIFO size to 32 */
 	switch_bank(iobase, SET2);
-	outb(ADCR2_RXFS32|ADCR2_TXFS32, iobase+ADCR2);
+	outb(ADCR2_RXFS32 | ADCR2_TXFS32, iobase + ADCR2);
 
 	/* set FIFO threshold to TX17, RX16 */
 	switch_bank(iobase, SET0);
-	outb(0x00, iobase+UFR);        /* Reset */
-	outb(UFR_EN_FIFO, iobase+UFR); /* First we must enable FIFO */
-	outb(0xa7, iobase+UFR);
+	outb(0x00, iobase + UFR);        /* Reset */
+	outb(UFR_EN_FIFO, iobase + UFR); /* First we must enable FIFO */
+	outb(0xa7, iobase + UFR);
 
 	netif_wake_queue(self->netdev);
 
 	/* Enable some interrupts so we can receive frames */
 	switch_bank(iobase, SET0);
 	if (speed > PIO_MAX_SPEED) {
-		outb(ICR_EFSFI, iobase+ICR);
+		outb(ICR_EFSFI, iobase + ICR);
 		w83977af_dma_receive(self);
 	} else
-		outb(ICR_ERBRI, iobase+ICR);
+		outb(ICR_ERBRI, iobase + ICR);
 
 	/* Restore SSR */
-	outb(set, iobase+SSR);
+	outb(set, iobase + SSR);
 }
 
 /*
@@ -489,7 +489,7 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 
 	iobase = self->io.fir_base;
 
-	pr_debug("%s(%ld), skb->len=%d\n", __func__ , jiffies,
+	pr_debug("%s(%ld), skb->len=%d\n", __func__, jiffies,
 		 (int)skb->len);
 
 	/* Lock transmit buffer */
@@ -508,7 +508,7 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 	}
 
 	/* Save current set */
-	set = inb(iobase+SSR);
+	set = inb(iobase + SSR);
 
 	/* Decide if we should use PIO or DMA transfer */
 	if (self->io.speed > PIO_MAX_SPEED) {
@@ -517,15 +517,15 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 		self->tx_buff.len = skb->len;
 
 		mtt = irda_get_mtt(skb);
-		pr_debug("%s(%ld), mtt=%d\n", __func__ , jiffies, mtt);
+		pr_debug("%s(%ld), mtt=%d\n", __func__, jiffies, mtt);
 			if (mtt > 1000)
-				mdelay(mtt/1000);
+				mdelay(mtt / 1000);
 			else if (mtt)
 				udelay(mtt);
 
 			/* Enable DMA interrupt */
 			switch_bank(iobase, SET0);
-			outb(ICR_EDMAI, iobase+ICR);
+			outb(ICR_EDMAI, iobase + ICR);
 			w83977af_dma_write(self, iobase);
 	} else {
 		self->tx_buff.data = self->tx_buff.head;
@@ -534,12 +534,12 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 
 		/* Add interrupt on tx low level (will fire immediately) */
 		switch_bank(iobase, SET0);
-		outb(ICR_ETXTHI, iobase+ICR);
+		outb(ICR_ETXTHI, iobase + ICR);
 	}
 	dev_kfree_skb(skb);
 
 	/* Restore set register */
-	outb(set, iobase+SSR);
+	outb(set, iobase + SSR);
 
 	return NETDEV_TX_OK;
 }
@@ -553,28 +553,28 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 static void w83977af_dma_write(struct w83977af_ir *self, int iobase)
 {
 	__u8 set;
-	pr_debug("%s(), len=%d\n", __func__ , self->tx_buff.len);
+	pr_debug("%s(), len=%d\n", __func__, self->tx_buff.len);
 
 	/* Save current set */
-	set = inb(iobase+SSR);
+	set = inb(iobase + SSR);
 
 	/* Disable DMA */
 	switch_bank(iobase, SET0);
-	outb(inb(iobase+HCR) & ~HCR_EN_DMA, iobase+HCR);
+	outb(inb(iobase + HCR) & ~HCR_EN_DMA, iobase + HCR);
 
 	/* Choose transmit DMA channel  */
 	switch_bank(iobase, SET2);
-	outb(ADCR1_D_CHSW|/*ADCR1_DMA_F|*/ADCR1_ADV_SL, iobase+ADCR1);
+	outb(ADCR1_D_CHSW | /*ADCR1_DMA_F|*/ADCR1_ADV_SL, iobase + ADCR1);
 	irda_setup_dma(self->io.dma, self->tx_buff_dma, self->tx_buff.len,
 		       DMA_MODE_WRITE);
 	self->io.direction = IO_XMIT;
 
 	/* Enable DMA */
 	switch_bank(iobase, SET0);
-	outb(inb(iobase+HCR) | HCR_EN_DMA | HCR_TX_WT, iobase+HCR);
+	outb(inb(iobase + HCR) | HCR_EN_DMA | HCR_TX_WT, iobase + HCR);
 
 	/* Restore set register */
-	outb(set, iobase+SSR);
+	outb(set, iobase + SSR);
 }
 
 /*
@@ -589,28 +589,28 @@ static int w83977af_pio_write(int iobase, __u8 *buf, int len, int fifo_size)
 	__u8 set;
 
 	/* Save current bank */
-	set = inb(iobase+SSR);
+	set = inb(iobase + SSR);
 
 	switch_bank(iobase, SET0);
-	if (!(inb_p(iobase+USR) & USR_TSRE)) {
+	if (!(inb_p(iobase + USR) & USR_TSRE)) {
 		pr_debug("%s(), warning, FIFO not empty yet!\n", __func__);
 
 		fifo_size -= 17;
 		pr_debug("%s(), %d bytes left in tx fifo\n",
-			 __func__ , fifo_size);
+			 __func__, fifo_size);
 	}
 
 	/* Fill FIFO with current frame */
 	while ((fifo_size-- > 0) && (actual < len)) {
 		/* Transmit next byte */
-		outb(buf[actual++], iobase+TBR);
+		outb(buf[actual++], iobase + TBR);
 	}
 
 	pr_debug("%s(), fifo_size %d ; %d sent of %d\n",
-		 __func__ , fifo_size, actual, len);
+		 __func__, fifo_size, actual, len);
 
 	/* Restore bank */
-	outb(set, iobase+SSR);
+	outb(set, iobase + SSR);
 
 	return actual;
 }
@@ -627,28 +627,28 @@ static void w83977af_dma_xmit_complete(struct w83977af_ir *self)
 	int iobase;
 	__u8 set;
 
-	pr_debug("%s(%ld)\n", __func__ , jiffies);
+	pr_debug("%s(%ld)\n", __func__, jiffies);
 
 	IRDA_ASSERT(self != NULL, return;);
 
 	iobase = self->io.fir_base;
 
 	/* Save current set */
-	set = inb(iobase+SSR);
+	set = inb(iobase + SSR);
 
 	/* Disable DMA */
 	switch_bank(iobase, SET0);
-	outb(inb(iobase+HCR) & ~HCR_EN_DMA, iobase+HCR);
+	outb(inb(iobase + HCR) & ~HCR_EN_DMA, iobase + HCR);
 
 	/* Check for underrun! */
-	if (inb(iobase+AUDR) & AUDR_UNDR) {
+	if (inb(iobase + AUDR) & AUDR_UNDR) {
 		pr_debug("%s(), Transmit underrun!\n", __func__);
 
 		self->netdev->stats.tx_errors++;
 		self->netdev->stats.tx_fifo_errors++;
 
 		/* Clear bit, by writing 1 to it */
-		outb(AUDR_UNDR, iobase+AUDR);
+		outb(AUDR_UNDR, iobase + AUDR);
 	} else
 		self->netdev->stats.tx_packets++;
 
@@ -663,7 +663,7 @@ static void w83977af_dma_xmit_complete(struct w83977af_ir *self)
 	netif_wake_queue(self->netdev);
 
 	/* Restore set */
-	outb(set, iobase+SSR);
+	outb(set, iobase + SSR);
 }
 
 /*
@@ -685,19 +685,19 @@ static int w83977af_dma_receive(struct w83977af_ir *self)
 
 	pr_debug("%s\n", __func__);
 
-	iobase= self->io.fir_base;
+	iobase = self->io.fir_base;
 
 	/* Save current set */
-	set = inb(iobase+SSR);
+	set = inb(iobase + SSR);
 
 	/* Disable DMA */
 	switch_bank(iobase, SET0);
-	outb(inb(iobase+HCR) & ~HCR_EN_DMA, iobase+HCR);
+	outb(inb(iobase + HCR) & ~HCR_EN_DMA, iobase + HCR);
 
 	/* Choose DMA Rx, DMA Fairness, and Advanced mode */
 	switch_bank(iobase, SET2);
-	outb((inb(iobase+ADCR1) & ~ADCR1_D_CHSW)/*|ADCR1_DMA_F*/|ADCR1_ADV_SL,
-	     iobase+ADCR1);
+	outb((inb(iobase + ADCR1) & ~ADCR1_D_CHSW)/*|ADCR1_DMA_F*/ | ADCR1_ADV_SL,
+	     iobase + ADCR1);
 
 	self->io.direction = IO_RECV;
 	self->rx_buff.data = self->rx_buff.head;
@@ -720,21 +720,21 @@ static int w83977af_dma_receive(struct w83977af_ir *self)
 	 * be finished transmitting yet
 	 */
 	switch_bank(iobase, SET0);
-	outb(UFR_RXTL|UFR_TXTL|UFR_RXF_RST|UFR_EN_FIFO, iobase+UFR);
+	outb(UFR_RXTL | UFR_TXTL | UFR_RXF_RST | UFR_EN_FIFO, iobase + UFR);
 	self->st_fifo.len = self->st_fifo.tail = self->st_fifo.head = 0;
 
 	/* Enable DMA */
 	switch_bank(iobase, SET0);
 #ifdef CONFIG_ARCH_NETWINDER
-	hcr = inb(iobase+HCR);
-	outb(hcr | HCR_EN_DMA, iobase+HCR);
+	hcr = inb(iobase + HCR);
+	outb(hcr | HCR_EN_DMA, iobase + HCR);
 	enable_dma(self->io.dma);
 	spin_unlock_irqrestore(&self->lock, flags);
 #else
-	outb(inb(iobase+HCR) | HCR_EN_DMA, iobase+HCR);
+	outb(inb(iobase + HCR) | HCR_EN_DMA, iobase + HCR);
 #endif
 	/* Restore set */
-	outb(set, iobase+SSR);
+	outb(set, iobase + SSR);
 
 	return 0;
 }
@@ -761,17 +761,17 @@ static int w83977af_dma_receive_complete(struct w83977af_ir *self)
 	iobase = self->io.fir_base;
 
 	/* Save current set */
-	set = inb(iobase+SSR);
+	set = inb(iobase + SSR);
 
 	iobase = self->io.fir_base;
 
 	/* Read status FIFO */
 	switch_bank(iobase, SET5);
-	while ((status = inb(iobase+FS_FO)) & FS_FO_FSFDR) {
+	while ((status = inb(iobase + FS_FO)) & FS_FO_FSFDR) {
 		st_fifo->entries[st_fifo->tail].status = status;
 
-		st_fifo->entries[st_fifo->tail].len  = inb(iobase+RFLFL);
-		st_fifo->entries[st_fifo->tail].len |= inb(iobase+RFLFH) << 8;
+		st_fifo->entries[st_fifo->tail].len  = inb(iobase + RFLFL);
+		st_fifo->entries[st_fifo->tail].len |= inb(iobase + RFLFH) << 8;
 
 		st_fifo->tail++;
 		st_fifo->len++;
@@ -814,16 +814,16 @@ static int w83977af_dma_receive_complete(struct w83977af_ir *self)
 		} else {
 			/* Check if we have transferred all data to memory */
 			switch_bank(iobase, SET0);
-			if (inb(iobase+USR) & USR_RDR) {
+			if (inb(iobase + USR) & USR_RDR) {
 				udelay(80); /* Should be enough!? */
 			}
 
-			skb = dev_alloc_skb(len+1);
+			skb = dev_alloc_skb(len + 1);
 			if (skb == NULL)  {
 				printk(KERN_INFO
 				       "%s(), memory squeeze, dropping frame.\n", __func__);
 				/* Restore set register */
-				outb(set, iobase+SSR);
+				outb(set, iobase + SSR);
 
 				return FALSE;
 			}
@@ -833,12 +833,12 @@ static int w83977af_dma_receive_complete(struct w83977af_ir *self)
 
 			/* Copy frame without CRC */
 			if (self->io.speed < 4000000) {
-				skb_put(skb, len-2);
+				skb_put(skb, len - 2);
 				skb_copy_to_linear_data(skb,
 							self->rx_buff.data,
 							len - 2);
 			} else {
-				skb_put(skb, len-4);
+				skb_put(skb, len - 4);
 				skb_copy_to_linear_data(skb,
 							self->rx_buff.data,
 							len - 4);
@@ -855,7 +855,7 @@ static int w83977af_dma_receive_complete(struct w83977af_ir *self)
 		}
 	}
 	/* Restore set register */
-	outb(set, iobase+SSR);
+	outb(set, iobase + SSR);
 
 	return TRUE;
 }
@@ -877,10 +877,10 @@ static void w83977af_pio_receive(struct w83977af_ir *self)
 
 	/*  Receive all characters in Rx FIFO */
 	do {
-		byte = inb(iobase+RBR);
+		byte = inb(iobase + RBR);
 		async_unwrap_char(self->netdev, &self->netdev->stats, &self->rx_buff,
 				  byte);
-	} while (inb(iobase+USR) & USR_RDR); /* Data available */
+	} while (inb(iobase + USR) & USR_RDR); /* Data available */
 }
 
 /*
@@ -896,7 +896,7 @@ static __u8 w83977af_sir_interrupt(struct w83977af_ir *self, int isr)
 	__u8 set;
 	int iobase;
 
-	pr_debug("%s(), isr=%#x\n", __func__ , isr);
+	pr_debug("%s(), isr=%#x\n", __func__, isr);
 
 	iobase = self->io.fir_base;
 	/* Transmit FIFO low on data */
@@ -916,10 +916,10 @@ static __u8 w83977af_sir_interrupt(struct w83977af_ir *self, int isr)
 		if (self->tx_buff.len > 0) {
 			new_icr |= ICR_ETXTHI;
 		} else {
-			set = inb(iobase+SSR);
+			set = inb(iobase + SSR);
 			switch_bank(iobase, SET0);
-			outb(AUDR_SFEND, iobase+AUDR);
-			outb(set, iobase+SSR);
+			outb(AUDR_SFEND, iobase + AUDR);
+			outb(set, iobase + SSR);
 
 			self->netdev->stats.tx_packets++;
 
@@ -965,10 +965,10 @@ static __u8 w83977af_fir_interrupt(struct w83977af_ir *self, int isr)
 	int iobase;
 
 	iobase = self->io.fir_base;
-	set = inb(iobase+SSR);
+	set = inb(iobase + SSR);
 
 	/* End of frame detected in FIFO */
-	if (isr & (ISR_FEND_I|ISR_FSF_I)) {
+	if (isr & (ISR_FEND_I | ISR_FSF_I)) {
 		if (w83977af_dma_receive_complete(self)) {
 
 			/* Wait for next status FIFO interrupt */
@@ -978,11 +978,11 @@ static __u8 w83977af_fir_interrupt(struct w83977af_ir *self, int isr)
 
 			/* Set timer value, resolution 1 ms */
 			switch_bank(iobase, SET4);
-			outb(0x01, iobase+TMRL); /* 1 ms */
-			outb(0x00, iobase+TMRH);
+			outb(0x01, iobase + TMRL); /* 1 ms */
+			outb(0x00, iobase + TMRH);
 
 			/* Start timer */
-			outb(IR_MSL_EN_TMR, iobase+IR_MSL);
+			outb(IR_MSL_EN_TMR, iobase + IR_MSL);
 
 			new_icr |= ICR_ETMRI;
 		}
@@ -991,7 +991,7 @@ static __u8 w83977af_fir_interrupt(struct w83977af_ir *self, int isr)
 	if (isr & ISR_TMR_I) {
 		/* Disable timer */
 		switch_bank(iobase, SET4);
-		outb(0, iobase+IR_MSL);
+		outb(0, iobase + IR_MSL);
 
 		/* Clear timer event */
 		/* switch_bank(iobase, SET0); */
@@ -1026,7 +1026,7 @@ static __u8 w83977af_fir_interrupt(struct w83977af_ir *self, int isr)
 	}
 
 	/* Restore set */
-	outb(set, iobase+SSR);
+	outb(set, iobase + SSR);
 
 	return new_icr;
 }
@@ -1049,24 +1049,24 @@ static irqreturn_t w83977af_interrupt(int irq, void *dev_id)
 	iobase = self->io.fir_base;
 
 	/* Save current bank */
-	set = inb(iobase+SSR);
+	set = inb(iobase + SSR);
 	switch_bank(iobase, SET0);
 
-	icr = inb(iobase+ICR);
-	isr = inb(iobase+ISR) & icr; /* Mask out the interesting ones */
+	icr = inb(iobase + ICR);
+	isr = inb(iobase + ISR) & icr; /* Mask out the interesting ones */
 
-	outb(0, iobase+ICR); /* Disable interrupts */
+	outb(0, iobase + ICR); /* Disable interrupts */
 
 	if (isr) {
 		/* Dispatch interrupt handler for the current speed */
-		if (self->io.speed > PIO_MAX_SPEED )
+		if (self->io.speed > PIO_MAX_SPEED)
 			icr = w83977af_fir_interrupt(self, isr);
 		else
 			icr = w83977af_sir_interrupt(self, isr);
 	}
 
-	outb(icr, iobase+ICR);    /* Restore (new) interrupts */
-	outb(set, iobase+SSR);    /* Restore bank register */
+	outb(icr, iobase + ICR);    /* Restore (new) interrupts */
+	outb(set, iobase + SSR);    /* Restore bank register */
 	return IRQ_RETVAL(isr);
 }
 
@@ -1088,13 +1088,13 @@ static int w83977af_is_receiving(struct w83977af_ir *self)
 		iobase = self->io.fir_base;
 
 		/* Check if rx FIFO is not empty */
-		set = inb(iobase+SSR);
+		set = inb(iobase + SSR);
 		switch_bank(iobase, SET2);
-		if ((inb(iobase+RXFDTH) & 0x3f) != 0) {
+		if ((inb(iobase + RXFDTH) & 0x3f) != 0) {
 			/* We are receiving something */
 			status =  TRUE;
 		}
-		outb(set, iobase+SSR);
+		outb(set, iobase + SSR);
 	} else
 		status = (self->rx_buff.state != OUTSIDE_FRAME);
 
@@ -1123,7 +1123,7 @@ static int w83977af_net_open(struct net_device *dev)
 	iobase = self->io.fir_base;
 
 	if (request_irq(self->io.irq, w83977af_interrupt, 0, dev->name,
-			(void *) dev)) {
+			(void *)dev)) {
 		return -EAGAIN;
 	}
 	/*
@@ -1136,18 +1136,18 @@ static int w83977af_net_open(struct net_device *dev)
 	}
 
 	/* Save current set */
-	set = inb(iobase+SSR);
+	set = inb(iobase + SSR);
 
 	/* Enable some interrupts so we can receive frames again */
 	switch_bank(iobase, SET0);
 	if (self->io.speed > 115200) {
-		outb(ICR_EFSFI, iobase+ICR);
+		outb(ICR_EFSFI, iobase + ICR);
 		w83977af_dma_receive(self);
 	} else
-		outb(ICR_ERBRI, iobase+ICR);
+		outb(ICR_ERBRI, iobase + ICR);
 
 	/* Restore bank register */
-	outb(set, iobase+SSR);
+	outb(set, iobase + SSR);
 
 	/* Ready to play! */
 	netif_start_queue(dev);
@@ -1195,17 +1195,17 @@ static int w83977af_net_close(struct net_device *dev)
 	disable_dma(self->io.dma);
 
 	/* Save current set */
-	set = inb(iobase+SSR);
+	set = inb(iobase + SSR);
 
 	/* Disable interrupts */
 	switch_bank(iobase, SET0);
-	outb(0, iobase+ICR);
+	outb(0, iobase + ICR);
 
 	free_irq(self->io.irq, dev);
 	free_dma(self->io.dma);
 
 	/* Restore bank register */
-	outb(set, iobase+SSR);
+	outb(set, iobase + SSR);
 
 	return 0;
 }
@@ -1218,7 +1218,7 @@ static int w83977af_net_close(struct net_device *dev)
  */
 static int w83977af_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct if_irda_req *irq = (struct if_irda_req *) rq;
+	struct if_irda_req *irq = (struct if_irda_req *)rq;
 	struct w83977af_ir *self;
 	unsigned long flags;
 	int ret = 0;
@@ -1229,7 +1229,7 @@ static int w83977af_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
-	pr_debug("%s(), %s, (cmd=0x%X)\n", __func__ , dev->name, cmd);
+	pr_debug("%s(), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
 
 	spin_lock_irqsave(&self->lock, flags);
 
-- 
2.10.0.rc2.1.g053435c
