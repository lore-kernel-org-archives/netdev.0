From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] use netdev_priv() in net/pcmcia/ drivers
Date: Thu, 4 Mar 2004 13:18:43 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040304131843.5126ab7f.rddunlap@osdl.org>
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




 linux-264-302-priv-rddunlap/drivers/net/pcmcia/3c574_cs.c    |   28 +++---
 linux-264-302-priv-rddunlap/drivers/net/pcmcia/3c589_cs.c    |   26 ++---
 linux-264-302-priv-rddunlap/drivers/net/pcmcia/com20020_cs.c |    6 -
 linux-264-302-priv-rddunlap/drivers/net/pcmcia/fmvj18x_cs.c  |   22 ++--
 linux-264-302-priv-rddunlap/drivers/net/pcmcia/ibmtr_cs.c    |    8 -
 linux-264-302-priv-rddunlap/drivers/net/pcmcia/smc91c92_cs.c |   50 +++++------
 6 files changed, 70 insertions(+), 70 deletions(-)

diff -puN drivers/net/pcmcia/3c574_cs.c~net_pcmcia_casts drivers/net/pcmcia/3c574_cs.c
--- linux-264-302-priv/drivers/net/pcmcia/3c574_cs.c~net_pcmcia_casts	2004-03-02 15:57:38.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/pcmcia/3c574_cs.c	2004-03-02 16:02:45.000000000 -0800
@@ -283,7 +283,7 @@ static dev_link_t *tc574_attach(void)
 	dev = alloc_etherdev(sizeof(struct el3_private));
 	if (!dev)
 		return NULL;
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	link = &lp->link;
 	link->priv = dev;
 
