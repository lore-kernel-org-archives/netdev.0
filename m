From: Frans Pop <elendil@planet.nl>
Subject: [PATCH 5/9] net/smc91xx: remove trailing space in messages
Date: Wed, 24 Mar 2010 18:57:32 +0100
Message-ID: <1269453456-13599-5-git-send-email-elendil@planet.nl>
References: <201003241840.18701.elendil@planet.nl>
Cc: Frans Pop <elendil@planet.nl>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201003241840.18701.elendil@planet.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Includes a few whitespace fixes to placate checkpatch.

Signed-off-by: Frans Pop <elendil@planet.nl>
---

Note that in drivers/net/smc911x.c, line 1139 there seems to be a
parameter missing (for %d):
   DBG(SMC_DEBUG_TX, "%s: TX status FIFO limit (%d) irq\n", dev->name, );
---
 drivers/net/smc911x.c |    6 +++---
 drivers/net/smc9194.c |   40 ++++++++++++++++++++--------------------
 drivers/net/smc91x.c  |    2 +-
 3 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 9871a2b..0f97b5a 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -383,7 +383,7 @@ static inline void	 smc911x_rcv(struct net_device *dev)
 	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_RX, "%s: --> %s\n",
 		dev->name, __func__);
 	status = SMC_GET_RX_STS_FIFO(lp);
