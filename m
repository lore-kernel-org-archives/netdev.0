From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] ethernet: amd: Remove typedef local_info_t
Date: Sat, 9 Aug 2014 21:30:59 +0530
Message-ID: <20140809160058.GA15164@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Linux kernel coding style guidelines suggest not using typedefs
for structure types. This patch gets rid of the typedef for local_info_t.
Also, the name of the struct is changed to drop the _t, to make the
name look less typedef-like.

The following Coccinelle semantic patch detects the case:

@tn@
identifier i;
type td;
@@

-typedef
 struct i { ... }
-td
 ;

@@
type tn.td;
identifier tn.i;
@@

-td
+ struct i

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
 drivers/net/ethernet/xircom/xirc2ps_cs.c | 40 ++++++++++++++++----------------
 1 file changed, 20 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/xircom/xirc2ps_cs.c b/drivers/net/ethernet/xircom/xirc2ps_cs.c
index 7c81ffb..d56f869 100644
--- a/drivers/net/ethernet/xircom/xirc2ps_cs.c
+++ b/drivers/net/ethernet/xircom/xirc2ps_cs.c
@@ -266,7 +266,7 @@ static void xirc2ps_detach(struct pcmcia_device *p_dev);
 
 static irqreturn_t xirc2ps_interrupt(int irq, void *dev_id);
 
-typedef struct local_info_t {
+struct local_info {
 	struct net_device	*dev;
 	struct pcmcia_device	*p_dev;
 
@@ -281,7 +281,7 @@ typedef struct local_info_t {
     unsigned last_ptr_value; /* last packets transmitted value */
     const char *manf_str;
     struct work_struct tx_timeout_task;
-} local_info_t;
+};
 
 /****************
  * Some more prototypes
@@ -475,12 +475,12 @@ static int
 xirc2ps_probe(struct pcmcia_device *link)
 {
     struct net_device *dev;
-    local_info_t *local;
+    struct local_info *local;
 
     dev_dbg(&link->dev, "attach()\n");
 
     /* Allocate the device structure */
-    dev = alloc_etherdev(sizeof(local_info_t));
+    dev = alloc_etherdev(sizeof(struct local_info));
     if (!dev)
 	    return -ENOMEM;
     local = netdev_priv(dev);
@@ -536,7 +536,7 @@ static int
 set_card_type(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
-    local_info_t *local = netdev_priv(dev);
+    struct local_info *local = netdev_priv(dev);
     u8 *buf;
     unsigned int cisrev, mediaid, prodid;
     size_t len;
@@ -690,7 +690,7 @@ static int
 xirc2ps_config(struct pcmcia_device * link)
 {
     struct net_device *dev = link->priv;
-    local_info_t *local = netdev_priv(dev);
+    struct local_info *local = netdev_priv(dev);
     unsigned int ioaddr;
     int err;
     u8 *buf;
@@ -931,7 +931,7 @@ xirc2ps_release(struct pcmcia_device *link)
 
 	if (link->resource[2]->end) {
 		struct net_device *dev = link->priv;
-		local_info_t *local = netdev_priv(dev);
+		struct local_info *local = netdev_priv(dev);
 		if (local->dingo)
 			iounmap(local->dingo_ccr - 0x0800);
 	}
@@ -975,7 +975,7 @@ static irqreturn_t
 xirc2ps_interrupt(int irq, void *dev_id)
 {
     struct net_device *dev = (struct net_device *)dev_id;
-    local_info_t *lp = netdev_priv(dev);
+    struct local_info *lp = netdev_priv(dev);
     unsigned int ioaddr;
     u_char saved_page;
     unsigned bytes_rcvd;
@@ -1194,8 +1194,8 @@ xirc2ps_interrupt(int irq, void *dev_id)
 static void
 xirc2ps_tx_timeout_task(struct work_struct *work)
 {
-	local_info_t *local =
-		container_of(work, local_info_t, tx_timeout_task);
+	struct local_info *local =
+		container_of(work, struct local_info, tx_timeout_task);
 	struct net_device *dev = local->dev;
     /* reset the card */
     do_reset(dev,1);
@@ -1206,7 +1206,7 @@ xirc2ps_tx_timeout_task(struct work_struct *work)
 static void
 xirc_tx_timeout(struct net_device *dev)
 {
-    local_info_t *lp = netdev_priv(dev);
+    struct local_info *lp = netdev_priv(dev);
     dev->stats.tx_errors++;
     netdev_notice(dev, "transmit timed out\n");
     schedule_work(&lp->tx_timeout_task);
@@ -1215,7 +1215,7 @@ xirc_tx_timeout(struct net_device *dev)
 static netdev_tx_t
 do_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-    local_info_t *lp = netdev_priv(dev);
+    struct local_info *lp = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
     int okay;
     unsigned freespace;
@@ -1300,7 +1300,7 @@ static void set_address(struct set_address_info *sa_info, char *addr)
 static void set_addresses(struct net_device *dev)
 {
 	unsigned int ioaddr = dev->base_addr;
-	local_info_t *lp = netdev_priv(dev);
+	struct local_info *lp = netdev_priv(dev);
 	struct netdev_hw_addr *ha;
 	struct set_address_info sa_info;
 	int i;
@@ -1362,7 +1362,7 @@ set_multicast_list(struct net_device *dev)
 static int
 do_config(struct net_device *dev, struct ifmap *map)
 {
-    local_info_t *local = netdev_priv(dev);
+    struct local_info *local = netdev_priv(dev);
 
     pr_debug("do_config(%p)\n", dev);
     if (map->port != 255 && map->port != dev->if_port) {
@@ -1387,7 +1387,7 @@ do_config(struct net_device *dev, struct ifmap *map)
 static int
 do_open(struct net_device *dev)
 {
-    local_info_t *lp = netdev_priv(dev);
+    struct local_info *lp = netdev_priv(dev);
     struct pcmcia_device *link = lp->p_dev;
 
     dev_dbg(&link->dev, "do_open(%p)\n", dev);
@@ -1421,7 +1421,7 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 static int
 do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-    local_info_t *local = netdev_priv(dev);
+    struct local_info *local = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
     struct mii_ioctl_data *data = if_mii(rq);
 
@@ -1453,7 +1453,7 @@ do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 static void
 hardreset(struct net_device *dev)
 {
-    local_info_t *local = netdev_priv(dev);
+    struct local_info *local = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
 
     SelectPage(4);
@@ -1470,7 +1470,7 @@ hardreset(struct net_device *dev)
 static void
 do_reset(struct net_device *dev, int full)
 {
-    local_info_t *local = netdev_priv(dev);
+    struct local_info *local = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
     unsigned value;
 
@@ -1631,7 +1631,7 @@ do_reset(struct net_device *dev, int full)
 static int
 init_mii(struct net_device *dev)
 {
-    local_info_t *local = netdev_priv(dev);
+    struct local_info *local = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
     unsigned control, status, linkpartner;
     int i;
@@ -1715,7 +1715,7 @@ static int
 do_stop(struct net_device *dev)
 {
     unsigned int ioaddr = dev->base_addr;
-    local_info_t *lp = netdev_priv(dev);
+    struct local_info *lp = netdev_priv(dev);
     struct pcmcia_device *link = lp->p_dev;
 
     dev_dbg(&link->dev, "do_stop(%p)\n", dev);
-- 
1.9.1
