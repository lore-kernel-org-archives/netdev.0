From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] use netdev_priv() in tap/tun/plip/loop/skel
Date: Thu, 4 Mar 2004 13:17:30 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040304131730.19dfeef9.rddunlap@osdl.org>
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



 linux-264-302-priv-rddunlap/drivers/net/ethertap.c     |   12 +++---
 linux-264-302-priv-rddunlap/drivers/net/isa-skeleton.c |   18 ++++-----
 linux-264-302-priv-rddunlap/drivers/net/loopback.c     |    2 -
 linux-264-302-priv-rddunlap/drivers/net/plip.c         |   32 ++++++++---------
 linux-264-302-priv-rddunlap/drivers/net/tun.c          |   22 +++++------
 5 files changed, 43 insertions(+), 43 deletions(-)

diff -puN drivers/net/ethertap.c~net_generic_casts drivers/net/ethertap.c
--- linux-264-302-priv/drivers/net/ethertap.c~net_generic_casts	2004-03-03 10:33:04.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/ethertap.c	2004-03-03 10:53:18.000000000 -0800
@@ -121,7 +121,7 @@ out:
 
 static int ethertap_open(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local*)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 
 	if (ethertap_debug > 2)
 		printk(KERN_DEBUG "%s: Doing ethertap_open()...", dev->name);
