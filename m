From: Joe Perches <joe@perches.com>
Subject: [PATCH 08/10] drivers/net: Remove unnecessary casts of netdev_priv
Date: Mon, 15 Nov 2010 13:12:31 -0800
Message-ID: <8b57be072e62f8f7d39d4ecd9ce5c999e4f8bbdc.1289855436.git.joe@perches.com>
References: <cover.1289855436.git.joe@perches.com>
Cc: Paul Gortmaker <p_gortmaker@yahoo.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1393 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758323Ab0KOVMs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Nov 2010 16:12:48 -0500
In-Reply-To: <cover.1289855436.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ax88796.c         |    8 ++++----
 drivers/net/dm9000.c          |    2 +-
 drivers/net/iseries_veth.c    |    2 +-
 drivers/net/lib8390.c         |   24 ++++++++++++------------
 drivers/net/ne-h8300.c        |   12 ++++++------
 drivers/net/xilinx_emaclite.c |   20 ++++++++++----------
 6 files changed, 34 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index b6da4cf..4bebff3 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -325,7 +325,7 @@ static void ax_block_output(struct net_device *dev, int count,
 static void
 ax_mii_ei_outbits(struct net_device *dev, unsigned int bits, int len)
 {
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 	void __iomem *memr_addr = (void __iomem *)dev->base_addr + AX_MEMR;
 	unsigned int memr;
 
@@ -364,7 +364,7 @@ ax_mii_ei_outbits(struct net_device *dev, unsigned int bits, int len)
 static unsigned int
 ax_phy_ei_inbits(struct net_device *dev, int no)
 {
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 	void __iomem *memr_addr = (void __iomem *)dev->base_addr + AX_MEMR;
 	unsigned int memr;
 	unsigned int result = 0;
@@ -412,7 +412,7 @@ ax_phy_issueaddr(struct net_device *dev, int phy_addr, int reg, int opc)
 static int
 ax_phy_read(struct net_device *dev, int phy_addr, int reg)
 {
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 	unsigned long flags;
  	unsigned int result;
 
@@ -435,7 +435,7 @@ ax_phy_read(struct net_device *dev, int phy_addr, int reg)
 static void
 ax_phy_write(struct net_device *dev, int phy_addr, int reg, int value)
 {
-	struct ei_device *ei = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei = netdev_priv(dev);
 	struct ax_device  *ax = to_ax_dev(dev);
 	unsigned long flags;
 
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 9f6aeef..2d4c4fc 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -1675,7 +1675,7 @@ dm9000_drv_remove(struct platform_device *pdev)
 	platform_set_drvdata(pdev, NULL);
 
 	unregister_netdev(ndev);
-	dm9000_release_board(pdev, (board_info_t *) netdev_priv(ndev));
+	dm9000_release_board(pdev, netdev_priv(ndev));
 	free_netdev(ndev);		/* free device structure */
 
 	dev_dbg(&pdev->dev, "released and freed device\n");
diff --git a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
index 8df645e..38e15be 100644
--- a/drivers/net/iseries_veth.c
+++ b/drivers/net/iseries_veth.c
@@ -1605,7 +1605,7 @@ static int veth_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 	}
 	veth_dev[i] = dev;
 
-	port = (struct veth_port*)netdev_priv(dev);
+	port = netdev_priv(dev);
 
 	/* Start the state machine on each connection on this vlan. If we're
 	 * the first dev to do so this will commence link negotiation */
diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index e7030ce..da74db4 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -203,7 +203,7 @@ static void __NS8390_init(struct net_device *dev, int startp);
 static int __ei_open(struct net_device *dev)
 {
 	unsigned long flags;
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 
 	if (dev->watchdog_timeo <= 0)
 		 dev->watchdog_timeo = TX_TIMEOUT;
@@ -231,7 +231,7 @@ static int __ei_open(struct net_device *dev)
  */
 static int __ei_close(struct net_device *dev)
 {
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 	unsigned long flags;
 
 	/*
@@ -256,7 +256,7 @@ static int __ei_close(struct net_device *dev)
 static void __ei_tx_timeout(struct net_device *dev)
 {
 	unsigned long e8390_base = dev->base_addr;
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 	int txsr, isr, tickssofar = jiffies - dev_trans_start(dev);
 	unsigned long flags;
 
@@ -303,7 +303,7 @@ static netdev_tx_t __ei_start_xmit(struct sk_buff *skb,
 				   struct net_device *dev)
 {
 	unsigned long e8390_base = dev->base_addr;
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 	int send_length = skb->len, output_page;
 	unsigned long flags;
 	char buf[ETH_ZLEN];
@@ -592,7 +592,7 @@ static void ei_tx_err(struct net_device *dev)
 static void ei_tx_intr(struct net_device *dev)
 {
 	unsigned long e8390_base = dev->base_addr;
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 	int status = ei_inb(e8390_base + EN0_TSR);
 
 	ei_outb_p(ENISR_TX, e8390_base + EN0_ISR); /* Ack intr. */
@@ -675,7 +675,7 @@ static void ei_tx_intr(struct net_device *dev)
 static void ei_receive(struct net_device *dev)
 {
 	unsigned long e8390_base = dev->base_addr;
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 	unsigned char rxing_page, this_frame, next_frame;
 	unsigned short current_offset;
 	int rx_pkt_count = 0;
@@ -879,7 +879,7 @@ static void ei_rx_overrun(struct net_device *dev)
 static struct net_device_stats *__ei_get_stats(struct net_device *dev)
 {
 	unsigned long ioaddr = dev->base_addr;
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 	unsigned long flags;
 
 	/* If the card is stopped, just return the present stats. */
@@ -927,7 +927,7 @@ static void do_set_multicast_list(struct net_device *dev)
 {
 	unsigned long e8390_base = dev->base_addr;
 	int i;
-	struct ei_device *ei_local = (struct ei_device*)netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 
 	if (!(dev->flags&(IFF_PROMISC|IFF_ALLMULTI)))
 	{
@@ -981,7 +981,7 @@ static void do_set_multicast_list(struct net_device *dev)
 static void __ei_set_multicast_list(struct net_device *dev)
 {
 	unsigned long flags;
-	struct ei_device *ei_local = (struct ei_device*)netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 
 	spin_lock_irqsave(&ei_local->page_lock, flags);
 	do_set_multicast_list(dev);
@@ -998,7 +998,7 @@ static void __ei_set_multicast_list(struct net_device *dev)
 
 static void ethdev_setup(struct net_device *dev)
 {
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 	if (ei_debug > 1)
 		printk(version);
 
@@ -1036,7 +1036,7 @@ static struct net_device *____alloc_ei_netdev(int size)
 static void __NS8390_init(struct net_device *dev, int startp)
 {
 	unsigned long e8390_base = dev->base_addr;
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 	int i;
 	int endcfg = ei_local->word16
 	    ? (0x48 | ENDCFG_WTS | (ei_local->bigendian ? ENDCFG_BOS : 0))
@@ -1099,7 +1099,7 @@ static void NS8390_trigger_send(struct net_device *dev, unsigned int length,
 								int start_page)
 {
 	unsigned long e8390_base = dev->base_addr;
- 	struct ei_device *ei_local __attribute((unused)) = (struct ei_device *) netdev_priv(dev);
+ 	struct ei_device *ei_local __attribute((unused)) = netdev_priv(dev);
 
 	ei_outb_p(E8390_NODMA+E8390_PAGE0, e8390_base+E8390_CMD);
 
diff --git a/drivers/net/ne-h8300.c b/drivers/net/ne-h8300.c
index e0b0ef1..30be8c6 100644
--- a/drivers/net/ne-h8300.c
+++ b/drivers/net/ne-h8300.c
@@ -86,7 +86,7 @@ static u32 reg_offset[16];
 
 static int __init init_reg_offset(struct net_device *dev,unsigned long base_addr)
 {
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 	int i;
 	unsigned char bus_width;
 
@@ -218,7 +218,7 @@ static int __init ne_probe1(struct net_device *dev, int ioaddr)
 	int start_page, stop_page;
 	int reg0, ret;
 	static unsigned version_printed;
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 	unsigned char bus_width;
 
 	if (!request_region(ioaddr, NE_IO_EXTENT, DRV_NAME))
@@ -371,7 +371,7 @@ static int ne_close(struct net_device *dev)
 static void ne_reset_8390(struct net_device *dev)
 {
 	unsigned long reset_start_time = jiffies;
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 
 	if (ei_debug > 1)
 		printk(KERN_DEBUG "resetting the 8390 t=%ld...", jiffies);
@@ -397,7 +397,7 @@ static void ne_reset_8390(struct net_device *dev)
 
 static void ne_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr, int ring_page)
 {
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 	/* This *shouldn't* happen. If it does, it's the last thing you'll see */
 
 	if (ei_status.dmaing)
@@ -437,7 +437,7 @@ static void ne_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr, i
 
 static void ne_block_input(struct net_device *dev, int count, struct sk_buff *skb, int ring_offset)
 {
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 #ifdef NE_SANITY_CHECK
 	int xfer_count = count;
 #endif
@@ -507,7 +507,7 @@ static void ne_block_input(struct net_device *dev, int count, struct sk_buff *sk
 static void ne_block_output(struct net_device *dev, int count,
 		const unsigned char *buf, const int start_page)
 {
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 	unsigned long dma_start;
 #ifdef NE_SANITY_CHECK
 	int retries = 0;
diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclite.c
index 14f0955..2de52d1 100644
--- a/drivers/net/xilinx_emaclite.c
+++ b/drivers/net/xilinx_emaclite.c
@@ -515,7 +515,7 @@ static void xemaclite_update_address(struct net_local *drvdata,
  */
 static int xemaclite_set_mac_address(struct net_device *dev, void *address)
 {
-	struct net_local *lp = (struct net_local *) netdev_priv(dev);
+	struct net_local *lp = netdev_priv(dev);
 	struct sockaddr *addr = address;
 
 	if (netif_running(dev))
@@ -534,7 +534,7 @@ static int xemaclite_set_mac_address(struct net_device *dev, void *address)
  */
 static void xemaclite_tx_timeout(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *) netdev_priv(dev);
+	struct net_local *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	dev_err(&lp->ndev->dev, "Exceeded transmit timeout of %lu ms\n",
@@ -578,7 +578,7 @@ static void xemaclite_tx_timeout(struct net_device *dev)
  */
 static void xemaclite_tx_handler(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *) netdev_priv(dev);
+	struct net_local *lp = netdev_priv(dev);
 
 	dev->stats.tx_packets++;
 	if (lp->deferred_skb) {
@@ -605,7 +605,7 @@ static void xemaclite_tx_handler(struct net_device *dev)
  */
 static void xemaclite_rx_handler(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *) netdev_priv(dev);
+	struct net_local *lp = netdev_priv(dev);
 	struct sk_buff *skb;
 	unsigned int align;
 	u32 len;
@@ -661,7 +661,7 @@ static irqreturn_t xemaclite_interrupt(int irq, void *dev_id)
 {
 	bool tx_complete = 0;
 	struct net_device *dev = dev_id;
-	struct net_local *lp = (struct net_local *) netdev_priv(dev);
+	struct net_local *lp = netdev_priv(dev);
 	void __iomem *base_addr = lp->base_addr;
 	u32 tx_status;
 
@@ -918,7 +918,7 @@ void xemaclite_adjust_link(struct net_device *ndev)
  */
 static int xemaclite_open(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *) netdev_priv(dev);
+	struct net_local *lp = netdev_priv(dev);
 	int retval;
 
 	/* Just to be safe, stop the device first */
@@ -987,7 +987,7 @@ static int xemaclite_open(struct net_device *dev)
  */
 static int xemaclite_close(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *) netdev_priv(dev);
+	struct net_local *lp = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 	xemaclite_disable_interrupts(lp);
@@ -1031,7 +1031,7 @@ static struct net_device_stats *xemaclite_get_stats(struct net_device *dev)
  */
 static int xemaclite_send(struct sk_buff *orig_skb, struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *) netdev_priv(dev);
+	struct net_local *lp = netdev_priv(dev);
 	struct sk_buff *new_skb;
 	unsigned int len;
 	unsigned long flags;
@@ -1068,7 +1068,7 @@ static int xemaclite_send(struct sk_buff *orig_skb, struct net_device *dev)
 static void xemaclite_remove_ndev(struct net_device *ndev)
 {
 	if (ndev) {
-		struct net_local *lp = (struct net_local *) netdev_priv(ndev);
+		struct net_local *lp = netdev_priv(ndev);
 
 		if (lp->base_addr)
 			iounmap((void __iomem __force *) (lp->base_addr));
@@ -1245,7 +1245,7 @@ static int __devexit xemaclite_of_remove(struct platform_device *of_dev)
 	struct device *dev = &of_dev->dev;
 	struct net_device *ndev = dev_get_drvdata(dev);
 
-	struct net_local *lp = (struct net_local *) netdev_priv(ndev);
+	struct net_local *lp = netdev_priv(ndev);
 
 	/* Un-register the mii_bus, if configured */
 	if (lp->has_mdio) {
-- 
1.7.3.1.g432b3.dirty

