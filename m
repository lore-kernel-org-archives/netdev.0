From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9-rc4 2/2] slip: use netdev_priv
Date: Fri, 15 Oct 2004 13:05:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015130539.00e6776c@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Replace dev->priv with netdev_priv(dev) 

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/slip.c b/drivers/net/slip.c
--- a/drivers/net/slip.c	2004-10-15 12:35:54 -07:00
+++ b/drivers/net/slip.c	2004-10-15 12:35:54 -07:00
@@ -459,13 +459,11 @@
 
 static void sl_tx_timeout(struct net_device *dev)
 {
-	struct slip *sl = (struct slip*)(dev->priv);
+	struct slip *sl = netdev_priv(dev);
 
 	spin_lock(&sl->lock);
 
 	if (netif_queue_stopped(dev)) {
-		struct slip *sl = (struct slip*)(dev->priv);
-
 		if (!netif_running(dev))
 			goto out;
 
@@ -495,7 +493,7 @@
 static int
 sl_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct slip *sl = (struct slip*)(dev->priv);
+	struct slip *sl = netdev_priv(dev);
 
 	spin_lock(&sl->lock);
 	if (!netif_running(dev))  {
@@ -529,7 +527,7 @@
 static int
 sl_close(struct net_device *dev)
 {
-	struct slip *sl = (struct slip*)(dev->priv);
+	struct slip *sl = netdev_priv(dev);
 
 	spin_lock_bh(&sl->lock);
 	if (sl->tty) {
@@ -548,7 +546,7 @@
 
 static int sl_open(struct net_device *dev)
 {
-	struct slip *sl = (struct slip*)(dev->priv);
+	struct slip *sl = netdev_priv(dev);
 
 	if (sl->tty==NULL)
 		return -ENODEV;
@@ -562,7 +560,7 @@
 
 static int sl_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct slip *sl = (struct slip*)(dev->priv);
+	struct slip *sl = netdev_priv(dev);
 
 	if (new_mtu < 68 || new_mtu > 65534)
 		return -EINVAL;
@@ -578,7 +576,7 @@
 sl_get_stats(struct net_device *dev)
 {
 	static struct net_device_stats stats;
-	struct slip *sl = (struct slip*)(dev->priv);
+	struct slip *sl = netdev_priv(dev);
 #ifdef SL_INCLUDE_CSLIP
 	struct slcompress *comp;
 #endif
@@ -613,7 +611,7 @@
 
 static int sl_init(struct net_device *dev)
 {
-	struct slip *sl = (struct slip*)(dev->priv);
+	struct slip *sl = netdev_priv(dev);
 
 	/*
 	 *	Finish setting up the DEVICE info. 
@@ -631,7 +629,7 @@
 
 static void sl_uninit(struct net_device *dev)
 {
-	struct slip *sl = (struct slip*)(dev->priv);
+	struct slip *sl = netdev_priv(dev);
 
 	sl_free_bufs(sl);
 }
@@ -720,7 +718,7 @@
 		if ((dev = slip_devs[i]) == NULL)
 			break;
 
-		sl = dev->priv;
+		sl = netdev_priv(dev);
 		if (sl->tty || sl->leased)
 			continue;
 		if (dev->flags&IFF_UP)
@@ -747,7 +745,7 @@
 		if (dev == NULL)
 			break;
 
-		sl = dev->priv;
+		sl = netdev_priv(dev);
 		if (sl->leased) {
 			if (sl->line != line)
 				continue;
@@ -789,7 +787,7 @@
 		i = sel;
 		dev = slip_devs[i];
 		if (score > 1) {
-			sl = dev->priv;
+			sl = netdev_priv(dev);
 			sl->flags &= (1 << SLF_INUSE);
 			return sl;
 		}
@@ -800,7 +798,7 @@
 		return NULL;
 
 	if (dev) {
-		sl = dev->priv;
+		sl = netdev_priv(dev);
 		if (test_bit(SLF_INUSE, &sl->flags)) {
 			unregister_netdevice(dev);
 			dev = NULL;
@@ -818,7 +816,7 @@
 		dev->base_addr  = i;
 	}
 
-	sl = dev->priv;
+	sl = netdev_priv(dev);
 
 	/* Initialize channel control data */
 	sl->magic       = SLIP_MAGIC;
@@ -1261,7 +1259,7 @@
 
 static int sl_ioctl(struct net_device *dev,struct ifreq *rq,int cmd)
 {
-	struct slip *sl = (struct slip*)(dev->priv);
+	struct slip *sl = netdev_priv(dev);
 	unsigned long *p = (unsigned long *)&rq->ifr_ifru;
 
 	if (sl == NULL)		/* Allocation failed ?? */
@@ -1407,7 +1405,7 @@
 			dev = slip_devs[i];
 			if (!dev)
 				continue;
-			sl = dev->priv;
+			sl = netdev_priv(dev);
 			spin_lock_bh(&sl->lock);
 			if (sl->tty) {
 				busy++;
@@ -1424,7 +1422,7 @@
 			continue;
 		slip_devs[i] = NULL;
 
-		sl = dev->priv;
+		sl = netdev_priv(dev);
 		if (sl->tty) {
 			printk(KERN_ERR "%s: tty discipline still running\n",
 			       dev->name);
