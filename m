From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] drivers/net: Remove typedefs pcnet_dev_t and hw_info_t
Date: Fri, 8 Aug 2014 02:10:39 +0530
Message-ID: <20140807204039.GA21415@himangi-Dell>
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
for structure types. This patch gets rid of the typedefs for pcnet_dev_t
and hw_info_t. Also, the name of the structs is changed to drop the _t,
to make the name look less typedef-like.

The following Coccinelle semantic patch detects the cases:

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
 drivers/net/ethernet/8390/pcnet_cs.c | 68 ++++++++++++++++++------------------
 1 file changed, 34 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/8390/pcnet_cs.c b/drivers/net/ethernet/8390/pcnet_cs.c
index ca3c2b9..9fb7b9d 100644
--- a/drivers/net/ethernet/8390/pcnet_cs.c
+++ b/drivers/net/ethernet/8390/pcnet_cs.c
@@ -111,11 +111,11 @@ static void pcnet_detach(struct pcmcia_device *p_dev);
 
 /*====================================================================*/
 
-typedef struct hw_info_t {
+struct hw_info {
     u_int	offset;
     u_char	a0, a1, a2;
     u_int	flags;
-} hw_info_t;
+};
 
 #define DELAY_OUTPUT	0x01
 #define HAS_MISC_REG	0x02
