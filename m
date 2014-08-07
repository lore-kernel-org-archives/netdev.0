From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] drivers/net: ethernet: Remove typedef for struct and enum
Date: Fri, 8 Aug 2014 02:09:16 +0530
Message-ID: <20140807203915.GA21337@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>
To: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Wilfried Klaebe <w-lkml@lebenslange-mailadresse.de>,
	Felipe Balbi <balbi@ti.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Linux kernel coding style guidelines suggest not using typedefs
for structure and enum types. This patch gets rid of the typedef for
cardtype_t and local_info_t. Also, the names of the struct and enum
are changed to drop the _t, to make the name look less typedef-like.

The following Coccinelle semantic patch detects the case for struct type:

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
 drivers/net/ethernet/fujitsu/fmvj18x_cs.c | 34 +++++++++++++++----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/fujitsu/fmvj18x_cs.c b/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
index cfe7a74..a7139f5 100644
--- a/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
+++ b/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
@@ -99,23 +99,23 @@ static const struct ethtool_ops netdev_ethtool_ops;
 /*
     card type
  */
-typedef enum { MBH10302, MBH10304, TDK, CONTEC, LA501, UNGERMANN, 
+enum cardtype { MBH10302, MBH10304, TDK, CONTEC, LA501, UNGERMANN,
 	       XXX10304, NEC, KME
-} cardtype_t;
+};
 
 /*
     driver specific data structure
 */
-typedef struct local_info_t {
+struct local_info {
 	struct pcmcia_device	*p_dev;
     long open_time;
     uint tx_started:1;
     uint tx_queue;
     u_short tx_queue_len;
-    cardtype_t cardtype;
+    enum cardtype cardtype;
     u_short sent;
     u_char __iomem *base;
-} local_info_t;
+};
 
 #define MC_FILTERBREAK 64
 
@@ -232,13 +232,13 @@ static const struct net_device_ops fjn_netdev_ops = {
 
 static int fmvj18x_probe(struct pcmcia_device *link)
 {
-    local_info_t *lp;
+    struct local_info *lp;
     struct net_device *dev;
 
     dev_dbg(&link->dev, "fmvj18x_attach()\n");
 
     /* Make up a FMVJ18x specific data structure */
-    dev = alloc_etherdev(sizeof(local_info_t));
+    dev = alloc_etherdev(sizeof(struct local_info));
     if (!dev)
 	return -ENOMEM;
     lp = netdev_priv(dev);
@@ -327,10 +327,10 @@ static int fmvj18x_ioprobe(struct pcmcia_device *p_dev, void *priv_data)
 static int fmvj18x_config(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
-    local_info_t *lp = netdev_priv(dev);
+    struct local_info *lp = netdev_priv(dev);
     int i, ret;
     unsigned int ioaddr;
-    cardtype_t cardtype;
+    enum cardtype cardtype;
     char *card_name = "unknown";
     u8 *buf;
     size_t len;
@@ -584,7 +584,7 @@ static int fmvj18x_setup_mfc(struct pcmcia_device *link)
     int i;
     struct net_device *dev = link->priv;
     unsigned int ioaddr;
-    local_info_t *lp = netdev_priv(dev);
+    struct local_info *lp = netdev_priv(dev);
 
     /* Allocate a small memory window */
     link->resource[3]->flags = WIN_DATA_WIDTH_8|WIN_MEMORY_TYPE_AM|WIN_ENABLE;
@@ -626,7 +626,7 @@ static void fmvj18x_release(struct pcmcia_device *link)
 {
 
     struct net_device *dev = link->priv;
-    local_info_t *lp = netdev_priv(dev);
+    struct local_info *lp = netdev_priv(dev);
     u_char __iomem *tmp;
 
     dev_dbg(&link->dev, "fmvj18x_release\n");
@@ -711,7 +711,7 @@ module_pcmcia_driver(fmvj18x_cs_driver);
 static irqreturn_t fjn_interrupt(int dummy, void *dev_id)
 {
     struct net_device *dev = dev_id;
-    local_info_t *lp = netdev_priv(dev);
+    struct local_info *lp = netdev_priv(dev);
     unsigned int ioaddr;
     unsigned short tx_stat, rx_stat;
 
@@ -772,7 +772,7 @@ static irqreturn_t fjn_interrupt(int dummy, void *dev_id)
 
 static void fjn_tx_timeout(struct net_device *dev)
 {
-    struct local_info_t *lp = netdev_priv(dev);
+    struct local_info *lp = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
 
     netdev_notice(dev, "transmit timed out with status %04x, %s?\n",
@@ -802,7 +802,7 @@ static void fjn_tx_timeout(struct net_device *dev)
 static netdev_tx_t fjn_start_xmit(struct sk_buff *skb,
 					struct net_device *dev)
 {
-    struct local_info_t *lp = netdev_priv(dev);
+    struct local_info *lp = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
     short length = skb->len;
     
@@ -874,7 +874,7 @@ static netdev_tx_t fjn_start_xmit(struct sk_buff *skb,
 
 static void fjn_reset(struct net_device *dev)
 {
-    struct local_info_t *lp = netdev_priv(dev);
+    struct local_info *lp = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
     int i;
 
@@ -1058,7 +1058,7 @@ static int fjn_config(struct net_device *dev, struct ifmap *map){
 
 static int fjn_open(struct net_device *dev)
 {
-    struct local_info_t *lp = netdev_priv(dev);
+    struct local_info *lp = netdev_priv(dev);
     struct pcmcia_device *link = lp->p_dev;
 
     pr_debug("fjn_open('%s').\n", dev->name);
@@ -1083,7 +1083,7 @@ static int fjn_open(struct net_device *dev)
 
 static int fjn_close(struct net_device *dev)
 {
-    struct local_info_t *lp = netdev_priv(dev);
+    struct local_info *lp = netdev_priv(dev);
     struct pcmcia_device *link = lp->p_dev;
     unsigned int ioaddr = dev->base_addr;
 
-- 
1.9.1
