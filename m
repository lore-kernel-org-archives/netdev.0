From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] dm9000: Remove typedef board_info_t
Date: Fri, 8 Aug 2014 00:48:14 +0530
Message-ID: <20140807191814.GA20351@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>
To: "David S. Miller" <davem@davemloft.net>,
	Andrew Ruder <andrew.ruder@elecsyscorp.com>,
	Joe Perches <joe@perches.com>,
	Barry Song <Baohua.Song@csr.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Linux kernel coding style guidelines suggest not using typedefs
for structure types. This patch gets rid of the typedef for board_info_t.
Also, the name of the structs is changed to drop the _t, to make the
name look less typedef-like.

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
 drivers/net/ethernet/davicom/dm9000.c | 92 +++++++++++++++++------------------
 1 file changed, 46 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 23084fb..9b33057 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -93,7 +93,7 @@ enum dm9000_type {
 };
 
 /* Structure/enum declaration ------------------------------- */
-typedef struct board_info {
+struct board_info {
 
 	void __iomem	*io_addr;	/* Register I/O base address */
 	void __iomem	*io_data;	/* Data I/O address */
@@ -141,7 +141,7 @@ typedef struct board_info {
 	u32		wake_state;
 
 	int		ip_summed;
-} board_info_t;
+};
 
 /* debug code */
 
@@ -151,7 +151,7 @@ typedef struct board_info {
 	}						\
 } while (0)
 
-static inline board_info_t *to_dm9000_board(struct net_device *dev)
+static inline struct board_info *to_dm9000_board(struct net_device *dev)
 {
 	return netdev_priv(dev);
 }
@@ -162,7 +162,7 @@ static inline board_info_t *to_dm9000_board(struct net_device *dev)
  *   Read a byte from I/O port
  */
 static u8
