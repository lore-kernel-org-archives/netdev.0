From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9-rc4] eql: use netdev_priv
Date: Fri, 15 Oct 2004 15:35:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015153519.6616db0d@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use netdev_priv where possible.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/eql.c b/drivers/net/eql.c
--- a/drivers/net/eql.c	2004-10-15 14:26:15 -07:00
+++ b/drivers/net/eql.c	2004-10-15 14:26:15 -07:00
@@ -164,12 +164,12 @@
 
 static void __init eql_setup(struct net_device *dev)
 {
-	equalizer_t *eql = dev->priv;
+	equalizer_t *eql = netdev_priv(dev);
 
 	SET_MODULE_OWNER(dev);
 
 	init_timer(&eql->timer);
-	eql->timer.data     	= (unsigned long) dev->priv;
+	eql->timer.data     	= (unsigned long) eql;
 	eql->timer.expires  	= jiffies + EQL_DEFAULT_RESCHED_IVAL;
 	eql->timer.function 	= eql_timer;
 
@@ -197,7 +197,7 @@
 
 static int eql_open(struct net_device *dev)
 {
-	equalizer_t *eql = dev->priv;
+	equalizer_t *eql = netdev_priv(dev);
 
 	/* XXX We should force this off automatically for the user. */
 	printk(KERN_INFO "%s: remember to turn off Van-Jacobson compression on "
@@ -241,7 +241,7 @@
 
 static int eql_close(struct net_device *dev)
 {
-	equalizer_t *eql = dev->priv;
+	equalizer_t *eql = netdev_priv(dev);
 
 	/*
 	 *	The timer has to be stopped first before we start hacking away
@@ -326,7 +326,7 @@
 
 static int eql_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	equalizer_t *eql = dev->priv;
+	equalizer_t *eql = netdev_priv(dev);
 	slave_t *slave;
 
 	spin_lock(&eql->queue.lock);
@@ -352,7 +352,7 @@
 
 static struct net_device_stats * eql_get_stats(struct net_device *dev)
 {
-	equalizer_t *eql = dev->priv;
+	equalizer_t *eql = netdev_priv(dev);
 	return &eql->stats;
 }
 
@@ -378,7 +378,7 @@
 
 static inline int eql_is_full(slave_queue_t *queue)
 {
-	equalizer_t *eql = queue->master_dev->priv;
+	equalizer_t *eql = netdev_priv(queue->master_dev);
 
 	if (queue->num_slaves >= eql->max_slaves)
 		return 1;
@@ -420,7 +420,7 @@
 			if (!eql_is_master(slave_dev) &&
 			    !eql_is_slave(slave_dev)) {
 				slave_t *s = kmalloc(sizeof(*s), GFP_KERNEL);
-				equalizer_t *eql = master_dev->priv;
+				equalizer_t *eql = netdev_priv(master_dev);
 				int ret;
 
 				if (!s) {
@@ -453,7 +453,7 @@
 
 static int eql_emancipate(struct net_device *master_dev, slaving_request_t __user *srqp)
 {
-	equalizer_t *eql = master_dev->priv;
+	equalizer_t *eql = netdev_priv(master_dev);
 	struct net_device *slave_dev;
 	slaving_request_t srq;
 	int ret;
@@ -485,7 +485,7 @@
 
 static int eql_g_slave_cfg(struct net_device *dev, slave_config_t __user *scp)
 {
-	equalizer_t *eql = dev->priv;
+	equalizer_t *eql = netdev_priv(dev);
 	slave_t *slave;
 	struct net_device *slave_dev;
 	slave_config_t sc;
@@ -539,7 +539,7 @@
 	if (!slave_dev)
 		return ret;
 
-	eql = dev->priv;
+	eql = netdev_priv(dev);
 	spin_lock_bh(&eql->queue.lock);
 	if (eql_is_slave(slave_dev)) {
 		slave = __eql_find_slave_dev(&eql->queue, slave_dev);
@@ -561,7 +561,7 @@
 	master_config_t mc;
 
 	if (eql_is_master(dev)) {
-		eql = dev->priv;
+		eql = netdev_priv(dev);
 		mc.max_slaves = eql->max_slaves;
 		mc.min_slaves = eql->min_slaves;
 		if (copy_to_user(mcp, &mc, sizeof (master_config_t)))
@@ -580,7 +580,7 @@
 		return -EFAULT;
 
 	if (eql_is_master(dev)) {
-		eql = dev->priv;
+		eql = netdev_priv(dev);
 		eql->max_slaves = mc.max_slaves;
 		eql->min_slaves = mc.min_slaves;
 		return 0;
