From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] revert some netdev_priv() changes
Date: Thu, 18 Mar 2004 13:49:41 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040318134941.485da95c.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


// linux-2.6.5-rc1-bk3
// These drivers don't use the usual/normal/typical netdevice->priv
// storage, so converting them to use netdev_priv() was not the
// right thing to do.  Back to using dev->priv for them.

diffstat:=
 drivers/net/82596.c              |   28 +++++++++++++--------------
 drivers/net/fc/iph5526.c         |    8 +++----
 drivers/net/lasi_82596.c         |   36 +++++++++++++++++------------------
 drivers/net/pcmcia/com20020_cs.c |    6 ++---
 drivers/net/sgiseeq.c            |   16 +++++++--------
 drivers/net/wan/comx.c           |   40 +++++++++++++++++++--------------------
 drivers/net/wan/cosa.c           |   12 +++++------
 7 files changed, 73 insertions(+), 73 deletions(-)


diff -Naurp ./drivers/net/pcmcia/com20020_cs.c~netdev_rev ./drivers/net/pcmcia/com20020_cs.c
--- ./drivers/net/pcmcia/com20020_cs.c~netdev_rev	2004-03-18 13:02:28.000000000 -0800
+++ ./drivers/net/pcmcia/com20020_cs.c	2004-03-18 13:23:09.000000000 -0800
@@ -179,7 +179,7 @@ static dev_link_t *com20020_attach(void)
 
     memset(info, 0, sizeof(struct com20020_dev_t));
     memset(link, 0, sizeof(struct dev_link_t));
-    lp = netdev_priv(dev);
+    lp = dev->priv;
     lp->timeout = timeout;
     lp->backplane = backplane;
     lp->clockp = clockp;
@@ -394,7 +394,7 @@ static void com20020_config(dev_link_t *
 	goto failed;
     }
     
-    lp = netdev_priv(dev);
+    lp = dev->priv;
     lp->card_name = "PCMCIA COM20020";
     lp->card_flags = ARC_CAN_10MBIT; /* pretend all of them can 10Mbit */
 
@@ -492,7 +492,7 @@ static int com20020_event(event_t event,
             pcmcia_request_configuration(link->handle, &link->conf);
             if (link->open) {
 		int ioaddr = dev->base_addr;
-		struct arcnet_local *lp = netdev_priv(dev);
+		struct arcnet_local *lp = dev->priv;
 		ARCRESET;
             }
         }