-ior(board_info_t *db, int reg)
+ior(struct board_info *db, int reg)
 {
 	writeb(reg, db->io_addr);
 	return readb(db->io_data);
@@ -173,14 +173,14 @@ ior(board_info_t *db, int reg)
  */
 
 static void
-iow(board_info_t *db, int reg, int value)
+iow(struct board_info *db, int reg, int value)
 {
 	writeb(reg, db->io_addr);
 	writeb(value, db->io_data);
 }
 
 static void
-dm9000_reset(board_info_t *db)
+dm9000_reset(struct board_info *db)
 {
 	dev_dbg(db->dev, "resetting device\n");
 
@@ -272,7 +272,7 @@ static void dm9000_dumpblk_32bit(void __iomem *reg, int count)
  * Sleep, either by using msleep() or if we are suspending, then
  * use mdelay() to sleep.
  */
-static void dm9000_msleep(board_info_t *db, unsigned int ms)
+static void dm9000_msleep(struct board_info *db, unsigned int ms)
 {
 	if (db->in_suspend || db->in_timeout)
 		mdelay(ms);
@@ -284,7 +284,7 @@ static void dm9000_msleep(board_info_t *db, unsigned int ms)
 static int
 dm9000_phy_read(struct net_device *dev, int phy_reg_unused, int reg)
 {
-	board_info_t *db = netdev_priv(dev);
+	struct board_info *db = netdev_priv(dev);
 	unsigned long flags;
 	unsigned int reg_save;
 	int ret;
@@ -330,7 +330,7 @@ static void
 dm9000_phy_write(struct net_device *dev,
 		 int phyaddr_unused, int reg, int value)
 {
-	board_info_t *db = netdev_priv(dev);
+	struct board_info *db = netdev_priv(dev);
 	unsigned long flags;
 	unsigned long reg_save;
 
@@ -408,7 +408,7 @@ static void dm9000_set_io(struct board_info *db, int byte_width)
 	}
 }
 
-static void dm9000_schedule_poll(board_info_t *db)
+static void dm9000_schedule_poll(struct board_info *db)
 {
 	if (db->type == TYPE_DM9000E)
 		schedule_delayed_work(&db->phy_poll, HZ * 2);
@@ -416,7 +416,7 @@ static void dm9000_schedule_poll(board_info_t *db)
 
 static int dm9000_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 {
-	board_info_t *dm = to_dm9000_board(dev);
+	struct board_info *dm = to_dm9000_board(dev);
 
 	if (!netif_running(dev))
 		return -EINVAL;
@@ -425,7 +425,7 @@ static int dm9000_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 }
 
 static unsigned int
-dm9000_read_locked(board_info_t *db, int reg)
+dm9000_read_locked(struct board_info *db, int reg)
 {
 	unsigned long flags;
 	unsigned int ret;
@@ -437,7 +437,7 @@ dm9000_read_locked(board_info_t *db, int reg)
 	return ret;
 }
 
-static int dm9000_wait_eeprom(board_info_t *db)
+static int dm9000_wait_eeprom(struct board_info *db)
 {
 	unsigned int status;
 	int timeout = 8;	/* wait max 8msec */
@@ -474,7 +474,7 @@ static int dm9000_wait_eeprom(board_info_t *db)
  *  Read a word data from EEPROM
  */
 static void
-dm9000_read_eeprom(board_info_t *db, int offset, u8 *to)
+dm9000_read_eeprom(struct board_info *db, int offset, u8 *to)
 {
 	unsigned long flags;
 
@@ -514,7 +514,7 @@ dm9000_read_eeprom(board_info_t *db, int offset, u8 *to)
  * Write a word data to SROM
  */
 static void
-dm9000_write_eeprom(board_info_t *db, int offset, u8 *data)
+dm9000_write_eeprom(struct board_info *db, int offset, u8 *data)
 {
 	unsigned long flags;
 
@@ -546,7 +546,7 @@ dm9000_write_eeprom(board_info_t *db, int offset, u8 *data)
 static void dm9000_get_drvinfo(struct net_device *dev,
 			       struct ethtool_drvinfo *info)
 {
-	board_info_t *dm = to_dm9000_board(dev);
+	struct board_info *dm = to_dm9000_board(dev);
 
 	strlcpy(info->driver, CARDNAME, sizeof(info->driver));
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
@@ -556,21 +556,21 @@ static void dm9000_get_drvinfo(struct net_device *dev,
 
 static u32 dm9000_get_msglevel(struct net_device *dev)
 {
-	board_info_t *dm = to_dm9000_board(dev);
+	struct board_info *dm = to_dm9000_board(dev);
 
 	return dm->msg_enable;
 }
 
 static void dm9000_set_msglevel(struct net_device *dev, u32 value)
 {
-	board_info_t *dm = to_dm9000_board(dev);
+	struct board_info *dm = to_dm9000_board(dev);
 
 	dm->msg_enable = value;
 }
 
 static int dm9000_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	board_info_t *dm = to_dm9000_board(dev);
+	struct board_info *dm = to_dm9000_board(dev);
 
 	mii_ethtool_gset(&dm->mii, cmd);
 	return 0;
@@ -578,21 +578,21 @@ static int dm9000_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static int dm9000_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	board_info_t *dm = to_dm9000_board(dev);
+	struct board_info *dm = to_dm9000_board(dev);
 
 	return mii_ethtool_sset(&dm->mii, cmd);
 }
 
 static int dm9000_nway_reset(struct net_device *dev)
 {
-	board_info_t *dm = to_dm9000_board(dev);
+	struct board_info *dm = to_dm9000_board(dev);
 	return mii_nway_restart(&dm->mii);
 }
 
 static int dm9000_set_features(struct net_device *dev,
 	netdev_features_t features)
 {
-	board_info_t *dm = to_dm9000_board(dev);
+	struct board_info *dm = to_dm9000_board(dev);
 	netdev_features_t changed = dev->features ^ features;
 	unsigned long flags;
 
@@ -608,7 +608,7 @@ static int dm9000_set_features(struct net_device *dev,
 
 static u32 dm9000_get_link(struct net_device *dev)
 {
-	board_info_t *dm = to_dm9000_board(dev);
+	struct board_info *dm = to_dm9000_board(dev);
 	u32 ret;
 
 	if (dm->flags & DM9000_PLATF_EXT_PHY)
@@ -629,7 +629,7 @@ static int dm9000_get_eeprom_len(struct net_device *dev)
 static int dm9000_get_eeprom(struct net_device *dev,
 			     struct ethtool_eeprom *ee, u8 *data)
 {
-	board_info_t *dm = to_dm9000_board(dev);
+	struct board_info *dm = to_dm9000_board(dev);
 	int offset = ee->offset;
 	int len = ee->len;
 	int i;
@@ -653,7 +653,7 @@ static int dm9000_get_eeprom(struct net_device *dev,
 static int dm9000_set_eeprom(struct net_device *dev,
 			     struct ethtool_eeprom *ee, u8 *data)
 {
-	board_info_t *dm = to_dm9000_board(dev);
+	struct board_info *dm = to_dm9000_board(dev);
 	int offset = ee->offset;
 	int len = ee->len;
 	int done;
@@ -691,7 +691,7 @@ static int dm9000_set_eeprom(struct net_device *dev,
 
 static void dm9000_get_wol(struct net_device *dev, struct ethtool_wolinfo *w)
 {
-	board_info_t *dm = to_dm9000_board(dev);
+	struct board_info *dm = to_dm9000_board(dev);
 
 	memset(w, 0, sizeof(struct ethtool_wolinfo));
 
@@ -702,7 +702,7 @@ static void dm9000_get_wol(struct net_device *dev, struct ethtool_wolinfo *w)
 
 static int dm9000_set_wol(struct net_device *dev, struct ethtool_wolinfo *w)
 {
-	board_info_t *dm = to_dm9000_board(dev);
+	struct board_info *dm = to_dm9000_board(dev);
 	unsigned long flags;
 	u32 opts = w->wolopts;
 	u32 wcr = 0;
@@ -752,7 +752,7 @@ static const struct ethtool_ops dm9000_ethtool_ops = {
 	.set_eeprom		= dm9000_set_eeprom,
 };
 
-static void dm9000_show_carrier(board_info_t *db,
+static void dm9000_show_carrier(struct board_info *db,
 				unsigned carrier, unsigned nsr)
 {
 	int lpa;
@@ -775,7 +775,7 @@ static void
 dm9000_poll_work(struct work_struct *w)
 {
 	struct delayed_work *dw = to_delayed_work(w);
-	board_info_t *db = container_of(dw, board_info_t, phy_poll);
+	struct board_info *db = container_of(dw, struct board_info, phy_poll);
 	struct net_device *ndev = db->ndev;
 
 	if (db->flags & DM9000_PLATF_SIMPLE_PHY &&
@@ -843,7 +843,7 @@ static unsigned char dm9000_type_to_char(enum dm9000_type type)
 static void
 dm9000_hash_table_unlocked(struct net_device *dev)
 {
-	board_info_t *db = netdev_priv(dev);
+	struct board_info *db = netdev_priv(dev);
 	struct netdev_hw_addr *ha;
 	int i, oft;
 	u32 hash_val;
@@ -879,7 +879,7 @@ dm9000_hash_table_unlocked(struct net_device *dev)
 static void
 dm9000_hash_table(struct net_device *dev)
 {
-	board_info_t *db = netdev_priv(dev);
+	struct board_info *db = netdev_priv(dev);
 	unsigned long flags;
 
 	spin_lock_irqsave(&db->lock, flags);
@@ -888,13 +888,13 @@ dm9000_hash_table(struct net_device *dev)
 }
 
 static void
-dm9000_mask_interrupts(board_info_t *db)
+dm9000_mask_interrupts(struct board_info *db)
 {
 	iow(db, DM9000_IMR, IMR_PAR);
 }
 
 static void
-dm9000_unmask_interrupts(board_info_t *db)
+dm9000_unmask_interrupts(struct board_info *db)
 {
 	iow(db, DM9000_IMR, db->imr_all);
 }
@@ -905,7 +905,7 @@ dm9000_unmask_interrupts(board_info_t *db)
 static void
 dm9000_init_dm9000(struct net_device *dev)
 {
-	board_info_t *db = netdev_priv(dev);
+	struct board_info *db = netdev_priv(dev);
 	unsigned int imr;
 	unsigned int ncr;
 
@@ -970,7 +970,7 @@ dm9000_init_dm9000(struct net_device *dev)
 /* Our watchdog timed out. Called by the networking layer */
 static void dm9000_timeout(struct net_device *dev)
 {
-	board_info_t *db = netdev_priv(dev);
+	struct board_info *db = netdev_priv(dev);
 	u8 reg_save;
 	unsigned long flags;
 
@@ -996,7 +996,7 @@ static void dm9000_send_packet(struct net_device *dev,
 			       int ip_summed,
 			       u16 pkt_len)
 {
-	board_info_t *dm = to_dm9000_board(dev);
+	struct board_info *dm = to_dm9000_board(dev);
 
 	/* The DM9000 is not smart enough to leave fragmented packets alone. */
 	if (dm->ip_summed != ip_summed) {
@@ -1023,7 +1023,7 @@ static int
 dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long flags;
-	board_info_t *db = netdev_priv(dev);
+	struct board_info *db = netdev_priv(dev);
 
 	dm9000_dbg(db, 3, "%s:\n", __func__);
 
@@ -1062,7 +1062,7 @@ dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
  * receive the packet to upper layer, free the transmitted packet
  */
 
-static void dm9000_tx_done(struct net_device *dev, board_info_t *db)
+static void dm9000_tx_done(struct net_device *dev, struct board_info *db)
 {
 	int tx_status = ior(db, DM9000_NSR);	/* Got TX status */
 
@@ -1094,7 +1094,7 @@ struct dm9000_rxhdr {
 static void
 dm9000_rx(struct net_device *dev)
 {
-	board_info_t *db = netdev_priv(dev);
+	struct board_info *db = netdev_priv(dev);
 	struct dm9000_rxhdr rxhdr;
 	struct sk_buff *skb;
 	u8 rxbyte, *rdptr;
@@ -1196,7 +1196,7 @@ dm9000_rx(struct net_device *dev)
 static irqreturn_t dm9000_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
-	board_info_t *db = netdev_priv(dev);
+	struct board_info *db = netdev_priv(dev);
 	int int_status;
 	unsigned long flags;
 	u8 reg_save;
@@ -1246,7 +1246,7 @@ static irqreturn_t dm9000_interrupt(int irq, void *dev_id)
 static irqreturn_t dm9000_wol_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
-	board_info_t *db = netdev_priv(dev);
+	struct board_info *db = netdev_priv(dev);
 	unsigned long flags;
 	unsigned nsr, wcr;
 
@@ -1296,7 +1296,7 @@ static void dm9000_poll_controller(struct net_device *dev)
 static int
 dm9000_open(struct net_device *dev)
 {
-	board_info_t *db = netdev_priv(dev);
+	struct board_info *db = netdev_priv(dev);
 	unsigned long irqflags = db->irq_res->flags & IRQF_TRIGGER_MASK;
 
 	if (netif_msg_ifup(db))
@@ -1342,7 +1342,7 @@ dm9000_open(struct net_device *dev)
 static void
 dm9000_shutdown(struct net_device *dev)
 {
-	board_info_t *db = netdev_priv(dev);
+	struct board_info *db = netdev_priv(dev);
 
 	/* RESET device */
 	dm9000_phy_write(dev, 0, MII_BMCR, BMCR_RESET);	/* PHY RESET */
@@ -1358,7 +1358,7 @@ dm9000_shutdown(struct net_device *dev)
 static int
 dm9000_stop(struct net_device *ndev)
 {
-	board_info_t *db = netdev_priv(ndev);
+	struct board_info *db = netdev_priv(ndev);
 
 	if (netif_msg_ifdown(db))
 		dev_dbg(db->dev, "shutting down %s\n", ndev->name);
@@ -1681,7 +1681,7 @@ dm9000_drv_suspend(struct device *dev)
 {
 	struct platform_device *pdev = to_platform_device(dev);
 	struct net_device *ndev = platform_get_drvdata(pdev);
-	board_info_t *db;
+	struct board_info *db;
 
 	if (ndev) {
 		db = netdev_priv(ndev);
@@ -1704,7 +1704,7 @@ dm9000_drv_resume(struct device *dev)
 {
 	struct platform_device *pdev = to_platform_device(dev);
 	struct net_device *ndev = platform_get_drvdata(pdev);
-	board_info_t *db = netdev_priv(ndev);
+	struct board_info *db = netdev_priv(ndev);
 
 	if (ndev) {
 		if (netif_running(ndev)) {
-- 
1.9.1
