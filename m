From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] use netdev_priv() in /hamradio/
Date: Thu, 4 Mar 2004 13:17:51 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040304131751.1443cf90.rddunlap@osdl.org>
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



 linux-264-302-priv-rddunlap/drivers/net/hamradio/baycom_epp.c     |   24 +++++-----
 linux-264-302-priv-rddunlap/drivers/net/hamradio/baycom_par.c     |   12 ++---
 linux-264-302-priv-rddunlap/drivers/net/hamradio/baycom_ser_fdx.c |   10 ++--
 linux-264-302-priv-rddunlap/drivers/net/hamradio/baycom_ser_hdx.c |   10 ++--
 4 files changed, 28 insertions(+), 28 deletions(-)

diff -puN drivers/net/hamradio/baycom_epp.c~net_hamradio_casts drivers/net/hamradio/baycom_epp.c
--- linux-264-302-priv/drivers/net/hamradio/baycom_epp.c~net_hamradio_casts	2004-03-02 15:41:21.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/hamradio/baycom_epp.c	2004-03-02 15:49:09.000000000 -0800
@@ -646,7 +646,7 @@ static int transmit(struct baycom_state 
 
 static void do_rxpacket(struct net_device *dev)
 {
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = netdev_priv(dev);
 	struct sk_buff *skb;
 	unsigned char *cp;
 	unsigned pktlen;
@@ -705,7 +705,7 @@ static void do_rxpacket(struct net_devic
         
 static int receive(struct net_device *dev, int cnt)
 {
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = netdev_priv(dev);
 	struct parport *pp = bc->pdev->port;
         unsigned int bitbuf, notbitstream, bitstream, numbits, state;
 	unsigned char tmp[128];
@@ -790,7 +790,7 @@ static void epp_bh(struct net_device *de
 	int cnt, cnt2;
 	
 	baycom_paranoia_check_void(dev, "epp_bh");
-	bc = (struct baycom_state *)dev->priv;
+	bc = netdev_priv(dev);
 	if (!bc->work_running)
 		return;
 	baycom_int_freq(bc);
@@ -908,7 +908,7 @@ static int baycom_send_packet(struct sk_
 	struct baycom_state *bc;
 
 	baycom_paranoia_check(dev, "baycom_send_packet", 0);
-	bc = (struct baycom_state *)dev->priv;
+	bc = netdev_priv(dev);
 	if (skb->data[0] != 0) {
 		do_kiss_params(bc, skb->data, skb->len);
 		dev_kfree_skb(skb);
@@ -944,7 +944,7 @@ static struct net_device_stats *baycom_g
 	struct baycom_state *bc;
 
 	baycom_paranoia_check(dev, "baycom_get_stats", NULL);
-	bc = (struct baycom_state *)dev->priv;
+	bc = netdev_priv(dev);
 	/* 
 	 * Get the current statistics.  This may be called with the
 	 * card open or closed. 
@@ -960,7 +960,7 @@ static void epp_wakeup(void *handle)
         struct baycom_state *bc;
 
 	baycom_paranoia_check_void(dev, "epp_wakeup");
-        bc = (struct baycom_state *)dev->priv;
+        bc = netdev_priv(dev);
         printk(KERN_DEBUG "baycom_epp: %s: why am I being woken up?\n", dev->name);
         if (!parport_claim(bc->pdev))
                 printk(KERN_DEBUG "baycom_epp: %s: I'm broken.\n", dev->name);
@@ -987,7 +987,7 @@ static int epp_open(struct net_device *d
 	unsigned long tstart;
 	
 	baycom_paranoia_check(dev, "epp_open", -ENXIO);
-	bc = (struct baycom_state *)dev->priv;
+	bc = netdev_priv(dev);
         pp = parport_find_base(dev->base_addr);
         if (!pp) {
                 printk(KERN_ERR "%s: parport at 0x%lx unknown\n", bc_drvname, dev->base_addr);
@@ -1102,7 +1102,7 @@ static int epp_close(struct net_device *
 	unsigned char tmp[1];
 
 	baycom_paranoia_check(dev, "epp_close", -EINVAL);
-	bc = (struct baycom_state *)dev->priv;
+	bc = netdev_priv(dev);
 	pp = bc->pdev->port;
 	bc->work_running = 0;
 	flush_scheduled_work();
@@ -1163,7 +1163,7 @@ static int baycom_ioctl(struct net_devic
 	struct hdlcdrv_ioctl hi;
 
 	baycom_paranoia_check(dev, "baycom_ioctl", -EINVAL);
-	bc = (struct baycom_state *)dev->priv;
+	bc = netdev_priv(dev);
 	if (cmd != SIOCDEVPRIVATE)
 		return -ENOIOCTLCMD;
 	if (get_user(cmd, (int *)ifr->ifr_data))
@@ -1290,7 +1290,7 @@ static void baycom_probe(struct net_devi
 	/*
 	 * not a real probe! only initialize data structures
 	 */
-	bc = (struct baycom_state *)dev->priv;
+	bc = netdev_priv(dev);
 	/*
 	 * initialize the baycom_state struct
 	 */
@@ -1351,7 +1351,7 @@ MODULE_LICENSE("GPL");
 
 static void __init baycom_epp_dev_setup(struct net_device *dev)
 {
-	struct baycom_state *bc = dev->priv;
+	struct baycom_state *bc = netdev_priv(dev);
 
 	/*
 	 * initialize part of the baycom_state struct
@@ -1415,7 +1415,7 @@ static void __exit cleanup_baycomepp(voi
 		struct net_device *dev = baycom_device[i];
 
 		if (dev) {
-			struct baycom_state *bc = dev->priv;
+			struct baycom_state *bc = netdev_priv(dev);
 			if (bc->magic == BAYCOM_MAGIC) {
 				unregister_netdev(dev);
 				free_netdev(dev);
diff -puN drivers/net/hamradio/baycom_par.c~net_hamradio_casts drivers/net/hamradio/baycom_par.c
--- linux-264-302-priv/drivers/net/hamradio/baycom_par.c~net_hamradio_casts	2004-03-02 15:41:21.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/hamradio/baycom_par.c	2004-03-02 15:46:19.000000000 -0800
@@ -272,7 +272,7 @@ static __inline__ void par96_rx(struct n
 static void par96_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = netdev_priv(dev);
 
 	if (!dev || !bc || bc->hdrv.magic != HDLCDRV_MAGIC)
 		return;
@@ -302,7 +302,7 @@ static void par96_interrupt(int irq, voi
 static void par96_wakeup(void *handle)
 {
         struct net_device *dev = (struct net_device *)handle;
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = netdev_priv(dev);
 
 	printk(KERN_DEBUG "baycom_par: %s: why am I being woken up?\n", dev->name);
 	if (!parport_claim(bc->pdev))
@@ -313,7 +313,7 @@ static void par96_wakeup(void *handle)
 
 static int par96_open(struct net_device *dev)
 {
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = netdev_priv(dev);
 	struct parport *pp;
 
 	if (!dev || !bc)
@@ -362,7 +362,7 @@ static int par96_open(struct net_device 
 
 static int par96_close(struct net_device *dev)
 {
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = netdev_priv(dev);
 	struct parport *pp;
 
 	if (!dev || !bc)
@@ -424,7 +424,7 @@ static int baycom_ioctl(struct net_devic
 		printk(KERN_ERR "bc_ioctl: invalid device struct\n");
 		return -EINVAL;
 	}
-	bc = (struct baycom_state *)dev->priv;
+	bc = netdev_priv(dev);
 
 	if (cmd != SIOCDEVPRIVATE)
 		return -ENOIOCTLCMD;
@@ -524,7 +524,7 @@ static int __init init_baycompar(void)
 		if (IS_ERR(dev)) 
 			break;
 
-		bc = (struct baycom_state *)dev->priv;
+		bc = netdev_priv(dev);
 		if (set_hw && baycom_setmode(bc, mode[i]))
 			set_hw = 0;
 		found++;
diff -puN drivers/net/hamradio/baycom_ser_fdx.c~net_hamradio_casts drivers/net/hamradio/baycom_ser_fdx.c
--- linux-264-302-priv/drivers/net/hamradio/baycom_ser_fdx.c~net_hamradio_casts	2004-03-02 15:41:21.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/hamradio/baycom_ser_fdx.c	2004-03-02 15:44:37.000000000 -0800
@@ -281,7 +281,7 @@ static __inline__ void ser12_rx(struct n
 static irqreturn_t ser12_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = netdev_priv(dev);
 	struct timeval tv;
 	unsigned char iir, msr;
 	unsigned int txcount = 0;
@@ -407,7 +407,7 @@ static enum uart ser12_check_uart(unsign
 
 static int ser12_open(struct net_device *dev)
 {
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = netdev_priv(dev);
 	enum uart u;
 
 	if (!dev || !bc)
@@ -466,7 +466,7 @@ static int ser12_open(struct net_device 
 
 static int ser12_close(struct net_device *dev)
 {
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = netdev_priv(dev);
 
 	if (!dev || !bc)
 		return -EINVAL;
@@ -536,7 +536,7 @@ static int baycom_ioctl(struct net_devic
 		printk(KERN_ERR "bc_ioctl: invalid device struct\n");
 		return -EINVAL;
 	}
-	bc = (struct baycom_state *)dev->priv;
+	bc = netdev_priv(dev);
 
 	if (cmd != SIOCDEVPRIVATE)
 		return -ENOIOCTLCMD;
@@ -644,7 +644,7 @@ static int __init init_baycomserfdx(void
 		if (IS_ERR(dev)) 
 			break;
 
-		bc = (struct baycom_state *)dev->priv;
+		bc = netdev_priv(dev);
 		if (set_hw && baycom_setmode(bc, mode[i]))
 			set_hw = 0;
 		bc->baud = baud[i];
diff -puN drivers/net/hamradio/baycom_ser_hdx.c~net_hamradio_casts drivers/net/hamradio/baycom_ser_hdx.c
--- linux-264-302-priv/drivers/net/hamradio/baycom_ser_hdx.c~net_hamradio_casts	2004-03-02 15:41:21.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/hamradio/baycom_ser_hdx.c	2004-03-02 15:49:54.000000000 -0800
@@ -375,7 +375,7 @@ static inline void ser12_rx(struct net_d
 static irqreturn_t ser12_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = netdev_priv(dev);
 	unsigned char iir;
 
 	if (!dev || !bc || bc->hdrv.magic != HDLCDRV_MAGIC)
@@ -468,7 +468,7 @@ static enum uart ser12_check_uart(unsign
 
 static int ser12_open(struct net_device *dev)
 {
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = netdev_priv(dev);
 	enum uart u;
 
 	if (!dev || !bc)
@@ -511,7 +511,7 @@ static int ser12_open(struct net_device 
 
 static int ser12_close(struct net_device *dev)
 {
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = netdev_priv(dev);
 
 	if (!dev || !bc)
 		return -EINVAL;
@@ -576,7 +576,7 @@ static int baycom_ioctl(struct net_devic
 		printk(KERN_ERR "bc_ioctl: invalid device struct\n");
 		return -EINVAL;
 	}
-	bc = (struct baycom_state *)dev->priv;
+	bc = netdev_priv(dev);
 
 	if (cmd != SIOCDEVPRIVATE)
 		return -ENOIOCTLCMD;
@@ -681,7 +681,7 @@ static int __init init_baycomserhdx(void
 		if (IS_ERR(dev)) 
 			break;
 
-		bc = (struct baycom_state *)dev->priv;
+		bc = netdev_priv(dev);
 		if (set_hw && baycom_setmode(bc, mode[i]))
 			set_hw = 0;
 		found++;

_


--
~Randy
