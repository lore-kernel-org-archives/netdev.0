From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] use netdev_priv() in net/ intel drivers
Date: Thu, 4 Mar 2004 13:18:05 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040304131805.2e3af4eb.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


| 
| From: Carlo Perassi <carlo@linux.it>
| and Randy.Dunlap <rddunlap@osdl.org>

--
~Randy




 linux-264-302-priv-rddunlap/drivers/net/82596.c      |   28 +++++-----
 linux-264-302-priv-rddunlap/drivers/net/eepro.c      |   28 +++++-----
 linux-264-302-priv-rddunlap/drivers/net/eepro100.c   |   52 +++++++++----------
 linux-264-302-priv-rddunlap/drivers/net/eexpress.c   |   34 ++++++------
 linux-264-302-priv-rddunlap/drivers/net/lasi_82596.c |   36 ++++++-------
 5 files changed, 89 insertions(+), 89 deletions(-)

diff -puN drivers/net/82596.c~net_intel_casts drivers/net/82596.c
--- linux-264-302-priv/drivers/net/82596.c~net_intel_casts	2004-03-03 11:59:08.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/82596.c	2004-03-03 12:03:40.000000000 -0800
@@ -458,7 +458,7 @@ static inline int wait_cfg(struct net_de
  
 static void i596_display_data(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	struct i596_cmd *cmd;
 	struct i596_rfd *rfd;
 	struct i596_rbd *rbd;
@@ -528,7 +528,7 @@ static irqreturn_t i596_error(int irq, v
 
 static inline void init_rx_bufs(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *)dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int i;
 	struct i596_rfd *rfd;
 	struct i596_rbd *rbd;
@@ -579,7 +579,7 @@ static inline void init_rx_bufs(struct n
 
 static inline void remove_rx_bufs(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *)dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	struct i596_rbd *rbd;
 	int i;
 
@@ -593,7 +593,7 @@ static inline void remove_rx_bufs(struct
 
 static void rebuild_rx_bufs(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int i;
 
 	/* Ensure rx frame/buffer descriptors are tidy */
@@ -612,7 +612,7 @@ static void rebuild_rx_bufs(struct net_d
 
 static int init_i596_mem(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 #if !defined(ENABLE_MVME16x_NET) && !defined(ENABLE_BVME6000_NET)
 	short ioaddr = dev->base_addr;
 #endif
@@ -765,7 +765,7 @@ failed:
 
 static inline int i596_rx(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *)dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	struct i596_rfd *rfd;
 	struct i596_rbd *rbd;
 	int frames = 0;
@@ -960,7 +960,7 @@ static inline void i596_reset(struct net
 
 static void i596_add_cmd(struct net_device *dev, struct i596_cmd *cmd)
 {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	unsigned long flags;
 
@@ -1030,7 +1030,7 @@ static int i596_open(struct net_device *
 
 static void i596_tx_timeout (struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	/* Transmitter timeout, serious problems. */
@@ -1059,7 +1059,7 @@ static void i596_tx_timeout (struct net_
 
 static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	struct tx_cmd *tx_cmd;
 	struct i596_tbd *tbd;
 	short length = skb->len;
@@ -1245,7 +1245,7 @@ struct net_device * __init i82596_probe(
 
 	dev->priv = (void *)(dev->mem_start);
 
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 	DEB(DEB_INIT,printk(KERN_DEBUG "%s: lp at 0x%08lx (%d bytes), lp->scb at 0x%08lx\n",
 			dev->name, (unsigned long)lp,
 			sizeof(struct i596_private), (unsigned long)&lp->scb));
@@ -1305,7 +1305,7 @@ static irqreturn_t i596_interrupt(int ir
 	}
 
 	ioaddr = dev->base_addr;
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 
 	spin_lock (&lp->lock);
 
@@ -1448,7 +1448,7 @@ static irqreturn_t i596_interrupt(int ir
 
 static int i596_close(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	netif_stop_queue(dev);
@@ -1495,7 +1495,7 @@ static int i596_close(struct net_device 
 static struct net_device_stats *
  i596_get_stats(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 
 	return &lp->stats;
 }
@@ -1506,7 +1506,7 @@ static struct net_device_stats *
 
 static void set_multicast_list(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int config = 0, cnt;
 
 	DEB(DEB_MULTI,printk(KERN_DEBUG "%s: set multicast list, %d entries, promisc %s, allmulti %s\n",
diff -puN drivers/net/eepro100.c~net_intel_casts drivers/net/eepro100.c
--- linux-264-302-priv/drivers/net/eepro100.c~net_intel_casts	2004-03-03 11:59:08.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/eepro100.c	2004-03-03 12:05:18.000000000 -0800
@@ -839,7 +839,7 @@ static int __devinit speedo_found1(struc
 
 	dev->irq = pdev->irq;
 
-	sp = dev->priv;
+	sp = netdev_priv(dev);
 	sp->pdev = pdev;
 	sp->msg_enable = DEBUG;
 	sp->acpi_pwr = acpi_idle_state;
@@ -995,7 +995,7 @@ static void mdio_write(struct net_device
 static int
 speedo_open(struct net_device *dev)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int retval;
 
@@ -1082,7 +1082,7 @@ speedo_open(struct net_device *dev)
 /* Start the chip hardware after a full reset. */
 static void speedo_resume(struct net_device *dev)
 {
-	struct speedo_private *sp = dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	/* Start with a Tx threshold of 256 (0x..20.... 8 byte units). */
@@ -1162,7 +1162,7 @@ static void speedo_resume(struct net_dev
 static void
 speedo_rx_soft_reset(struct net_device *dev)
 {
-	struct speedo_private *sp = dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 	struct RxFD *rfd;
 	long ioaddr;
 
@@ -1194,7 +1194,7 @@ speedo_rx_soft_reset(struct net_device *
 static void speedo_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int phy_num = sp->phy[0] & 0x1f;
 
@@ -1239,7 +1239,7 @@ static void speedo_timer(unsigned long d
 
 static void speedo_show_state(struct net_device *dev)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 	int i;
 
 	if (netif_msg_pktdata(sp)) {
@@ -1282,7 +1282,7 @@ static void speedo_show_state(struct net
 static void
 speedo_init_rx_ring(struct net_device *dev)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 	struct RxFD *rxf, *last_rxf = NULL;
 	dma_addr_t last_rxf_dma = 0 /* to shut up the compiler */;
 	int i;
@@ -1330,7 +1330,7 @@ speedo_init_rx_ring(struct net_device *d
 
 static void speedo_purge_tx(struct net_device *dev)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 	int entry;
 
 	while ((int)(sp->cur_tx - sp->dirty_tx) > 0) {
@@ -1362,7 +1362,7 @@ static void speedo_purge_tx(struct net_d
 
 static void reset_mii(struct net_device *dev)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 
 	/* Reset the MII transceiver, suggested by Fred Young @ scalable.com. */
 	if ((sp->phy[0] & 0x8000) == 0) {
@@ -1385,7 +1385,7 @@ static void reset_mii(struct net_device 
 
 static void speedo_tx_timeout(struct net_device *dev)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int status = inw(ioaddr + SCBStatus);
 	unsigned long flags;
@@ -1447,7 +1447,7 @@ static void speedo_tx_timeout(struct net
 static int
 speedo_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int entry;
 
@@ -1518,7 +1518,7 @@ speedo_start_xmit(struct sk_buff *skb, s
 static void speedo_tx_buffer_gc(struct net_device *dev)
 {
 	unsigned int dirty_tx;
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 
 	dirty_tx = sp->dirty_tx;
 	while ((int)(sp->cur_tx - dirty_tx) > 0) {
@@ -1585,7 +1585,7 @@ static irqreturn_t speedo_interrupt(int 
 	unsigned int handled = 0;
 
 	ioaddr = dev->base_addr;
-	sp = (struct speedo_private *)dev->priv;
+	sp = netdev_priv(dev);
 
 #ifndef final_version
 	/* A lock to prevent simultaneous entry on SMP machines. */
@@ -1677,7 +1677,7 @@ static irqreturn_t speedo_interrupt(int 
 
 static inline struct RxFD *speedo_rx_alloc(struct net_device *dev, int entry)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 	struct RxFD *rxf;
 	struct sk_buff *skb;
 	/* Get a fresh skbuff to replace the consumed one. */
@@ -1704,7 +1704,7 @@ static inline struct RxFD *speedo_rx_all
 static inline void speedo_rx_link(struct net_device *dev, int entry,
 								  struct RxFD *rxf, dma_addr_t rxf_dma)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 	rxf->status = cpu_to_le32(0xC0000001); 	/* '1' for driver use only. */
 	rxf->link = 0;			/* None yet. */
 	rxf->count = cpu_to_le32(PKT_BUF_SZ << 16);
@@ -1718,7 +1718,7 @@ static inline void speedo_rx_link(struct
 
 static int speedo_refill_rx_buf(struct net_device *dev, int force)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 	int entry;
 	struct RxFD *rxf;
 
@@ -1760,7 +1760,7 @@ static int speedo_refill_rx_buf(struct n
 
 static void speedo_refill_rx_buffers(struct net_device *dev, int force)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 
 	/* Refill the RX ring. */
 	while ((int)(sp->cur_rx - sp->dirty_rx) > 0 &&
@@ -1770,7 +1770,7 @@ static void speedo_refill_rx_buffers(str
 static int
 speedo_rx(struct net_device *dev)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 	int entry = sp->cur_rx % RX_RING_SIZE;
 	int rx_work_limit = sp->dirty_rx + RX_RING_SIZE - sp->cur_rx;
 	int alloc_ok = 1;
@@ -1884,7 +1884,7 @@ static int
 speedo_close(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 	int i;
 
 	netdevice_stop(dev);
@@ -1962,7 +1962,7 @@ speedo_close(struct net_device *dev)
 static struct net_device_stats *
 speedo_get_stats(struct net_device *dev)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	/* Update only if the previous dump finished. */
@@ -1995,7 +1995,7 @@ speedo_get_stats(struct net_device *dev)
 static int netdev_ethtool_ioctl(struct net_device *dev, void *useraddr)
 {
 	u32 ethcmd;
-	struct speedo_private *sp = dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 		
 	if (copy_from_user(&ethcmd, useraddr, sizeof(ethcmd)))
 		return -EFAULT;
@@ -2070,7 +2070,7 @@ static int netdev_ethtool_ioctl(struct n
 
 static int speedo_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 	struct mii_ioctl_data *data = (struct mii_ioctl_data *)&rq->ifr_data;
 	int phy = sp->phy[0] & 0x1f;
 	int saved_acpi;
@@ -2121,7 +2121,7 @@ static int speedo_ioctl(struct net_devic
 */
 static void set_rx_mode(struct net_device *dev)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	struct descriptor *last_cmd;
 	char new_rx_mode;
@@ -2313,7 +2313,7 @@ static void set_rx_mode(struct net_devic
 static int eepro100_suspend(struct pci_dev *pdev, u32 state)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	pci_save_state(pdev, sp->pm_state);
@@ -2333,7 +2333,7 @@ static int eepro100_suspend(struct pci_d
 static int eepro100_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	pci_restore_state(pdev, sp->pm_state);
@@ -2363,7 +2363,7 @@ static int eepro100_resume(struct pci_de
 static void __devexit eepro100_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = netdev_priv(dev);
 	
 	unregister_netdev(dev);
 
diff -puN drivers/net/eepro.c~net_intel_casts drivers/net/eepro.c
--- linux-264-302-priv/drivers/net/eepro.c~net_intel_casts	2004-03-03 11:59:08.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/eepro.c	2004-03-03 12:06:42.000000000 -0800
@@ -662,7 +662,7 @@ static void eepro_recalc (struct net_dev
 {
 	struct eepro_local *	lp;
 
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	lp->xmt_ram = RAM_SIZE - lp->rcv_ram;
 
 	if (lp->eepro == LAN595FX_10ISA) {
@@ -682,7 +682,7 @@ static void eepro_recalc (struct net_dev
 /* prints boot-time info */
 static void eepro_print_info (struct net_device *dev)
 {
-	struct eepro_local *	lp = dev->priv;
+	struct eepro_local *	lp = netdev_priv(dev);
 	int			i;
 	const char *		ifmap[] = {"AUI", "10Base2", "10BaseT"};
 
@@ -769,7 +769,7 @@ static int __init eepro_probe1(struct ne
 	if ((inb(ioaddr + ID_REG) & R_ROBIN_BITS) != (counter + 0x40))
 		goto exit;
 
-	lp = (struct eepro_local *)dev->priv;
+	lp = netdev_priv(dev);
 	memset(lp, 0, sizeof(struct eepro_local));
 	lp->xmt_bar = XMT_BAR_PRO;
 	lp->xmt_lower_limit_reg = XMT_LOWER_LIMIT_REG_PRO;
@@ -932,7 +932,7 @@ static int eepro_open(struct net_device 
 	unsigned short temp_reg, old8, old9;
 	int irqMask;
 	int i, ioaddr = dev->base_addr;
-	struct eepro_local *lp = (struct eepro_local *)dev->priv;
+	struct eepro_local *lp = netdev_priv(dev);
 
 	if (net_debug > 3)
 		printk(KERN_DEBUG "%s: entering eepro_open routine.\n", dev->name);
@@ -1106,7 +1106,7 @@ static int eepro_open(struct net_device 
 
 static void eepro_tx_timeout (struct net_device *dev)
 {
-	struct eepro_local *lp = (struct eepro_local *) dev->priv;
+	struct eepro_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	/* if (net_debug > 1) */
@@ -1122,7 +1122,7 @@ static void eepro_tx_timeout (struct net
 
 static int eepro_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct eepro_local *lp = (struct eepro_local *)dev->priv;
+	struct eepro_local *lp = netdev_priv(dev);
 	unsigned long flags;
 	int ioaddr = dev->base_addr;
 	short length = skb->len;
@@ -1187,7 +1187,7 @@ eepro_interrupt(int irq, void *dev_id, s
                 return IRQ_NONE;
         }
 
-	lp = (struct eepro_local *)dev->priv;
+	lp = netdev_priv(dev);
 
         spin_lock(&lp->lock);
 
@@ -1235,7 +1235,7 @@ eepro_interrupt(int irq, void *dev_id, s
 
 static int eepro_close(struct net_device *dev)
 {
-	struct eepro_local *lp = (struct eepro_local *)dev->priv;
+	struct eepro_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	short temp_reg;
 
@@ -1280,7 +1280,7 @@ static int eepro_close(struct net_device
 static struct net_device_stats *
 eepro_get_stats(struct net_device *dev)
 {
-	struct eepro_local *lp = (struct eepro_local *)dev->priv;
+	struct eepro_local *lp = netdev_priv(dev);
 
 	return &lp->stats;
 }
@@ -1290,7 +1290,7 @@ eepro_get_stats(struct net_device *dev)
 static void
 set_multicast_list(struct net_device *dev)
 {
-	struct eepro_local *lp = (struct eepro_local *)dev->priv;
+	struct eepro_local *lp = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 	unsigned short mode;
 	struct dev_mc_list *dmi=dev->mc_list;
@@ -1424,7 +1424,7 @@ read_eeprom(int ioaddr, int location, st
 {
 	int i;
 	unsigned short retval = 0;
-	struct eepro_local *lp = dev->priv;
+	struct eepro_local *lp = netdev_priv(dev);
 	short ee_addr = ioaddr + lp->eeprom_reg;
 	int read_cmd = location | EE_READ_CMD;
 	short ctrl_val = EECS ;
@@ -1468,7 +1468,7 @@ read_eeprom(int ioaddr, int location, st
 static int
 hardware_send_packet(struct net_device *dev, void *buf, short length)
 {
-	struct eepro_local *lp = (struct eepro_local *)dev->priv;
+	struct eepro_local *lp = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 	unsigned status, tx_available, last, end;
 
@@ -1553,7 +1553,7 @@ hardware_send_packet(struct net_device *
 static void
 eepro_rx(struct net_device *dev)
 {
-	struct eepro_local *lp = (struct eepro_local *)dev->priv;
+	struct eepro_local *lp = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 	short boguscount = 20;
 	short rcv_car = lp->rx_start;
@@ -1651,7 +1651,7 @@ eepro_rx(struct net_device *dev)
 static void
 eepro_transmit_interrupt(struct net_device *dev)
 {
-	struct eepro_local *lp = (struct eepro_local *)dev->priv;
+	struct eepro_local *lp = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 	short boguscount = 25; 
 	short xmt_status;
diff -puN drivers/net/eexpress.c~net_intel_casts drivers/net/eexpress.c
--- linux-264-302-priv/drivers/net/eexpress.c~net_intel_casts	2004-03-03 11:59:08.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/eexpress.c	2004-03-03 12:07:35.000000000 -0800
@@ -452,7 +452,7 @@ static int eexp_open(struct net_device *
 {
 	int ret;
 	unsigned short ioaddr = dev->base_addr;
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 
 #if NET_DEBUG > 6
 	printk(KERN_DEBUG "%s: eexp_open()\n", dev->name);
@@ -515,7 +515,7 @@ static int eexp_open(struct net_device *
 static int eexp_close(struct net_device *dev)
 {
 	unsigned short ioaddr = dev->base_addr;
-	struct net_local *lp = dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 
 	int irq = dev->irq;
 
@@ -541,7 +541,7 @@ static int eexp_close(struct net_device 
 
 static struct net_device_stats *eexp_stats(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 
 	return &lp->stats;
 }
@@ -553,7 +553,7 @@ static struct net_device_stats *eexp_sta
 
 static void unstick_cu(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	unsigned short ioaddr = dev->base_addr;
 
 	if (lp->started)
@@ -627,7 +627,7 @@ static void unstick_cu(struct net_device
 
 static void eexp_timeout(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 #ifdef CONFIG_SMP
 	unsigned long flags;
 #endif
@@ -667,7 +667,7 @@ static void eexp_timeout(struct net_devi
  */
 static int eexp_xmit(struct sk_buff *buf, struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	short length = buf->len;
 #ifdef CONFIG_SMP
 	unsigned long flags;
@@ -728,7 +728,7 @@ static unsigned short eexp_start_irq(str
 				     unsigned short status)
 {
 	unsigned short ack_cmd = SCB_ack(status);
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	unsigned short ioaddr = dev->base_addr;
 	if ((dev->flags & IFF_UP) && !(lp->started & STARTED_CU)) {
 		short diag_status, tdr_status;
@@ -806,7 +806,7 @@ static irqreturn_t eexp_irq(int irq, voi
 		return IRQ_NONE;
 	}
 
-	lp = (struct net_local *)dev->priv;
+	lp = netdev_priv(dev);
 	ioaddr = dev->base_addr;
 
 	spin_lock(&lp->lock);
@@ -925,7 +925,7 @@ static void eexp_hw_set_interface(struct
 
 static void eexp_hw_rx_pio(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	unsigned short rx_block = lp->rx_ptr;
 	unsigned short boguscount = lp->num_rx_bufs;
 	unsigned short ioaddr = dev->base_addr;
@@ -1022,7 +1022,7 @@ static void eexp_hw_rx_pio(struct net_de
 static void eexp_hw_tx_pio(struct net_device *dev, unsigned short *buf,
 		       unsigned short len)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	unsigned short ioaddr = dev->base_addr;
 
 	if (LOCKUP16 || lp->width) {
@@ -1090,7 +1090,7 @@ static int __init eexp_hw_probe(struct n
 	unsigned int memory_size;
 	int i;
 	unsigned short xsum = 0;
-	struct net_local *lp = dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 
 	printk("%s: EtherExpress 16 at %#x ",dev->name,ioaddr);
 
@@ -1262,7 +1262,7 @@ static unsigned short __init eexp_hw_rea
 
 static unsigned short eexp_hw_lasttxstat(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	unsigned short tx_block = lp->tx_reap;
 	unsigned short status;
 
@@ -1332,7 +1332,7 @@ static unsigned short eexp_hw_lasttxstat
 
 static void eexp_hw_txrestart(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	unsigned short ioaddr = dev->base_addr;
 
 	lp->last_tx_restart = lp->tx_link;
@@ -1377,7 +1377,7 @@ static void eexp_hw_txrestart(struct net
 
 static void eexp_hw_txinit(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	unsigned short tx_block = TX_BUF_START;
 	unsigned short curtbuf;
 	unsigned short ioaddr = dev->base_addr;
@@ -1419,7 +1419,7 @@ static void eexp_hw_txinit(struct net_de
 
 static void eexp_hw_rxinit(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	unsigned short rx_block = lp->rx_buf_start;
 	unsigned short ioaddr = dev->base_addr;
 
@@ -1478,7 +1478,7 @@ static void eexp_hw_rxinit(struct net_de
 
 static void eexp_hw_init586(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	unsigned short ioaddr = dev->base_addr;
 	int i;
 
@@ -1639,7 +1639,7 @@ static void
 eexp_set_multicast(struct net_device *dev)
 {
         unsigned short ioaddr = dev->base_addr;
-        struct net_local *lp = (struct net_local *)dev->priv;
+        struct net_local *lp = netdev_priv(dev);
         int kick = 0, i;
         if ((dev->flags & IFF_PROMISC) != lp->was_promisc) {
                 outw(CONF_PROMISC & ~31, ioaddr+SM_PTR);
diff -puN drivers/net/lasi_82596.c~net_intel_casts drivers/net/lasi_82596.c
--- linux-264-302-priv/drivers/net/lasi_82596.c~net_intel_casts	2004-03-03 11:59:08.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/lasi_82596.c	2004-03-03 12:10:55.000000000 -0800
@@ -426,7 +426,7 @@ static inline void CA(struct net_device 
 
 static inline void MPU_PORT(struct net_device *dev, int c, dma_addr_t x)
 {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 
 	u32 v = (u32) (c) | (u32) (x);
 	u16 a, b;
@@ -481,7 +481,7 @@ static inline int wait_cmd(struct net_de
 
 static void i596_display_data(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	struct i596_cmd *cmd;
 	struct i596_rfd *rfd;
 	struct i596_rbd *rbd;
@@ -541,7 +541,7 @@ static void i596_error(int irq, void *de
 
 static inline void init_rx_bufs(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *)dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int i;
 	struct i596_rfd *rfd;
 	struct i596_rbd *rbd;
@@ -595,7 +595,7 @@ static inline void init_rx_bufs(struct n
 
 static inline void remove_rx_bufs(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *)dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	struct i596_rbd *rbd;
 	int i;
 
@@ -612,7 +612,7 @@ static inline void remove_rx_bufs(struct
 
 static void rebuild_rx_bufs(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int i;
 
 	/* Ensure rx frame/buffer descriptors are tidy */
@@ -633,7 +633,7 @@ static void rebuild_rx_bufs(struct net_d
 
 static int init_i596_mem(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	disable_irq(dev->irq);	/* disable IRQs from LAN */
@@ -727,7 +727,7 @@ failed:
 
 static inline int i596_rx(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *)dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	struct i596_rfd *rfd;
 	struct i596_rbd *rbd;
 	int frames = 0;
@@ -939,7 +939,7 @@ static inline void i596_reset(struct net
 
 static void i596_add_cmd(struct net_device *dev, struct i596_cmd *cmd)
 {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	DEB(DEB_ADDCMD,printk("i596_add_cmd cmd_head %p\n", lp->cmd_head));
@@ -987,7 +987,7 @@ static void i596_add_cmd(struct net_devi
    device list */
 static int i596_test(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	volatile int *tint;
 	u32 data;
 
@@ -1041,7 +1041,7 @@ out:
 
 static void i596_tx_timeout (struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 
 	/* Transmitter timeout, serious problems. */
 	DEB(DEB_ERRORS,printk("%s: transmit timed out, status resetting.\n",
@@ -1070,7 +1070,7 @@ static void i596_tx_timeout (struct net_
 
 static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	struct tx_cmd *tx_cmd;
 	struct i596_tbd *tbd;
 	short length = skb->len;
@@ -1219,7 +1219,7 @@ static int __devinit i82596_probe(struct
 
 	dev->priv = (void *)(dev->mem_start);
 
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 	DEB(DEB_INIT,printk ("%s: lp at 0x%08lx (%d bytes), lp->scb at 0x%08lx\n",
 		dev->name, (unsigned long)lp,
 		sizeof(struct i596_private), (unsigned long)&lp->scb));
@@ -1249,7 +1249,7 @@ static irqreturn_t i596_interrupt(int ir
 		return IRQ_NONE;
 	}
 
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 
 	spin_lock (&lp->lock);
 
@@ -1395,7 +1395,7 @@ static irqreturn_t i596_interrupt(int ir
 
 static int i596_close(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	netif_stop_queue(dev);
@@ -1429,7 +1429,7 @@ static int i596_close(struct net_device 
 static struct net_device_stats *
  i596_get_stats(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 
 	return &lp->stats;
 }
@@ -1440,7 +1440,7 @@ static struct net_device_stats *
 
 static void set_multicast_list(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int config = 0, cnt;
 
 	DEB(DEB_MULTI,printk("%s: set multicast list, %d entries, promisc %s, allmulti %s\n", dev->name, dev->mc_count, dev->flags & IFF_PROMISC ? "ON" : "OFF", dev->flags & IFF_ALLMULTI ? "ON" : "OFF"));
@@ -1540,7 +1540,7 @@ lan_init_chip(struct parisc_device *dev)
 
 	retval = register_netdev(netdevice);
 	if (retval) {
-		struct i596_private *lp = netdevice->priv;
+		struct i596_private *lp = netdev_priv(netdevice);
 		printk(KERN_WARNING __FILE__ ": register_netdevice ret'd %d\n", retval);
 		dma_free_noncoherent(lp->dev, sizeof(struct i596_private), 
 				    (void *)netdevice->mem_start, lp->dma_addr);
@@ -1594,7 +1594,7 @@ static void __exit lasi_82596_exit(void)
 		
 		unregister_netdev(netdevice);
 
-		lp = (struct i596_private *) netdevice->priv;
+		lp = netdev_priv(netdevice);
 		dma_free_noncoherent(lp->dev, sizeof(struct i596_private), 
 				       (void *)netdevice->mem_start, lp->dma_addr);
 		free_netdev(netdevice);

_


--
~Randy
