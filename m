From: Daniel Ritz <daniel.ritz@gmx.ch>
Subject: [PATCH] netdev_priv for xirc2ps_cs, nmclan_cs
Date: Mon, 15 Mar 2004 00:11:09 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403150011.09952.daniel.ritz@gmx.ch>
Reply-To: daniel.ritz@gmx.ch
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

s/dev->priv/netdev_priv(dev)/ for xirc2ps_cs.c and nmclan_cs.c
xircom one is tested. against 2.6.4-bk

rgds
-daniel

--- 1.31/drivers/net/pcmcia/xirc2ps_cs.c	Fri Mar 12 01:00:00 2004
+++ edited/drivers/net/pcmcia/xirc2ps_cs.c	Sun Mar 14 16:01:12 2004
@@ -595,7 +595,7 @@
     dev = alloc_etherdev(sizeof(local_info_t));
     if (!dev)
 	    return NULL;
-    local = dev->priv;
+    local = netdev_priv(dev);
     link = &local->link;
     link->priv = dev;
 
@@ -710,7 +710,7 @@
 set_card_type(dev_link_t *link, const void *s)
 {
     struct net_device *dev = link->priv;
-    local_info_t *local = dev->priv;
+    local_info_t *local = netdev_priv(dev);
   #ifdef PCMCIA_DEBUG
     unsigned cisrev = ((const unsigned char *)s)[2];
   #endif
@@ -805,7 +805,7 @@
 {
     client_handle_t handle = link->handle;
     struct net_device *dev = link->priv;
-    local_info_t *local = dev->priv;
+    local_info_t *local = netdev_priv(dev);
     tuple_t tuple;
     cisparse_t parse;
     ioaddr_t ioaddr;
@@ -1159,7 +1159,7 @@
 
     if (link->win) {
 	struct net_device *dev = link->priv;
-	local_info_t *local = dev->priv;
+	local_info_t *local = netdev_priv(dev);
 	if (local->dingo)
 	    iounmap(local->dingo_ccr - 0x0800);
 	pcmcia_release_window(link->win);
@@ -1246,7 +1246,7 @@
 xirc2ps_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
     struct net_device *dev = (struct net_device *)dev_id;
-    local_info_t *lp = dev->priv;
+    local_info_t *lp = netdev_priv(dev);
     ioaddr_t ioaddr;
     u_char saved_page;
     unsigned bytes_rcvd;
@@ -1468,7 +1468,7 @@
 static void
 do_tx_timeout(struct net_device *dev)
 {
-    local_info_t *lp = dev->priv;
+    local_info_t *lp = netdev_priv(dev);
     printk(KERN_NOTICE "%s: transmit timed out\n", dev->name);
     lp->stats.tx_errors++;
     /* reset the card */
@@ -1480,7 +1480,7 @@
 static int
 do_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-    local_info_t *lp = dev->priv;
+    local_info_t *lp = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
     int okay;
     unsigned freespace;
@@ -1537,7 +1537,7 @@
 static struct net_device_stats *
 do_get_stats(struct net_device *dev)
 {
-    local_info_t *lp = dev->priv;
+    local_info_t *lp = netdev_priv(dev);
 
     /*	lp->stats.rx_missed_errors = GetByte(?) */
     return &lp->stats;
@@ -1552,7 +1552,7 @@
 set_addresses(struct net_device *dev)
 {
     ioaddr_t ioaddr = dev->base_addr;
-    local_info_t *lp = dev->priv;
+    local_info_t *lp = netdev_priv(dev);
     struct dev_mc_list *dmi = dev->mc_list;
     char *addr;
     int i,j,k,n;
@@ -1617,7 +1617,7 @@
 static int
 do_config(struct net_device *dev, struct ifmap *map)
 {
-    local_info_t *local = dev->priv;
+    local_info_t *local = netdev_priv(dev);
 
     DEBUG(0, "do_config(%p)\n", dev);
     if (map->port != 255 && map->port != dev->if_port) {
@@ -1643,7 +1643,7 @@
 static int
 do_open(struct net_device *dev)
 {
-    local_info_t *lp = dev->priv;
+    local_info_t *lp = netdev_priv(dev);
     dev_link_t *link = &lp->link;
 
     DEBUG(0, "do_open(%p)\n", dev);
@@ -1676,7 +1676,7 @@
 static int
 do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-    local_info_t *local = dev->priv;
+    local_info_t *local = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
     u16 *data = (u16 *)&rq->ifr_data;
 
@@ -1708,7 +1708,7 @@
 static void
 hardreset(struct net_device *dev)
 {
-    local_info_t *local = dev->priv;
+    local_info_t *local = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
 
     SelectPage(4);
@@ -1725,7 +1725,7 @@
 static void
 do_reset(struct net_device *dev, int full)
 {
-    local_info_t *local = dev->priv;
+    local_info_t *local = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
     unsigned value;
 
@@ -1886,7 +1886,7 @@
 static int
 init_mii(struct net_device *dev)
 {
-    local_info_t *local = dev->priv;
+    local_info_t *local = netdev_priv(dev);
     ioaddr_t ioaddr = dev->base_addr;
     unsigned control, status, linkpartner;
     int i;
@@ -1973,7 +1973,7 @@
 do_stop(struct net_device *dev)
 {
     ioaddr_t ioaddr = dev->base_addr;
-    local_info_t *lp = dev->priv;
+    local_info_t *lp = netdev_priv(dev);
     dev_link_t *link = &lp->link;
 
     DEBUG(0, "do_stop(%p)\n", dev);
--- 1.24/drivers/net/pcmcia/nmclan_cs.c	Tue Jan 20 00:34:56 2004
+++ edited/drivers/net/pcmcia/nmclan_cs.c	Sun Mar 14 16:05:00 2004
@@ -470,7 +470,7 @@
     dev = alloc_etherdev(sizeof(mace_private));
     if (!dev)
 	return NULL;
-    lp = dev->priv;
+    lp = netdev_priv(dev);
     link = &lp->link;
     link->priv = dev;
     
@@ -707,7 +707,7 @@
 {
   client_handle_t handle = link->handle;
   struct net_device *dev = link->priv;
-  mace_private *lp = dev->priv;
+  mace_private *lp = netdev_priv(dev);
   tuple_t tuple;
   cisparse_t parse;
   u_char buf[64];
@@ -875,7 +875,7 @@
 ---------------------------------------------------------------------------- */
 static void nmclan_reset(struct net_device *dev)
 {
-  mace_private *lp = dev->priv;
+  mace_private *lp = netdev_priv(dev);
 
 #if RESET_XILINX
   dev_link_t *link = &lp->link;
@@ -944,7 +944,7 @@
 static int mace_open(struct net_device *dev)
 {
   ioaddr_t ioaddr = dev->base_addr;
-  mace_private *lp = dev->priv;
+  mace_private *lp = netdev_priv(dev);
   dev_link_t *link = &lp->link;
 
   if (!DEV_OK(link))
@@ -967,7 +967,7 @@
 static int mace_close(struct net_device *dev)
 {
   ioaddr_t ioaddr = dev->base_addr;
-  mace_private *lp = dev->priv;
+  mace_private *lp = netdev_priv(dev);
   dev_link_t *link = &lp->link;
 
   DEBUG(2, "%s: shutting down ethercard.\n", dev->name);
@@ -1022,7 +1022,7 @@
 
 static void mace_tx_timeout(struct net_device *dev)
 {
-  mace_private *lp = (mace_private *)dev->priv;
+  mace_private *lp = netdev_priv(dev);
   dev_link_t *link = &lp->link;
 
   printk(KERN_NOTICE "%s: transmit timed out -- ", dev->name);
@@ -1038,7 +1038,7 @@
 
 static int mace_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-  mace_private *lp = (mace_private *)dev->priv;
+  mace_private *lp = netdev_priv(dev);
   ioaddr_t ioaddr = dev->base_addr;
 
   netif_stop_queue(dev);
@@ -1099,7 +1099,7 @@
 static irqreturn_t mace_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
   struct net_device *dev = (struct net_device *) dev_id;
-  mace_private *lp = dev->priv;
+  mace_private *lp = netdev_priv(dev);
   ioaddr_t ioaddr = dev->base_addr;
   int status;
   int IntrCnt = MACE_MAX_IR_ITERATIONS;
@@ -1241,7 +1241,7 @@
 ---------------------------------------------------------------------------- */
 static int mace_rx(struct net_device *dev, unsigned char RxCnt)
 {
-  mace_private *lp = (mace_private *)dev->priv;
+  mace_private *lp = netdev_priv(dev);
   ioaddr_t ioaddr = dev->base_addr;
   unsigned char rx_framecnt;
   unsigned short rx_status;
@@ -1408,7 +1408,7 @@
 ---------------------------------------------------------------------------- */
 static void update_stats(ioaddr_t ioaddr, struct net_device *dev)
 {
-  mace_private *lp = (mace_private *)dev->priv;
+  mace_private *lp = netdev_priv(dev);
 
   lp->mace_stats.rcvcc += mace_read(lp, ioaddr, MACE_RCVCC);
   lp->mace_stats.rntpc += mace_read(lp, ioaddr, MACE_RNTPC);
@@ -1454,7 +1454,7 @@
 ---------------------------------------------------------------------------- */
 static struct net_device_stats *mace_get_stats(struct net_device *dev)
 {
-  mace_private *lp = (mace_private *)dev->priv;
+  mace_private *lp = netdev_priv(dev);
 
   update_stats(dev->base_addr, dev);
 
@@ -1549,7 +1549,7 @@
 ---------------------------------------------------------------------------- */
 static void restore_multicast_list(struct net_device *dev)
 {
-  mace_private *lp = (mace_private *)dev->priv;
+  mace_private *lp = netdev_priv(dev);
   int num_addrs = lp->multicast_num_addrs;
   int *ladrf = lp->multicast_ladrf;
   ioaddr_t ioaddr = dev->base_addr;
@@ -1606,7 +1606,7 @@
 
 static void set_multicast_list(struct net_device *dev)
 {
-  mace_private *lp = (mace_private *)dev->priv;
+  mace_private *lp = netdev_priv(dev);
   int adr[ETHER_ADDR_LEN] = {0}; /* Ethernet address */
   int i;
   struct dev_mc_list *dmi = dev->mc_list;
@@ -1645,10 +1645,10 @@
 static void restore_multicast_list(struct net_device *dev)
 {
   ioaddr_t ioaddr = dev->base_addr;
-  mace_private *lp = (mace_private *)dev->priv;
+  mace_private *lp = netdev_priv(dev);
 
   DEBUG(2, "%s: restoring Rx mode to %d addresses.\n", dev->name,
-	((mace_private *)(dev->priv))->multicast_num_addrs);
+	lp->multicast_num_addrs);
 
   if (dev->flags & IFF_PROMISC) {
     /* Promiscuous mode: receive all packets */
@@ -1665,7 +1665,7 @@
 
 static void set_multicast_list(struct net_device *dev)
 {
-  mace_private *lp = (mace_private *)dev->priv;
+  mace_private *lp = netdev_priv(dev);
 
 #ifdef PCMCIA_DEBUG
   if (pc_debug > 1) {
