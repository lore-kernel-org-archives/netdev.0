From: Amos Kong <jianjun@zeuux.org>
Subject: [PATCH] net: unify the struct's name
Date: Mon, 20 Apr 2009 22:05:34 +0800
Message-ID: <20090420140534.GB9119@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeuux.org ([210.51.160.52]:65454 "EHLO z.billxu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755400AbZDTOF4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 10:05:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


unify the struct's name of "struct rtl8139_private *np" to "struct rtl8139_private *tp"

most of them like this:
struct rtl8139_private *tp = netdev_priv(dev);

Signed-off-by: Amos Kong <jianjun@zeuux.org>
---
 drivers/net/8139too.c |   92 ++++++++++++++++++++++++------------------------
 1 files changed, 46 insertions(+), 46 deletions(-)

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 29df398..00fe130 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -2292,11 +2292,11 @@ static int rtl8139_close (struct net_device *dev)
    other threads or interrupts aren't messing with the 8139.  */
 static void rtl8139_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
-	struct rtl8139_private *np = netdev_priv(dev);
-	void __iomem *ioaddr = np->mmio_addr;
+	struct rtl8139_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
 
-	spin_lock_irq(&np->lock);
-	if (rtl_chip_info[np->chipset].flags & HasLWake) {
+	spin_lock_irq(&tp->lock);
+	if (rtl_chip_info[tp->chipset].flags & HasLWake) {
 		u8 cfg3 = RTL_R8 (Config3);
 		u8 cfg5 = RTL_R8 (Config5);
 
@@ -2317,7 +2317,7 @@ static void rtl8139_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 		if (cfg5 & Cfg5_BWF)
 			wol->wolopts |= WAKE_BCAST;
 	}
-	spin_unlock_irq(&np->lock);
+	spin_unlock_irq(&tp->lock);
 }
 
 
@@ -2326,19 +2326,19 @@ static void rtl8139_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
    aren't messing with the 8139.  */
 static int rtl8139_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
-	struct rtl8139_private *np = netdev_priv(dev);
-	void __iomem *ioaddr = np->mmio_addr;
+	struct rtl8139_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
 	u32 support;
 	u8 cfg3, cfg5;
 
-	support = ((rtl_chip_info[np->chipset].flags & HasLWake)
+	support = ((rtl_chip_info[tp->chipset].flags & HasLWake)
 		   ? (WAKE_PHY | WAKE_MAGIC
 		      | WAKE_UCAST | WAKE_MCAST | WAKE_BCAST)
 		   : 0);
 	if (wol->wolopts & ~support)
 		return -EINVAL;
 
-	spin_lock_irq(&np->lock);
+	spin_lock_irq(&tp->lock);
 	cfg3 = RTL_R8 (Config3) & ~(Cfg3_LinkUp | Cfg3_Magic);
 	if (wol->wolopts & WAKE_PHY)
 		cfg3 |= Cfg3_LinkUp;
@@ -2359,87 +2359,87 @@ static int rtl8139_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	if (wol->wolopts & WAKE_BCAST)
 		cfg5 |= Cfg5_BWF;
 	RTL_W8 (Config5, cfg5);	/* need not unlock via Cfg9346 */
-	spin_unlock_irq(&np->lock);
+	spin_unlock_irq(&tp->lock);
 
 	return 0;
 }
 
 static void rtl8139_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct rtl8139_private *np = netdev_priv(dev);
+	struct rtl8139_private *tp = netdev_priv(dev);
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
-	strcpy(info->bus_info, pci_name(np->pci_dev));
-	info->regdump_len = np->regs_len;
+	strcpy(info->bus_info, pci_name(tp->pci_dev));
+	info->regdump_len = tp->regs_len;
 }
 
 static int rtl8139_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct rtl8139_private *np = netdev_priv(dev);
-	spin_lock_irq(&np->lock);
-	mii_ethtool_gset(&np->mii, cmd);
-	spin_unlock_irq(&np->lock);
+	struct rtl8139_private *tp = netdev_priv(dev);
+	spin_lock_irq(&tp->lock);
+	mii_ethtool_gset(&tp->mii, cmd);
+	spin_unlock_irq(&tp->lock);
 	return 0;
 }
 
 static int rtl8139_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct rtl8139_private *np = netdev_priv(dev);
+	struct rtl8139_private *tp = netdev_priv(dev);
 	int rc;
