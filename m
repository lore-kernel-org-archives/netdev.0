From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] use netdev_priv() in net/wan drivers
Date: Thu, 4 Mar 2004 13:19:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040304131948.36158994.rddunlap@osdl.org>
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



 linux-264-302-priv-rddunlap/drivers/net/wan/comx-hw-locomx.c |   22 +++---
 linux-264-302-priv-rddunlap/drivers/net/wan/comx-hw-munich.c |   32 ++++----
 linux-264-302-priv-rddunlap/drivers/net/wan/comx.c           |   40 +++++------
 linux-264-302-priv-rddunlap/drivers/net/wan/cosa.c           |   20 ++---
 linux-264-302-priv-rddunlap/drivers/net/wan/lapbether.c      |   10 +-
 5 files changed, 62 insertions(+), 62 deletions(-)

diff -puN drivers/net/wan/comx.c~net_wan_casts drivers/net/wan/comx.c
--- linux-264-302-priv/drivers/net/wan/comx.c~net_wan_casts	2004-03-03 09:12:10.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/wan/comx.c	2004-03-03 09:30:17.000000000 -0800
@@ -119,7 +119,7 @@ struct comx_debugflags_struct	comx_debug
 
 int comx_debug(struct net_device *dev, char *fmt, ...)
 {
-	struct comx_channel *ch = dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 	char *page,*str;
 	va_list args;
 	int len;
@@ -162,7 +162,7 @@ int comx_debug(struct net_device *dev, c
 
 int comx_debug_skb(struct net_device *dev, struct sk_buff *skb, char *msg)
 {
-	struct comx_channel *ch = dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 
 	if (!ch->debug_area) return 0;
 	if (!skb) comx_debug(dev, "%s: %s NULL skb\n\n", dev->name, msg);
@@ -175,7 +175,7 @@ int comx_debug_bytes(struct net_device *
 		char *msg)
 {
 	int pos = 0;
-	struct comx_channel *ch = dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 
 	if (!ch->debug_area) return 0;
 
@@ -207,7 +207,7 @@ int comx_debug_bytes(struct net_device *
 static void comx_loadavg_timerfun(unsigned long d)
 {
 	struct net_device *dev = (struct net_device *)d;
-	struct comx_channel *ch = dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 
 	ch->avg_bytes[ch->loadavg_counter] = ch->current_stats->rx_bytes;
 	ch->avg_bytes[ch->loadavg_counter + ch->loadavg_size] = 
@@ -222,7 +222,7 @@ static void comx_loadavg_timerfun(unsign
 static void comx_reset_timerfun(unsigned long d)
 { 
 	struct net_device *dev = (struct net_device *)d;
-	struct comx_channel *ch = dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 
 	if(!(ch->line_status & (PROTO_LOOP | PROTO_UP))) {
 		if(test_and_set_bit(0,&ch->reset_pending) && ch->HW_reset) {
@@ -236,7 +236,7 @@ static void comx_reset_timerfun(unsigned
 
 static int comx_open(struct net_device *dev)
 {
-	struct comx_channel *ch = dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 	struct proc_dir_entry *comxdir = ch->procdir->subdir;
 	int ret=0;
 
@@ -268,7 +268,7 @@ static int comx_open(struct net_device *
 
 static int comx_close(struct net_device *dev)
 {
-	struct comx_channel *ch = dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 	struct proc_dir_entry *comxdir = ch->procdir->subdir;
 	int ret = -ENODEV;
 
@@ -303,7 +303,7 @@ static int comx_close(struct net_device 
 
 void comx_status(struct net_device *dev, int status)
 {
-	struct comx_channel *ch = dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 
 #if 0
 	if(status & (PROTO_UP | PROTO_LOOP)) {
@@ -321,7 +321,7 @@ void comx_status(struct net_device *dev,
 
 static int comx_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct comx_channel *ch = dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 	int rc;
 
 	if (skb->len > dev->mtu + dev->hard_header_len) {
@@ -342,7 +342,7 @@ static int comx_xmit(struct sk_buff *skb
 static int comx_header(struct sk_buff *skb, struct net_device *dev, 
 	unsigned short type, void *daddr, void *saddr, unsigned len) 
 {
-	struct comx_channel *ch = dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 
 	if (ch->LINE_header) {
 		return (ch->LINE_header(skb, dev, type, daddr, saddr, len));
@@ -354,7 +354,7 @@ static int comx_header(struct sk_buff *s
 static int comx_rebuild_header(struct sk_buff *skb) 
 {
 	struct net_device *dev = skb->dev;
-	struct comx_channel *ch = dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 
 	if (ch->LINE_rebuild_header) {
 		return(ch->LINE_rebuild_header(skb));
@@ -365,7 +365,7 @@ static int comx_rebuild_header(struct sk
 
 int comx_rx(struct net_device *dev, struct sk_buff *skb)
 {
-	struct comx_channel *ch = dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 
 	if (ch->debug_flags & DEBUG_COMX_RX) {
 		comx_debug_skb(dev, skb, "comx_rx skb");
@@ -379,7 +379,7 @@ int comx_rx(struct net_device *dev, stru
 
 static struct net_device_stats *comx_stats(struct net_device *dev)
 {
-	struct comx_channel *ch = (struct comx_channel *)dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 
 	return ch->current_stats;
 }
@@ -387,7 +387,7 @@ static struct net_device_stats *comx_sta
 void comx_lineup_func(unsigned long d)
 {
 	struct net_device *dev = (struct net_device *)d;
-	struct comx_channel *ch = dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 
 	del_timer(&ch->lineup_timer);
 	clear_bit(0, &ch->lineup_pending);
@@ -405,7 +405,7 @@ void comx_lineup_func(unsigned long d)
 
 static int comx_statistics(struct net_device *dev, char *page)
 {
-	struct comx_channel *ch = dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 	int len = 0;
 	int tmp;
 	int i = 0;
@@ -472,7 +472,7 @@ static int comx_statistics(struct net_de
 
 static int comx_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct comx_channel *ch = dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 
 	if (ch->LINE_ioctl) {
 		return(ch->LINE_ioctl(dev, ifr, cmd));
@@ -535,7 +535,7 @@ static int comx_read_proc(char *page, ch
 {
 	struct proc_dir_entry *file = (struct proc_dir_entry *)data;
 	struct net_device *dev = file->parent->data;
-	struct comx_channel *ch=(struct comx_channel *)dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 	int len = 0;
 
 	if (strcmp(file->name, FILENAME_STATUS) == 0) {
@@ -599,7 +599,7 @@ static int comx_write_proc(struct file *
 {
 	struct proc_dir_entry *entry = (struct proc_dir_entry *)data;
 	struct net_device *dev = (struct net_device *)entry->parent->data;
-	struct comx_channel *ch=(struct comx_channel *)dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 	char *page;
 	struct comx_hardware *hw = comx_channels;
 	struct comx_protocol *line = comx_lines;
@@ -821,7 +821,7 @@ static int comx_mkdir(struct inode *dir,
 	if (register_netdevice(dev)) {
 		goto cleanup_filename_debug;
 	}
-	ch=dev->priv;
+	ch = netdev_priv(dev);
 	if((ch->if_ptr = (void *)kmalloc(sizeof(struct ppp_device), 
 				 GFP_KERNEL)) == NULL) {
 		goto cleanup_register;
@@ -874,7 +874,7 @@ static int comx_rmdir(struct inode *dir,
 
 	lock_kernel();
 	dev = entry->data;
-	ch = dev->priv;
+	ch = netdev_priv(dev);
 	if (dev->flags & IFF_UP) {
 		printk(KERN_ERR "%s: down interface before removing it\n", dev->name);
 		unlock_kernel();
diff -puN drivers/net/wan/comx-hw-locomx.c~net_wan_casts drivers/net/wan/comx-hw-locomx.c
--- linux-264-302-priv/drivers/net/wan/comx-hw-locomx.c~net_wan_casts	2004-03-03 09:12:10.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/wan/comx-hw-locomx.c	2004-03-03 09:42:59.000000000 -0800
@@ -77,7 +77,7 @@ struct locomx_data {
 
 static int LOCOMX_txe(struct net_device *dev)
 {
-	struct comx_channel *ch = dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 	struct locomx_data *hw = ch->HW_privdata;
 
 	return (!hw->board.chanA.tx_next_skb);
@@ -86,8 +86,8 @@ static int LOCOMX_txe(struct net_device 
 
 static void locomx_rx(struct z8530_channel *c, struct sk_buff *skb)
 {
-	struct net_device *dev=c->netdevice;
-	struct comx_channel *ch=dev->priv;
+	struct net_device *dev = c->netdevice;
+	struct comx_channel *ch = netdev_priv(dev);
 	
 	if (ch->debug_flags & DEBUG_HW_RX) {
 		comx_debug_skb(dev, skb, "locomx_rx receiving");
@@ -97,7 +97,7 @@ static void locomx_rx(struct z8530_chann
 
 static int LOCOMX_send_packet(struct net_device *dev, struct sk_buff *skb) 
 {
-	struct comx_channel *ch = (struct comx_channel *)dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 	struct locomx_data *hw = ch->HW_privdata;
 
 	if (ch->debug_flags & DEBUG_HW_TX) {
@@ -126,9 +126,9 @@ static int LOCOMX_send_packet(struct net
 
 static void locomx_status_timerfun(unsigned long d)
 {
-	struct net_device *dev=(struct net_device *)d;
-	struct comx_channel *ch=dev->priv;
-	struct locomx_data *hw=ch->HW_privdata;
+	struct net_device *dev = (struct net_device *)d;
+	struct comx_channel *ch = netdev_priv(dev);
+	struct locomx_data *hw = ch->HW_privdata;
 
 	if(!(ch->line_status & LINE_UP) &&
 	    (hw->board.chanA.status & CTS)) {
@@ -144,7 +144,7 @@ static void locomx_status_timerfun(unsig
 
 static int LOCOMX_open(struct net_device *dev)
 {
-	struct comx_channel *ch = dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 	struct locomx_data *hw = ch->HW_privdata;
 	struct proc_dir_entry *procfile = ch->procdir->subdir;
 	unsigned long flags;
@@ -256,7 +256,7 @@ irq_fail:
 
 static int LOCOMX_close(struct net_device *dev)
 {
-	struct comx_channel *ch = dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 	struct locomx_data *hw = ch->HW_privdata;
 	struct proc_dir_entry *procfile = ch->procdir->subdir;
 
@@ -376,7 +376,7 @@ static int locomx_write_proc(struct file
 
 static int LOCOMX_init(struct net_device *dev) 
 {
-	struct comx_channel *ch = (struct comx_channel *)dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 	struct locomx_data *hw;
 	struct proc_dir_entry *new_file;
 
@@ -449,7 +449,7 @@ cleanup_HW_privdata:
 
 static int LOCOMX_exit(struct net_device *dev)
 {
-	struct comx_channel *ch = (struct comx_channel *)dev->priv;
+	struct comx_channel *ch = netdev_priv(dev);
 
 	ch->HW_access_board = NULL;
 	ch->HW_release_board = NULL;
diff -puN drivers/net/wan/comx-hw-munich.c~net_wan_casts drivers/net/wan/comx-hw-munich.c
--- linux-264-302-priv/drivers/net/wan/comx-hw-munich.c~net_wan_casts	2004-03-03 09:12:10.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/wan/comx-hw-munich.c	2004-03-03 09:32:01.000000000 -0800
@@ -373,7 +373,7 @@ static munich_board_t pcicom_boards[MAX_
 
 void rework_idle_channels(struct net_device *dev)
 {
-    struct comx_channel *ch = dev->priv;
+    struct comx_channel *ch = netdev_priv(dev);
     struct slicecom_privdata *hw = ch->HW_privdata;
     munich_board_t *board = slicecom_boards + hw->boardnum;
     munich_ccb_t *ccb = board->ccb;
@@ -731,7 +731,7 @@ static void pcicom_modemline(unsigned lo
 {
     munich_board_t *board = (munich_board_t *) b;
     struct net_device *dev = board->twins[0];
-    struct comx_channel *ch = dev->priv;
+    struct comx_channel *ch = netdev_priv(dev);
     unsigned long regs;
 
     regs = readl((void *)(&board->bar1[GPDATA]));
@@ -765,7 +765,7 @@ static void pcicom_modemline(unsigned lo
 
 static int MUNICH_txe(struct net_device *dev)
 {
-    struct comx_channel *ch = dev->priv;
+    struct comx_channel *ch = netdev_priv(dev);
     struct slicecom_privdata *hw = ch->HW_privdata;
 
     return (hw->busy < TX_DESC_MAX - 1);
@@ -905,7 +905,7 @@ static int munich_probe(void)
 #if 0
 static int slicecom_reset(struct net_device *dev)
 {
-    struct comx_channel *ch = dev->priv;
+    struct comx_channel *ch = netdev_priv(dev);
 
     printk("slicecom_reset: resetting the hardware\n");
 
@@ -933,7 +933,7 @@ static int slicecom_reset(struct net_dev
 
 static int MUNICH_send_packet(struct net_device *dev, struct sk_buff *skb)
 {
-    struct comx_channel *ch = (struct comx_channel *)dev->priv;
+    struct comx_channel *ch = netdev_priv(dev);
     struct slicecom_privdata *hw = ch->HW_privdata;
 
     /* Send it to the debug facility too if needed: */
@@ -1085,7 +1085,7 @@ static irqreturn_t MUNICH_interrupt(int 
 		goto go_for_next_interrupt;
 	    }
 
-	    ch = (struct comx_channel *)dev->priv;
+	    ch = netdev_priv(dev);
 	    hw = (struct slicecom_privdata *)ch->HW_privdata;
 
 	    //      printk("Rx STAT=0x%08x int_info=0x%08x rx_desc_ptr=%d rx_desc.status=0x%01x\n",
@@ -1125,7 +1125,7 @@ static irqreturn_t MUNICH_interrupt(int 
 
 	    if (dev != NULL)
 	    {
-		ch = (struct comx_channel *)dev->priv;
+		ch = netdev_priv(dev);
 		hw = (struct slicecom_privdata *)ch->HW_privdata;
 
 		rx_status = hw->rx_desc[hw->rx_desc_ptr].status;
@@ -1261,7 +1261,7 @@ static irqreturn_t MUNICH_interrupt(int 
 		goto go_for_next_tx_interrupt;
 	    }
 
-	    ch = (struct comx_channel *)dev->priv;
+	    ch = netdev_priv(dev);
 	    hw = (struct slicecom_privdata *)ch->HW_privdata;
 
 	    //      printk("Tx STAT=0x%08x int_info=0x%08x tiq_ptr=%d\n", stat, int_info.all, board->tiq_ptr );
@@ -1295,7 +1295,7 @@ static irqreturn_t MUNICH_interrupt(int 
 	    {
 		int newbusy;
 
-		ch = (struct comx_channel *)dev->priv;
+		ch = netdev_priv(dev);
 		hw = (struct slicecom_privdata *)ch->HW_privdata;
 
 		/* We don't trust the "Tx available" info from the TIQ, but check        */
@@ -1398,7 +1398,7 @@ static irqreturn_t MUNICH_interrupt(int 
 
 static int MUNICH_open(struct net_device *dev)
 {
-    struct comx_channel *ch = dev->priv;
+    struct comx_channel *ch = netdev_priv(dev);
     struct slicecom_privdata *hw = ch->HW_privdata;
     struct proc_dir_entry *procfile = ch->procdir->subdir;
     munich_board_t *board;
@@ -1891,7 +1891,7 @@ static int MUNICH_open(struct net_device
 
 static int MUNICH_close(struct net_device *dev)
 {
-    struct comx_channel *ch = dev->priv;
+    struct comx_channel *ch = netdev_priv(dev);
     struct slicecom_privdata *hw = ch->HW_privdata;
     struct proc_dir_entry *procfile = ch->procdir->subdir;
     munich_board_t *board;
@@ -2028,7 +2028,7 @@ static int MUNICH_close(struct net_devic
 
 static int MUNICH_minden(struct net_device *dev, char *page)
 {
-    struct comx_channel *ch = dev->priv;
+    struct comx_channel *ch = netdev_priv(dev);
     struct slicecom_privdata *hw = ch->HW_privdata;
     munich_board_t *board;
     struct net_device *devp;
@@ -2290,7 +2290,7 @@ static int munich_read_proc(char *page, 
 {
     struct proc_dir_entry *file = (struct proc_dir_entry *)data;
     struct net_device *dev = file->parent->data;
-    struct comx_channel *ch = dev->priv;
+    struct comx_channel *ch = netdev_priv(dev);
     struct slicecom_privdata *hw = ch->HW_privdata;
     munich_board_t *board;
 
@@ -2388,7 +2388,7 @@ static int munich_write_proc(struct file
 {
     struct proc_dir_entry *entry = (struct proc_dir_entry *)data;
     struct net_device *dev = (struct net_device *)entry->parent->data;
-    struct comx_channel *ch = dev->priv;
+    struct comx_channel *ch = netdev_priv(dev);
     struct slicecom_privdata *hw = ch->HW_privdata;
     munich_board_t *board;
 
@@ -2656,7 +2656,7 @@ static int init_escape(struct comx_chann
 
 static int BOARD_init(struct net_device *dev)
 {
-    struct comx_channel *ch = (struct comx_channel *)dev->priv;
+    struct comx_channel *ch = netdev_priv(dev);
     struct slicecom_privdata *hw;
     struct proc_dir_entry *new_file;
 
@@ -2772,7 +2772,7 @@ static int BOARD_init(struct net_device 
  */
 static int BOARD_exit(struct net_device *dev)
 {
-    struct comx_channel *ch = (struct comx_channel *)dev->priv;
+    struct comx_channel *ch = netdev_priv(dev);
 
     /* Free private data area */
 //    board = hw->boardnum + (ch->hardware == &pcicomhw ? pcicom_boards : slicecom_boards);
diff -puN drivers/net/wan/cosa.c~net_wan_casts drivers/net/wan/cosa.c
--- linux-264-302-priv/drivers/net/wan/cosa.c~net_wan_casts	2004-03-03 09:12:10.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/wan/cosa.c	2004-03-03 09:26:33.000000000 -0800
@@ -639,7 +639,7 @@ static void sppp_channel_delete(struct c
 
 static int cosa_sppp_open(struct net_device *d)
 {
-	struct channel_data *chan = d->priv;
+	struct channel_data *chan = netdev_priv(d);
 	int err;
 	unsigned long flags;
 
@@ -679,7 +679,7 @@ static int cosa_sppp_open(struct net_dev
 
 static int cosa_sppp_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct channel_data *chan = dev->priv;
+	struct channel_data *chan = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 
@@ -690,7 +690,7 @@ static int cosa_sppp_tx(struct sk_buff *
 
 static void cosa_sppp_timeout(struct net_device *dev)
 {
-	struct channel_data *chan = dev->priv;
+	struct channel_data *chan = netdev_priv(dev);
 
 	if (test_bit(RXBIT, &chan->cosa->rxtx)) {
 		chan->stats.rx_errors++;
@@ -709,7 +709,7 @@ static void cosa_sppp_timeout(struct net
 
 static int cosa_sppp_close(struct net_device *d)
 {
-	struct channel_data *chan = d->priv;
+	struct channel_data *chan = netdev_priv(d);
 	unsigned long flags;
 
 	netif_stop_queue(d);
@@ -789,7 +789,7 @@ static int sppp_tx_done(struct channel_d
 
 static struct net_device_stats *cosa_net_stats(struct net_device *dev)
 {
-	struct channel_data *chan = dev->priv;
+	struct channel_data *chan = netdev_priv(dev);
 	return &chan->stats;
 }
 
@@ -807,7 +807,7 @@ static ssize_t cosa_read(struct file *fi
 {
 	DECLARE_WAITQUEUE(wait, current);
 	unsigned long flags;
-	struct channel_data *chan = (struct channel_data *)file->private_data;
+	struct channel_data *chan = file->private_data;
 	struct cosa_data *cosa = chan->cosa;
 	char *kbuf;
 
@@ -881,7 +881,7 @@ static ssize_t cosa_write(struct file *f
 	const char *buf, size_t count, loff_t *ppos)
 {
 	DECLARE_WAITQUEUE(wait, current);
-	struct channel_data *chan = (struct channel_data *)file->private_data;
+	struct channel_data *chan = file->private_data;
 	struct cosa_data *cosa = chan->cosa;
 	unsigned long flags;
 	char *kbuf;
@@ -990,7 +990,7 @@ static int cosa_open(struct inode *inode
 
 static int cosa_release(struct inode *inode, struct file *file)
 {
-	struct channel_data *channel = (struct channel_data *)file->private_data;
+	struct channel_data *channel = file->private_data;
 	struct cosa_data *cosa;
 	unsigned long flags;
 
@@ -1205,7 +1205,7 @@ static int cosa_sppp_ioctl(struct net_de
 	int cmd)
 {
 	int rv;
-	struct channel_data *chan = (struct channel_data *)dev->priv;
+	struct channel_data *chan = netdev_priv(dev);
 	rv = cosa_ioctl_common(chan->cosa, chan, cmd, (unsigned long)ifr->ifr_data);
 	if (rv == -ENOIOCTLCMD) {
 		return sppp_do_ioctl(dev, ifr, cmd);
@@ -1216,7 +1216,7 @@ static int cosa_sppp_ioctl(struct net_de
 static int cosa_chardev_ioctl(struct inode *inode, struct file *file,
 	unsigned int cmd, unsigned long arg)
 {
-	struct channel_data *channel = (struct channel_data *)file->private_data;
+	struct channel_data *channel = file->private_data;
 	struct cosa_data *cosa = channel->cosa;
 	return cosa_ioctl_common(cosa, channel, cmd, arg);
 }
diff -puN drivers/net/wan/lapbether.c~net_wan_casts drivers/net/wan/lapbether.c
--- linux-264-302-priv/drivers/net/wan/lapbether.c~net_wan_casts	2004-03-03 09:12:10.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/wan/lapbether.c	2004-03-03 09:37:46.000000000 -0800
@@ -198,7 +198,7 @@ drop:
 
 static void lapbeth_data_transmit(struct net_device *ndev, struct sk_buff *skb)
 {
-	struct lapbethdev *lapbeth = ndev->priv;
+	struct lapbethdev *lapbeth = netdev_priv(ndev);
 	unsigned char *ptr;
 	struct net_device *dev;
 	int size = skb->len;
@@ -269,7 +269,7 @@ static void lapbeth_disconnected(struct 
  */
 static struct net_device_stats *lapbeth_get_stats(struct net_device *dev)
 {
-	struct lapbethdev *lapbeth = (struct lapbethdev *)dev->priv;
+	struct lapbethdev *lapbeth = netdev_priv(dev);
 	return &lapbeth->stats;
 }
 
@@ -278,7 +278,7 @@ static struct net_device_stats *lapbeth_
  */
 static int lapbeth_set_mac_address(struct net_device *dev, void *addr)
 {
-	struct sockaddr *sa = (struct sockaddr *)addr;
+	struct sockaddr *sa = addr;
 	memcpy(dev->dev_addr, sa->sa_data, dev->addr_len);
 	return 0;
 }
@@ -355,7 +355,7 @@ static int lapbeth_new_device(struct net
 	if (!ndev)
 		goto out;
 
-	lapbeth = ndev->priv;
+	lapbeth = netdev_priv(ndev);
 	lapbeth->axdev = ndev;
 
 	dev_hold(dev);
@@ -397,7 +397,7 @@ static int lapbeth_device_event(struct n
 				unsigned long event, void *ptr)
 {
 	struct lapbethdev *lapbeth;
-	struct net_device *dev = (struct net_device *)ptr;
+	struct net_device *dev = ptr;
 
 	if (!dev_is_ethdev(dev))
 		return NOTIFY_DONE;

_


--
~Randy
