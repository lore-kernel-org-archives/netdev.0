From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/15] netdevice: safe convert to netdev_priv() #part-3
Date: Tue, 26 Aug 2008 22:18:24 +0800
Message-ID: <48B410B0.5050805@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59739 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755783AbYHZOUw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 10:20:52 -0400
In-Reply-To: <48B3D717.7070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index 0860cc2..484c5ca 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -521,7 +521,7 @@ static unsigned long __init lance_probe1( struct net_device *dev,
 	return( 0 );
 
   probe_ok:
-	lp = (struct lance_private *)dev->priv;
+	lp = netdev_priv(dev);
 	MEM = (struct lance_memory *)memaddr;
 	IO = lp->iobase = (struct lance_ioreg *)ioaddr;
 	dev->base_addr = (unsigned long)ioaddr; /* informational only */
@@ -640,8 +640,8 @@ static unsigned long __init lance_probe1( struct net_device *dev,
 
 
 static int lance_open( struct net_device *dev )
-
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{
+	struct lance_private *lp = netdev_priv(dev);
 	struct lance_ioreg	 *IO = lp->iobase;
 	int i;
 
@@ -681,8 +681,8 @@ static int lance_open( struct net_device *dev )
 /* Initialize the LANCE Rx and Tx rings. */
 
 static void lance_init_ring( struct net_device *dev )
-
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{
+	struct lance_private *lp = netdev_priv(dev);
 	int i;
 	unsigned offset;
 
@@ -730,7 +730,7 @@ static void lance_init_ring( struct net_device *dev )
 
 static void lance_tx_timeout (struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	struct lance_ioreg	 *IO = lp->iobase;
 
 	AREG = CSR0;
@@ -772,8 +772,8 @@ static void lance_tx_timeout (struct net_device *dev)
 /* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
 
 static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
-
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{
+	struct lance_private *lp = netdev_priv(dev);
 	struct lance_ioreg	 *IO = lp->iobase;
 	int entry, len;
 	struct lance_tx_head *head;
@@ -865,7 +865,7 @@ static irqreturn_t lance_interrupt( int irq, void *dev_id )
 		return IRQ_NONE;
 	}
 
-	lp = (struct lance_private *)dev->priv;
+	lp = netdev_priv(dev);
 	IO = lp->iobase;
 	spin_lock (&lp->devlock);
 
@@ -965,8 +965,8 @@ static irqreturn_t lance_interrupt( int irq, void *dev_id )
 
 
 static int lance_rx( struct net_device *dev )
-
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{
+	struct lance_private *lp = netdev_priv(dev);
 	int entry = lp->cur_rx & RX_RING_MOD_MASK;
 	int i;
 
@@ -1057,8 +1057,8 @@ static int lance_rx( struct net_device *dev )
 
 
 static int lance_close( struct net_device *dev )
-
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{
+	struct lance_private *lp = netdev_priv(dev);
 	struct lance_ioreg	 *IO = lp->iobase;
 
 	netif_stop_queue (dev);
@@ -1084,8 +1084,8 @@ static int lance_close( struct net_device *dev )
  */
 
 static void set_multicast_list( struct net_device *dev )
-
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{
+	struct lance_private *lp = netdev_priv(dev);
 	struct lance_ioreg	 *IO = lp->iobase;
 
 	if (netif_running(dev))
@@ -1126,8 +1126,8 @@ static void set_multicast_list( struct net_device *dev )
 /* This is needed for old RieblCards and possible for new RieblCards */
 
 static int lance_set_mac_address( struct net_device *dev, void *addr )
-
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{
+	struct lance_private *lp = netdev_priv(dev);
 	struct sockaddr *saddr = addr;
 	int i;
 
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 82d7be1..ae7ce44 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -2489,7 +2489,7 @@ static pci_ers_result_t
 atl1e_io_error_detected(struct pci_dev *pdev, pci_channel_state_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct atl1e_adapter *adapter = netdev->priv;
+	struct atl1e_adapter *adapter = netdev_priv(netdev);
 
 	netif_device_detach(netdev);
 
@@ -2512,7 +2512,7 @@ atl1e_io_error_detected(struct pci_dev *pdev, pci_channel_state_t state)
 static pci_ers_result_t atl1e_io_slot_reset(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct atl1e_adapter *adapter = netdev->priv;
+	struct atl1e_adapter *adapter = netdev_priv(netdev);
 
 	if (pci_enable_device(pdev)) {
 		dev_err(&pdev->dev,
@@ -2540,7 +2540,7 @@ static pci_ers_result_t atl1e_io_slot_reset(struct pci_dev *pdev)
 static void atl1e_io_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct atl1e_adapter *adapter = netdev->priv;
+	struct atl1e_adapter *adapter = netdev_priv(netdev);
 
 	if (netif_running(netdev)) {
 		if (atl1e_up(adapter)) {
diff --git a/drivers/net/atp.c b/drivers/net/atp.c
index c10cd80..eeb93c4 100644
--- a/drivers/net/atp.c
+++ b/drivers/net/atp.c
@@ -913,7 +913,8 @@ static void __exit atp_cleanup_module(void) {
 	struct net_device *next_dev;
 
 	while (root_atp_dev) {
-		next_dev = ((struct net_local *)root_atp_dev->priv)->next_module;
+		struct net_local *atp_local = netdev_priv(root_atp_dev);
+		next_dev = atp_local->next_module;
 		unregister_netdev(root_atp_dev);
 		/* No need to release_region(), since we never snarf it. */
 		free_netdev(root_atp_dev);
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 5ee1b05..9c4b8bd 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -193,7 +193,7 @@ struct au1000_private *au_macs[NUM_ETH_INTERFACES];
  */
 static int mdio_read(struct net_device *dev, int phy_addr, int reg)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	volatile u32 *const mii_control_reg = &aup->mac->mii_control;
 	volatile u32 *const mii_data_reg = &aup->mac->mii_data;
 	u32 timedout = 20;
@@ -227,7 +227,7 @@ static int mdio_read(struct net_device *dev, int phy_addr, int reg)
 
 static void mdio_write(struct net_device *dev, int phy_addr, int reg, u16 value)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	volatile u32 *const mii_control_reg = &aup->mac->mii_control;
 	volatile u32 *const mii_data_reg = &aup->mac->mii_data;
 	u32 timedout = 20;
@@ -282,7 +282,7 @@ static int mdiobus_reset(struct mii_bus *bus)
 
 static int mii_probe (struct net_device *dev)
 {
-	struct au1000_private *const aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 	struct phy_device *phydev = NULL;
 
 #if defined(AU1XXX_PHY_STATIC_CONFIG)
@@ -414,7 +414,7 @@ void ReleaseDB(struct au1000_private *aup, db_dest_t *pDB)
 
 static void enable_rx_tx(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	if (au1000_debug > 4)
 		printk(KERN_INFO "%s: enable_rx_tx\n", dev->name);
@@ -425,7 +425,7 @@ static void enable_rx_tx(struct net_device *dev)
 
 static void hard_stop(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	if (au1000_debug > 4)
 		printk(KERN_INFO "%s: hard stop\n", dev->name);
@@ -437,7 +437,7 @@ static void hard_stop(struct net_device *dev)
 static void enable_mac(struct net_device *dev, int force_reset)
 {
 	unsigned long flags;
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	spin_lock_irqsave(&aup->lock, flags);
 
@@ -456,7 +456,7 @@ static void enable_mac(struct net_device *dev, int force_reset)
 
 static void reset_mac_unlocked(struct net_device *dev)
 {
-	struct au1000_private *const aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 	int i;
 
 	hard_stop(dev);
@@ -482,7 +482,7 @@ static void reset_mac_unlocked(struct net_device *dev)
 
 static void reset_mac(struct net_device *dev)
 {
-	struct au1000_private *const aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 	unsigned long flags;
 
 	if (au1000_debug > 4)
@@ -571,7 +571,7 @@ static int __init au1000_init_module(void)
 
 static int au1000_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	if (aup->phy_dev)
 		return phy_ethtool_gset(aup->phy_dev, cmd);
@@ -581,7 +581,7 @@ static int au1000_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static int au1000_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -595,7 +595,7 @@ static int au1000_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 static void
 au1000_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
@@ -651,7 +651,7 @@ static struct net_device * au1000_probe(int port_num)
 	printk("%s: Au1xx0 Ethernet found at 0x%x, irq %d\n",
 		dev->name, base, irq);
 
-	aup = dev->priv;
+	aup = netdev_priv(dev);
 
 	/* Allocate the data buffers */
 	/* Snooping works fine with eth on all au1xxx */
@@ -806,7 +806,7 @@ err_out:
  */
 static int au1000_init(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	unsigned long flags;
 	int i;
 	u32 control;
@@ -857,7 +857,7 @@ static int au1000_init(struct net_device *dev)
 static void
 au1000_adjust_link(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	struct phy_device *phydev = aup->phy_dev;
 	unsigned long flags;
 
@@ -936,7 +936,7 @@ au1000_adjust_link(struct net_device *dev)
 static int au1000_open(struct net_device *dev)
 {
 	int retval;
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	if (au1000_debug > 4)
 		printk("%s: open: dev=%p\n", dev->name, dev);
@@ -971,7 +971,7 @@ static int au1000_open(struct net_device *dev)
 static int au1000_close(struct net_device *dev)
 {
 	unsigned long flags;
-	struct au1000_private *const aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 
 	if (au1000_debug > 4)
 		printk("%s: close: dev=%p\n", dev->name, dev);
@@ -1002,7 +1002,7 @@ static void __exit au1000_cleanup_module(void)
 	for (i = 0; i < num_ifs; i++) {
 		dev = iflist[i].dev;
 		if (dev) {
-			aup = (struct au1000_private *) dev->priv;
+			aup = netdev_priv(dev);
 			unregister_netdev(dev);
 			for (j = 0; j < NUM_RX_DMA; j++)
 				if (aup->rx_db_inuse[j])
@@ -1022,7 +1022,7 @@ static void __exit au1000_cleanup_module(void)
 
 static void update_tx_stats(struct net_device *dev, u32 status)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	struct net_device_stats *ps = &dev->stats;
 
 	if (status & TX_FRAME_ABORTED) {
@@ -1051,7 +1051,7 @@ static void update_tx_stats(struct net_device *dev, u32 status)
  */
 static void au1000_tx_ack(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	volatile tx_dma_t *ptxd;
 
 	ptxd = aup->tx_dma_ring[aup->tx_tail];
@@ -1078,7 +1078,7 @@ static void au1000_tx_ack(struct net_device *dev)
  */
 static int au1000_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	struct net_device_stats *ps = &dev->stats;
 	volatile tx_dma_t *ptxd;
 	u32 buff_stat;
@@ -1132,7 +1132,7 @@ static int au1000_tx(struct sk_buff *skb, struct net_device *dev)
 
 static inline void update_rx_stats(struct net_device *dev, u32 status)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	struct net_device_stats *ps = &dev->stats;
 
 	ps->rx_packets++;
@@ -1160,7 +1160,7 @@ static inline void update_rx_stats(struct net_device *dev, u32 status)
  */
 static int au1000_rx(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	struct sk_buff *skb;
 	volatile rx_dma_t *prxd;
 	u32 buff_stat, status;
@@ -1263,7 +1263,7 @@ static void au1000_tx_timeout(struct net_device *dev)
 
 static void set_rx_mode(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	if (au1000_debug > 4)
 		printk("%s: set_rx_mode: flags=%x\n", dev->name, dev->flags);
@@ -1295,7 +1295,7 @@ static void set_rx_mode(struct net_device *dev)
 
 static int au1000_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	if (!netif_running(dev)) return -EINVAL;
 
diff --git a/drivers/net/lp486e.c b/drivers/net/lp486e.c
index 83fa9d8..5d27ff9 100644
--- a/drivers/net/lp486e.c
+++ b/drivers/net/lp486e.c
@@ -390,7 +390,7 @@ i596_timeout(struct net_device *dev, char *msg, int ct) {
 	struct i596_private *lp;
 	int boguscnt = ct;
 
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 	while (lp->scb.command) {
 		if (--boguscnt == 0) {
 			printk("%s: %s timed out - stat %4.4x, cmd %4.4x\n",
@@ -411,7 +411,7 @@ init_rx_bufs(struct net_device *dev, int num) {
 	int i;
 	// struct i596_rbd *rbd;
 
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 	lp->scb.pa_rfd = I596_NULL;
 
 	for (i = 0; i < num; i++) {
@@ -468,7 +468,7 @@ remove_rx_bufs(struct net_device *dev) {
 	struct i596_private *lp;
 	struct i596_rfd *rfd;
 
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 	lp->rx_tail->pa_next = I596_NULL;
 
 	do {
@@ -517,7 +517,7 @@ CLEAR_INT(void) {
 /* selftest or dump */
 static void
 i596_port_do(struct net_device *dev, int portcmd, char *cmdname) {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	u16 *outp;
 	int i, m;
 
@@ -541,7 +541,7 @@ i596_port_do(struct net_device *dev, int portcmd, char *cmdname) {
 
 static int
 i596_scp_setup(struct net_device *dev) {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int boguscnt;
 
 	/* Setup SCP, ISCP, SCB */
@@ -622,7 +622,7 @@ init_i596(struct net_device *dev) {
 	if (i596_scp_setup(dev))
 		return 1;
 
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 	lp->scb.command = 0;
 
 	memcpy ((void *)lp->i596_config, init_setup, 14);
@@ -705,7 +705,7 @@ i596_rx_one(struct net_device *dev, struct i596_private *lp,
 
 static int
 i596_rx(struct net_device *dev) {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	struct i596_rfd *rfd;
 	int frames = 0;
 
@@ -738,7 +738,7 @@ i596_cleanup_cmd(struct net_device *dev) {
 	struct i596_private *lp;
 	struct i596_cmd *cmd;
 
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 	while (lp->cmd_head) {
 		cmd = (struct i596_cmd *)lp->cmd_head;
 
@@ -806,7 +806,7 @@ static void i596_reset(struct net_device *dev, struct i596_private *lp, int ioad
 }
 
 static void i596_add_cmd(struct net_device *dev, struct i596_cmd *cmd) {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	unsigned long flags;
 
@@ -912,7 +912,7 @@ static int i596_start_xmit (struct sk_buff *skb, struct net_device *dev) {
 
 static void
 i596_tx_timeout (struct net_device *dev) {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	/* Transmitter timeout, serious problems. */
@@ -970,7 +970,7 @@ static int __init lp486e_probe(struct net_device *dev) {
 		return -EBUSY;
 	}
 
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 	spin_lock_init(&lp->cmd_lock);
 
 	/*
@@ -1147,7 +1147,7 @@ static irqreturn_t
 i596_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	unsigned short status, ack_cmd = 0;
 	int frames_in = 0;
 
@@ -1215,7 +1215,7 @@ i596_interrupt(int irq, void *dev_instance)
 }
 
 static int i596_close(struct net_device *dev) {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 
@@ -1242,7 +1242,7 @@ static int i596_close(struct net_device *dev) {
 */
 
 static void set_multicast_list(struct net_device *dev) {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	struct i596_cmd *cmd;
 
 	if (i596_debug > 1)