@@ -150,7 +150,7 @@ static unsigned ethertap_mc_hash(__u8 *d
 static void set_multicast_list(struct net_device *dev)
 {
 	unsigned groups = ~0;
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 
 	if (!(dev->flags&(IFF_NOARP|IFF_PROMISC|IFF_ALLMULTI))) {
 		struct dev_mc_list *dmi;
@@ -176,7 +176,7 @@ static void set_multicast_list(struct ne
  
 static int ethertap_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 #ifdef CONFIG_ETHERTAP_MC
 	struct ethhdr *eth = (struct ethhdr*)skb->data;
 #endif
@@ -234,7 +234,7 @@ static int ethertap_start_xmit(struct sk
 
 static __inline__ int ethertap_rx_skb(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 #ifdef CONFIG_ETHERTAP_MC
 	struct ethhdr *eth = (struct ethhdr*)(skb->data + 2);
 #endif
@@ -320,7 +320,7 @@ static void ethertap_rx(struct sock *sk,
 
 static int ethertap_close(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	struct sock *sk = lp->nl;
 
 	if (ethertap_debug > 2)
@@ -338,7 +338,7 @@ static int ethertap_close(struct net_dev
 
 static struct net_device_stats *ethertap_get_stats(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	return &lp->stats;
 }
 
diff -puN drivers/net/isa-skeleton.c~net_generic_casts drivers/net/isa-skeleton.c
--- linux-264-302-priv/drivers/net/isa-skeleton.c~net_generic_casts	2004-03-03 10:33:04.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/isa-skeleton.c	2004-03-03 10:54:41.000000000 -0800
@@ -303,7 +303,7 @@ static int __init netcard_probe1(struct 
 	}
 #endif	/* jumpered DMA */
 
-	np = (struct net_local *)dev->priv;
+	np = netdev_priv(dev);
 	spin_lock_init(&np->lock);
 
 	dev->open		= net_open;
@@ -326,7 +326,7 @@ out:
 
 static void net_tx_timeout(struct net_device *dev)
 {
-	struct net_local *np = (struct net_local *)dev->priv;
+	struct net_local *np = netdev_priv(dev);
 
 	printk(KERN_WARNING "%s: transmit timed out, %s?\n", dev->name,
 	       tx_done(dev) ? "IRQ conflict" : "network cable problem");
@@ -361,7 +361,7 @@ static void net_tx_timeout(struct net_de
 static int
 net_open(struct net_device *dev)
 {
-	struct net_local *np = (struct net_local *)dev->priv;
+	struct net_local *np = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	/*
 	 * This is used if the interrupt line can turned off (shared).
@@ -399,7 +399,7 @@ net_open(struct net_device *dev)
  */
 static int net_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_local *np = (struct net_local *)dev->priv;
+	struct net_local *np = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	short length = ETH_ZLEN < skb->len ? skb->len : ETH_ZLEN;
 	unsigned char *buf = skb->data;
@@ -465,7 +465,7 @@ static int net_send_packet(struct sk_buf
  */
 void net_tx(struct net_device *dev)
 {
-	struct net_local *np = (struct net_local *)dev->priv;
+	struct net_local *np = netdev_priv(dev);
 	int entry;
 
 	/* This protects us from concurrent execution of
@@ -508,7 +508,7 @@ static irqreturn_t net_interrupt(int irq
 
 	ioaddr = dev->base_addr;
 
-	np = (struct net_local *)dev->priv;
+	np = netdev_priv(dev);
 	status = inw(ioaddr + 0);
 
 	if (status == 0)
@@ -539,7 +539,7 @@ out:
 static void
 net_rx(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int boguscount = 10;
 
@@ -591,7 +591,7 @@ net_rx(struct net_device *dev)
 static int
 net_close(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	lp->open_time = 0;
@@ -620,7 +620,7 @@ net_close(struct net_device *dev)
  */
 static struct net_device_stats *net_get_stats(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 
 	/* Update the statistics from the device registers. */
diff -puN drivers/net/loopback.c~net_generic_casts drivers/net/loopback.c
--- linux-264-302-priv/drivers/net/loopback.c~net_generic_casts	2004-03-03 10:33:04.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/loopback.c	2004-03-03 10:42:24.000000000 -0800
@@ -123,7 +123,7 @@ static void emulate_large_send_offload(s
  */
 static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_device_stats *stats = (struct net_device_stats *)dev->priv;
+	struct net_device_stats *stats = netdev_priv(dev);
 
 	skb_orphan(skb);
 
diff -puN drivers/net/plip.c~net_generic_casts drivers/net/plip.c
--- linux-264-302-priv/drivers/net/plip.c~net_generic_casts	2004-03-03 10:33:04.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/plip.c	2004-03-03 10:52:24.000000000 -0800
@@ -280,7 +280,7 @@ inline static unsigned char read_status 
 static void
 plip_init_netdev(struct net_device *dev)
 {
-	struct net_local *nl = dev->priv;
+	struct net_local *nl = netdev_priv(dev);
 
 	/* Then, override parts of it */
 	dev->hard_start_xmit	 = plip_tx_packet;
@@ -323,7 +323,7 @@ plip_init_netdev(struct net_device *dev)
 static void
 plip_kick_bh(struct net_device *dev)
 {
-	struct net_local *nl = (struct net_local *)dev->priv;
+	struct net_local *nl = netdev_priv(dev);
 
 	if (nl->is_deferred)
 		schedule_work(&nl->immediate);
@@ -366,7 +366,7 @@ static plip_func connection_state_table[
 static void
 plip_bh(struct net_device *dev)
 {
-	struct net_local *nl = (struct net_local *)dev->priv;
+	struct net_local *nl = netdev_priv(dev);
 	struct plip_local *snd = &nl->snd_data;
 	struct plip_local *rcv = &nl->rcv_data;
 	plip_func f;
@@ -384,7 +384,7 @@ plip_bh(struct net_device *dev)
 static void
 plip_timer_bh(struct net_device *dev)
 {
-	struct net_local *nl = (struct net_local *)dev->priv;
+	struct net_local *nl = netdev_priv(dev);
 	
 	if (!(atomic_read (&nl->kill_timer))) {
 		plip_interrupt (-1, dev, NULL);
@@ -917,7 +917,7 @@ plip_interrupt(int irq, void *dev_id, st
 		return;
 	}
 
-	nl = (struct net_local *)dev->priv;
+	nl = netdev_priv(dev);
 	rcv = &nl->rcv_data;
 
 	spin_lock_irq (&nl->lock);
@@ -961,7 +961,7 @@ plip_interrupt(int irq, void *dev_id, st
 static int
 plip_tx_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_local *nl = (struct net_local *)dev->priv;
+	struct net_local *nl = netdev_priv(dev);
 	struct plip_local *snd = &nl->snd_data;
 
 	if (netif_queue_stopped(dev))
@@ -1021,7 +1021,7 @@ plip_hard_header(struct sk_buff *skb, st
                  unsigned short type, void *daddr,
 	         void *saddr, unsigned len)
 {
-	struct net_local *nl = (struct net_local *)dev->priv;
+	struct net_local *nl = netdev_priv(dev);
 	int ret;
 
 	if ((ret = nl->orig_hard_header(skb, dev, type, daddr, saddr, len)) >= 0)
@@ -1033,7 +1033,7 @@ plip_hard_header(struct sk_buff *skb, st
 int plip_hard_header_cache(struct neighbour *neigh,
                            struct hh_cache *hh)
 {
-	struct net_local *nl = (struct net_local *)neigh->dev->priv;
+	struct net_local *nl = neigh->dev->priv;
 	int ret;
 	
 	if ((ret = nl->orig_hard_header_cache(neigh, hh)) == 0)
@@ -1057,7 +1057,7 @@ int plip_hard_header_cache(struct neighb
 static int
 plip_open(struct net_device *dev)
 {
-	struct net_local *nl = (struct net_local *)dev->priv;
+	struct net_local *nl = netdev_priv(dev);
 	struct in_device *in_dev;
 
 	/* Grab the port */
@@ -1116,7 +1116,7 @@ plip_open(struct net_device *dev)
 static int
 plip_close(struct net_device *dev)
 {
-	struct net_local *nl = (struct net_local *)dev->priv;
+	struct net_local *nl = netdev_priv(dev);
 	struct plip_local *snd = &nl->snd_data;
 	struct plip_local *rcv = &nl->rcv_data;
 
@@ -1163,7 +1163,7 @@ static int
 plip_preempt(void *handle)
 {
 	struct net_device *dev = (struct net_device *)handle;
-	struct net_local *nl = (struct net_local *)dev->priv;
+	struct net_local *nl = netdev_priv(dev);
 
 	/* Stand our ground if a datagram is on the wire */
 	if (nl->connection != PLIP_CN_NONE) {
@@ -1179,7 +1179,7 @@ static void
 plip_wakeup(void *handle)
 {
 	struct net_device *dev = (struct net_device *)handle;
-	struct net_local *nl = (struct net_local *)dev->priv;
+	struct net_local *nl = netdev_priv(dev);
 
 	if (nl->port_owner) {
 		/* Why are we being woken up? */
@@ -1207,7 +1207,7 @@ plip_wakeup(void *handle)
 static struct net_device_stats *
 plip_get_stats(struct net_device *dev)
 {
-	struct net_local *nl = (struct net_local *)dev->priv;
+	struct net_local *nl = netdev_priv(dev);
 	struct net_device_stats *r = &nl->enet_stats;
 
 	return r;
@@ -1216,7 +1216,7 @@ plip_get_stats(struct net_device *dev)
 static int
 plip_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct net_local *nl = (struct net_local *) dev->priv;
+	struct net_local *nl = netdev_priv(dev);
 	struct plipconf *pc = (struct plipconf *) &rq->ifr_data;
 
 	switch(pc->pcmd) {
@@ -1288,7 +1288,7 @@ static void plip_attach (struct parport 
 		                 "which is fairly inefficient!\n", port->name);
 		}
 
-		nl = dev->priv;
+		nl = netdev_priv(dev);
 		nl->pardev = parport_register_device(port, name, plip_preempt,
 						 plip_wakeup, plip_interrupt, 
 						 0, dev);
@@ -1348,7 +1348,7 @@ static void __exit plip_cleanup_module (
 
 	for (i=0; i < PLIP_MAX; i++) {
 		if ((dev = dev_plip[i])) {
-			struct net_local *nl = dev->priv;
+			struct net_local *nl = netdev_priv(dev);
 			unregister_netdev(dev);
 			if (nl->port_owner)
 				parport_release(nl->pardev);
diff -puN drivers/net/tun.c~net_generic_casts drivers/net/tun.c
--- linux-264-302-priv/drivers/net/tun.c~net_generic_casts	2004-03-03 10:33:04.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/tun.c	2004-03-03 10:44:01.000000000 -0800
@@ -70,7 +70,7 @@ static int tun_net_close(struct net_devi
 /* Net device start xmit */
 static int tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct tun_struct *tun = (struct tun_struct *)dev->priv;
+	struct tun_struct *tun = netdev_priv(dev);
 
 	DBG(KERN_INFO "%s: tun_net_xmit %d\n", tun->dev->name, skb->len);
 
@@ -113,14 +113,14 @@ static void tun_net_mclist(struct net_de
 
 static struct net_device_stats *tun_net_stats(struct net_device *dev)
 {
-	struct tun_struct *tun = (struct tun_struct *)dev->priv;
+	struct tun_struct *tun = netdev_priv(dev);
 	return &tun->stats;
 }
 
 /* Initialize net device. */
 static void tun_net_init(struct net_device *dev)
 {
-	struct tun_struct *tun = (struct tun_struct *)dev->priv;
+	struct tun_struct *tun = netdev_priv(dev);
    
 	switch (tun->flags & TUN_TYPE_MASK) {
 	case TUN_TUN_DEV:
@@ -153,7 +153,7 @@ static void tun_net_init(struct net_devi
 /* Poll */
 static unsigned int tun_chr_poll(struct file *file, poll_table * wait)
 {  
-	struct tun_struct *tun = (struct tun_struct *)file->private_data;
+	struct tun_struct *tun = file->private_data;
 	unsigned int mask = POLLOUT | POLLWRNORM;
 
 	if (!tun)
@@ -217,7 +217,7 @@ static __inline__ ssize_t tun_get_user(s
 static ssize_t tun_chr_writev(struct file * file, const struct iovec *iv, 
 			      unsigned long count, loff_t *pos)
 {
-	struct tun_struct *tun = (struct tun_struct *)file->private_data;
+	struct tun_struct *tun = file->private_data;
 	unsigned long i;
 	size_t len;
 
@@ -279,7 +279,7 @@ static __inline__ ssize_t tun_put_user(s
 static ssize_t tun_chr_readv(struct file *file, const struct iovec *iv,
 			    unsigned long count, loff_t *pos)
 {
-	struct tun_struct *tun = (struct tun_struct *)file->private_data;
+	struct tun_struct *tun = file->private_data;
 	DECLARE_WAITQUEUE(wait, current);
 	struct sk_buff *skb;
 	ssize_t len, ret = 0;
@@ -341,7 +341,7 @@ static ssize_t tun_chr_read(struct file 
 
 static void tun_setup(struct net_device *dev)
 {
-	struct tun_struct *tun = dev->priv;
+	struct tun_struct *tun = netdev_priv(dev);
 
 	skb_queue_head_init(&tun->readq);
 	init_waitqueue_head(&tun->read_wait);
@@ -413,7 +413,7 @@ static int tun_set_iff(struct file *file
 		if (!dev)
 			return -ENOMEM;
 
-		tun = dev->priv;
+		tun = netdev_priv(dev);
 		tun->dev = dev;
 		tun->flags = flags;
 
@@ -455,7 +455,7 @@ static int tun_set_iff(struct file *file
 static int tun_chr_ioctl(struct inode *inode, struct file *file, 
 			 unsigned int cmd, unsigned long arg)
 {
-	struct tun_struct *tun = (struct tun_struct *)file->private_data;
+	struct tun_struct *tun = file->private_data;
 
 	if (cmd == TUNSETIFF && !tun) {
 		struct ifreq ifr;
@@ -527,7 +527,7 @@ static int tun_chr_ioctl(struct inode *i
 
 static int tun_chr_fasync(int fd, struct file *file, int on)
 {
-	struct tun_struct *tun = (struct tun_struct *)file->private_data;
+	struct tun_struct *tun = file->private_data;
 	int ret;
 
 	if (!tun)
@@ -558,7 +558,7 @@ static int tun_chr_open(struct inode *in
 
 static int tun_chr_close(struct inode *inode, struct file *file)
 {
-	struct tun_struct *tun = (struct tun_struct *)file->private_data;
+	struct tun_struct *tun = file->private_data;
 
 	if (!tun)
 		return 0;

_


--
~Randy
