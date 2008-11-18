From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH net-next v3]netdevice: 82596: Convert netdev->priv to netdev_priv
Date: Tue, 18 Nov 2008 11:57:25 +0800
Message-ID: <49223D25.9030006@cn.fujitsu.com>
References: <4921095D.9010109@cn.fujitsu.com>	<20081116.223637.108010315.davem@davemloft.net>	<49213856.6040802@cn.fujitsu.com> <20081117.012939.72047312.davem@davemloft.net> <492182C8.6060704@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62486 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751589AbYKRD5o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 22:57:44 -0500
In-Reply-To: <492182C8.6060704@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. When alloc_etherdev(), no memory be allocated to netdev->priv.
2. And it's need to get a whole page for priv.

For these reasons, use netdev->ml_priv to point to the page is the
best method to convert directly reference of netdev->priv.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/82596.c |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/82596.c b/drivers/net/82596.c
index 717fe2f..23fe416 100644
--- a/drivers/net/82596.c
+++ b/drivers/net/82596.c
@@ -457,7 +457,7 @@ static inline int wait_cfg(struct net_device *dev, struct i596_cmd *cmd, int del
 
 static void i596_display_data(struct net_device *dev)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = dev->ml_priv;
 	struct i596_cmd *cmd;
 	struct i596_rfd *rfd;
 	struct i596_rbd *rbd;
@@ -527,7 +527,7 @@ static irqreturn_t i596_error(int irq, void *dev_id)
 
 static inline void init_rx_bufs(struct net_device *dev)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = dev->ml_priv;
 	int i;
 	struct i596_rfd *rfd;
 	struct i596_rbd *rbd;
@@ -578,7 +578,7 @@ static inline void init_rx_bufs(struct net_device *dev)
 
 static inline void remove_rx_bufs(struct net_device *dev)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = dev->ml_priv;
 	struct i596_rbd *rbd;
 	int i;
 
@@ -592,7 +592,7 @@ static inline void remove_rx_bufs(struct net_device *dev)
 
 static void rebuild_rx_bufs(struct net_device *dev)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = dev->ml_priv;
 	int i;
 
 	/* Ensure rx frame/buffer descriptors are tidy */
@@ -611,7 +611,7 @@ static void rebuild_rx_bufs(struct net_device *dev)
 
 static int init_i596_mem(struct net_device *dev)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = dev->ml_priv;
 #if !defined(ENABLE_MVME16x_NET) && !defined(ENABLE_BVME6000_NET) || defined(ENABLE_APRICOT)
 	short ioaddr = dev->base_addr;
 #endif
@@ -764,7 +764,7 @@ failed:
 
 static inline int i596_rx(struct net_device *dev)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = dev->ml_priv;
 	struct i596_rfd *rfd;
 	struct i596_rbd *rbd;
 	int frames = 0;
@@ -958,7 +958,7 @@ static void i596_reset(struct net_device *dev, struct i596_private *lp,
 
 static void i596_add_cmd(struct net_device *dev, struct i596_cmd *cmd)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = dev->ml_priv;
 	int ioaddr = dev->base_addr;
 	unsigned long flags;
 
@@ -1028,7 +1028,7 @@ static int i596_open(struct net_device *dev)
 
 static void i596_tx_timeout (struct net_device *dev)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = dev->ml_priv;
 	int ioaddr = dev->base_addr;
 
 	/* Transmitter timeout, serious problems. */
@@ -1057,7 +1057,7 @@ static void i596_tx_timeout (struct net_device *dev)
 
 static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = dev->ml_priv;
 	struct tx_cmd *tx_cmd;
 	struct i596_tbd *tbd;
 	short length = skb->len;
@@ -1239,9 +1239,9 @@ found:
 	dev->tx_timeout = i596_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
-	dev->priv = (void *)(dev->mem_start);
+	dev->ml_priv = (void *)(dev->mem_start);
 
-	lp = dev->priv;
+	lp = dev->ml_priv;
 	DEB(DEB_INIT,printk(KERN_DEBUG "%s: lp at 0x%08lx (%zd bytes), "
 			"lp->scb at 0x%08lx\n",
 			dev->name, (unsigned long)lp,
@@ -1302,7 +1302,7 @@ static irqreturn_t i596_interrupt(int irq, void *dev_id)
 	}
 
 	ioaddr = dev->base_addr;
-	lp = dev->priv;
+	lp = dev->ml_priv;
 
 	spin_lock (&lp->lock);
 
@@ -1445,7 +1445,7 @@ static irqreturn_t i596_interrupt(int irq, void *dev_id)
 
 static int i596_close(struct net_device *dev)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = dev->ml_priv;
 	unsigned long flags;
 
 	netif_stop_queue(dev);
@@ -1495,7 +1495,7 @@ static int i596_close(struct net_device *dev)
 
 static void set_multicast_list(struct net_device *dev)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = dev->ml_priv;
 	int config = 0, cnt;
 
 	DEB(DEB_MULTI,printk(KERN_DEBUG "%s: set multicast list, %d entries, promisc %s, allmulti %s\n",
-- 
1.5.3.4

