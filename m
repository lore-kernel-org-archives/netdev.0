From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] drivers/net: Remove typedef axnet_dev_t
Date: Fri, 8 Aug 2014 02:11:33 +0530
Message-ID: <20140807204133.GA21448@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>
To: "David S. Miller" <davem@davemloft.net>,
	Matthew Whitehead <tedheadster@gmail.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Linux kernel coding style guidelines suggest not using typedefs
for structure types. This patch gets rid of the typedef for axnet_dev_t.
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
 drivers/net/ethernet/8390/axnet_cs.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/8390/axnet_cs.c b/drivers/net/ethernet/8390/axnet_cs.c
index 73c57a4..7769c05 100644
--- a/drivers/net/ethernet/8390/axnet_cs.c
+++ b/drivers/net/ethernet/8390/axnet_cs.c
@@ -108,7 +108,7 @@ static u32 axnet_msg_enable;
 
 /*====================================================================*/
 
-typedef struct axnet_dev_t {
+struct axnet_dev {
 	struct pcmcia_device	*p_dev;
 	caddr_t	base;
 	struct timer_list	watchdog;
@@ -118,9 +118,9 @@ typedef struct axnet_dev_t {
 	int	phy_id;
 	int	flags;
 	int	active_low;
-} axnet_dev_t;
+};
 
-static inline axnet_dev_t *PRIV(struct net_device *dev)
+static inline struct axnet_dev *PRIV(struct net_device *dev)
 {
 	void *p = (char *)netdev_priv(dev) + sizeof(struct ei_device);
 	return p;
@@ -141,13 +141,13 @@ static const struct net_device_ops axnet_netdev_ops = {
 
 static int axnet_probe(struct pcmcia_device *link)
 {
-    axnet_dev_t *info;
+    struct axnet_dev *info;
     struct net_device *dev;
     struct ei_device *ei_local;
 
     dev_dbg(&link->dev, "axnet_attach()\n");
 
-    dev = alloc_etherdev(sizeof(struct ei_device) + sizeof(axnet_dev_t));
+    dev = alloc_etherdev(sizeof(struct ei_device) + sizeof(struct axnet_dev));
     if (!dev)
 	return -ENOMEM;
 
@@ -274,7 +274,7 @@ static int axnet_configcheck(struct pcmcia_device *p_dev, void *priv_data)
 static int axnet_config(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
-    axnet_dev_t *info = PRIV(dev);
+    struct axnet_dev *info = PRIV(dev);
     int i, j, j2, ret;
 
     dev_dbg(&link->dev, "axnet_config(0x%p)\n", link);
@@ -389,7 +389,7 @@ static int axnet_suspend(struct pcmcia_device *link)
 static int axnet_resume(struct pcmcia_device *link)
 {
 	struct net_device *dev = link->priv;
-	axnet_dev_t *info = PRIV(dev);
+	struct axnet_dev *info = PRIV(dev);
 
 	if (link->open) {
 		if (info->active_low == 1)
@@ -467,7 +467,7 @@ static void mdio_write(unsigned int addr, int phy_id, int loc, int value)
 static int axnet_open(struct net_device *dev)
 {
     int ret;
-    axnet_dev_t *info = PRIV(dev);
+    struct axnet_dev *info = PRIV(dev);
     struct pcmcia_device *link = info->p_dev;
     unsigned int nic_base = dev->base_addr;
     
@@ -497,7 +497,7 @@ static int axnet_open(struct net_device *dev)
 
 static int axnet_close(struct net_device *dev)
 {
-    axnet_dev_t *info = PRIV(dev);
+    struct axnet_dev *info = PRIV(dev);
     struct pcmcia_device *link = info->p_dev;
 
     dev_dbg(&link->dev, "axnet_close('%s')\n", dev->name);
@@ -554,7 +554,7 @@ static irqreturn_t ei_irq_wrapper(int irq, void *dev_id)
 static void ei_watchdog(u_long arg)
 {
     struct net_device *dev = (struct net_device *)(arg);
-    axnet_dev_t *info = PRIV(dev);
+    struct axnet_dev *info = PRIV(dev);
     unsigned int nic_base = dev->base_addr;
     unsigned int mii_addr = nic_base + AXNET_MII_EEP;
     u_short link;
@@ -610,7 +610,7 @@ reschedule:
 
 static int axnet_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-    axnet_dev_t *info = PRIV(dev);
+    struct axnet_dev *info = PRIV(dev);
     struct mii_ioctl_data *data = if_mii(rq);
     unsigned int mii_addr = dev->base_addr + AXNET_MII_EEP;
     switch (cmd) {
@@ -1452,7 +1452,7 @@ static void ei_receive(struct net_device *dev)
 
 static void ei_rx_overrun(struct net_device *dev)
 {
-	axnet_dev_t *info = PRIV(dev);
+	struct axnet_dev *info = PRIV(dev);
 	long e8390_base = dev->base_addr;
 	unsigned char was_txing, must_resend = 0;
 	struct ei_device *ei_local = netdev_priv(dev);
@@ -1624,7 +1624,7 @@ static void set_multicast_list(struct net_device *dev)
 
 static void AX88190_init(struct net_device *dev, int startp)
 {
-	axnet_dev_t *info = PRIV(dev);
+	struct axnet_dev *info = PRIV(dev);
 	long e8390_base = dev->base_addr;
 	struct ei_device *ei_local = netdev_priv(dev);
 	int i;
-- 
1.9.1