-	DBG(SMC_DEBUG_RX, "%s: Rx pkt len %d status 0x%08x \n",
+	DBG(SMC_DEBUG_RX, "%s: Rx pkt len %d status 0x%08x\n",
 		dev->name, (status & 0x3fff0000) >> 16, status & 0xc000ffff);
 	pkt_len = (status & RX_STS_PKT_LEN_) >> 16;
 	if (status & RX_STS_ES_) {
@@ -1136,7 +1136,7 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 		}
 #else
 		if (status & INT_STS_TSFL_) {
-			DBG(SMC_DEBUG_TX, "%s: TX status FIFO limit (%d) irq \n", dev->name, );
+			DBG(SMC_DEBUG_TX, "%s: TX status FIFO limit (%d) irq\n", dev->name, );
 			smc911x_tx(dev);
 			SMC_ACK_INT(lp, INT_STS_TSFL_);
 		}
@@ -1275,7 +1275,7 @@ static void smc911x_timeout(struct net_device *dev)
 	status = SMC_GET_INT(lp);
 	mask = SMC_GET_INT_EN(lp);
 	spin_unlock_irqrestore(&lp->lock, flags);
-	DBG(SMC_DEBUG_MISC, "%s: INT 0x%02x MASK 0x%02x \n",
+	DBG(SMC_DEBUG_MISC, "%s: INT 0x%02x MASK 0x%02x\n",
 		dev->name, status, mask);
 
 	/* Dump the current TX FIFO contents and restart */
diff --git a/drivers/net/smc9194.c b/drivers/net/smc9194.c
index f9a960e..ee14877 100644
--- a/drivers/net/smc9194.c
+++ b/drivers/net/smc9194.c
@@ -529,7 +529,7 @@ static netdev_tx_t smc_wait_to_send_packet(struct sk_buff *skb,
 	numPages =  ((length & 0xfffe) + 6) / 256;
 
 	if (numPages > 7 ) {
-		printk(CARDNAME": Far too big packet error. \n");
+		printk(CARDNAME": Far too big packet error.\n");
 		/* freeing the packet is a good thing here... but should
 		 . any packets of this size get down here?   */
 		dev_kfree_skb (skb);
@@ -571,9 +571,9 @@ static netdev_tx_t smc_wait_to_send_packet(struct sk_buff *skb,
    	if ( !time_out ) {
 		/* oh well, wait until the chip finds memory later */
 		SMC_ENABLE_INT( IM_ALLOC_INT );
-      		PRINTK2((CARDNAME": memory allocation deferred. \n"));
+		PRINTK2((CARDNAME": memory allocation deferred.\n"));
 		/* it's deferred, but I'll handle it later */
-      		return NETDEV_TX_OK;
+		return NETDEV_TX_OK;
    	}
 	/* or YES! I can send the packet now.. */
 	smc_hardware_send_packet(dev);
@@ -611,7 +611,7 @@ static void smc_hardware_send_packet( struct net_device * dev )
 	ioaddr = dev->base_addr;
 
 	if ( !skb ) {
-		PRINTK((CARDNAME": In XMIT with no packet to send \n"));
+		PRINTK((CARDNAME": In XMIT with no packet to send\n"));
 		return;
 	}
 	length = ETH_ZLEN < skb->len ? skb->len : ETH_ZLEN;
@@ -621,7 +621,7 @@ static void smc_hardware_send_packet( struct net_device * dev )
 	packet_no = inb( ioaddr + PNR_ARR + 1 );
 	if ( packet_no & 0x80 ) {
 		/* or isn't there?  BAD CHIP! */
-		printk(KERN_DEBUG CARDNAME": Memory allocation failed. \n");
+		printk(KERN_DEBUG CARDNAME": Memory allocation failed.\n");
 		dev_kfree_skb_any(skb);
 		lp->saved_skb = NULL;
 		netif_wake_queue(dev);
@@ -686,7 +686,7 @@ static void smc_hardware_send_packet( struct net_device * dev )
 	/* and let the chipset deal with it */
 	outw( MC_ENQUEUE , ioaddr + MMU_CMD );
 
-	PRINTK2((CARDNAME": Sent packet of length %d \n",length));
+	PRINTK2((CARDNAME": Sent packet of length %d\n", length));
 
 	lp->saved_skb = NULL;
 	dev_kfree_skb_any (skb);
@@ -938,7 +938,7 @@ static int __init smc_probe(struct net_device *dev, int ioaddr)
 	if ( !chip_ids[ ( revision_register  >> 4 ) & 0xF  ] ) {
 		/* I don't recognize this chip, so... */
 		printk(CARDNAME ": IO %x: Unrecognized revision register:"
-			" %x, Contact author. \n", ioaddr, revision_register );
+			" %x, Contact author.\n", ioaddr, revision_register);
 
 		retval = -ENODEV;
 		goto err_out;
@@ -1075,7 +1075,7 @@ static void print_packet( byte * buf, int length )
 	int remainder;
 	int lines;
 
-	printk("Packet of length %d \n", length );
+	printk("Packet of length %d\n", length);
 	lines = length / 16;
 	remainder = length % 16;
 
@@ -1202,7 +1202,7 @@ static void smc_rcv(struct net_device *dev)
 
 	if ( packet_number & FP_RXEMPTY ) {
 		/* we got called , but nothing was on the FIFO */
-		PRINTK((CARDNAME ": WARNING: smc_rcv with nothing on FIFO. \n"));
+		PRINTK((CARDNAME ": WARNING: smc_rcv with nothing on FIFO.\n"));
 		/* don't need to restore anything */
 		return;
 	}
@@ -1258,14 +1258,14 @@ static void smc_rcv(struct net_device *dev)
 		   to send the DWORDs or the bytes first, or some
 		   mixture.  A mixture might improve already slow PIO
 		   performance  */
-		PRINTK3((" Reading %d dwords (and %d bytes) \n",
+		PRINTK3((" Reading %d dwords (and %d bytes)\n",
 			packet_length >> 2, packet_length & 3 ));
 		insl(ioaddr + DATA_1 , data, packet_length >> 2 );
 		/* read the left over bytes */
 		insb( ioaddr + DATA_1, data + (packet_length & 0xFFFFFC),
 			packet_length & 0x3  );
 #else
-		PRINTK3((" Reading %d words and %d byte(s) \n",
+		PRINTK3((" Reading %d words and %d byte(s)\n",
 			(packet_length >> 1 ), packet_length & 1 ));
 		insw(ioaddr + DATA_1 , data, packet_length >> 1);
 		if ( packet_length & 1 ) {
@@ -1334,7 +1334,7 @@ static void smc_tx( struct net_device * dev )
 	outw( PTR_AUTOINC | PTR_READ, ioaddr + POINTER );
 
 	tx_status = inw( ioaddr + DATA_1 );
-	PRINTK3((CARDNAME": TX DONE STATUS: %4x \n", tx_status ));
+	PRINTK3((CARDNAME": TX DONE STATUS: %4x\n", tx_status));
 
 	dev->stats.tx_errors++;
 	if ( tx_status & TS_LOSTCAR ) dev->stats.tx_carrier_errors++;
@@ -1348,7 +1348,7 @@ static void smc_tx( struct net_device * dev )
 #endif
 
 	if ( tx_status & TS_SUCCESS ) {
-		printk(CARDNAME": Successful packet caused interrupt \n");
+		printk(CARDNAME": Successful packet caused interrupt\n");
 	}
 	/* re-enable transmit */
 	SMC_SELECT_BANK( 0 );
@@ -1394,7 +1394,7 @@ static irqreturn_t smc_interrupt(int irq, void * dev_id)
 	int handled = 0;
 
 
-	PRINTK3((CARDNAME": SMC interrupt started \n"));
+	PRINTK3((CARDNAME": SMC interrupt started\n"));
 
 	saved_bank = inw( ioaddr + BANK_SELECT );
 
@@ -1409,7 +1409,7 @@ static irqreturn_t smc_interrupt(int irq, void * dev_id)
 	/* set a timeout value, so I don't stay here forever */
 	timeout = 4;
 
-	PRINTK2((KERN_WARNING CARDNAME ": MASK IS %x \n", mask ));
+	PRINTK2((KERN_WARNING CARDNAME ": MASK IS %x\n", mask));
 	do {
 		/* read the status flag, and mask it */
 		status = inb( ioaddr + INTERRUPT ) & mask;
@@ -1419,7 +1419,7 @@ static irqreturn_t smc_interrupt(int irq, void * dev_id)
 		handled = 1;
 
 		PRINTK3((KERN_WARNING CARDNAME
-			": Handling interrupt status %x \n", status ));
+			": Handling interrupt status %x\n", status));
 
 		if (status & IM_RCV_INT) {
 			/* Got a packet(s). */
@@ -1453,7 +1453,7 @@ static irqreturn_t smc_interrupt(int irq, void * dev_id)
 
 		} else if (status & IM_ALLOC_INT ) {
 			PRINTK2((KERN_DEBUG CARDNAME
-				": Allocation interrupt \n"));
+				": Allocation interrupt\n"));
 			/* clear this interrupt so it doesn't happen again */
 			mask &= ~IM_ALLOC_INT;
 
@@ -1471,9 +1471,9 @@ static irqreturn_t smc_interrupt(int irq, void * dev_id)
 			dev->stats.rx_fifo_errors++;
 			outb( IM_RX_OVRN_INT, ioaddr + INTERRUPT );
 		} else if (status & IM_EPH_INT ) {
-			PRINTK((CARDNAME ": UNSUPPORTED: EPH INTERRUPT \n"));
+			PRINTK((CARDNAME ": UNSUPPORTED: EPH INTERRUPT\n"));
 		} else if (status & IM_ERCV_INT ) {
-			PRINTK((CARDNAME ": UNSUPPORTED: ERCV INTERRUPT \n"));
+			PRINTK((CARDNAME ": UNSUPPORTED: ERCV INTERRUPT\n"));
 			outb( IM_ERCV_INT, ioaddr + INTERRUPT );
 		}
 	} while ( timeout -- );
@@ -1483,7 +1483,7 @@ static irqreturn_t smc_interrupt(int irq, void * dev_id)
 	SMC_SELECT_BANK( 2 );
 	outb( mask, ioaddr + INT_MASK );
 
-	PRINTK3(( KERN_WARNING CARDNAME ": MASK is now %x \n", mask ));
+	PRINTK3((KERN_WARNING CARDNAME ": MASK is now %x\n", mask));
 	outw( saved_pointer, ioaddr + POINTER );
 
 	SMC_SELECT_BANK( saved_bank );
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index fc1b5a1..2e81338 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -1286,7 +1286,7 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
 			smc_phy_interrupt(dev);
 		} else if (status & IM_ERCV_INT) {
 			SMC_ACK_INT(lp, IM_ERCV_INT);
-			PRINTK("%s: UNSUPPORTED: ERCV INTERRUPT \n", dev->name);
+			PRINTK("%s: UNSUPPORTED: ERCV INTERRUPT\n", dev->name);
 		}
 	} while (--timeout);
 
-- 
1.6.6.1
