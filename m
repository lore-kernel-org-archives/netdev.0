From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] remove unneeded casts in generic drivers/net/
Date: Sun, 29 Feb 2004 14:57:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040229145750.3afe6034.rddunlap@osdl.org>
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


 drivers/net/ethertap.c     |   10 +++++-----
 drivers/net/isa-skeleton.c |   14 +++++++-------
 drivers/net/loopback.c     |    2 +-
 drivers/net/plip.c         |   20 ++++++++++----------
 drivers/net/tun.c          |    6 +++---
 5 files changed, 26 insertions(+), 26 deletions(-)

diff -puN drivers/net/ethertap.c~net_generic_casts drivers/net/ethertap.c
--- linux-263-229/drivers/net/ethertap.c~net_generic_casts	2004-02-29 14:02:00.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/ethertap.c	2004-02-29 14:02:00.000000000 -0800
@@ -150,7 +150,7 @@ static unsigned ethertap_mc_hash(__u8 *d
 static void set_multicast_list(struct net_device *dev)
 {
 	unsigned groups = ~0;
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 
 	if (!(dev->flags&(IFF_NOARP|IFF_PROMISC|IFF_ALLMULTI))) {
 		struct dev_mc_list *dmi;
@@ -176,7 +176,7 @@ static void set_multicast_list(struct ne
  
 static int ethertap_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 #ifdef CONFIG_ETHERTAP_MC
 	struct ethhdr *eth = (struct ethhdr*)skb->data;
 #endif
@@ -234,7 +234,7 @@ static int ethertap_start_xmit(struct sk
 
 static __inline__ int ethertap_rx_skb(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 #ifdef CONFIG_ETHERTAP_MC
 	struct ethhdr *eth = (struct ethhdr*)(skb->data + 2);
 #endif
@@ -320,7 +320,7 @@ static void ethertap_rx(struct sock *sk,
 
 static int ethertap_close(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	struct sock *sk = lp->nl;
 
 	if (ethertap_debug > 2)
@@ -338,7 +338,7 @@ static int ethertap_close(struct net_dev
 
 static struct net_device_stats *ethertap_get_stats(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	return &lp->stats;
 }
 
diff -puN drivers/net/isa-skeleton.c~net_generic_casts drivers/net/isa-skeleton.c
--- linux-263-229/drivers/net/isa-skeleton.c~net_generic_casts	2004-02-29 14:02:00.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/isa-skeleton.c	2004-02-29 14:02:00.000000000 -0800
@@ -326,7 +326,7 @@ out:
 
 static void net_tx_timeout(struct net_device *dev)
 {
-	struct net_local *np = (struct net_local *)dev->priv;
+	struct net_local *np = dev->priv;
 
 	printk(KERN_WARNING "%s: transmit timed out, %s?\n", dev->name,
 	       tx_done(dev) ? "IRQ conflict" : "network cable problem");
@@ -361,7 +361,7 @@ static void net_tx_timeout(struct net_de
 static int
 net_open(struct net_device *dev)
 {
-	struct net_local *np = (struct net_local *)dev->priv;
+	struct net_local *np = dev->priv;
 	int ioaddr = dev->base_addr;
 	/*
 	 * This is used if the interrupt line can turned off (shared).
@@ -399,7 +399,7 @@ net_open(struct net_device *dev)
  */
 static int net_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_local *np = (struct net_local *)dev->priv;
+	struct net_local *np = dev->priv;
 	int ioaddr = dev->base_addr;
 	short length = ETH_ZLEN < skb->len ? skb->len : ETH_ZLEN;
 	unsigned char *buf = skb->data;
@@ -465,7 +465,7 @@ static int net_send_packet(struct sk_buf
  */
 void net_tx(struct net_device *dev)
 {
-	struct net_local *np = (struct net_local *)dev->priv;
+	struct net_local *np = dev->priv;
 	int entry;
 
 	/* This protects us from concurrent execution of
@@ -539,7 +539,7 @@ out:
 static void
 net_rx(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 	int boguscount = 10;
 
@@ -591,7 +591,7 @@ net_rx(struct net_device *dev)
 static int
 net_close(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 
 	lp->open_time = 0;
@@ -620,7 +620,7 @@ net_close(struct net_device *dev)
  */
 static struct net_device_stats *net_get_stats(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	short ioaddr = dev->base_addr;
 
 	/* Update the statistics from the device registers. */
diff -puN drivers/net/loopback.c~net_generic_casts drivers/net/loopback.c
--- linux-263-229/drivers/net/loopback.c~net_generic_casts	2004-02-29 14:02:00.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/loopback.c	2004-02-29 14:02:00.000000000 -0800
@@ -123,7 +123,7 @@ static void emulate_large_send_offload(s
  */
 static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_device_stats *stats = (struct net_device_stats *)dev->priv;
+	struct net_device_stats *stats = dev->priv;
 
 	skb_orphan(skb);
 
diff -puN drivers/net/plip.c~net_generic_casts drivers/net/plip.c
--- linux-263-229/drivers/net/plip.c~net_generic_casts	2004-02-29 14:02:00.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/plip.c	2004-02-29 14:02:00.000000000 -0800
@@ -323,7 +323,7 @@ plip_init_netdev(struct net_device *dev)
 static void
 plip_kick_bh(struct net_device *dev)
 {
-	struct net_local *nl = (struct net_local *)dev->priv;
+	struct net_local *nl = dev->priv;
 
 	if (nl->is_deferred)
 		schedule_work(&nl->immediate);
@@ -366,7 +366,7 @@ static plip_func connection_state_table[
 static void
 plip_bh(struct net_device *dev)
 {
-	struct net_local *nl = (struct net_local *)dev->priv;
+	struct net_local *nl = dev->priv;
 	struct plip_local *snd = &nl->snd_data;
 	struct plip_local *rcv = &nl->rcv_data;
 	plip_func f;
@@ -384,7 +384,7 @@ plip_bh(struct net_device *dev)
 static void
 plip_timer_bh(struct net_device *dev)
 {
-	struct net_local *nl = (struct net_local *)dev->priv;
+	struct net_local *nl = dev->priv;
 	
 	if (!(atomic_read (&nl->kill_timer))) {
 		plip_interrupt (-1, dev, NULL);
@@ -961,7 +961,7 @@ plip_interrupt(int irq, void *dev_id, st
 static int
 plip_tx_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_local *nl = (struct net_local *)dev->priv;
+	struct net_local *nl = dev->priv;
 	struct plip_local *snd = &nl->snd_data;
 
 	if (netif_queue_stopped(dev))
@@ -1021,7 +1021,7 @@ plip_hard_header(struct sk_buff *skb, st
                  unsigned short type, void *daddr,
 	         void *saddr, unsigned len)
 {
-	struct net_local *nl = (struct net_local *)dev->priv;
+	struct net_local *nl = dev->priv;
 	int ret;
 
 	if ((ret = nl->orig_hard_header(skb, dev, type, daddr, saddr, len)) >= 0)
@@ -1057,7 +1057,7 @@ int plip_hard_header_cache(struct neighb
 static int
 plip_open(struct net_device *dev)
 {
-	struct net_local *nl = (struct net_local *)dev->priv;
+	struct net_local *nl = dev->priv;
 	struct in_device *in_dev;
 
 	/* Grab the port */
@@ -1116,7 +1116,7 @@ plip_open(struct net_device *dev)
 static int
 plip_close(struct net_device *dev)
 {
-	struct net_local *nl = (struct net_local *)dev->priv;
+	struct net_local *nl = dev->priv;
 	struct plip_local *snd = &nl->snd_data;
 	struct plip_local *rcv = &nl->rcv_data;
 
@@ -1163,7 +1163,7 @@ static int
 plip_preempt(void *handle)
 {
 	struct net_device *dev = (struct net_device *)handle;
-	struct net_local *nl = (struct net_local *)dev->priv;
+	struct net_local *nl = dev->priv;
 
 	/* Stand our ground if a datagram is on the wire */
 	if (nl->connection != PLIP_CN_NONE) {
@@ -1179,7 +1179,7 @@ static void
 plip_wakeup(void *handle)
 {
 	struct net_device *dev = (struct net_device *)handle;
-	struct net_local *nl = (struct net_local *)dev->priv;
+	struct net_local *nl = dev->priv;
 
 	if (nl->port_owner) {
 		/* Why are we being woken up? */
@@ -1207,7 +1207,7 @@ plip_wakeup(void *handle)
 static struct net_device_stats *
 plip_get_stats(struct net_device *dev)
 {
-	struct net_local *nl = (struct net_local *)dev->priv;
+	struct net_local *nl = dev->priv;
 	struct net_device_stats *r = &nl->enet_stats;
 
 	return r;
diff -puN drivers/net/tun.c~net_generic_casts drivers/net/tun.c
--- linux-263-229/drivers/net/tun.c~net_generic_casts	2004-02-29 14:02:00.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/tun.c	2004-02-29 14:02:00.000000000 -0800
@@ -70,7 +70,7 @@ static int tun_net_close(struct net_devi
 /* Net device start xmit */
 static int tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct tun_struct *tun = (struct tun_struct *)dev->priv;
+	struct tun_struct *tun = dev->priv;
 
 	DBG(KERN_INFO "%s: tun_net_xmit %d\n", tun->dev->name, skb->len);
 
@@ -113,14 +113,14 @@ static void tun_net_mclist(struct net_de
 
 static struct net_device_stats *tun_net_stats(struct net_device *dev)
 {
-	struct tun_struct *tun = (struct tun_struct *)dev->priv;
+	struct tun_struct *tun = dev->priv;
 	return &tun->stats;
 }
 
 /* Initialize net device. */
 static void tun_net_init(struct net_device *dev)
 {
-	struct tun_struct *tun = (struct tun_struct *)dev->priv;
+	struct tun_struct *tun = dev->priv;
    
 	switch (tun->flags & TUN_TYPE_MASK) {
 	case TUN_TUN_DEV:

_

--
~Randy
