From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] use netdev_priv() in net/tulip drivers
Date: Thu, 4 Mar 2004 13:19:36 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040304131936.7bc66cac.rddunlap@osdl.org>
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



 linux-264-302-priv-rddunlap/drivers/net/tulip/21142.c      |    6 
 linux-264-302-priv-rddunlap/drivers/net/tulip/de4x5.c      |  164 ++++++-------
 linux-264-302-priv-rddunlap/drivers/net/tulip/dmfe.c       |   26 +-
 linux-264-302-priv-rddunlap/drivers/net/tulip/eeprom.c     |    2 
 linux-264-302-priv-rddunlap/drivers/net/tulip/interrupt.c  |   10 
 linux-264-302-priv-rddunlap/drivers/net/tulip/media.c      |   10 
 linux-264-302-priv-rddunlap/drivers/net/tulip/pnic.c       |    6 
 linux-264-302-priv-rddunlap/drivers/net/tulip/pnic2.c      |    6 
 linux-264-302-priv-rddunlap/drivers/net/tulip/timer.c      |    6 
 linux-264-302-priv-rddunlap/drivers/net/tulip/tulip_core.c |   30 +-
 linux-264-302-priv-rddunlap/drivers/net/tulip/xircom_cb.c  |   16 -
 11 files changed, 141 insertions(+), 141 deletions(-)

