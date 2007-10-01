From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH 1/9] fs_enet: Whitespace cleanup.
Date: Mon, 1 Oct 2007 14:20:17 -0500
Message-ID: <20071001192017.GA28410@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:47497 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719AbXJATUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 15:20:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Scott Wood <scottwood@freescale.com>
---
This patch series applies to the net-2.6.24 branch.

 drivers/net/fs_enet/fs_enet-main.c |   85 ++++++++++++++++-------------------
 drivers/net/fs_enet/fs_enet.h      |    4 +-
 drivers/net/fs_enet/mac-fcc.c      |    1 -
 drivers/net/fs_enet/mii-bitbang.c  |    3 -
 drivers/net/fs_enet/mii-fec.c      |    1 -
 5 files changed, 41 insertions(+), 53 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index ebdcf3f..2a1b150 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -343,7 +343,6 @@ static void fs_enet_tx(struct net_device *dev)
 
 	do_wake = do_restart = 0;
 	while (((sc = CBDR_SC(bdp)) & BD_ENET_TX_READY) == 0) {
-
 		dirtyidx = bdp - fep->tx_bd_base;
 
 		if (fep->tx_free == fep->tx_ring)
@@ -444,7 +443,6 @@ fs_enet_interrupt(int irq, void *dev_id)
 
 	nr = 0;
 	while ((int_events = (*fep->ops->get_int_events)(dev)) != 0) {
-
 		nr++;
 
 		int_clr_events = int_events;
@@ -700,45 +698,43 @@ static void fs_timeout(struct net_device *dev)
  *-----------------------------------------------------------------------------*/
 static void generic_adjust_link(struct  net_device *dev)
 {
-       struct fs_enet_private *fep = netdev_priv(dev);
-       struct phy_device *phydev = fep->phydev;
-       int new_state = 0;
-
-       if (phydev->link) {
-
-               /* adjust to duplex mode */
-               if (phydev->duplex != fep->oldduplex){
-                       new_state = 1;
-                       fep->oldduplex = phydev->duplex;
-               }
-
-               if (phydev->speed != fep->oldspeed) {
-                       new_state = 1;
-                       fep->oldspeed = phydev->speed;
-               }
-
-               if (!fep->oldlink) {
-                       new_state = 1;
-                       fep->oldlink = 1;
-                       netif_schedule(dev);
-                       netif_carrier_on(dev);
-                       netif_start_queue(dev);
-               }
-
-               if (new_state)
-                       fep->ops->restart(dev);
-
-       } else if (fep->oldlink) {
-               new_state = 1;
-               fep->oldlink = 0;
-               fep->oldspeed = 0;
-               fep->oldduplex = -1;
-               netif_carrier_off(dev);
-               netif_stop_queue(dev);
-       }
-
-       if (new_state && netif_msg_link(fep))
-               phy_print_status(phydev);
+	struct fs_enet_private *fep = netdev_priv(dev);
+	struct phy_device *phydev = fep->phydev;
+	int new_state = 0;
+
+	if (phydev->link) {
+		/* adjust to duplex mode */
+		if (phydev->duplex != fep->oldduplex) {
+			new_state = 1;
+			fep->oldduplex = phydev->duplex;
+		}
+
+		if (phydev->speed != fep->oldspeed) {
+			new_state = 1;
+			fep->oldspeed = phydev->speed;
+		}
+
+		if (!fep->oldlink) {
+			new_state = 1;
+			fep->oldlink = 1;
+			netif_schedule(dev);
+			netif_carrier_on(dev);
+			netif_start_queue(dev);
+		}
+
+		if (new_state)
+			fep->ops->restart(dev);
+	} else if (fep->oldlink) {
+		new_state = 1;
+		fep->oldlink = 0;
+		fep->oldspeed = 0;
+		fep->oldduplex = -1;
+		netif_carrier_off(dev);
+		netif_stop_queue(dev);
+	}
+
+	if (new_state && netif_msg_link(fep))
+		phy_print_status(phydev);
 }
 
 
@@ -782,7 +778,6 @@ static int fs_init_phy(struct net_device *dev)
 	return 0;
 }
 
-
 static int fs_enet_open(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
@@ -971,7 +966,7 @@ static struct net_device *fs_init_instance(struct device *dev,
 #endif
 
 #ifdef CONFIG_FS_ENET_HAS_SCC
-	if (fs_get_scc_index(fpi->fs_no) >=0 )
+	if (fs_get_scc_index(fpi->fs_no) >=0)
 		fep->ops = &fs_scc_ops;
 #endif
 
@@ -1066,9 +1061,8 @@ static struct net_device *fs_init_instance(struct device *dev,
 
 	return ndev;
 
-      err:
+err:
 	if (ndev != NULL) {
-
 		if (registered)
 			unregister_netdev(ndev);
 
@@ -1259,7 +1253,6 @@ static int __init fs_init(void)
 err:
 	cleanup_immap();
 	return r;
-
 }
 
 static void __exit fs_cleanup(void)
diff --git a/drivers/net/fs_enet/fs_enet.h b/drivers/net/fs_enet/fs_enet.h
index 46d0606..fbe2087 100644
--- a/drivers/net/fs_enet/fs_enet.h
+++ b/drivers/net/fs_enet/fs_enet.h
@@ -15,8 +15,8 @@
 #include <asm/commproc.h>
 
 struct fec_info {
-        fec_t*  fecp;
-	u32     mii_speed;
+	fec_t *fecp;
+	u32 mii_speed;
 };
 #endif
 
diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
index 6407151..1e1024a 100644
--- a/drivers/net/fs_enet/mac-fcc.c
+++ b/drivers/net/fs_enet/mac-fcc.c
@@ -86,7 +86,6 @@
 static inline int fcc_cr_cmd(struct fs_enet_private *fep, u32 mcn, u32 op)
 {
 	const struct fs_platform_info *fpi = fep->fpi;
-
 	cpm2_map_t *immap = fs_enet_immap;
 	cpm_cpm2_t *cpmp = &immap->im_cpm;
 	u32 v;
diff --git a/drivers/net/fs_enet/mii-bitbang.c b/drivers/net/fs_enet/mii-bitbang.c
index 1a41ea6..422f828 100644
--- a/drivers/net/fs_enet/mii-bitbang.c
+++ b/drivers/net/fs_enet/mii-bitbang.c
@@ -12,7 +12,6 @@
  * kind, whether express or implied.
  */
 
-
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
@@ -308,7 +307,6 @@ static int fs_mii_bitbang_init(struct bb_info *bitbang, struct fs_mii_bb_platfor
 	return 0;
 }
 
-
 static int __devinit fs_enet_mdio_probe(struct device *dev)
 {
 	struct platform_device *pdev = to_platform_device(dev);
@@ -371,7 +369,6 @@ bus_register_fail:
 	return err;
 }
 
-
 static int fs_enet_mdio_remove(struct device *dev)
 {
 	struct mii_bus *bus = dev_get_drvdata(dev);
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index 0a563a8..53db696 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -113,7 +113,6 @@ static int fs_enet_fec_mii_read(struct mii_bus *bus , int phy_id, int location)
 	}
 
 	return ret;
-
 }
 
 static int fs_enet_fec_mii_write(struct mii_bus *bus, int phy_id, int location, u16 val)
-- 
1.5.3.2