@@ -132,7 +132,7 @@ typedef struct hw_info_t {
 #define MII_PHYID_REG1		0x02
 #define MII_PHYID_REG2		0x03
 
-static hw_info_t hw_info[] = {
+static struct hw_info hw_info[] = {
     { /* Accton EN2212 */ 0x0ff0, 0x00, 0x00, 0xe8, DELAY_OUTPUT },
     { /* Allied Telesis LA-PCM */ 0x0ff0, 0x00, 0x00, 0xf4, 0 },
     { /* APEX MultiCard */ 0x03f4, 0x00, 0x20, 0xe5, 0 },
@@ -196,11 +196,11 @@ static hw_info_t hw_info[] = {
 
 #define NR_INFO		ARRAY_SIZE(hw_info)
 
-static hw_info_t default_info = { 0, 0, 0, 0, 0 };
-static hw_info_t dl10019_info = { 0, 0, 0, 0, IS_DL10019|HAS_MII };
-static hw_info_t dl10022_info = { 0, 0, 0, 0, IS_DL10022|HAS_MII };
+static struct hw_info default_info = { 0, 0, 0, 0, 0 };
+static struct hw_info dl10019_info = { 0, 0, 0, 0, IS_DL10019|HAS_MII };
+static struct hw_info dl10022_info = { 0, 0, 0, 0, IS_DL10022|HAS_MII };
 
-typedef struct pcnet_dev_t {
+struct pcnet_dev {
 	struct pcmcia_device	*p_dev;
     u_int		flags;
     void		__iomem *base;
@@ -210,12 +210,12 @@ typedef struct pcnet_dev_t {
     u_char		eth_phy, pna_phy;
     u_short		link_status;
     u_long		mii_reset;
-} pcnet_dev_t;
+};
 
-static inline pcnet_dev_t *PRIV(struct net_device *dev)
+static inline struct pcnet_dev *PRIV(struct net_device *dev)
 {
 	char *p = netdev_priv(dev);
-	return (pcnet_dev_t *)(p + sizeof(struct ei_device));
+	return (struct pcnet_dev *)(p + sizeof(struct ei_device));
 }
 
 static const struct net_device_ops pcnet_netdev_ops = {
@@ -237,13 +237,13 @@ static const struct net_device_ops pcnet_netdev_ops = {
 
 static int pcnet_probe(struct pcmcia_device *link)
 {
-    pcnet_dev_t *info;
+    struct pcnet_dev *info;
     struct net_device *dev;
 
     dev_dbg(&link->dev, "pcnet_attach()\n");
 
     /* Create new ethernet device */
-    dev = __alloc_ei_netdev(sizeof(pcnet_dev_t));
+    dev = __alloc_ei_netdev(sizeof(struct pcnet_dev));
     if (!dev) return -ENOMEM;
     info = PRIV(dev);
     info->p_dev = link;
@@ -276,7 +276,7 @@ static void pcnet_detach(struct pcmcia_device *link)
 
 ======================================================================*/
 
-static hw_info_t *get_hwinfo(struct pcmcia_device *link)
+static struct hw_info *get_hwinfo(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
     u_char __iomem *base, *virt;
@@ -317,7 +317,7 @@ static hw_info_t *get_hwinfo(struct pcmcia_device *link)
 
 ======================================================================*/
 
-static hw_info_t *get_prom(struct pcmcia_device *link)
+static struct hw_info *get_prom(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
     unsigned int ioaddr = dev->base_addr;
@@ -371,7 +371,7 @@ static hw_info_t *get_prom(struct pcmcia_device *link)
 
 ======================================================================*/
 
-static hw_info_t *get_dl10019(struct pcmcia_device *link)
+static struct hw_info *get_dl10019(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
     int i;
@@ -393,7 +393,7 @@ static hw_info_t *get_dl10019(struct pcmcia_device *link)
 
 ======================================================================*/
 
-static hw_info_t *get_ax88190(struct pcmcia_device *link)
+static struct hw_info *get_ax88190(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
     unsigned int ioaddr = dev->base_addr;
@@ -424,7 +424,7 @@ static hw_info_t *get_ax88190(struct pcmcia_device *link)
 
 ======================================================================*/
 
-static hw_info_t *get_hwired(struct pcmcia_device *link)
+static struct hw_info *get_hwired(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
     int i;
@@ -489,12 +489,12 @@ static int pcnet_confcheck(struct pcmcia_device *p_dev, void *priv_data)
 	return try_io_port(p_dev);
 }
 
-static hw_info_t *pcnet_try_config(struct pcmcia_device *link,
-				   int *has_shmem, int try)
+static struct hw_info *pcnet_try_config(struct pcmcia_device *link,
+					int *has_shmem, int try)
 {
 	struct net_device *dev = link->priv;
-	hw_info_t *local_hw_info;
-	pcnet_dev_t *info = PRIV(dev);
+	struct hw_info *local_hw_info;
+	struct pcnet_dev *info = PRIV(dev);
 	int priv = try;
 	int ret;
 
@@ -553,10 +553,10 @@ static hw_info_t *pcnet_try_config(struct pcmcia_device *link,
 static int pcnet_config(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
-    pcnet_dev_t *info = PRIV(dev);
+    struct pcnet_dev *info = PRIV(dev);
     int start_pg, stop_pg, cm_offset;
     int has_shmem = 0;
-    hw_info_t *local_hw_info;
+    struct hw_info *local_hw_info;
     struct ei_device *ei_local;
 
     dev_dbg(&link->dev, "pcnet_config\n");
@@ -639,7 +639,7 @@ failed:
 
 static void pcnet_release(struct pcmcia_device *link)
 {
-	pcnet_dev_t *info = PRIV(link->priv);
+	struct pcnet_dev *info = PRIV(link->priv);
 
 	dev_dbg(&link->dev, "pcnet_release\n");
 
@@ -836,7 +836,7 @@ static void write_asic(unsigned int ioaddr, int location, short asic_data)
 static void set_misc_reg(struct net_device *dev)
 {
     unsigned int nic_base = dev->base_addr;
-    pcnet_dev_t *info = PRIV(dev);
+    struct pcnet_dev *info = PRIV(dev);
     u_char tmp;
 
     if (info->flags & HAS_MISC_REG) {
@@ -873,7 +873,7 @@ static void set_misc_reg(struct net_device *dev)
 
 static void mii_phy_probe(struct net_device *dev)
 {
-    pcnet_dev_t *info = PRIV(dev);
+    struct pcnet_dev *info = PRIV(dev);
     unsigned int mii_addr = dev->base_addr + DLINK_GPIO;
     int i;
     u_int tmp, phyid;
@@ -898,7 +898,7 @@ static void mii_phy_probe(struct net_device *dev)
 static int pcnet_open(struct net_device *dev)
 {
     int ret;
-    pcnet_dev_t *info = PRIV(dev);
+    struct pcnet_dev *info = PRIV(dev);
     struct pcmcia_device *link = info->p_dev;
     unsigned int nic_base = dev->base_addr;
 
@@ -931,7 +931,7 @@ static int pcnet_open(struct net_device *dev)
 
 static int pcnet_close(struct net_device *dev)
 {
-    pcnet_dev_t *info = PRIV(dev);
+    struct pcnet_dev *info = PRIV(dev);
     struct pcmcia_device *link = info->p_dev;
 
     dev_dbg(&link->dev, "pcnet_close('%s')\n", dev->name);
@@ -982,7 +982,7 @@ static void pcnet_reset_8390(struct net_device *dev)
 
 static int set_config(struct net_device *dev, struct ifmap *map)
 {
-    pcnet_dev_t *info = PRIV(dev);
+    struct pcnet_dev *info = PRIV(dev);
     if ((map->port != (u_char)(-1)) && (map->port != dev->if_port)) {
 	if (!(info->flags & HAS_MISC_REG))
 	    return -EOPNOTSUPP;
@@ -1000,7 +1000,7 @@ static int set_config(struct net_device *dev, struct ifmap *map)
 static irqreturn_t ei_irq_wrapper(int irq, void *dev_id)
 {
     struct net_device *dev = dev_id;
-    pcnet_dev_t *info;
+    struct pcnet_dev *info;
     irqreturn_t ret = ei_interrupt(irq, dev_id);
 
     if (ret == IRQ_HANDLED) {
@@ -1013,7 +1013,7 @@ static irqreturn_t ei_irq_wrapper(int irq, void *dev_id)
 static void ei_watchdog(u_long arg)
 {
     struct net_device *dev = (struct net_device *)arg;
-    pcnet_dev_t *info = PRIV(dev);
+    struct pcnet_dev *info = PRIV(dev);
     unsigned int nic_base = dev->base_addr;
     unsigned int mii_addr = nic_base + DLINK_GPIO;
     u_short link;
@@ -1101,7 +1101,7 @@ reschedule:
 
 static int ei_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-    pcnet_dev_t *info = PRIV(dev);
+    struct pcnet_dev *info = PRIV(dev);
     struct mii_ioctl_data *data = if_mii(rq);
     unsigned int mii_addr = dev->base_addr + DLINK_GPIO;
 
@@ -1214,7 +1214,7 @@ static void dma_block_output(struct net_device *dev, int count,
 			     const u_char *buf, const int start_page)
 {
     unsigned int nic_base = dev->base_addr;
-    pcnet_dev_t *info = PRIV(dev);
+    struct pcnet_dev *info = PRIV(dev);
 #ifdef PCMCIA_DEBUG
     int retries = 0;
     struct ei_device *ei_local = netdev_priv(dev);
@@ -1403,7 +1403,7 @@ static int setup_shmem_window(struct pcmcia_device *link, int start_pg,
 			      int stop_pg, int cm_offset)
 {
     struct net_device *dev = link->priv;
-    pcnet_dev_t *info = PRIV(dev);
+    struct pcnet_dev *info = PRIV(dev);
     int i, window_size, offset, ret;
 
     window_size = (stop_pg - start_pg) << 8;
-- 
1.9.1