diff -puN drivers/net/tulip/21142.c~net_tulip_casts drivers/net/tulip/21142.c
--- linux-264-302-priv/drivers/net/tulip/21142.c~net_tulip_casts	2004-03-02 20:28:49.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/tulip/21142.c	2004-03-02 20:43:32.000000000 -0800
@@ -29,7 +29,7 @@ static u16 t21142_csr15[] = { 0x0008, 0x
 void t21142_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int csr12 = inl(ioaddr + CSR12);
 	int next_tick = 60*HZ;
@@ -103,7 +103,7 @@ void t21142_timer(unsigned long data)
 
 void t21142_start_nway(struct net_device *dev)
 {
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int csr14 = ((tp->sym_advertise & 0x0780) << 9)  |
 		((tp->sym_advertise & 0x0020) << 1) | 0xffbf;
@@ -131,7 +131,7 @@ void t21142_start_nway(struct net_device
 
 void t21142_lnk_change(struct net_device *dev, int csr5)
 {
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int csr12 = inl(ioaddr + CSR12);
 
diff -puN drivers/net/tulip/de4x5.c~net_tulip_casts drivers/net/tulip/de4x5.c
--- linux-264-302-priv/drivers/net/tulip/de4x5.c~net_tulip_casts	2004-03-02 20:28:49.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/tulip/de4x5.c	2004-03-02 20:41:58.000000000 -0800
@@ -1086,7 +1086,7 @@ static int __devinit 
 de4x5_hw_init(struct net_device *dev, u_long iobase, struct device *gendev)
 {
     char name[DE4X5_NAME_LENGTH + 1];
-    struct de4x5_private *lp = dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     struct pci_dev *pdev = NULL;
     int i, status=0;
 
@@ -1294,7 +1294,7 @@ de4x5_hw_init(struct net_device *dev, u_
 static int
 de4x5_open(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     int i, status = 0;
     s32 omr;
@@ -1384,7 +1384,7 @@ de4x5_init(struct net_device *dev)
 static int
 de4x5_sw_reset(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     int i, j, status = 0;
     s32 bmr, omr;
@@ -1462,7 +1462,7 @@ de4x5_sw_reset(struct net_device *dev)
 static int
 de4x5_queue_pkt(struct sk_buff *skb, struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     int status = 0;
     u_long flags = 0;
@@ -1551,7 +1551,7 @@ de4x5_interrupt(int irq, void *dev_id, s
 	printk ("de4x5_interrupt(): irq %d for unknown device.\n", irq);
 	return IRQ_NONE;
     }
-    lp = (struct de4x5_private *)dev->priv;
+    lp = netdev_priv(dev);
     spin_lock(&lp->lock);
     iobase = dev->base_addr;
 	
@@ -1610,7 +1610,7 @@ de4x5_interrupt(int irq, void *dev_id, s
 static int
 de4x5_rx(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     int entry;
     s32 status;
@@ -1701,7 +1701,7 @@ de4x5_free_tx_buff(struct de4x5_private 
 static int
 de4x5_tx(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     int entry;
     s32 status;
@@ -1753,7 +1753,7 @@ de4x5_tx(struct net_device *dev)
 static int
 de4x5_ast(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     int next_tick = DE4X5_AUTOSENSE_MS;
     
     disable_ast(dev);
@@ -1776,7 +1776,7 @@ de4x5_ast(struct net_device *dev)
 static int
 de4x5_txur(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     int omr;
 
@@ -1799,7 +1799,7 @@ de4x5_txur(struct net_device *dev)
 static int 
 de4x5_rx_ovfc(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     int omr;
 
@@ -1820,7 +1820,7 @@ de4x5_rx_ovfc(struct net_device *dev)
 static int
 de4x5_close(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     s32 imr, omr;
     
@@ -1856,7 +1856,7 @@ de4x5_close(struct net_device *dev)
 static struct net_device_stats *
 de4x5_get_stats(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     
     lp->stats.rx_missed_errors = (int)(inl(DE4X5_MFC) & (MFC_OVFL | MFC_CNTR));
@@ -1867,7 +1867,7 @@ de4x5_get_stats(struct net_device *dev)
 static void
 de4x5_local_stats(struct net_device *dev, char *buf, int pkt_len)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     int i;
 
     for (i=1; i<DE4X5_PKT_STAT_SZ-1; i++) {
@@ -1906,7 +1906,7 @@ de4x5_local_stats(struct net_device *dev
 static void
 load_packet(struct net_device *dev, char *buf, u32 flags, struct sk_buff *skb)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     int entry = (lp->tx_new ? lp->tx_new-1 : lp->txRingSize-1);
     dma_addr_t buf_dma = dma_map_single(lp->gendev, buf, flags & TD_TBS1, DMA_TO_DEVICE);
 
@@ -1927,7 +1927,7 @@ load_packet(struct net_device *dev, char
 static void
 set_multicast_list(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
 
     /* First, double check that the adapter is open */
@@ -1957,7 +1957,7 @@ set_multicast_list(struct net_device *de
 static void
 SetMulticastFilter(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     struct dev_mc_list *dmi=dev->mc_list;
     u_long iobase = dev->base_addr;
     int i, j, bit, byte;
@@ -2036,7 +2036,7 @@ static int __init de4x5_eisa_probe (stru
 		status = -ENOMEM;
 		goto release_reg_2;
 	}
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	
 	cfid = (u32) inl(PCI_CFID);
 	lp->cfrv = (u_short) inl(PCI_CFRV);
@@ -2142,7 +2142,7 @@ srom_search(struct net_device *dev, stru
     u_int irq = 0, device;
     u_long iobase = 0;                     /* Clear upper 32 bits in Alphas */
     int i, j, cfrv;
-    struct de4x5_private *lp = dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     struct list_head *walk = &pdev->bus_list;
 
     for (walk = walk->next; walk != &pdev->bus_list; walk = walk->next) {
@@ -2245,7 +2245,7 @@ static int __devinit de4x5_pci_probe (st
 	if (!(dev = alloc_etherdev (sizeof (struct de4x5_private))))
 		return -ENOMEM;
 
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	lp->bus = PCI;
 	lp->bus_num = 0;
 	
@@ -2374,7 +2374,7 @@ static struct pci_driver de4x5_pci_drive
 static int
 autoconf_media(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     int next_tick = DE4X5_AUTOSENSE_MS;
 
@@ -2415,7 +2415,7 @@ autoconf_media(struct net_device *dev)
 static int
 dc21040_autoconf(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     int next_tick = DE4X5_AUTOSENSE_MS;
     s32 imr;
@@ -2488,7 +2488,7 @@ dc21040_state(struct net_device *dev, in
 	      int next_state, int suspect_state, 
 	      int (*fn)(struct net_device *, int))
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     int next_tick = DE4X5_AUTOSENSE_MS;
     int linkBad;
 
@@ -2527,7 +2527,7 @@ de4x5_suspect_state(struct net_device *d
 		      int (*fn)(struct net_device *, int),
 		      int (*asfn)(struct net_device *))
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     int next_tick = DE4X5_AUTOSENSE_MS;
     int linkBad;
 
@@ -2569,7 +2569,7 @@ de4x5_suspect_state(struct net_device *d
 static int
 dc21041_autoconf(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     s32 sts, irqs, irq_mask, imr, omr;
     int next_tick = DE4X5_AUTOSENSE_MS;
@@ -2771,7 +2771,7 @@ dc21041_autoconf(struct net_device *dev)
 static int
 dc21140m_autoconf(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     int ana, anlpa, cap, cr, slnk, sr;
     int next_tick = DE4X5_AUTOSENSE_MS;
     u_long imr, omr, iobase = dev->base_addr;
@@ -2955,7 +2955,7 @@ dc21140m_autoconf(struct net_device *dev
 static int
 dc2114x_autoconf(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     s32 cr, anlpa, ana, cap, irqs, irq_mask, imr, omr, slnk, sr, sts;
     int next_tick = DE4X5_AUTOSENSE_MS;
@@ -3206,7 +3206,7 @@ printk("Huh?: media:%02x\n", lp->media);
 static int
 srom_autoconf(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
 
     return lp->infoleaf_fn(dev);
 }
@@ -3219,7 +3219,7 @@ srom_autoconf(struct net_device *dev)
 static int
 srom_map_media(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
 
     lp->fdx = 0;
     if (lp->infoblock_media == lp->media) 
@@ -3284,7 +3284,7 @@ srom_map_media(struct net_device *dev)
 static void
 de4x5_init_connection(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     u_long flags = 0;
 
@@ -3313,7 +3313,7 @@ de4x5_init_connection(struct net_device 
 static int
 de4x5_reset_phy(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     int next_tick = 0;
 
@@ -3347,7 +3347,7 @@ de4x5_reset_phy(struct net_device *dev)
 static int
 test_media(struct net_device *dev, s32 irqs, s32 irq_mask, s32 csr13, s32 csr14, s32 csr15, s32 msec)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     s32 sts, csr12;
     
@@ -3385,7 +3385,7 @@ test_media(struct net_device *dev, s32 i
 static int
 test_tp(struct net_device *dev, s32 msec)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     int sisr;
     
@@ -3414,7 +3414,7 @@ test_tp(struct net_device *dev, s32 msec
 static int
 test_for_100Mb(struct net_device *dev, int msec)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     int gep = 0, ret = ((lp->chipset & ~0x00ff)==DC2114x? -1 :GEP_SLNK);
 
     if (lp->timeout < 0) {
@@ -3445,7 +3445,7 @@ test_for_100Mb(struct net_device *dev, i
 static int
 wait_for_link(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
 
     if (lp->timeout < 0) {
 	lp->timeout = 1;
@@ -3467,7 +3467,7 @@ wait_for_link(struct net_device *dev)
 static int
 test_mii_reg(struct net_device *dev, int reg, int mask, int pol, long msec)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     int test;
     u_long iobase = dev->base_addr;
     
@@ -3491,7 +3491,7 @@ test_mii_reg(struct net_device *dev, int
 static int
 is_spd_100(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     int spd;
     
@@ -3515,7 +3515,7 @@ is_spd_100(struct net_device *dev)
 static int
 is_100_up(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     
     if (lp->useMII) {
@@ -3536,7 +3536,7 @@ is_100_up(struct net_device *dev)
 static int
 is_10_up(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     
     if (lp->useMII) {
@@ -3559,7 +3559,7 @@ is_10_up(struct net_device *dev)
 static int
 is_anc_capable(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     
     if (lp->phy[lp->active].id && (!lp->useSROM || lp->useMII)) {
@@ -3578,7 +3578,7 @@ is_anc_capable(struct net_device *dev)
 static int
 ping_media(struct net_device *dev, int msec)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     int sisr;
     
@@ -3619,7 +3619,7 @@ ping_media(struct net_device *dev, int m
 static struct sk_buff *
 de4x5_alloc_rx_buff(struct net_device *dev, int index, int len)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     struct sk_buff *p;
 
 #if !defined(__alpha__) && !defined(__powerpc__) && !defined(__sparc_v9__) && !defined(DE4X5_DO_MEMCPY)
@@ -3667,7 +3667,7 @@ de4x5_alloc_rx_buff(struct net_device *d
 static void
 de4x5_free_rx_buffs(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     int i;
 
     for (i=0; i<lp->rxRingSize; i++) {
@@ -3684,7 +3684,7 @@ de4x5_free_rx_buffs(struct net_device *d
 static void
 de4x5_free_tx_buffs(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     int i;
 
     for (i=0; i<lp->txRingSize; i++) {
@@ -3711,7 +3711,7 @@ de4x5_free_tx_buffs(struct net_device *d
 static void
 de4x5_save_skbs(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     s32 omr;
 
@@ -3732,7 +3732,7 @@ de4x5_save_skbs(struct net_device *dev)
 static void
 de4x5_rst_desc_ring(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     int i;
     s32 omr;
@@ -3765,7 +3765,7 @@ de4x5_rst_desc_ring(struct net_device *d
 static void
 de4x5_cache_state(struct net_device *dev, int flag)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
 
     switch(flag) {
@@ -3795,7 +3795,7 @@ de4x5_cache_state(struct net_device *dev
 static void
 de4x5_put_cache(struct net_device *dev, struct sk_buff *skb)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     struct sk_buff *p;
 
     if (lp->cache.skb) {
@@ -3812,7 +3812,7 @@ de4x5_put_cache(struct net_device *dev, 
 static void
 de4x5_putb_cache(struct net_device *dev, struct sk_buff *skb)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     struct sk_buff *p = lp->cache.skb;
 
     lp->cache.skb = skb;
@@ -3824,7 +3824,7 @@ de4x5_putb_cache(struct net_device *dev,
 static struct sk_buff *
 de4x5_get_cache(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     struct sk_buff *p = lp->cache.skb;
 
     if (p) {
@@ -3842,7 +3842,7 @@ de4x5_get_cache(struct net_device *dev)
 static int
 test_ans(struct net_device *dev, s32 irqs, s32 irq_mask, s32 msec)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     s32 sts, ans;
     
@@ -3870,7 +3870,7 @@ test_ans(struct net_device *dev, s32 irq
 static void
 de4x5_setup_intr(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     s32 imr, sts;
     
@@ -3891,7 +3891,7 @@ de4x5_setup_intr(struct net_device *dev)
 static void
 reset_init_sia(struct net_device *dev, s32 csr13, s32 csr14, s32 csr15)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
 
     RESET_SIA;
@@ -4014,7 +4014,7 @@ static void
 DevicePresent(struct net_device *dev, u_long aprom_addr)
 {
     int i, j=0;
-    struct de4x5_private *lp = (struct de4x5_private *) dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     
     if (lp->chipset == DC21040) {
 	if (lp->bus == EISA) {
@@ -4095,7 +4095,7 @@ get_hw_addr(struct net_device *dev)
     u_long iobase = dev->base_addr;
     int broken, i, k, tmp, status = 0;
     u_short j,chksum;
-    struct de4x5_private *lp = dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
 
     broken = de4x5_bad_srom(lp);
 
@@ -4210,7 +4210,7 @@ de4x5_strncmp(char *a, char *b, int n)
 static void
 srom_repair(struct net_device *dev, int card)
 {
-    struct de4x5_private *lp = dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
 
     switch(card) {
       case SMC:
@@ -4231,7 +4231,7 @@ srom_repair(struct net_device *dev, int 
 static int
 test_bad_enet(struct net_device *dev, int status)
 {
-    struct de4x5_private *lp = dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     int i, tmp;
 
     for (tmp=0,i=0; i<ETH_ALEN; i++) tmp += (u_char)dev->dev_addr[i];
@@ -4384,7 +4384,7 @@ getfrom_srom(u_long addr)
 static int
 srom_infoleaf_info(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     int i, count;
     u_char *p;
 
@@ -4432,7 +4432,7 @@ srom_infoleaf_info(struct net_device *de
 static void
 srom_init(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_char *p = (u_char *)&lp->srom + lp->infoleaf_offset;
     u_char count;
 
@@ -4477,7 +4477,7 @@ srom_init(struct net_device *dev)
 static void
 srom_exec(struct net_device *dev, u_char *p)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     u_char count = (p ? *p++ : 0);
     u_short *w = (u_short *)p;
@@ -4514,7 +4514,7 @@ dc21041_infoleaf(struct net_device *dev)
 static int 
 dc21140_infoleaf(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_char count = 0;
     u_char *p = (u_char *)&lp->srom + lp->infoleaf_offset;
     int next_tick = DE4X5_AUTOSENSE_MS;
@@ -4552,7 +4552,7 @@ dc21140_infoleaf(struct net_device *dev)
 static int 
 dc21142_infoleaf(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_char count = 0;
     u_char *p = (u_char *)&lp->srom + lp->infoleaf_offset;
     int next_tick = DE4X5_AUTOSENSE_MS;
@@ -4587,7 +4587,7 @@ dc21142_infoleaf(struct net_device *dev)
 static int 
 dc21143_infoleaf(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_char count = 0;
     u_char *p = (u_char *)&lp->srom + lp->infoleaf_offset;
     int next_tick = DE4X5_AUTOSENSE_MS;
@@ -4625,7 +4625,7 @@ dc21143_infoleaf(struct net_device *dev)
 static int 
 compact_infoblock(struct net_device *dev, u_char count, u_char *p)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_char flags, csr6;
 
     /* Recursively figure out the info blocks */
@@ -4665,7 +4665,7 @@ compact_infoblock(struct net_device *dev
 static int 
 type0_infoblock(struct net_device *dev, u_char count, u_char *p)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_char flags, csr6, len = (*p & BLOCK_LEN)+1;
 
     /* Recursively figure out the info blocks */
@@ -4705,7 +4705,7 @@ type0_infoblock(struct net_device *dev, 
 static int 
 type1_infoblock(struct net_device *dev, u_char count, u_char *p)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_char len = (*p & BLOCK_LEN)+1;
 
     /* Recursively figure out the info blocks */
@@ -4744,7 +4744,7 @@ type1_infoblock(struct net_device *dev, 
 static int 
 type2_infoblock(struct net_device *dev, u_char count, u_char *p)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_char len = (*p & BLOCK_LEN)+1;
 
     /* Recursively figure out the info blocks */
@@ -4785,7 +4785,7 @@ type2_infoblock(struct net_device *dev, 
 static int 
 type3_infoblock(struct net_device *dev, u_char count, u_char *p)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_char len = (*p & BLOCK_LEN)+1;
 
     /* Recursively figure out the info blocks */
@@ -4827,7 +4827,7 @@ type3_infoblock(struct net_device *dev, 
 static int 
 type4_infoblock(struct net_device *dev, u_char count, u_char *p)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_char flags, csr6, len = (*p & BLOCK_LEN)+1;
 
     /* Recursively figure out the info blocks */
@@ -4872,7 +4872,7 @@ type4_infoblock(struct net_device *dev, 
 static int 
 type5_infoblock(struct net_device *dev, u_char count, u_char *p)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_char len = (*p & BLOCK_LEN)+1;
 
     /* Recursively figure out the info blocks */
@@ -5072,7 +5072,7 @@ mii_get_oui(u_char phyaddr, u_long ioadd
 static int
 mii_get_phy(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     int i, j, k, n, limit=sizeof(phy_info)/sizeof(struct phy_table);
     int id;
@@ -5136,7 +5136,7 @@ mii_get_phy(struct net_device *dev)
 static char *
 build_setup_frame(struct net_device *dev, int mode)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     int i;
     char *pa = lp->setup_frame;
     
@@ -5176,7 +5176,7 @@ enable_ast(struct net_device *dev, u32 t
 static void
 disable_ast(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     
     del_timer(&lp->timer);
     
@@ -5186,7 +5186,7 @@ disable_ast(struct net_device *dev)
 static long
 de4x5_switch_mac_port(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     s32 omr;
 
@@ -5222,7 +5222,7 @@ de4x5_switch_mac_port(struct net_device 
 static void
 gep_wr(s32 data, struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
 
     if (lp->chipset == DC21140) {
@@ -5237,7 +5237,7 @@ gep_wr(s32 data, struct net_device *dev)
 static int
 gep_rd(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
 
     if (lp->chipset == DC21140) {
@@ -5252,7 +5252,7 @@ gep_rd(struct net_device *dev)
 static void
 timeout(struct net_device *dev, void (*fn)(u_long data), u_long data, u_long msec)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     int dt;
     
     /* First, cancel any pending timer events */
@@ -5275,7 +5275,7 @@ timeout(struct net_device *dev, void (*f
 static void
 yawn(struct net_device *dev, int state)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
 
     if ((lp->chipset == DC21040) || (lp->chipset == DC21140)) return;
@@ -5321,7 +5321,7 @@ yawn(struct net_device *dev, int state)
 static void
 de4x5_parse_params(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     char *p, *q, t;
 
     lp->params.fdx = 0;
@@ -5364,7 +5364,7 @@ de4x5_parse_params(struct net_device *de
 static void
 de4x5_dbg_open(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     int i;
     
     if (de4x5_debug & DEBUG_OPEN) {
@@ -5415,7 +5415,7 @@ de4x5_dbg_open(struct net_device *dev)
 static void
 de4x5_dbg_mii(struct net_device *dev, int k)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
     
     if (de4x5_debug & DEBUG_MII) {
@@ -5443,7 +5443,7 @@ de4x5_dbg_mii(struct net_device *dev, in
 static void
 de4x5_dbg_media(struct net_device *dev)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     
     if (lp->media != lp->c_media) {
 	if (de4x5_debug & DEBUG_MEDIA) {
@@ -5534,7 +5534,7 @@ de4x5_dbg_rx(struct sk_buff *skb, int le
 static int
 de4x5_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-    struct de4x5_private *lp = (struct de4x5_private *)dev->priv;
+    struct de4x5_private *lp = netdev_priv(dev);
     struct de4x5_ioctl *ioc = (struct de4x5_ioctl *) &rq->ifr_data;
     u_long iobase = dev->base_addr;
     int i, j, status = 0;
diff -puN drivers/net/tulip/dmfe.c~net_tulip_casts drivers/net/tulip/dmfe.c
--- linux-264-302-priv/drivers/net/tulip/dmfe.c~net_tulip_casts	2004-03-02 20:28:49.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/tulip/dmfe.c	2004-03-02 20:32:55.000000000 -0800
@@ -392,7 +392,7 @@ static int __devinit dmfe_init_one (stru
 	}
 
 	/* Init system & device */
-	db = dev->priv;
+	db = netdev_priv(dev);
 
 	/* Allocate Tx/Rx descriptor memory */
 	db->desc_pool_ptr = pci_alloc_consistent(pdev, sizeof(struct tx_desc) * DESC_ALL_CNT + 0x20, &db->desc_pool_dma_ptr);
@@ -466,7 +466,7 @@ err_out_free:
 static void __devexit dmfe_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct dmfe_board_info *db = dev->priv;
+	struct dmfe_board_info *db = netdev_priv(dev);
 
 	DMFE_DBUG(0, "dmfe_remove_one()", 0);
 
@@ -494,7 +494,7 @@ static void __devexit dmfe_remove_one (s
 static int dmfe_open(struct DEVICE *dev)
 {
 	int ret;
-	struct dmfe_board_info *db = dev->priv;
+	struct dmfe_board_info *db = netdev_priv(dev);
 
 	DMFE_DBUG(0, "dmfe_open", 0);
 
@@ -552,7 +552,7 @@ static int dmfe_open(struct DEVICE *dev)
 
 static void dmfe_init_dm910x(struct DEVICE *dev)
 {
-	struct dmfe_board_info *db = dev->priv;
+	struct dmfe_board_info *db = netdev_priv(dev);
 	unsigned long ioaddr = db->ioaddr;
 
 	DMFE_DBUG(0, "dmfe_init_dm910x()", 0);
@@ -618,7 +618,7 @@ static void dmfe_init_dm910x(struct DEVI
 
 static int dmfe_start_xmit(struct sk_buff *skb, struct DEVICE *dev)
 {
-	struct dmfe_board_info *db = dev->priv;
+	struct dmfe_board_info *db = netdev_priv(dev);
 	struct tx_desc *txptr;
 	unsigned long flags;
 
@@ -687,7 +687,7 @@ static int dmfe_start_xmit(struct sk_buf
 
 static int dmfe_stop(struct DEVICE *dev)
 {
-	struct dmfe_board_info *db = dev->priv;
+	struct dmfe_board_info *db = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 
 	DMFE_DBUG(0, "dmfe_stop", 0);
@@ -730,7 +730,7 @@ static int dmfe_stop(struct DEVICE *dev)
 static irqreturn_t dmfe_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct DEVICE *dev = dev_id;
-	struct dmfe_board_info *db = (struct dmfe_board_info *) dev->priv;
+	struct dmfe_board_info *db = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	unsigned long flags;
 
@@ -957,7 +957,7 @@ static void dmfe_rx_packet(struct DEVICE
 
 static struct net_device_stats * dmfe_get_stats(struct DEVICE *dev)
 {
-	struct dmfe_board_info *db = (struct dmfe_board_info *)dev->priv;
+	struct dmfe_board_info *db = netdev_priv(dev);
 
 	DMFE_DBUG(0, "dmfe_get_stats", 0);
 	return &db->stats;
@@ -970,7 +970,7 @@ static struct net_device_stats * dmfe_ge
 
 static void dmfe_set_filter_mode(struct DEVICE * dev)
 {
-	struct dmfe_board_info *db = dev->priv;
+	struct dmfe_board_info *db = netdev_priv(dev);
 	unsigned long flags;
 
 	DMFE_DBUG(0, "dmfe_set_filter_mode()", 0);
@@ -1003,7 +1003,7 @@ static void dmfe_set_filter_mode(struct 
 static void netdev_get_drvinfo(struct net_device *dev,
 			       struct ethtool_drvinfo *info)
 {
-	struct dmfe_board_info *np = dev->priv;
+	struct dmfe_board_info *np = netdev_priv(dev);
 
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
@@ -1028,7 +1028,7 @@ static void dmfe_timer(unsigned long dat
 	u32 tmp_cr8;
 	unsigned char tmp_cr12;
 	struct DEVICE *dev = (struct DEVICE *) data;
-	struct dmfe_board_info *db = (struct dmfe_board_info *) dev->priv;
+	struct dmfe_board_info *db = netdev_priv(dev);
  	unsigned long flags;
 
 	DMFE_DBUG(0, "dmfe_timer()", 0);
@@ -1160,7 +1160,7 @@ static void dmfe_timer(unsigned long dat
 
 static void dmfe_dynamic_reset(struct DEVICE *dev)
 {
-	struct dmfe_board_info *db = dev->priv;
+	struct dmfe_board_info *db = netdev_priv(dev);
 
 	DMFE_DBUG(0, "dmfe_dynamic_reset()", 0);
 
@@ -1358,7 +1358,7 @@ static void dm9132_id_table(struct DEVIC
 
 static void send_filter_frame(struct DEVICE *dev, int mc_cnt)
 {
-	struct dmfe_board_info *db = dev->priv;
+	struct dmfe_board_info *db = netdev_priv(dev);
 	struct dev_mc_list *mcptr;
 	struct tx_desc *txptr;
 	u16 * addrptr;
diff -puN drivers/net/tulip/eeprom.c~net_tulip_casts drivers/net/tulip/eeprom.c
--- linux-264-302-priv/drivers/net/tulip/eeprom.c~net_tulip_casts	2004-03-02 20:28:49.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/tulip/eeprom.c	2004-03-02 20:44:17.000000000 -0800
@@ -136,7 +136,7 @@ void __devinit tulip_parse_eeprom(struct
 	static struct mediatable *last_mediatable;
 	static unsigned char *last_ee_data;
 	static int controller_index;
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	unsigned char *ee_data = tp->eeprom;
 	int i;
 
diff -puN drivers/net/tulip/interrupt.c~net_tulip_casts drivers/net/tulip/interrupt.c
--- linux-264-302-priv/drivers/net/tulip/interrupt.c~net_tulip_casts	2004-03-02 20:28:49.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/tulip/interrupt.c	2004-03-02 20:37:57.000000000 -0800
@@ -63,7 +63,7 @@ unsigned int mit_table[MIT_SIZE+1] =
 
 int tulip_refill_rx(struct net_device *dev)
 {
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	int entry;
 	int refilled = 0;
 
@@ -109,7 +109,7 @@ void oom_timer(unsigned long data)
 
 int tulip_poll(struct net_device *dev, int *budget)
 {
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	int entry = tp->cur_rx % RX_RING_SIZE;
 	int rx_work_limit = *budget;
 	int received = 0;
@@ -354,7 +354,7 @@ done:
 
 static int tulip_rx(struct net_device *dev)
 {
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	int entry = tp->cur_rx % RX_RING_SIZE;
 	int rx_work_limit = tp->dirty_rx + RX_RING_SIZE - tp->cur_rx;
 	int received = 0;
@@ -465,7 +465,7 @@ static inline unsigned int phy_interrupt
 {
 #ifdef __hppa__
 	int csr12 = inl(dev->base_addr + CSR12) & 0xff;
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 
 	if (csr12 != tp->csr12_shadow) {
 		/* ack interrupt */
@@ -490,7 +490,7 @@ static inline unsigned int phy_interrupt
 irqreturn_t tulip_interrupt(int irq, void *dev_instance, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *)dev_instance;
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int csr5;
 	int missed;
diff -puN drivers/net/tulip/media.c~net_tulip_casts drivers/net/tulip/media.c
--- linux-264-302-priv/drivers/net/tulip/media.c~net_tulip_casts	2004-03-02 20:28:49.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/tulip/media.c	2004-03-02 20:42:38.000000000 -0800
@@ -48,7 +48,7 @@ static const unsigned char comet_miireg2
 
 int tulip_mdio_read(struct net_device *dev, int phy_id, int location)
 {
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	int i;
 	int read_cmd = (0xf6 << 10) | ((phy_id & 0x1f) << 5) | location;
 	int retval = 0;
@@ -111,7 +111,7 @@ int tulip_mdio_read(struct net_device *d
 
 void tulip_mdio_write(struct net_device *dev, int phy_id, int location, int val)
 {
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	int i;
 	int cmd = (0x5002 << 16) | ((phy_id & 0x1f) << 23) | (location<<18) | (val & 0xffff);
 	long ioaddr = dev->base_addr;
@@ -171,7 +171,7 @@ void tulip_mdio_write(struct net_device 
 void tulip_select_media(struct net_device *dev, int startup)
 {
 	long ioaddr = dev->base_addr;
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	struct mediatable *mtable = tp->mtable;
 	u32 new_csr6;
 	int i;
@@ -374,7 +374,7 @@ void tulip_select_media(struct net_devic
   */
 int tulip_check_duplex(struct net_device *dev)
 {
-	struct tulip_private *tp = dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	unsigned int bmsr, lpa, negotiated, new_csr6;
 
 	bmsr = tulip_mdio_read(dev, tp->phys[0], MII_BMSR);
@@ -420,7 +420,7 @@ int tulip_check_duplex(struct net_device
 
 void __devinit tulip_find_mii (struct net_device *dev, int board_idx)
 {
-	struct tulip_private *tp = dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	int phyn, phy_idx = 0;
 	int mii_reg0;
 	int mii_advert;
diff -puN drivers/net/tulip/pnic2.c~net_tulip_casts drivers/net/tulip/pnic2.c
--- linux-264-302-priv/drivers/net/tulip/pnic2.c~net_tulip_casts	2004-03-02 20:28:49.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/tulip/pnic2.c	2004-03-02 20:43:57.000000000 -0800
@@ -84,7 +84,7 @@
 void pnic2_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int next_tick = 60*HZ;
 
@@ -100,7 +100,7 @@ void pnic2_timer(unsigned long data)
 
 void pnic2_start_nway(struct net_device *dev)
 {
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
         int csr14;
         int csr12;
@@ -175,7 +175,7 @@ void pnic2_start_nway(struct net_device 
 
 void pnic2_lnk_change(struct net_device *dev, int csr5)
 {
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
         int csr14;
 
diff -puN drivers/net/tulip/pnic.c~net_tulip_casts drivers/net/tulip/pnic.c
--- linux-264-302-priv/drivers/net/tulip/pnic.c~net_tulip_casts	2004-03-02 20:28:49.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/tulip/pnic.c	2004-03-02 20:33:51.000000000 -0800
@@ -20,7 +20,7 @@
 
 void pnic_do_nway(struct net_device *dev)
 {
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	u32 phy_reg = inl(ioaddr + 0xB8);
 	u32 new_csr6 = tp->csr6 & ~0x40C40200;
@@ -53,7 +53,7 @@ void pnic_do_nway(struct net_device *dev
 
 void pnic_lnk_change(struct net_device *dev, int csr5)
 {
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int phy_reg = inl(ioaddr + 0xB8);
 
@@ -89,7 +89,7 @@ void pnic_lnk_change(struct net_device *
 void pnic_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int next_tick = 60*HZ;
 
diff -puN drivers/net/tulip/timer.c~net_tulip_casts drivers/net/tulip/timer.c
--- linux-264-302-priv/drivers/net/tulip/timer.c~net_tulip_casts	2004-03-02 20:28:49.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/tulip/timer.c	2004-03-02 20:43:05.000000000 -0800
@@ -20,7 +20,7 @@
 void tulip_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	u32 csr12 = inl(ioaddr + CSR12);
 	int next_tick = 2*HZ;
@@ -135,7 +135,7 @@ void tulip_timer(unsigned long data)
 void mxic_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int next_tick = 60*HZ;
 
@@ -152,7 +152,7 @@ void mxic_timer(unsigned long data)
 void comet_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int next_tick = 60*HZ;
 
diff -puN drivers/net/tulip/tulip_core.c~net_tulip_casts drivers/net/tulip/tulip_core.c
--- linux-264-302-priv/drivers/net/tulip/tulip_core.c~net_tulip_casts	2004-03-02 20:28:49.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/tulip/tulip_core.c	2004-03-02 20:36:35.000000000 -0800
@@ -276,7 +276,7 @@ static void tulip_set_power_state (struc
 
 static void tulip_up(struct net_device *dev)
 {
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int next_tick = 3*HZ;
 	int i;
@@ -499,7 +499,7 @@ tulip_open(struct net_device *dev)
 
 static void tulip_tx_timeout(struct net_device *dev)
 {
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	unsigned long flags;
 
@@ -587,7 +587,7 @@ static void tulip_tx_timeout(struct net_
 /* Initialize the Rx and Tx rings, along with various 'dev' bits. */
 static void tulip_init_ring(struct net_device *dev)
 {
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	int i;
 
 	tp->susp_rx = 0;
@@ -638,7 +638,7 @@ static void tulip_init_ring(struct net_d
 static int
 tulip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	int entry;
 	u32 flag;
 	dma_addr_t mapping;
@@ -724,7 +724,7 @@ static void tulip_clean_tx_ring(struct t
 static void tulip_down (struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct tulip_private *tp = (struct tulip_private *) dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	unsigned long flags;
 
 	del_timer_sync (&tp->timer);
@@ -764,7 +764,7 @@ static void tulip_down (struct net_devic
 static int tulip_close (struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct tulip_private *tp = (struct tulip_private *) dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	int i;
 
 	netif_stop_queue (dev);
@@ -811,7 +811,7 @@ static int tulip_close (struct net_devic
 
 static struct net_device_stats *tulip_get_stats(struct net_device *dev)
 {
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	if (netif_running(dev)) {
@@ -830,7 +830,7 @@ static struct net_device_stats *tulip_ge
 
 static int netdev_ethtool_ioctl(struct net_device *dev, void *useraddr)
 {
-	struct tulip_private *np = dev->priv;
+	struct tulip_private *np = netdev_priv(dev);
 	u32 ethcmd;
 
 	if (copy_from_user(&ethcmd, useraddr, sizeof(ethcmd)))
@@ -855,7 +855,7 @@ static int netdev_ethtool_ioctl(struct n
 /* Provide ioctl() calls to examine the MII xcvr state. */
 static int private_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct tulip_private *tp = dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	struct mii_ioctl_data *data = (struct mii_ioctl_data *) & rq->ifr_data;
 	const unsigned int phy_idx = 0;
@@ -964,7 +964,7 @@ static int private_ioctl (struct net_dev
 
 static void build_setup_frame_hash(u16 *setup_frm, struct net_device *dev)
 {
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	u16 hash_table[32];
 	struct dev_mc_list *mclist;
 	int i;
@@ -995,7 +995,7 @@ static void build_setup_frame_hash(u16 *
 
 static void build_setup_frame_perfect(u16 *setup_frm, struct net_device *dev)
 {
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	struct dev_mc_list *mclist;
 	int i;
 	u16 *eaddrs;
@@ -1023,7 +1023,7 @@ static void build_setup_frame_perfect(u1
 
 static void set_rx_mode(struct net_device *dev)
 {
-	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int csr6;
 
@@ -1150,7 +1150,7 @@ static void set_rx_mode(struct net_devic
 static void __devinit tulip_mwi_config (struct pci_dev *pdev,
 					struct net_device *dev)
 {
-	struct tulip_private *tp = dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	u8 cache;
 	u16 pci_command;
 	u32 csr0;
@@ -1373,7 +1373,7 @@ static int __devinit tulip_init_one (str
 	 * initialize private data structure 'tp'
 	 * it is zeroed and aligned in alloc_etherdev
 	 */
-	tp = dev->priv;
+	tp = netdev_priv(dev);
 
 	tp->rx_ring = pci_alloc_consistent(pdev,
 					   sizeof(struct tulip_rx_desc) * RX_RING_SIZE +
@@ -1756,7 +1756,7 @@ static void __devexit tulip_remove_one (
 	if (!dev)
 		return;
 
-	tp = dev->priv;
+	tp = netdev_priv(dev);
 	pci_free_consistent (pdev,
 			     sizeof (struct tulip_rx_desc) * RX_RING_SIZE +
 			     sizeof (struct tulip_tx_desc) * TX_RING_SIZE,
diff -puN drivers/net/tulip/xircom_cb.c~net_tulip_casts drivers/net/tulip/xircom_cb.c
--- linux-264-302-priv/drivers/net/tulip/xircom_cb.c~net_tulip_casts	2004-03-02 20:28:49.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/tulip/xircom_cb.c	2004-03-02 20:46:11.000000000 -0800
@@ -178,7 +178,7 @@ static void print_binary(unsigned int nu
 static void netdev_get_drvinfo(struct net_device *dev,
 			       struct ethtool_drvinfo *info)
 {
-	struct xircom_private *private = dev->priv;
+	struct xircom_private *private = netdev_priv(dev);
 
 	strcpy(info->driver, "xircom_cb");
 	strcpy(info->bus_info, pci_name(private->pdev));
@@ -235,7 +235,7 @@ static int __devinit xircom_probe(struct
 		printk(KERN_ERR "xircom_probe: failed to allocate etherdev\n");
 		goto device_fail;
 	}
-	private = dev->priv;
+	private = netdev_priv(dev);
 	
 	/* Allocate the send/receive buffers */
 	private->rx_buffer = pci_alloc_consistent(pdev,8192,&private->rx_dma_handle);
@@ -312,7 +312,7 @@ device_fail:
 static void __devexit xircom_remove(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct xircom_private *card = dev->priv;
+	struct xircom_private *card = netdev_priv(dev);
 
 	enter("xircom_remove");
 	pci_free_consistent(pdev,8192,card->rx_buffer,card->rx_dma_handle);
@@ -328,7 +328,7 @@ static void __devexit xircom_remove(stru
 static irqreturn_t xircom_interrupt(int irq, void *dev_instance, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) dev_instance;
-	struct xircom_private *card = (struct xircom_private *) dev->priv;
+	struct xircom_private *card = netdev_priv(dev);
 	unsigned int status;
 	int i;
 
@@ -385,7 +385,7 @@ static int xircom_start_xmit(struct sk_b
 	int desc;
 	enter("xircom_start_xmit");
 	
-	card = (struct xircom_private*)dev->priv;
+	card = netdev_priv(dev);
 	spin_lock_irqsave(&card->lock,flags);
 	
 	/* First see if we can free some descriptors */
@@ -444,7 +444,7 @@ static int xircom_start_xmit(struct sk_b
 
 static int xircom_open(struct net_device *dev)
 {
-	struct xircom_private *xp = (struct xircom_private *) dev->priv;
+	struct xircom_private *xp = netdev_priv(dev);
 	int retval;
 	enter("xircom_open");
 	printk(KERN_INFO "xircom cardbus adaptor found, registering as %s, using irq %i \n",dev->name,dev->irq);
@@ -466,7 +466,7 @@ static int xircom_close(struct net_devic
 	unsigned long flags;
 	
 	enter("xircom_close");
-	card = dev->priv;
+	card = netdev_priv(dev);
 	netif_stop_queue(dev); /* we don't want new packets */
 
 	
@@ -495,7 +495,7 @@ static int xircom_close(struct net_devic
 
 static struct net_device_stats *xircom_get_stats(struct net_device *dev)
 {
-        struct xircom_private *card = (struct xircom_private *)dev->priv;
+        struct xircom_private *card = netdev_priv(dev);
         return &card->stats;
 } 
                                                  

_


--
~Randy
