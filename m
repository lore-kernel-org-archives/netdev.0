From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] remove unneeded casts in intel-ee drivers
Date: Sun, 29 Feb 2004 14:56:33 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040229145633.008ea503.rddunlap@osdl.org>
References: <20040229142516.3d218ed0.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik <jgarzik@pobox.com>
In-Reply-To: <20040229142516.3d218ed0.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Carlo Perassi <carlo@linux.it>


 drivers/net/82596.c      |    6 +++---
 drivers/net/eepro.c      |   16 ++++++++--------
 drivers/net/eepro100.c   |   42 +++++++++++++++++++++---------------------
 drivers/net/eexpress.c   |   28 ++++++++++++++--------------
 drivers/net/lasi_82596.c |    6 +++---
 5 files changed, 49 insertions(+), 49 deletions(-)

diff -puN drivers/net/82596.c~net_intel_casts drivers/net/82596.c
--- linux-263-229/drivers/net/82596.c~net_intel_casts	2004-02-29 14:02:15.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/82596.c	2004-02-29 14:02:15.000000000 -0800
@@ -528,7 +528,7 @@ static irqreturn_t i596_error(int irq, v
 
 static inline void init_rx_bufs(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *)dev->priv;
+	struct i596_private *lp = dev->priv;
 	int i;
 	struct i596_rfd *rfd;
 	struct i596_rbd *rbd;
@@ -579,7 +579,7 @@ static inline void init_rx_bufs(struct n
 
 static inline void remove_rx_bufs(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *)dev->priv;
+	struct i596_private *lp = dev->priv;
 	struct i596_rbd *rbd;
 	int i;
 
@@ -765,7 +765,7 @@ failed:
 
 static inline int i596_rx(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *)dev->priv;
+	struct i596_private *lp = dev->priv;
 	struct i596_rfd *rfd;
 	struct i596_rbd *rbd;
 	int frames = 0;
diff -puN drivers/net/eepro100.c~net_intel_casts drivers/net/eepro100.c
--- linux-263-229/drivers/net/eepro100.c~net_intel_casts	2004-02-29 14:02:15.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/eepro100.c	2004-02-29 14:02:15.000000000 -0800
@@ -995,7 +995,7 @@ static void mdio_write(struct net_device
 static int
 speedo_open(struct net_device *dev)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = dev->priv;
 	long ioaddr = dev->base_addr;
 	int retval;
 
@@ -1194,7 +1194,7 @@ speedo_rx_soft_reset(struct net_device *
 static void speedo_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = dev->priv;
 	long ioaddr = dev->base_addr;
 	int phy_num = sp->phy[0] & 0x1f;
 
@@ -1239,7 +1239,7 @@ static void speedo_timer(unsigned long d
 
 static void speedo_show_state(struct net_device *dev)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = dev->priv;
 	int i;
 
 	if (netif_msg_pktdata(sp)) {
@@ -1282,7 +1282,7 @@ static void speedo_show_state(struct net
 static void
 speedo_init_rx_ring(struct net_device *dev)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = dev->priv;
 	struct RxFD *rxf, *last_rxf = NULL;
 	dma_addr_t last_rxf_dma = 0 /* to shut up the compiler */;
 	int i;
@@ -1330,7 +1330,7 @@ speedo_init_rx_ring(struct net_device *d
 
 static void speedo_purge_tx(struct net_device *dev)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = dev->priv;
 	int entry;
 
 	while ((int)(sp->cur_tx - sp->dirty_tx) > 0) {
@@ -1362,7 +1362,7 @@ static void speedo_purge_tx(struct net_d
 
 static void reset_mii(struct net_device *dev)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = dev->priv;
 
 	/* Reset the MII transceiver, suggested by Fred Young @ scalable.com. */
 	if ((sp->phy[0] & 0x8000) == 0) {
@@ -1385,7 +1385,7 @@ static void reset_mii(struct net_device 
 
 static void speedo_tx_timeout(struct net_device *dev)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = dev->priv;
 	long ioaddr = dev->base_addr;
 	int status = inw(ioaddr + SCBStatus);
 	unsigned long flags;
@@ -1447,7 +1447,7 @@ static void speedo_tx_timeout(struct net
 static int
 speedo_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = dev->priv;
 	long ioaddr = dev->base_addr;
 	int entry;
 
@@ -1518,7 +1518,7 @@ speedo_start_xmit(struct sk_buff *skb, s
 static void speedo_tx_buffer_gc(struct net_device *dev)
 {
 	unsigned int dirty_tx;
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = dev->priv;
 
 	dirty_tx = sp->dirty_tx;
 	while ((int)(sp->cur_tx - dirty_tx) > 0) {
@@ -1677,7 +1677,7 @@ static irqreturn_t speedo_interrupt(int 
 
 static inline struct RxFD *speedo_rx_alloc(struct net_device *dev, int entry)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = dev->priv;
 	struct RxFD *rxf;
 	struct sk_buff *skb;
 	/* Get a fresh skbuff to replace the consumed one. */
@@ -1704,7 +1704,7 @@ static inline struct RxFD *speedo_rx_all
 static inline void speedo_rx_link(struct net_device *dev, int entry,
 								  struct RxFD *rxf, dma_addr_t rxf_dma)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = dev->priv;
 	rxf->status = cpu_to_le32(0xC0000001); 	/* '1' for driver use only. */
 	rxf->link = 0;			/* None yet. */
 	rxf->count = cpu_to_le32(PKT_BUF_SZ << 16);
@@ -1718,7 +1718,7 @@ static inline void speedo_rx_link(struct
 
 static int speedo_refill_rx_buf(struct net_device *dev, int force)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = dev->priv;
 	int entry;
 	struct RxFD *rxf;
 
@@ -1760,7 +1760,7 @@ static int speedo_refill_rx_buf(struct n
 
 static void speedo_refill_rx_buffers(struct net_device *dev, int force)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = dev->priv;
 
 	/* Refill the RX ring. */
 	while ((int)(sp->cur_rx - sp->dirty_rx) > 0 &&
@@ -1770,7 +1770,7 @@ static void speedo_refill_rx_buffers(str
 static int
 speedo_rx(struct net_device *dev)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = dev->priv;
 	int entry = sp->cur_rx % RX_RING_SIZE;
 	int rx_work_limit = sp->dirty_rx + RX_RING_SIZE - sp->cur_rx;
 	int alloc_ok = 1;
@@ -1884,7 +1884,7 @@ static int
 speedo_close(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = dev->priv;
 	int i;
 
 	netdevice_stop(dev);
@@ -1962,7 +1962,7 @@ speedo_close(struct net_device *dev)
 static struct net_device_stats *
 speedo_get_stats(struct net_device *dev)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = dev->priv;
 	long ioaddr = dev->base_addr;
 
 	/* Update only if the previous dump finished. */
@@ -2070,7 +2070,7 @@ static int netdev_ethtool_ioctl(struct n
 
 static int speedo_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = dev->priv;
 	struct mii_ioctl_data *data = (struct mii_ioctl_data *)&rq->ifr_data;
 	int phy = sp->phy[0] & 0x1f;
 	int saved_acpi;
@@ -2121,7 +2121,7 @@ static int speedo_ioctl(struct net_devic
 */
 static void set_rx_mode(struct net_device *dev)
 {
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = dev->priv;
 	long ioaddr = dev->base_addr;
 	struct descriptor *last_cmd;
 	char new_rx_mode;
@@ -2313,7 +2313,7 @@ static void set_rx_mode(struct net_devic
 static int eepro100_suspend(struct pci_dev *pdev, u32 state)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = dev->priv;
 	long ioaddr = dev->base_addr;
 
 	pci_save_state(pdev, sp->pm_state);
@@ -2333,7 +2333,7 @@ static int eepro100_suspend(struct pci_d
 static int eepro100_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = dev->priv;
 	long ioaddr = dev->base_addr;
 
 	pci_restore_state(pdev, sp->pm_state);
@@ -2363,7 +2363,7 @@ static int eepro100_resume(struct pci_de
 static void __devexit eepro100_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct speedo_private *sp = (struct speedo_private *)dev->priv;
+	struct speedo_private *sp = dev->priv;
 	
 	unregister_netdev(dev);
 
diff -puN drivers/net/eepro.c~net_intel_casts drivers/net/eepro.c
--- linux-263-229/drivers/net/eepro.c~net_intel_casts	2004-02-29 14:02:15.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/eepro.c	2004-02-29 14:02:15.000000000 -0800
@@ -932,7 +932,7 @@ static int eepro_open(struct net_device 
 	unsigned short temp_reg, old8, old9;
 	int irqMask;
 	int i, ioaddr = dev->base_addr;
-	struct eepro_local *lp = (struct eepro_local *)dev->priv;
+	struct eepro_local *lp = dev->priv;
 
 	if (net_debug > 3)
 		printk(KERN_DEBUG "%s: entering eepro_open routine.\n", dev->name);
@@ -1122,7 +1122,7 @@ static void eepro_tx_timeout (struct net
 
 static int eepro_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct eepro_local *lp = (struct eepro_local *)dev->priv;
+	struct eepro_local *lp = dev->priv;
 	unsigned long flags;
 	int ioaddr = dev->base_addr;
 	short length = skb->len;
@@ -1235,7 +1235,7 @@ eepro_interrupt(int irq, void *dev_id, s
 
 static int eepro_close(struct net_device *dev)
 {
-	struct eepro_local *lp = (struct eepro_local *)dev->priv;
+	struct eepro_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 	short temp_reg;
 
@@ -1280,7 +1280,7 @@ static int eepro_close(struct net_device
 static struct net_device_stats *
 eepro_get_stats(struct net_device *dev)
 {
-	struct eepro_local *lp = (struct eepro_local *)dev->priv;
+	struct eepro_local *lp = dev->priv;
 
 	return &lp->stats;
 }
@@ -1290,7 +1290,7 @@ eepro_get_stats(struct net_device *dev)
 static void
 set_multicast_list(struct net_device *dev)
 {
-	struct eepro_local *lp = (struct eepro_local *)dev->priv;
+	struct eepro_local *lp = dev->priv;
 	short ioaddr = dev->base_addr;
 	unsigned short mode;
 	struct dev_mc_list *dmi=dev->mc_list;
@@ -1468,7 +1468,7 @@ read_eeprom(int ioaddr, int location, st
 static int
 hardware_send_packet(struct net_device *dev, void *buf, short length)
 {
-	struct eepro_local *lp = (struct eepro_local *)dev->priv;
+	struct eepro_local *lp = dev->priv;
 	short ioaddr = dev->base_addr;
 	unsigned status, tx_available, last, end;
 
@@ -1553,7 +1553,7 @@ hardware_send_packet(struct net_device *
 static void
 eepro_rx(struct net_device *dev)
 {
-	struct eepro_local *lp = (struct eepro_local *)dev->priv;
+	struct eepro_local *lp = dev->priv;
 	short ioaddr = dev->base_addr;
 	short boguscount = 20;
 	short rcv_car = lp->rx_start;
@@ -1651,7 +1651,7 @@ eepro_rx(struct net_device *dev)
 static void
 eepro_transmit_interrupt(struct net_device *dev)
 {
-	struct eepro_local *lp = (struct eepro_local *)dev->priv;
+	struct eepro_local *lp = dev->priv;
 	short ioaddr = dev->base_addr;
 	short boguscount = 25; 
 	short xmt_status;
diff -puN drivers/net/eexpress.c~net_intel_casts drivers/net/eexpress.c
--- linux-263-229/drivers/net/eexpress.c~net_intel_casts	2004-02-29 14:02:15.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/eexpress.c	2004-02-29 14:02:15.000000000 -0800
@@ -452,7 +452,7 @@ static int eexp_open(struct net_device *
 {
 	int ret;
 	unsigned short ioaddr = dev->base_addr;
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 
 #if NET_DEBUG > 6
 	printk(KERN_DEBUG "%s: eexp_open()\n", dev->name);
@@ -541,7 +541,7 @@ static int eexp_close(struct net_device 
 
 static struct net_device_stats *eexp_stats(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 
 	return &lp->stats;
 }
@@ -553,7 +553,7 @@ static struct net_device_stats *eexp_sta
 
 static void unstick_cu(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	unsigned short ioaddr = dev->base_addr;
 
 	if (lp->started)
@@ -627,7 +627,7 @@ static void unstick_cu(struct net_device
 
 static void eexp_timeout(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 #ifdef CONFIG_SMP
 	unsigned long flags;
 #endif
@@ -667,7 +667,7 @@ static void eexp_timeout(struct net_devi
  */
 static int eexp_xmit(struct sk_buff *buf, struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	short length = buf->len;
 #ifdef CONFIG_SMP
 	unsigned long flags;
@@ -728,7 +728,7 @@ static unsigned short eexp_start_irq(str
 				     unsigned short status)
 {
 	unsigned short ack_cmd = SCB_ack(status);
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	unsigned short ioaddr = dev->base_addr;
 	if ((dev->flags & IFF_UP) && !(lp->started & STARTED_CU)) {
 		short diag_status, tdr_status;
@@ -925,7 +925,7 @@ static void eexp_hw_set_interface(struct
 
 static void eexp_hw_rx_pio(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	unsigned short rx_block = lp->rx_ptr;
 	unsigned short boguscount = lp->num_rx_bufs;
 	unsigned short ioaddr = dev->base_addr;
@@ -1022,7 +1022,7 @@ static void eexp_hw_rx_pio(struct net_de
 static void eexp_hw_tx_pio(struct net_device *dev, unsigned short *buf,
 		       unsigned short len)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	unsigned short ioaddr = dev->base_addr;
 
 	if (LOCKUP16 || lp->width) {
@@ -1262,7 +1262,7 @@ static unsigned short __init eexp_hw_rea
 
 static unsigned short eexp_hw_lasttxstat(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	unsigned short tx_block = lp->tx_reap;
 	unsigned short status;
 
@@ -1332,7 +1332,7 @@ static unsigned short eexp_hw_lasttxstat
 
 static void eexp_hw_txrestart(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	unsigned short ioaddr = dev->base_addr;
 
 	lp->last_tx_restart = lp->tx_link;
@@ -1377,7 +1377,7 @@ static void eexp_hw_txrestart(struct net
 
 static void eexp_hw_txinit(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	unsigned short tx_block = TX_BUF_START;
 	unsigned short curtbuf;
 	unsigned short ioaddr = dev->base_addr;
@@ -1419,7 +1419,7 @@ static void eexp_hw_txinit(struct net_de
 
 static void eexp_hw_rxinit(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	unsigned short rx_block = lp->rx_buf_start;
 	unsigned short ioaddr = dev->base_addr;
 
@@ -1478,7 +1478,7 @@ static void eexp_hw_rxinit(struct net_de
 
 static void eexp_hw_init586(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	unsigned short ioaddr = dev->base_addr;
 	int i;
 
@@ -1639,7 +1639,7 @@ static void
 eexp_set_multicast(struct net_device *dev)
 {
         unsigned short ioaddr = dev->base_addr;
-        struct net_local *lp = (struct net_local *)dev->priv;
+        struct net_local *lp = dev->priv;
         int kick = 0, i;
         if ((dev->flags & IFF_PROMISC) != lp->was_promisc) {
                 outw(CONF_PROMISC & ~31, ioaddr+SM_PTR);
diff -puN drivers/net/lasi_82596.c~net_intel_casts drivers/net/lasi_82596.c
--- linux-263-229/drivers/net/lasi_82596.c~net_intel_casts	2004-02-29 14:02:15.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/lasi_82596.c	2004-02-29 14:02:15.000000000 -0800
@@ -541,7 +541,7 @@ static void i596_error(int irq, void *de
 
 static inline void init_rx_bufs(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *)dev->priv;
+	struct i596_private *lp = dev->priv;
 	int i;
 	struct i596_rfd *rfd;
 	struct i596_rbd *rbd;
@@ -595,7 +595,7 @@ static inline void init_rx_bufs(struct n
 
 static inline void remove_rx_bufs(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *)dev->priv;
+	struct i596_private *lp = dev->priv;
 	struct i596_rbd *rbd;
 	int i;
 
@@ -727,7 +727,7 @@ failed:
 
 static inline int i596_rx(struct net_device *dev)
 {
-	struct i596_private *lp = (struct i596_private *)dev->priv;
+	struct i596_private *lp = dev->priv;
 	struct i596_rfd *rfd;
 	struct i596_rbd *rbd;
 	int frames = 0;

_


--
~Randy