-	spin_lock_irq(&np->lock);
-	rc = mii_ethtool_sset(&np->mii, cmd);
-	spin_unlock_irq(&np->lock);
+	spin_lock_irq(&tp->lock);
+	rc = mii_ethtool_sset(&tp->mii, cmd);
+	spin_unlock_irq(&tp->lock);
 	return rc;
 }
 
 static int rtl8139_nway_reset(struct net_device *dev)
 {
-	struct rtl8139_private *np = netdev_priv(dev);
-	return mii_nway_restart(&np->mii);
+	struct rtl8139_private *tp = netdev_priv(dev);
+	return mii_nway_restart(&tp->mii);
 }
 
 static u32 rtl8139_get_link(struct net_device *dev)
 {
-	struct rtl8139_private *np = netdev_priv(dev);
-	return mii_link_ok(&np->mii);
+	struct rtl8139_private *tp = netdev_priv(dev);
+	return mii_link_ok(&tp->mii);
 }
 
 static u32 rtl8139_get_msglevel(struct net_device *dev)
 {
-	struct rtl8139_private *np = netdev_priv(dev);
-	return np->msg_enable;
+	struct rtl8139_private *tp = netdev_priv(dev);
+	return tp->msg_enable;
 }
 
 static void rtl8139_set_msglevel(struct net_device *dev, u32 datum)
 {
-	struct rtl8139_private *np = netdev_priv(dev);
-	np->msg_enable = datum;
+	struct rtl8139_private *tp = netdev_priv(dev);
+	tp->msg_enable = datum;
 }
 
 static int rtl8139_get_regs_len(struct net_device *dev)
 {
-	struct rtl8139_private *np;
+	struct rtl8139_private *tp;
 	/* TODO: we are too slack to do reg dumping for pio, for now */
 	if (use_io)
 		return 0;
-	np = netdev_priv(dev);
-	return np->regs_len;
+	tp = netdev_priv(dev);
+	return tp->regs_len;
 }
 
 static void rtl8139_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *regbuf)
 {
-	struct rtl8139_private *np;
+	struct rtl8139_private *tp;
 
 	/* TODO: we are too slack to do reg dumping for pio, for now */
 	if (use_io)
 		return;
-	np = netdev_priv(dev);
+	tp = netdev_priv(dev);
 
 	regs->version = RTL_REGS_VER;
 
-	spin_lock_irq(&np->lock);
-	memcpy_fromio(regbuf, np->mmio_addr, regs->len);
-	spin_unlock_irq(&np->lock);
+	spin_lock_irq(&tp->lock);
+	memcpy_fromio(regbuf, tp->mmio_addr, regs->len);
+	spin_unlock_irq(&tp->lock);
 }
 
 static int rtl8139_get_sset_count(struct net_device *dev, int sset)
@@ -2454,12 +2454,12 @@ static int rtl8139_get_sset_count(struct net_device *dev, int sset)
 
 static void rtl8139_get_ethtool_stats(struct net_device *dev, struct ethtool_stats *stats, u64 *data)
 {
-	struct rtl8139_private *np = netdev_priv(dev);
+	struct rtl8139_private *tp = netdev_priv(dev);
 
-	data[0] = np->xstats.early_rx;
-	data[1] = np->xstats.tx_buf_mapped;
-	data[2] = np->xstats.tx_timeouts;
-	data[3] = np->xstats.rx_lost_in_ring;
+	data[0] = tp->xstats.early_rx;
+	data[1] = tp->xstats.tx_buf_mapped;
+	data[2] = tp->xstats.tx_timeouts;
+	data[3] = tp->xstats.rx_lost_in_ring;
 }
 
 static void rtl8139_get_strings(struct net_device *dev, u32 stringset, u8 *data)
@@ -2486,15 +2486,15 @@ static const struct ethtool_ops rtl8139_ethtool_ops = {
 
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct rtl8139_private *np = netdev_priv(dev);
+	struct rtl8139_private *tp = netdev_priv(dev);
 	int rc;
 
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	spin_lock_irq(&np->lock);
-	rc = generic_mii_ioctl(&np->mii, if_mii(rq), cmd, NULL);
-	spin_unlock_irq(&np->lock);
+	spin_lock_irq(&tp->lock);
+	rc = generic_mii_ioctl(&tp->mii, if_mii(rq), cmd, NULL);
+	spin_unlock_irq(&tp->lock);
 
 	return rc;
 }
-- 
1.5.6.3

--
Amos Kong(http://kongove.cn/)
