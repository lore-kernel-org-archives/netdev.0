From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] use netdev_priv() in appletalk & fc
Date: Thu, 4 Mar 2004 13:17:15 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040304131715.757b7f48.rddunlap@osdl.org>
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



 linux-264-302-priv-rddunlap/drivers/net/appletalk/cops.c |   26 +++++++--------
 linux-264-302-priv-rddunlap/drivers/net/fc/iph5526.c     |    8 ++--
 2 files changed, 17 insertions(+), 17 deletions(-)

diff -puN drivers/net/appletalk/cops.c~net_atalk_fc_casts drivers/net/appletalk/cops.c
--- linux-264-302-priv/drivers/net/appletalk/cops.c~net_atalk_fc_casts	2004-03-02 15:16:36.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/appletalk/cops.c	2004-03-02 15:27:01.000000000 -0800
@@ -333,7 +333,7 @@ static int __init cops_probe1(struct net
 
 	dev->base_addr = ioaddr;
 
-        lp = (struct cops_local *)dev->priv;
+        lp = netdev_priv(dev);
         memset(lp, 0, sizeof(struct cops_local));
         spin_lock_init(&lp->lock);
 
@@ -422,7 +422,7 @@ static int __init cops_irq (int ioaddr, 
  */
 static int cops_open(struct net_device *dev)
 {
-    struct cops_local *lp = (struct cops_local *)dev->priv;
+    struct cops_local *lp = netdev_priv(dev);
 
 	if(dev->irq==0)
 	{
@@ -456,7 +456,7 @@ static int cops_open(struct net_device *
  */
 static int cops_jumpstart(struct net_device *dev)
 {
-	struct cops_local *lp = (struct cops_local *)dev->priv;
+	struct cops_local *lp = netdev_priv(dev);
 
 	/*
          *      Once the card has the firmware loaded and has acquired
@@ -490,7 +490,7 @@ static void tangent_wait_reset(int ioadd
  */
 static void cops_reset(struct net_device *dev, int sleep)
 {
-        struct cops_local *lp = (struct cops_local *)dev->priv;
+        struct cops_local *lp = netdev_priv(dev);
         int ioaddr=dev->base_addr;
 
         if(lp->board==TANGENT)
@@ -525,7 +525,7 @@ static void cops_load (struct net_device
 {
         struct ifreq ifr;
         struct ltfirmware *ltf= (struct ltfirmware *)&ifr.ifr_data;
-        struct cops_local *lp=(struct cops_local *)dev->priv;
+        struct cops_local *lp = netdev_priv(dev);
         int ioaddr=dev->base_addr;
 	int length, i = 0;
 
@@ -618,7 +618,7 @@ static void cops_load (struct net_device
  */
 static int cops_nodeid (struct net_device *dev, int nodeid)
 {
-	struct cops_local *lp = (struct cops_local *) dev->priv;
+	struct cops_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	if(lp->board == DAYNA)
@@ -730,7 +730,7 @@ static irqreturn_t cops_interrupt(int ir
         int boguscount = 0;
 
         ioaddr = dev->base_addr;
-        lp = (struct cops_local *)dev->priv;
+        lp = netdev_priv(dev);
 
 	if(lp->board==DAYNA)
 	{
@@ -765,7 +765,7 @@ static void cops_rx(struct net_device *d
         int pkt_len = 0;
         int rsp_type = 0;
         struct sk_buff *skb = NULL;
-        struct cops_local *lp = dev->priv;
+        struct cops_local *lp = netdev_priv(dev);
         int ioaddr = dev->base_addr;
         int boguscount = 0;
         unsigned long flags;
@@ -869,7 +869,7 @@ static void cops_rx(struct net_device *d
 
 static void cops_timeout(struct net_device *dev)
 {
-        struct cops_local *lp = (struct cops_local *)dev->priv;
+        struct cops_local *lp = netdev_priv(dev);
         int ioaddr = dev->base_addr;
 
 	lp->stats.tx_errors++;
@@ -891,7 +891,7 @@ static void cops_timeout(struct net_devi
 
 static int cops_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-        struct cops_local *lp = (struct cops_local *)dev->priv;
+        struct cops_local *lp = netdev_priv(dev);
         int ioaddr = dev->base_addr;
         unsigned long flags;
 
@@ -966,7 +966,7 @@ static int cops_hard_header(struct sk_bu
  
 static int cops_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-        struct cops_local *lp = (struct cops_local *)dev->priv;
+        struct cops_local *lp = netdev_priv(dev);
         struct sockaddr_at *sa = (struct sockaddr_at *)&ifr->ifr_addr;
         struct atalk_addr *aa = (struct atalk_addr *)&lp->node_addr;
 
@@ -1002,7 +1002,7 @@ static int cops_ioctl(struct net_device 
  
 static int cops_close(struct net_device *dev)
 {
-	struct cops_local *lp = (struct cops_local *)dev->priv;
+	struct cops_local *lp = netdev_priv(dev);
 
 	/* If we were running polled, yank the timer.
 	 */
@@ -1019,7 +1019,7 @@ static int cops_close(struct net_device 
  */
 static struct net_device_stats *cops_get_stats(struct net_device *dev)
 {
-        struct cops_local *lp = (struct cops_local *)dev->priv;
+        struct cops_local *lp = netdev_priv(dev);
         return &lp->stats;
 }
 
diff -puN drivers/net/fc/iph5526.c~net_atalk_fc_casts drivers/net/fc/iph5526.c
--- linux-264-302-priv/drivers/net/fc/iph5526.c~net_atalk_fc_casts	2004-03-02 15:16:36.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/fc/iph5526.c	2004-03-02 15:30:14.000000000 -0800
@@ -238,7 +238,7 @@ int __init iph5526_probe(struct net_devi
 
 static int __init iph5526_probe_pci(struct net_device *dev)
 {
-	struct fc_info *fi = (struct fc_info *)dev->priv;
+	struct fc_info *fi = netdev_priv(dev);
 	fi->dev = dev;
 	dev->base_addr = fi->base_addr;
 	dev->irq = fi->irq;
@@ -2908,7 +2908,7 @@ static int iph5526_close(struct net_devi
 
 static void iph5526_timeout(struct net_device *dev)
 {
-	struct fc_info *fi = (struct fc_info*)dev->priv;
+	struct fc_info *fi = netdev_priv(dev);
 	printk(KERN_WARNING "%s: timed out on send.\n", dev->name);
 	fi->fc_stats.rx_dropped++;
 	dev->trans_start = jiffies;
@@ -2917,7 +2917,7 @@ static void iph5526_timeout(struct net_d
 
 static int iph5526_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct fc_info *fi = (struct fc_info*)dev->priv;
+	struct fc_info *fi = netdev_priv(dev);
 	int status = 0;
 	short type = 0;
 	u_long flags;
@@ -3688,7 +3688,7 @@ int count = 0, j;
 
 static struct net_device_stats * iph5526_get_stats(struct net_device *dev)
 {	
-struct fc_info *fi = (struct fc_info*)dev->priv; 
+struct fc_info *fi = netdev_priv(dev);
 	return (struct net_device_stats *) &fi->fc_stats;
 }
 

_


--
~Randy
