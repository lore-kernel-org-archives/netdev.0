From: Ralf Baechle <ralf@linux-mips.org>
Subject: [MIPS] MIPSnet: Delete all the useless debugging printks.
Date: Tue, 23 Oct 2007 00:35:26 +0100
Message-ID: <20071022233526.GA3301@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:55352 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752785AbXJVXfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 19:35:39 -0400
Received: from localhost.localdomain ([127.0.0.1]:2006 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20024813AbXJVXfh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 00:35:37 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Plus minor formatting fixes.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
---

 drivers/net/mipsnet.c |   44 ++++----------------------------------------
 1 file changed, 4 insertions(+), 40 deletions(-)

diff --git a/drivers/net/mipsnet.c b/drivers/net/mipsnet.c
index 37707a0..aafc3ce 100644
--- a/drivers/net/mipsnet.c
+++ b/drivers/net/mipsnet.c
@@ -30,6 +30,7 @@ static int ioiocpy_frommipsnet(struct net_device *dev, unsigned char *kdata,
 			int len)
 {
 	uint32_t available_len = inl(mipsnet_reg_address(dev, rxDataCount));
+
 	if (available_len < len)
 		return -EFAULT;
 
@@ -45,14 +46,8 @@ static inline ssize_t mipsnet_put_todevice(struct net_device *dev,
 	int count_to_go = skb->len;
 	char *buf_ptr = skb->data;
 
-	pr_debug("%s: %s(): telling MIPSNET txDataCount(%d)\n",
-		 dev->name, __FUNCTION__, skb->len);
-
 	outl(skb->len, mipsnet_reg_address(dev, txDataCount));
 
-	pr_debug("%s: %s(): sending data to MIPSNET txDataBuffer(%d)\n",
-		 dev->name, __FUNCTION__, skb->len);
-
 	for (; count_to_go; buf_ptr++, count_to_go--)
 		outb(*buf_ptr, mipsnet_reg_address(dev, txDataBuffer));
 
@@ -64,10 +59,8 @@ static inline ssize_t mipsnet_put_todevice(struct net_device *dev,
 
 static int mipsnet_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	pr_debug("%s:%s(): transmitting %d bytes\n",
-		 dev->name, __FUNCTION__, skb->len);
-
-	/* Only one packet at a time. Once TXDONE interrupt is serviced, the
+	/*
+	 * Only one packet at a time. Once TXDONE interrupt is serviced, the
 	 * queue will be restarted.
 	 */
 	netif_stop_queue(dev);
@@ -94,8 +87,6 @@ static inline ssize_t mipsnet_get_fromdev(struct net_device *dev, size_t count)
 	skb->protocol = eth_type_trans(skb, dev);
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-	pr_debug("%s:%s(): pushing RXed data to kernel\n",
-		 dev->name, __FUNCTION__);
 	netif_rx(skb);
 
 	dev->stats.rx_packets++;
@@ -112,44 +103,29 @@ static irqreturn_t mipsnet_interrupt(int irq, void *dev_id)
 	uint64_t interruptFlags;
 
 	if (irq == dev->irq) {
-		pr_debug("%s:%s(): irq %d for device\n",
-			 dev->name, __FUNCTION__, irq);
-
 		retval = IRQ_HANDLED;
 
 		interruptFlags =
 		    inl(mipsnet_reg_address(dev, interruptControl));
-		pr_debug("%s:%s(): intCtl=0x%016llx\n", dev->name,
-			 __FUNCTION__, interruptFlags);
 
 		if (interruptFlags & MIPSNET_INTCTL_TXDONE) {
-			pr_debug("%s:%s(): got TXDone\n",
-				 dev->name, __FUNCTION__);
 			outl(MIPSNET_INTCTL_TXDONE,
 			     mipsnet_reg_address(dev, interruptControl));
 			/* only one packet at a time, we are done. */
 			netif_wake_queue(dev);
 		} else if (interruptFlags & MIPSNET_INTCTL_RXDONE) {
-			pr_debug("%s:%s(): got RX data\n",
-				 dev->name, __FUNCTION__);
 			mipsnet_get_fromdev(dev,
 				    inl(mipsnet_reg_address(dev, rxDataCount)));
-			pr_debug("%s:%s(): clearing RX int\n",
-				 dev->name, __FUNCTION__);
 			outl(MIPSNET_INTCTL_RXDONE,
 			     mipsnet_reg_address(dev, interruptControl));
 
 		} else if (interruptFlags & MIPSNET_INTCTL_TESTBIT) {
-			pr_debug("%s:%s(): got test interrupt\n",
-				 dev->name, __FUNCTION__);
 			/*
 			 * TESTBIT is cleared on read.
 			 * And takes effect after a write with 0
 			 */
 			outl(0, mipsnet_reg_address(dev, interruptControl));
 		} else {
-			pr_debug("%s:%s(): no valid fags 0x%016llx\n",
-				 dev->name, __FUNCTION__, interruptFlags);
 			/* Maybe shared IRQ, just ignore, no clearing. */
 			retval = IRQ_NONE;
 		}
@@ -165,22 +141,15 @@ static irqreturn_t mipsnet_interrupt(int irq, void *dev_id)
 static int mipsnet_open(struct net_device *dev)
 {
 	int err;
-	pr_debug("%s: mipsnet_open\n", dev->name);
 
 	err = request_irq(dev->irq, &mipsnet_interrupt,
 			  IRQF_SHARED, dev->name, (void *) dev);
 
 	if (err) {
-		pr_debug("%s: %s(): can't get irq %d\n",
-			 dev->name, __FUNCTION__, dev->irq);
 		release_region(dev->base_addr, MIPSNET_IO_EXTENT);
 		return err;
 	}
 
-	pr_debug("%s: %s(): got IO region at 0x%04lx and irq %d for dev.\n",
-		 dev->name, __FUNCTION__, dev->base_addr, dev->irq);
-
-
 	netif_start_queue(dev);
 
 	/* test interrupt handler */
@@ -193,8 +162,8 @@ static int mipsnet_open(struct net_device *dev)
 
 static int mipsnet_close(struct net_device *dev)
 {
-	pr_debug("%s: %s()\n", dev->name, __FUNCTION__);
 	netif_stop_queue(dev);
+
 	return 0;
 }
 
@@ -229,9 +198,6 @@ static int __init mipsnet_probe(struct device *dev)
 
 	/* Get the io region now, get irq on open() */
 	if (!request_region(netdev->base_addr, MIPSNET_IO_EXTENT, "mipsnet")) {
-		pr_debug("%s: %s(): IO region {start: 0x%04lux, len: %d} "
-			 "for dev is not availble.\n", netdev->name,
-			 __FUNCTION__, netdev->base_addr, MIPSNET_IO_EXTENT);
 		err = -EBUSY;
 		goto out_free_netdev;
 	}
@@ -295,8 +261,6 @@ static int __init mipsnet_init_module(void)
 
 static void __exit mipsnet_exit_module(void)
 {
-	pr_debug("MIPSNet Ethernet driver exiting\n");
-
 	driver_unregister(&mipsnet_driver);
 }
 