diff -Naurp ./drivers/net/wan/comx.c~netdev_rev ./drivers/net/wan/comx.c
--- ./drivers/net/wan/comx.c~netdev_rev	2004-03-18 13:02:29.000000000 -0800
+++ ./drivers/net/wan/comx.c	2004-03-18 13:27:11.000000000 -0800
@@ -119,7 +119,7 @@ struct comx_debugflags_struct	comx_debug
 
 int comx_debug(struct net_device *dev, char *fmt, ...)
 {
-	struct comx_channel *ch = netdev_priv(dev);
+	struct comx_channel *ch = dev->priv;
 	char *page,*str;
 	va_list args;
 	int len;
@@ -162,7 +162,7 @@ int comx_debug(struct net_device *dev, c
 
 int comx_debug_skb(struct net_device *dev, struct sk_buff *skb, char *msg)
 {
-	struct comx_channel *ch = netdev_priv(dev);
+	struct comx_channel *ch = dev->priv;
 
 	if (!ch->debug_area) return 0;
 	if (!skb) comx_debug(dev, "%s: %s NULL skb\n\n", dev->name, msg);
@@ -175,7 +175,7 @@ int comx_debug_bytes(struct net_device *
 		char *msg)
 {
 	int pos = 0;
-	struct comx_channel *ch = netdev_priv(dev);
+	struct comx_channel *ch = dev->priv;
 
 	if (!ch->debug_area) return 0;
 
@@ -207,7 +207,7 @@ int comx_debug_bytes(struct net_device *
 static void comx_loadavg_timerfun(unsigned long d)
 {
 	struct net_device *dev = (struct net_device *)d;
-	struct comx_channel *ch = netdev_priv(dev);
+	struct comx_channel *ch = dev->priv;
 
 	ch->avg_bytes[ch->loadavg_counter] = ch->current_stats->rx_bytes;
 	ch->avg_bytes[ch->loadavg_counter + ch->loadavg_size] = 
@@ -222,7 +222,7 @@ static void comx_loadavg_timerfun(unsign
 static void comx_reset_timerfun(unsigned long d)
 { 
 	struct net_device *dev = (struct net_device *)d;
-	struct comx_channel *ch = netdev_priv(dev);
+	struct comx_channel *ch = dev->priv;
 
 	if(!(ch->line_status & (PROTO_LOOP | PROTO_UP))) {
 		if(test_and_set_bit(0,&ch->reset_pending) && ch->HW_reset) {
@@ -236,7 +236,7 @@ static void comx_reset_timerfun(unsigned
 
 static int comx_open(struct net_device *dev)
 {
-	struct comx_channel *ch = netdev_priv(dev);
+	struct comx_channel *ch = dev->priv;
 	struct proc_dir_entry *comxdir = ch->procdir->subdir;
 	int ret=0;
 
@@ -268,7 +268,7 @@ static int comx_open(struct net_device *
 
 static int comx_close(struct net_device *dev)
 {
-	struct comx_channel *ch = netdev_priv(dev);
+	struct comx_channel *ch = dev->priv;
 	struct proc_dir_entry *comxdir = ch->procdir->subdir;
 	int ret = -ENODEV;
 
@@ -303,7 +303,7 @@ static int comx_close(struct net_device 
 
 void comx_status(struct net_device *dev, int status)
 {
-	struct comx_channel *ch = netdev_priv(dev);
+	struct comx_channel *ch = dev->priv;
 
 #if 0
 	if(status & (PROTO_UP | PROTO_LOOP)) {
@@ -321,7 +321,7 @@ void comx_status(struct net_device *dev,
 
 static int comx_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct comx_channel *ch = netdev_priv(dev);
+	struct comx_channel *ch = dev->priv;
 	int rc;
 
 	if (skb->len > dev->mtu + dev->hard_header_len) {
@@ -342,7 +342,7 @@ static int comx_xmit(struct sk_buff *skb
 static int comx_header(struct sk_buff *skb, struct net_device *dev, 
 	unsigned short type, void *daddr, void *saddr, unsigned len) 
 {
-	struct comx_channel *ch = netdev_priv(dev);
+	struct comx_channel *ch = dev->priv;
 
 	if (ch->LINE_header) {
 		return (ch->LINE_header(skb, dev, type, daddr, saddr, len));
@@ -354,7 +354,7 @@ static int comx_header(struct sk_buff *s
 static int comx_rebuild_header(struct sk_buff *skb) 
 {
 	struct net_device *dev = skb->dev;
-	struct comx_channel *ch = netdev_priv(dev);
+	struct comx_channel *ch = dev->priv;
 
 	if (ch->LINE_rebuild_header) {
 		return(ch->LINE_rebuild_header(skb));
@@ -365,7 +365,7 @@ static int comx_rebuild_header(struct sk
 
 int comx_rx(struct net_device *dev, struct sk_buff *skb)
 {
-	struct comx_channel *ch = netdev_priv(dev);
+	struct comx_channel *ch = dev->priv;
 
 	if (ch->debug_flags & DEBUG_COMX_RX) {
 		comx_debug_skb(dev, skb, "comx_rx skb");
@@ -379,7 +379,7 @@ int comx_rx(struct net_device *dev, stru
 
 static struct net_device_stats *comx_stats(struct net_device *dev)
 {
-	struct comx_channel *ch = netdev_priv(dev);
+	struct comx_channel *ch = dev->priv;
 
 	return ch->current_stats;
 }
@@ -387,7 +387,7 @@ static struct net_device_stats *comx_sta
 void comx_lineup_func(unsigned long d)
 {
 	struct net_device *dev = (struct net_device *)d;
-	struct comx_channel *ch = netdev_priv(dev);
+	struct comx_channel *ch = dev->priv;
 
 	del_timer(&ch->lineup_timer);
 	clear_bit(0, &ch->lineup_pending);
@@ -405,7 +405,7 @@ void comx_lineup_func(unsigned long d)
 
 static int comx_statistics(struct net_device *dev, char *page)
 {
-	struct comx_channel *ch = netdev_priv(dev);
+	struct comx_channel *ch = dev->priv;
 	int len = 0;
 	int tmp;
 	int i = 0;
@@ -472,7 +472,7 @@ static int comx_statistics(struct net_de
 
 static int comx_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct comx_channel *ch = netdev_priv(dev);
+	struct comx_channel *ch = dev->priv;
 
 	if (ch->LINE_ioctl) {
 		return(ch->LINE_ioctl(dev, ifr, cmd));
@@ -535,7 +535,7 @@ static int comx_read_proc(char *page, ch
 {
 	struct proc_dir_entry *file = (struct proc_dir_entry *)data;
 	struct net_device *dev = file->parent->data;
-	struct comx_channel *ch = netdev_priv(dev);
+	struct comx_channel *ch = dev->priv;
 	int len = 0;
 
 	if (strcmp(file->name, FILENAME_STATUS) == 0) {
@@ -599,7 +599,7 @@ static int comx_write_proc(struct file *
 {
 	struct proc_dir_entry *entry = (struct proc_dir_entry *)data;
 	struct net_device *dev = (struct net_device *)entry->parent->data;
-	struct comx_channel *ch = netdev_priv(dev);
+	struct comx_channel *ch = dev->priv;
 	char *page;
 	struct comx_hardware *hw = comx_channels;
 	struct comx_protocol *line = comx_lines;
@@ -821,7 +821,7 @@ static int comx_mkdir(struct inode *dir,
 	if (register_netdevice(dev)) {
 		goto cleanup_filename_debug;
 	}
-	ch = netdev_priv(dev);
+	ch = dev->priv;
 	if((ch->if_ptr = (void *)kmalloc(sizeof(struct ppp_device), 
 				 GFP_KERNEL)) == NULL) {
 		goto cleanup_register;
@@ -874,7 +874,7 @@ static int comx_rmdir(struct inode *dir,
 
 	lock_kernel();
 	dev = entry->data;
-	ch = netdev_priv(dev);
+	ch = dev->priv;
 	if (dev->flags & IFF_UP) {
 		printk(KERN_ERR "%s: down interface before removing it\n", dev->name);
 		unlock_kernel();
diff -Naurp ./drivers/net/wan/cosa.c~netdev_rev ./drivers/net/wan/cosa.c
--- ./drivers/net/wan/cosa.c~netdev_rev	2004-03-18 13:02:29.000000000 -0800
+++ ./drivers/net/wan/cosa.c	2004-03-18 13:29:45.000000000 -0800
@@ -639,7 +639,7 @@ static void sppp_channel_delete(struct c
 
 static int cosa_sppp_open(struct net_device *d)
 {
-	struct channel_data *chan = netdev_priv(d);
+	struct channel_data *chan = d->priv;
 	int err;
 	unsigned long flags;
 
@@ -679,7 +679,7 @@ static int cosa_sppp_open(struct net_dev
 
 static int cosa_sppp_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct channel_data *chan = netdev_priv(dev);
+	struct channel_data *chan = dev->priv;
 
 	netif_stop_queue(dev);
 
@@ -690,7 +690,7 @@ static int cosa_sppp_tx(struct sk_buff *
 
 static void cosa_sppp_timeout(struct net_device *dev)
 {
-	struct channel_data *chan = netdev_priv(dev);
+	struct channel_data *chan = dev->priv;
 
 	if (test_bit(RXBIT, &chan->cosa->rxtx)) {
 		chan->stats.rx_errors++;
@@ -709,7 +709,7 @@ static void cosa_sppp_timeout(struct net
 
 static int cosa_sppp_close(struct net_device *d)
 {
-	struct channel_data *chan = netdev_priv(d);
+	struct channel_data *chan = d->priv;
 	unsigned long flags;
 
 	netif_stop_queue(d);
@@ -789,7 +789,7 @@ static int sppp_tx_done(struct channel_d
 
 static struct net_device_stats *cosa_net_stats(struct net_device *dev)
 {
-	struct channel_data *chan = netdev_priv(dev);
+	struct channel_data *chan = dev->priv;
 	return &chan->stats;
 }
 
@@ -1205,7 +1205,7 @@ static int cosa_sppp_ioctl(struct net_de
 	int cmd)
 {
 	int rv;
-	struct channel_data *chan = netdev_priv(dev);
+	struct channel_data *chan = dev->priv;
 	rv = cosa_ioctl_common(chan->cosa, chan, cmd, (unsigned long)ifr->ifr_data);
 	if (rv == -ENOIOCTLCMD) {
 		return sppp_do_ioctl(dev, ifr, cmd);
diff -Naurp ./drivers/net/fc/iph5526.c~netdev_rev ./drivers/net/fc/iph5526.c
--- ./drivers/net/fc/iph5526.c~netdev_rev	2004-03-18 13:02:27.000000000 -0800
+++ ./drivers/net/fc/iph5526.c	2004-03-18 13:16:32.000000000 -0800
@@ -238,7 +238,7 @@ int __init iph5526_probe(struct net_devi
 
 static int __init iph5526_probe_pci(struct net_device *dev)
 {
-	struct fc_info *fi = netdev_priv(dev);
+	struct fc_info *fi = dev->priv;
 	fi->dev = dev;
 	dev->base_addr = fi->base_addr;
 	dev->irq = fi->irq;
@@ -2908,7 +2908,7 @@ static int iph5526_close(struct net_devi
 
 static void iph5526_timeout(struct net_device *dev)
 {
-	struct fc_info *fi = netdev_priv(dev);
+	struct fc_info *fi = dev->priv;
 	printk(KERN_WARNING "%s: timed out on send.\n", dev->name);
 	fi->fc_stats.rx_dropped++;
 	dev->trans_start = jiffies;
@@ -2917,7 +2917,7 @@ static void iph5526_timeout(struct net_d
 
 static int iph5526_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct fc_info *fi = netdev_priv(dev);
+	struct fc_info *fi = dev->priv;
 	int status = 0;
 	short type = 0;
 	u_long flags;
@@ -3688,7 +3688,7 @@ int count = 0, j;
 
 static struct net_device_stats * iph5526_get_stats(struct net_device *dev)
 {	
-struct fc_info *fi = netdev_priv(dev);
+struct fc_info *fi = dev->priv;
 	return (struct net_device_stats *) &fi->fc_stats;
 }
 
diff -Naurp ./drivers/net/82596.c~netdev_rev ./drivers/net/82596.c
--- ./drivers/net/82596.c~netdev_rev	2004-03-18 13:02:27.000000000 -0800
+++ ./drivers/net/82596.c	2004-03-18 13:14:48.000000000 -0800
@@ -458,7 +458,7 @@ static inline int wait_cfg(struct net_de
  
 static void i596_display_data(struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 	struct i596_cmd *cmd;
 	struct i596_rfd *rfd;
 	struct i596_rbd *rbd;
@@ -528,7 +528,7 @@ static irqreturn_t i596_error(int irq, v
 
 static inline void init_rx_bufs(struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 	int i;
 	struct i596_rfd *rfd;
 	struct i596_rbd *rbd;
@@ -579,7 +579,7 @@ static inline void init_rx_bufs(struct n
 
 static inline void remove_rx_bufs(struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 	struct i596_rbd *rbd;
 	int i;
 
@@ -593,7 +593,7 @@ static inline void remove_rx_bufs(struct
 
 static void rebuild_rx_bufs(struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 	int i;
 
 	/* Ensure rx frame/buffer descriptors are tidy */
@@ -612,7 +612,7 @@ static void rebuild_rx_bufs(struct net_d
 
 static int init_i596_mem(struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 #if !defined(ENABLE_MVME16x_NET) && !defined(ENABLE_BVME6000_NET)
 	short ioaddr = dev->base_addr;
 #endif
@@ -765,7 +765,7 @@ failed:
 
 static inline int i596_rx(struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 	struct i596_rfd *rfd;
 	struct i596_rbd *rbd;
 	int frames = 0;
@@ -960,7 +960,7 @@ static inline void i596_reset(struct net
 
 static void i596_add_cmd(struct net_device *dev, struct i596_cmd *cmd)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 	unsigned long flags;
 
@@ -1030,7 +1030,7 @@ static int i596_open(struct net_device *
 
 static void i596_tx_timeout (struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 
 	/* Transmitter timeout, serious problems. */
@@ -1059,7 +1059,7 @@ static void i596_tx_timeout (struct net_
 
 static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 	struct tx_cmd *tx_cmd;
 	struct i596_tbd *tbd;
 	short length = skb->len;
@@ -1245,7 +1245,7 @@ struct net_device * __init i82596_probe(
 
 	dev->priv = (void *)(dev->mem_start);
 
-	lp = netdev_priv(dev);
+	lp = dev->priv;
 	DEB(DEB_INIT,printk(KERN_DEBUG "%s: lp at 0x%08lx (%d bytes), lp->scb at 0x%08lx\n",
 			dev->name, (unsigned long)lp,
 			sizeof(struct i596_private), (unsigned long)&lp->scb));
@@ -1305,7 +1305,7 @@ static irqreturn_t i596_interrupt(int ir
 	}
 
 	ioaddr = dev->base_addr;
-	lp = netdev_priv(dev);
+	lp = dev->priv;
 
 	spin_lock (&lp->lock);
 
@@ -1448,7 +1448,7 @@ static irqreturn_t i596_interrupt(int ir
 
 static int i596_close(struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 	unsigned long flags;
 
 	netif_stop_queue(dev);
@@ -1495,7 +1495,7 @@ static int i596_close(struct net_device 
 static struct net_device_stats *
  i596_get_stats(struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 
 	return &lp->stats;
 }
@@ -1506,7 +1506,7 @@ static struct net_device_stats *
 
 static void set_multicast_list(struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 	int config = 0, cnt;
 
 	DEB(DEB_MULTI,printk(KERN_DEBUG "%s: set multicast list, %d entries, promisc %s, allmulti %s\n",
diff -Naurp ./drivers/net/lasi_82596.c~netdev_rev ./drivers/net/lasi_82596.c
--- ./drivers/net/lasi_82596.c~netdev_rev	2004-03-18 13:02:28.000000000 -0800
+++ ./drivers/net/lasi_82596.c	2004-03-18 13:19:49.000000000 -0800
@@ -426,7 +426,7 @@ static inline void CA(struct net_device 
 
 static inline void MPU_PORT(struct net_device *dev, int c, dma_addr_t x)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 
 	u32 v = (u32) (c) | (u32) (x);
 	u16 a, b;
@@ -481,7 +481,7 @@ static inline int wait_cmd(struct net_de
 
 static void i596_display_data(struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 	struct i596_cmd *cmd;
 	struct i596_rfd *rfd;
 	struct i596_rbd *rbd;
@@ -541,7 +541,7 @@ static void i596_error(int irq, void *de
 
 static inline void init_rx_bufs(struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 	int i;
 	struct i596_rfd *rfd;
 	struct i596_rbd *rbd;
@@ -595,7 +595,7 @@ static inline void init_rx_bufs(struct n
 
 static inline void remove_rx_bufs(struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 	struct i596_rbd *rbd;
 	int i;
 
@@ -612,7 +612,7 @@ static inline void remove_rx_bufs(struct
 
 static void rebuild_rx_bufs(struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 	int i;
 
 	/* Ensure rx frame/buffer descriptors are tidy */
@@ -633,7 +633,7 @@ static void rebuild_rx_bufs(struct net_d
 
 static int init_i596_mem(struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 	unsigned long flags;
 
 	disable_irq(dev->irq);	/* disable IRQs from LAN */
@@ -727,7 +727,7 @@ failed:
 
 static inline int i596_rx(struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 	struct i596_rfd *rfd;
 	struct i596_rbd *rbd;
 	int frames = 0;
@@ -940,7 +940,7 @@ static inline void i596_reset(struct net
 
 static void i596_add_cmd(struct net_device *dev, struct i596_cmd *cmd)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 	unsigned long flags;
 
 	DEB(DEB_ADDCMD,printk("i596_add_cmd cmd_head %p\n", lp->cmd_head));
@@ -988,7 +988,7 @@ static void i596_add_cmd(struct net_devi
    device list */
 static int i596_test(struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 	volatile int *tint;
 	u32 data;
 
@@ -1042,7 +1042,7 @@ out:
 
 static void i596_tx_timeout (struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 
 	/* Transmitter timeout, serious problems. */
 	DEB(DEB_ERRORS,printk("%s: transmit timed out, status resetting.\n",
@@ -1071,7 +1071,7 @@ static void i596_tx_timeout (struct net_
 
 static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 	struct tx_cmd *tx_cmd;
 	struct i596_tbd *tbd;
 	short length = skb->len;
@@ -1220,7 +1220,7 @@ static int __devinit i82596_probe(struct
 
 	dev->priv = (void *)(dev->mem_start);
 
-	lp = netdev_priv(dev);
+	lp = dev->priv;
 	DEB(DEB_INIT,printk ("%s: lp at 0x%08lx (%d bytes), lp->scb at 0x%08lx\n",
 		dev->name, (unsigned long)lp,
 		sizeof(struct i596_private), (unsigned long)&lp->scb));
@@ -1250,7 +1250,7 @@ static irqreturn_t i596_interrupt(int ir
 		return IRQ_NONE;
 	}
 
-	lp = netdev_priv(dev);
+	lp = dev->priv;
 
 	spin_lock (&lp->lock);
 
@@ -1396,7 +1396,7 @@ static irqreturn_t i596_interrupt(int ir
 
 static int i596_close(struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 	unsigned long flags;
 
 	netif_stop_queue(dev);
@@ -1430,7 +1430,7 @@ static int i596_close(struct net_device 
 static struct net_device_stats *
  i596_get_stats(struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 
 	return &lp->stats;
 }
@@ -1441,7 +1441,7 @@ static struct net_device_stats *
 
 static void set_multicast_list(struct net_device *dev)
 {
-	struct i596_private *lp = netdev_priv(dev);
+	struct i596_private *lp = dev->priv;
 	int config = 0, cnt;
 
 	DEB(DEB_MULTI,printk("%s: set multicast list, %d entries, promisc %s, allmulti %s\n", dev->name, dev->mc_count, dev->flags & IFF_PROMISC ? "ON" : "OFF", dev->flags & IFF_ALLMULTI ? "ON" : "OFF"));
@@ -1541,7 +1541,7 @@ lan_init_chip(struct parisc_device *dev)
 
 	retval = register_netdev(netdevice);
 	if (retval) {
-		struct i596_private *lp = netdev_priv(netdevice);
+		struct i596_private *lp = netdevice->priv;
 		printk(KERN_WARNING __FILE__ ": register_netdevice ret'd %d\n", retval);
 		dma_free_noncoherent(lp->dev, sizeof(struct i596_private), 
 				    (void *)netdevice->mem_start, lp->dma_addr);
@@ -1595,7 +1595,7 @@ static void __exit lasi_82596_exit(void)
 		
 		unregister_netdev(netdevice);
 
-		lp = netdev_priv(netdevice);
+		lp = netdevice->priv;
 		dma_free_noncoherent(lp->dev, sizeof(struct i596_private), 
 				       (void *)netdevice->mem_start, lp->dma_addr);
 		free_netdev(netdevice);
diff -Naurp ./drivers/net/sgiseeq.c~netdev_rev ./drivers/net/sgiseeq.c
--- ./drivers/net/sgiseeq.c~netdev_rev	2004-03-18 13:02:28.000000000 -0800
+++ ./drivers/net/sgiseeq.c	2004-03-18 13:24:32.000000000 -0800
@@ -151,7 +151,7 @@ static inline void seeq_load_eaddr(struc
 
 static int seeq_init_ring(struct net_device *dev)
 {
-	struct sgiseeq_private *sp = netdev_priv(dev);
+	struct sgiseeq_private *sp = dev->priv;
 	volatile struct sgiseeq_init_block *ib = &sp->srings;
 	int i;
 
@@ -423,7 +423,7 @@ static inline void sgiseeq_tx(struct net
 static irqreturn_t sgiseeq_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
-	struct sgiseeq_private *sp = netdev_priv(dev);
+	struct sgiseeq_private *sp = dev->priv;
 	struct hpc3_ethregs *hregs = sp->hregs;
 	struct sgiseeq_regs *sregs = sp->sregs;
 
@@ -445,7 +445,7 @@ static irqreturn_t sgiseeq_interrupt(int
 
 static int sgiseeq_open(struct net_device *dev)
 {
-	struct sgiseeq_private *sp = netdev_priv(dev);
+	struct sgiseeq_private *sp = dev->priv;
 	struct sgiseeq_regs *sregs = sp->sregs;
 
 	int err = init_seeq(dev, sp, sregs);
@@ -459,7 +459,7 @@ static int sgiseeq_open(struct net_devic
 
 static int sgiseeq_close(struct net_device *dev)
 {
-	struct sgiseeq_private *sp = netdev_priv(dev);
+	struct sgiseeq_private *sp = dev->priv;
 	struct sgiseeq_regs *sregs = sp->sregs;
 
 	netif_stop_queue(dev);
@@ -472,7 +472,7 @@ static int sgiseeq_close(struct net_devi
 
 static inline int sgiseeq_reset(struct net_device *dev)
 {
-	struct sgiseeq_private *sp = netdev_priv(dev);
+	struct sgiseeq_private *sp = dev->priv;
 	struct sgiseeq_regs *sregs = sp->sregs;
 	int err;
 
@@ -494,7 +494,7 @@ void sgiseeq_my_reset(void)
 
 static int sgiseeq_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct sgiseeq_private *sp = netdev_priv(dev);
+	struct sgiseeq_private *sp = dev->priv;
 	struct hpc3_ethregs *hregs = sp->hregs;
 	unsigned long flags;
 	struct sgiseeq_tx_desc *td;
@@ -560,7 +560,7 @@ static void timeout(struct net_device *d
 
 static struct net_device_stats *sgiseeq_get_stats(struct net_device *dev)
 {
-	struct sgiseeq_private *sp = netdev_priv(dev);
+	struct sgiseeq_private *sp = dev->priv;
 
 	return &sp->stats;
 }
@@ -710,7 +710,7 @@ static void __exit sgiseeq_exit(void)
 	struct net_device *next, *dev = root_sgiseeq_dev;
 
 	while (dev) {
-		sp = netdev_priv(dev);
+		sp = dev->priv;
 		next = sp->next_module;
 		unregister_netdev(dev);
 		free_irq(dev->irq, dev);


--
~Randy