@@ -388,7 +388,7 @@ static void tc574_config(dev_link_t *lin
 {
 	client_handle_t handle = link->handle;
 	struct net_device *dev = link->priv;
-	struct el3_private *lp = dev->priv;
+	struct el3_private *lp = netdev_priv(dev);
 	tuple_t tuple;
 	cisparse_t parse;
 	unsigned short buf[32];
@@ -733,7 +733,7 @@ static void mdio_write(ioaddr_t ioaddr, 
 /* Reset and restore all of the 3c574 registers. */
 static void tc574_reset(struct net_device *dev)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = netdev_priv(dev);
 	int i, ioaddr = dev->base_addr;
 	unsigned long flags;
 
@@ -814,7 +814,7 @@ static void tc574_reset(struct net_devic
 
 static int el3_open(struct net_device *dev)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = netdev_priv(dev);
 	dev_link_t *link = &lp->link;
 
 	if (!DEV_OK(link))
@@ -837,7 +837,7 @@ static int el3_open(struct net_device *d
 
 static void el3_tx_timeout(struct net_device *dev)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = netdev_priv(dev);
 	ioaddr_t ioaddr = dev->base_addr;
 	
 	printk(KERN_NOTICE "%s: Transmit timed out!\n", dev->name);
@@ -852,7 +852,7 @@ static void el3_tx_timeout(struct net_de
 
 static void pop_tx_status(struct net_device *dev)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = netdev_priv(dev);
 	ioaddr_t ioaddr = dev->base_addr;
 	int i;
     
@@ -877,7 +877,7 @@ static void pop_tx_status(struct net_dev
 static int el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	ioaddr_t ioaddr = dev->base_addr;
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	DEBUG(3, "%s: el3_start_xmit(length = %ld) called, "
@@ -909,7 +909,7 @@ static int el3_start_xmit(struct sk_buff
 static irqreturn_t el3_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
-	struct el3_private *lp = dev->priv;
+	struct el3_private *lp = netdev_priv(dev);
 	ioaddr_t ioaddr, status;
 	int work_budget = max_interrupt_work;
 	int handled = 0;
@@ -1002,7 +1002,7 @@ static irqreturn_t el3_interrupt(int irq
 static void media_check(unsigned long arg)
 {
 	struct net_device *dev = (struct net_device *) arg;
-	struct el3_private *lp = dev->priv;
+	struct el3_private *lp = netdev_priv(dev);
 	ioaddr_t ioaddr = dev->base_addr;
 	unsigned long flags;
 	unsigned short /* cable, */ media, partner;
@@ -1074,7 +1074,7 @@ reschedule:
 
 static struct net_device_stats *el3_get_stats(struct net_device *dev)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = netdev_priv(dev);
 
 	if (netif_device_present(dev)) {
 		unsigned long flags;
@@ -1091,7 +1091,7 @@ static struct net_device_stats *el3_get_
  */
 static void update_stats(struct net_device *dev)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = netdev_priv(dev);
 	ioaddr_t ioaddr = dev->base_addr;
 	u8 rx, tx, up;
 
@@ -1128,7 +1128,7 @@ static void update_stats(struct net_devi
 
 static int el3_rx(struct net_device *dev, int worklimit)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = netdev_priv(dev);
 	ioaddr_t ioaddr = dev->base_addr;
 	short rx_status;
 	
@@ -1190,7 +1190,7 @@ static struct ethtool_ops netdev_ethtool
 /* Provide ioctl() calls to examine the MII xcvr state. */
 static int el3_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = netdev_priv(dev);
 	ioaddr_t ioaddr = dev->base_addr;
 	u16 *data = (u16 *)&rq->ifr_data;
 	int phy = lp->phys & 0x1f;
@@ -1259,7 +1259,7 @@ static void set_rx_mode(struct net_devic
 static int el3_close(struct net_device *dev)
 {
 	ioaddr_t ioaddr = dev->base_addr;
-	struct el3_private *lp = dev->priv;
+	struct el3_private *lp = netdev_priv(dev);
 	dev_link_t *link = &lp->link;
 
 	DEBUG(2, "%s: shutting down ethercard.\n", dev->name);
diff -puN drivers/net/pcmcia/3c589_cs.c~net_pcmcia_casts drivers/net/pcmcia/3c589_cs.c
--- linux-264-302-priv/drivers/net/pcmcia/3c589_cs.c~net_pcmcia_casts	2004-03-02 15:57:38.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/pcmcia/3c589_cs.c	2004-03-02 16:03:51.000000000 -0800
@@ -196,7 +196,7 @@ static dev_link_t *tc589_attach(void)
     dev = alloc_etherdev(sizeof(struct el3_private));
     if (!dev)
 	 return NULL;
-    lp = dev->priv;
+    lp = netdev_priv(dev);
     link = &lp->link;
     link->priv = dev;
 
@@ -304,7 +304,7 @@ static void tc589_config(dev_link_t *lin
 {
     client_handle_t handle = link->handle;
     struct net_device *dev = link->priv;
-    struct el3_private *lp = dev->priv;
+    struct el3_private *lp = netdev_priv(dev);
     tuple_t tuple;
     cisparse_t parse;
     u16 buf[32], *phys_addr;
@@ -526,7 +526,7 @@ static u16 read_eeprom(ioaddr_t ioaddr, 
 */
 static void tc589_set_xcvr(struct net_device *dev, int if_port)
 {
-    struct el3_private *lp = (struct el3_private *)dev->priv;
+    struct el3_private *lp = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
     
     EL3WINDOW(0);
@@ -648,7 +648,7 @@ static int el3_config(struct net_device 
 
 static int el3_open(struct net_device *dev)
 {
-    struct el3_private *lp = (struct el3_private *)dev->priv;
+    struct el3_private *lp = netdev_priv(dev);
     dev_link_t *link = &lp->link;
     
     if (!DEV_OK(link))
@@ -672,7 +672,7 @@ static int el3_open(struct net_device *d
 
 static void el3_tx_timeout(struct net_device *dev)
 {
-    struct el3_private *lp = (struct el3_private *)dev->priv;
+    struct el3_private *lp = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
     
     printk(KERN_WARNING "%s: Transmit timed out!\n", dev->name);
@@ -687,7 +687,7 @@ static void el3_tx_timeout(struct net_de
 
 static void pop_tx_status(struct net_device *dev)
 {
-    struct el3_private *lp = (struct el3_private *)dev->priv;
+    struct el3_private *lp = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
     int i;
     
@@ -741,7 +741,7 @@ static int el3_start_xmit(struct sk_buff
 static irqreturn_t el3_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
     struct net_device *dev = (struct net_device *) dev_id;
-    struct el3_private *lp = dev->priv;
+    struct el3_private *lp = netdev_priv(dev);
     ioaddr_t ioaddr, status;
     int i = 0, handled = 1;
     
@@ -826,7 +826,7 @@ static irqreturn_t el3_interrupt(int irq
 static void media_check(unsigned long arg)
 {
     struct net_device *dev = (struct net_device *)(arg);
-    struct el3_private *lp = dev->priv;
+    struct el3_private *lp = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
     u16 media, errs;
     unsigned long flags;
@@ -906,7 +906,7 @@ reschedule:
 
 static struct net_device_stats *el3_get_stats(struct net_device *dev)
 {
-    struct el3_private *lp = (struct el3_private *)dev->priv;
+    struct el3_private *lp = netdev_priv(dev);
     unsigned long flags;
     dev_link_t *link = &lp->link;
 
@@ -928,7 +928,7 @@ static struct net_device_stats *el3_get_
 */
 static void update_stats(struct net_device *dev)
 {
-    struct el3_private *lp = (struct el3_private *)dev->priv;
+    struct el3_private *lp = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
 
     DEBUG(2, "%s: updating the statistics.\n", dev->name);
@@ -955,7 +955,7 @@ static void update_stats(struct net_devi
 
 static int el3_rx(struct net_device *dev)
 {
-    struct el3_private *lp = (struct el3_private *)dev->priv;
+    struct el3_private *lp = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
     int worklimit = 32;
     short rx_status;
@@ -1009,7 +1009,7 @@ static int el3_rx(struct net_device *dev
 
 static void set_multicast_list(struct net_device *dev)
 {
-    struct el3_private *lp = dev->priv;
+    struct el3_private *lp = netdev_priv(dev);
     dev_link_t *link = &lp->link;
     ioaddr_t ioaddr = dev->base_addr;
     u16 opts = SetRxFilter | RxStation | RxBroadcast;
@@ -1024,7 +1024,7 @@ static void set_multicast_list(struct ne
 
 static int el3_close(struct net_device *dev)
 {
-    struct el3_private *lp = dev->priv;
+    struct el3_private *lp = netdev_priv(dev);
     dev_link_t *link = &lp->link;
     ioaddr_t ioaddr = dev->base_addr;
     
diff -puN drivers/net/pcmcia/com20020_cs.c~net_pcmcia_casts drivers/net/pcmcia/com20020_cs.c
--- linux-264-302-priv/drivers/net/pcmcia/com20020_cs.c~net_pcmcia_casts	2004-03-02 15:57:38.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/pcmcia/com20020_cs.c	2004-03-02 16:04:30.000000000 -0800
@@ -179,7 +179,7 @@ static dev_link_t *com20020_attach(void)
 
     memset(info, 0, sizeof(struct com20020_dev_t));
     memset(link, 0, sizeof(struct dev_link_t));
-    lp = dev->priv;
+    lp = netdev_priv(dev);
     lp->timeout = timeout;
     lp->backplane = backplane;
     lp->clockp = clockp;
@@ -394,7 +394,7 @@ static void com20020_config(dev_link_t *
 	goto failed;
     }
     
-    lp = dev->priv;
+    lp = netdev_priv(dev);
     lp->card_name = "PCMCIA COM20020";
     lp->card_flags = ARC_CAN_10MBIT; /* pretend all of them can 10Mbit */
 
@@ -492,7 +492,7 @@ static int com20020_event(event_t event,
             pcmcia_request_configuration(link->handle, &link->conf);
             if (link->open) {
 		int ioaddr = dev->base_addr;
-		struct arcnet_local *lp = (struct arcnet_local *)dev->priv;
+		struct arcnet_local *lp = netdev_priv(dev);
 		ARCRESET;
             }
         }
diff -puN drivers/net/pcmcia/fmvj18x_cs.c~net_pcmcia_casts drivers/net/pcmcia/fmvj18x_cs.c
--- linux-264-302-priv/drivers/net/pcmcia/fmvj18x_cs.c~net_pcmcia_casts	2004-03-02 15:57:38.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/pcmcia/fmvj18x_cs.c	2004-03-02 16:05:23.000000000 -0800
@@ -256,7 +256,7 @@ static dev_link_t *fmvj18x_attach(void)
     dev = alloc_etherdev(sizeof(local_info_t));
     if (!dev)
 	return NULL;
-    lp = dev->priv;
+    lp = netdev_priv(dev);
     link = &lp->link;
     link->priv = dev;
 
@@ -394,7 +394,7 @@ static void fmvj18x_config(dev_link_t *l
 {
     client_handle_t handle = link->handle;
     struct net_device *dev = link->priv;
-    local_info_t *lp = dev->priv;
+    local_info_t *lp = netdev_priv(dev);
     tuple_t tuple;
     cisparse_t parse;
     u_short buf[32];
@@ -803,7 +803,7 @@ module_exit(exit_fmvj18x_cs);
 static irqreturn_t fjn_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
     struct net_device *dev = dev_id;
-    local_info_t *lp = dev->priv;
+    local_info_t *lp = netdev_priv(dev);
     ioaddr_t ioaddr;
     unsigned short tx_stat, rx_stat;
 
@@ -862,7 +862,7 @@ static irqreturn_t fjn_interrupt(int irq
 
 static void fjn_tx_timeout(struct net_device *dev)
 {
-    struct local_info_t *lp = (struct local_info_t *)dev->priv;
+    struct local_info_t *lp = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
 
     printk(KERN_NOTICE "%s: transmit timed out with status %04x, %s?\n",
@@ -892,7 +892,7 @@ static void fjn_tx_timeout(struct net_de
 
 static int fjn_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-    struct local_info_t *lp = (struct local_info_t *)dev->priv;
+    struct local_info_t *lp = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
     short length = skb->len;
     
@@ -966,7 +966,7 @@ static int fjn_start_xmit(struct sk_buff
 
 static void fjn_reset(struct net_device *dev)
 {
-    struct local_info_t *lp = (struct local_info_t *)dev->priv;
+    struct local_info_t *lp = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
     int i;
 
@@ -1052,7 +1052,7 @@ static void fjn_reset(struct net_device 
 
 static void fjn_rx(struct net_device *dev)
 {
-    struct local_info_t *lp = (struct local_info_t *)dev->priv;
+    struct local_info_t *lp = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
     int boguscount = 10;	/* 5 -> 10: by agy 19940922 */
 
@@ -1181,7 +1181,7 @@ static int fjn_config(struct net_device 
 
 static int fjn_open(struct net_device *dev)
 {
-    struct local_info_t *lp = (struct local_info_t *)dev->priv;
+    struct local_info_t *lp = netdev_priv(dev);
     dev_link_t *link = &lp->link;
 
     DEBUG(4, "fjn_open('%s').\n", dev->name);
@@ -1206,7 +1206,7 @@ static int fjn_open(struct net_device *d
 
 static int fjn_close(struct net_device *dev)
 {
-    struct local_info_t *lp = (struct local_info_t *)dev->priv;
+    struct local_info_t *lp = netdev_priv(dev);
     dev_link_t *link = &lp->link;
     ioaddr_t ioaddr = dev->base_addr;
 
@@ -1239,7 +1239,7 @@ static int fjn_close(struct net_device *
 
 static struct net_device_stats *fjn_get_stats(struct net_device *dev)
 {
-    local_info_t *lp = (local_info_t *)dev->priv;
+    local_info_t *lp = netdev_priv(dev);
     return &lp->stats;
 } /* fjn_get_stats */
 
@@ -1252,7 +1252,7 @@ static struct net_device_stats *fjn_get_
 static void set_rx_mode(struct net_device *dev)
 {
     ioaddr_t ioaddr = dev->base_addr;
-    struct local_info_t *lp = (struct local_info_t *)dev->priv;
+    struct local_info_t *lp = netdev_priv(dev);
     u_char mc_filter[8];		 /* Multicast hash filter */
     u_long flags;
     int i;
diff -puN drivers/net/pcmcia/ibmtr_cs.c~net_pcmcia_casts drivers/net/pcmcia/ibmtr_cs.c
--- linux-264-302-priv/drivers/net/pcmcia/ibmtr_cs.c~net_pcmcia_casts	2004-03-02 15:57:38.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/pcmcia/ibmtr_cs.c	2004-03-02 16:06:03.000000000 -0800
@@ -178,7 +178,7 @@ static dev_link_t *ibmtr_attach(void)
 
     link = &info->link;
     link->priv = info;
-    info->ti = dev->priv; 
+    info->ti = netdev_priv(dev);
 
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
     link->io.NumPorts1 = 4;
@@ -256,7 +256,7 @@ static void ibmtr_detach(dev_link_t *lin
 	unregister_netdev(dev);
 
     {
-	struct tok_info *ti = (struct tok_info *)dev->priv;
+	struct tok_info *ti = netdev_priv(dev);
 	del_timer_sync(&(ti->tr_timer));
     }
     if (link->state & DEV_CONFIG)
@@ -287,7 +287,7 @@ static void ibmtr_config(dev_link_t *lin
     client_handle_t handle = link->handle;
     ibmtr_dev_t *info = link->priv;
     struct net_device *dev = info->dev;
-    struct tok_info *ti = dev->priv;
+    struct tok_info *ti = netdev_priv(dev);
     tuple_t tuple;
     cisparse_t parse;
     win_req_t req;
@@ -412,7 +412,7 @@ static void ibmtr_release(dev_link_t *li
     pcmcia_release_io(link->handle, &link->io);
     pcmcia_release_irq(link->handle, &link->irq);
     if (link->win) {
-	struct tok_info *ti = dev->priv;
+	struct tok_info *ti = netdev_priv(dev);
 	iounmap((void *)ti->mmio);
 	pcmcia_release_window(link->win);
 	pcmcia_release_window(info->sram_win_handle);
diff -puN drivers/net/pcmcia/smc91c92_cs.c~net_pcmcia_casts drivers/net/pcmcia/smc91c92_cs.c
--- linux-264-302-priv/drivers/net/pcmcia/smc91c92_cs.c~net_pcmcia_casts	2004-03-02 15:57:38.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/pcmcia/smc91c92_cs.c	2004-03-02 16:07:05.000000000 -0800
@@ -327,7 +327,7 @@ static dev_link_t *smc91c92_attach(void)
     dev = alloc_etherdev(sizeof(struct smc_private));
     if (!dev)
 	return NULL;
-    smc = dev->priv;
+    smc = netdev_priv(dev);
     link = &smc->link;
     link->priv = dev;
 
@@ -483,7 +483,7 @@ static int next_tuple(client_handle_t ha
 static int mhz_3288_power(dev_link_t *link)
 {
     struct net_device *dev = link->priv;
-    struct smc_private *smc = dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
     u_char tmp;
 
     /* Read the ISR twice... */
@@ -505,7 +505,7 @@ static int mhz_3288_power(dev_link_t *li
 static int mhz_mfc_config(dev_link_t *link)
 {
     struct net_device *dev = link->priv;
-    struct smc_private *smc = dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
     tuple_t tuple;
     cisparse_t parse;
     u_char buf[255];
@@ -618,7 +618,7 @@ static int mhz_setup(dev_link_t *link)
 static void mot_config(dev_link_t *link)
 {
     struct net_device *dev = link->priv;
-    struct smc_private *smc = dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
     ioaddr_t iouart = link->io.BasePort2;
 
@@ -894,7 +894,7 @@ static void smc91c92_config(dev_link_t *
 {
     client_handle_t handle = link->handle;
     struct net_device *dev = link->priv;
-    struct smc_private *smc = dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
     tuple_t tuple;
     cisparse_t parse;
     u_short buf[32];
@@ -1069,7 +1069,7 @@ static void smc91c92_release(dev_link_t 
     pcmcia_release_irq(link->handle, &link->irq);
     if (link->win) {
 	struct net_device *dev = link->priv;
-	struct smc_private *smc = dev->priv;
+	struct smc_private *smc = netdev_priv(dev);
 	iounmap(smc->base);
 	pcmcia_release_window(link->win);
     }
@@ -1091,7 +1091,7 @@ static int smc91c92_event(event_t event,
 {
     dev_link_t *link = args->client_data;
     struct net_device *dev = link->priv;
-    struct smc_private *smc = dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
     int i;
 
     DEBUG(1, "smc91c92_event(0x%06x)\n", event);
@@ -1240,7 +1240,7 @@ static void smc_dump(struct net_device *
 
 static int smc_open(struct net_device *dev)
 {
-    struct smc_private *smc = dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
     dev_link_t *link = &smc->link;
 
 #ifdef PCMCIA_DEBUG
@@ -1277,7 +1277,7 @@ static int smc_open(struct net_device *d
 
 static int smc_close(struct net_device *dev)
 {
-    struct smc_private *smc = dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
     dev_link_t *link = &smc->link;
     ioaddr_t ioaddr = dev->base_addr;
 
@@ -1314,7 +1314,7 @@ static int smc_close(struct net_device *
 
 static void smc_hardware_send_packet(struct net_device * dev)
 {
-    struct smc_private *smc = dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
     struct sk_buff *skb = smc->saved_skb;
     ioaddr_t ioaddr = dev->base_addr;
     u_char packet_no;
@@ -1379,7 +1379,7 @@ static void smc_hardware_send_packet(str
 
 static void smc_tx_timeout(struct net_device *dev)
 {
-    struct smc_private *smc = dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
 
     printk(KERN_NOTICE "%s: SMC91c92 transmit timed out, "
@@ -1394,7 +1394,7 @@ static void smc_tx_timeout(struct net_de
 
 static int smc_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-    struct smc_private *smc = dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
     u_short num_pages;
     short time_out, ir;
@@ -1460,7 +1460,7 @@ static int smc_start_xmit(struct sk_buff
 
 static void smc_tx_err(struct net_device * dev)
 {
-    struct smc_private *smc = (struct smc_private *)dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
     int saved_packet = inw(ioaddr + PNR_ARR) & 0xff;
     int packet_no = inw(ioaddr + FIFO_PORTS) & 0x7f;
@@ -1504,7 +1504,7 @@ static void smc_tx_err(struct net_device
 
 static void smc_eph_irq(struct net_device *dev)
 {
-    struct smc_private *smc = dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
     u_short card_stats, ephs;
 
@@ -1539,7 +1539,7 @@ static void smc_eph_irq(struct net_devic
 static irqreturn_t smc_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
     struct net_device *dev = dev_id;
-    struct smc_private *smc = dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
     ioaddr_t ioaddr;
     u_short saved_bank, saved_pointer, mask, status;
     unsigned int handled = 1;
@@ -1657,7 +1657,7 @@ irq_done:
 
 static void smc_rx(struct net_device *dev)
 {
-    struct smc_private *smc = (struct smc_private *)dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
     int rx_status;
     int packet_length;	/* Caution: not frame length, rather words
@@ -1725,7 +1725,7 @@ static void smc_rx(struct net_device *de
 
 static struct net_device_stats *smc_get_stats(struct net_device *dev)
 {
-    struct smc_private *smc = (struct smc_private *)dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
     /* Nothing to update - the 91c92 is a pretty primative chip. */
     return &smc->stats;
 }
@@ -1765,7 +1765,7 @@ static void fill_multicast_tbl(int count
 static void set_rx_mode(struct net_device *dev)
 {
     ioaddr_t ioaddr = dev->base_addr;
-    struct smc_private *smc = dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
     u_int multicast_table[ 2 ] = { 0, };
     unsigned long flags;
     u_short rx_cfg_setting;
@@ -1804,7 +1804,7 @@ static void set_rx_mode(struct net_devic
 
 static int s9k_config(struct net_device *dev, struct ifmap *map)
 {
-    struct smc_private *smc = dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
     if ((map->port != (u_char)(-1)) && (map->port != dev->if_port)) {
 	if (smc->cfg & CFG_MII_SELECT)
 	    return -EOPNOTSUPP;
@@ -1830,7 +1830,7 @@ static int s9k_config(struct net_device 
 */
 static void smc_set_xcvr(struct net_device *dev, int if_port)
 {
-    struct smc_private *smc = (struct smc_private *)dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
     u_short saved_bank;
 
@@ -1855,7 +1855,7 @@ static void smc_set_xcvr(struct net_devi
 static void smc_reset(struct net_device *dev)
 {
     ioaddr_t ioaddr = dev->base_addr;
-    struct smc_private *smc = dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
     int i;
 
     DEBUG(0, "%s: smc91c92 reset called.\n", dev->name);
@@ -1930,7 +1930,7 @@ static void smc_reset(struct net_device 
 static void media_check(u_long arg)
 {
     struct net_device *dev = (struct net_device *) arg;
-    struct smc_private *smc = dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
     u_short i, media, saved_bank;
     u_short link;
@@ -2044,7 +2044,7 @@ reschedule:
 static int smc_link_ok(struct net_device *dev)
 {
     ioaddr_t ioaddr = dev->base_addr;
-    struct smc_private *smc = dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
 
     if (smc->cfg & CFG_MII_SELECT) {
 	return mii_link_ok(&smc->mii_if);
@@ -2109,7 +2109,7 @@ static int smc_netdev_set_ecmd(struct ne
 static int smc_ethtool_ioctl (struct net_device *dev, void *useraddr)
 {
     u32 ethcmd;
-    struct smc_private *smc = dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
 
     if (get_user(ethcmd, (u32 *)useraddr))
 	return -EFAULT;
@@ -2202,7 +2202,7 @@ static int smc_ethtool_ioctl (struct net
 
 static int smc_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
 {
-    struct smc_private *smc = dev->priv;
+    struct smc_private *smc = netdev_priv(dev);
     struct mii_ioctl_data *mii;
     int rc = 0;
     u_short saved_bank;

_


--
~Randy
