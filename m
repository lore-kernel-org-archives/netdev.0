From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: [PATCH] net/phy: Make phy_ethtool_ksettings_get return void
Date: Sun,  4 Jun 2017 20:14:28 +0300
Message-ID: <20170604171428.4012-1-yuval.shaia@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: michael.chan@broadcom.com, f.fainelli@gmail.com,
 bcm-kernel-feedback-list@broadcom.com, siva.kallam@broadcom.com,
 prashant@broadcom.com, madalin.bucur@nxp.com, leoli@freescale.com,
 sebastian.hesselbarth@gmail.com, grygorii.strashko@ti.com,
 andrew@lunn.ch, woojung.huh@microchip.com,
 UNGLinuxDriver@microchip.com, vivien.didelot@savoirfairelinux.com,
 davem@davemloft.net, arnd@arndb.de, tremyfr@gmail.com,
 yuval.shaia@oracle.com, xypron.glpk@gmx.de, jarod@redhat.com,
 ivan.khoronzhuk@linaro.org, mugunthanvnm@ti.com, johan@kernel.org,
 netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linuxppc-dev@lists.ozlabs.org, linux-omap@vger.kernel.org,
 linux-usb@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Make return value void since function never return meaningfull value

Signed-off-by: Yuval Shaia <yuval.shaia@oracle.com>
---
 drivers/net/ethernet/broadcom/b44.c                |  3 ++-
 drivers/net/ethernet/broadcom/bcm63xx_enet.c       |  3 ++-
 drivers/net/ethernet/broadcom/genet/bcmgenet.c     |  4 +++-
 drivers/net/ethernet/broadcom/tg3.c                |  4 +++-
 drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c |  6 ++----
 drivers/net/ethernet/freescale/ucc_geth_ethtool.c  |  4 +++-
 drivers/net/ethernet/marvell/mv643xx_eth.c         |  5 ++---
 drivers/net/ethernet/ti/cpsw.c                     |  9 +++++----
 drivers/net/phy/phy.c                              | 10 +++++-----
 drivers/net/usb/lan78xx.c                          |  2 +-
 include/linux/phy.h                                |  4 ++--
 net/dsa/slave.c                                    |  9 +++++----
 12 files changed, 35 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 5b95bb4..9873d2d 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -1836,7 +1836,8 @@ static int b44_get_link_ksettings(struct net_device *dev,
 
 	if (bp->flags & B44_FLAG_EXTERNAL_PHY) {
 		BUG_ON(!dev->phydev);
-		return phy_ethtool_ksettings_get(dev->phydev, cmd);
+		phy_ethtool_ksettings_get(dev->phydev, cmd);
+		return 0;
 	}
 
 	supported = (SUPPORTED_Autoneg);
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 50d88d3..34ebb40 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1453,7 +1453,8 @@ static int bcm_enet_get_link_ksettings(struct net_device *dev,
 	if (priv->has_phy) {
 		if (!dev->phydev)
 			return -ENODEV;
-		return phy_ethtool_ksettings_get(dev->phydev, cmd);
+		phy_ethtool_ksettings_get(dev->phydev, cmd);
+		return 0;
 	} else {
 		cmd->base.autoneg = 0;
 		cmd->base.speed = (priv->force_speed_100) ?
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index a205a9f..daca1c9 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -477,7 +477,9 @@ static int bcmgenet_get_link_ksettings(struct net_device *dev,
 	if (!priv->phydev)
 		return -ENODEV;
 
-	return phy_ethtool_ksettings_get(priv->phydev, cmd);
+	phy_ethtool_ksettings_get(priv->phydev, cmd);
+
+	return 0;
 }
 
 static int bcmgenet_set_link_ksettings(struct net_device *dev,
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 537d571..d600c41 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -12097,7 +12097,9 @@ static int tg3_get_link_ksettings(struct net_device *dev,
 		if (!(tp->phy_flags & TG3_PHYFLG_IS_CONNECTED))
 			return -EAGAIN;
 		phydev = mdiobus_get_phy(tp->mdio_bus, tp->phy_addr);
-		return phy_ethtool_ksettings_get(phydev, cmd);
+		phy_ethtool_ksettings_get(phydev, cmd);
+
+		return 0;
 	}
 
 	supported = (SUPPORTED_Autoneg);
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c b/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c
index 15571e2..aad825088 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c
@@ -75,16 +75,14 @@ static char dpaa_stats_global[][ETH_GSTRING_LEN] = {
 static int dpaa_get_link_ksettings(struct net_device *net_dev,
 				   struct ethtool_link_ksettings *cmd)
 {
-	int err;
-
 	if (!net_dev->phydev) {
 		netdev_dbg(net_dev, "phy device not initialized\n");
 		return 0;
 	}
 
-	err = phy_ethtool_ksettings_get(net_dev->phydev, cmd);
+	phy_ethtool_ksettings_get(net_dev->phydev, cmd);
 
-	return err;
+	return 0;
 }
 
 static int dpaa_set_link_ksettings(struct net_device *net_dev,
diff --git a/drivers/net/ethernet/freescale/ucc_geth_ethtool.c b/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
index b642990..4df282e 100644
--- a/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
+++ b/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
@@ -113,7 +113,9 @@ uec_get_ksettings(struct net_device *netdev, struct ethtool_link_ksettings *cmd)
 	if (!phydev)
 		return -ENODEV;
 
-	return phy_ethtool_ksettings_get(phydev, cmd);
+	phy_ethtool_ksettings_get(phydev, cmd);
+
+	return 0;
 }
 
 static int
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 25642de..5794d98 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1501,10 +1501,9 @@ mv643xx_eth_get_link_ksettings_phy(struct mv643xx_eth_private *mp,
 				   struct ethtool_link_ksettings *cmd)
 {
 	struct net_device *dev = mp->dev;
-	int err;
 	u32 supported, advertising;
 
-	err = phy_ethtool_ksettings_get(dev->phydev, cmd);
+	phy_ethtool_ksettings_get(dev->phydev, cmd);
 
 	/*
 	 * The MAC does not support 1000baseT_Half.
@@ -1520,7 +1519,7 @@ mv643xx_eth_get_link_ksettings_phy(struct mv643xx_eth_private *mp,
 	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
 						advertising);
 
-	return err;
+	return 0;
 }
 
 static int
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index f4d7aec..03707ee 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2165,11 +2165,12 @@ static int cpsw_get_link_ksettings(struct net_device *ndev,
 	struct cpsw_common *cpsw = priv->cpsw;
 	int slave_no = cpsw_slave_index(cpsw, priv);
 
-	if (cpsw->slaves[slave_no].phy)
-		return phy_ethtool_ksettings_get(cpsw->slaves[slave_no].phy,
-						 ecmd);
-	else
+	if (cpsw->slaves[slave_no].phy) {
+		phy_ethtool_ksettings_get(cpsw->slaves[slave_no].phy, ecmd);
+		return 0;
+	} else {
 		return -EOPNOTSUPP;
+	}
 }
 
 static int cpsw_set_link_ksettings(struct net_device *ndev,
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 82ab8fb..9c372bf 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -508,8 +508,8 @@ int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 }
 EXPORT_SYMBOL(phy_ethtool_gset);
 
-int phy_ethtool_ksettings_get(struct phy_device *phydev,
-			      struct ethtool_link_ksettings *cmd)
+void phy_ethtool_ksettings_get(struct phy_device *phydev,
+			       struct ethtool_link_ksettings *cmd)
 {
 	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
 						phydev->supported);
@@ -531,8 +531,6 @@ int phy_ethtool_ksettings_get(struct phy_device *phydev,
 	cmd->base.autoneg = phydev->autoneg;
 	cmd->base.eth_tp_mdix_ctrl = phydev->mdix_ctrl;
 	cmd->base.eth_tp_mdix = phydev->mdix;
-
-	return 0;
 }
 EXPORT_SYMBOL(phy_ethtool_ksettings_get);
 
@@ -1448,7 +1446,9 @@ int phy_ethtool_get_link_ksettings(struct net_device *ndev,
 	if (!phydev)
 		return -ENODEV;
 
-	return phy_ethtool_ksettings_get(phydev, cmd);
+	phy_ethtool_ksettings_get(phydev, cmd);
+
+	return 0;
 }
 EXPORT_SYMBOL(phy_ethtool_get_link_ksettings);
 
diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 9eff97a..5833f7e 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -1490,7 +1490,7 @@ static int lan78xx_get_link_ksettings(struct net_device *net,
 	if (ret < 0)
 		return ret;
 
-	ret = phy_ethtool_ksettings_get(phydev, cmd);
+	phy_ethtool_ksettings_get(phydev, cmd);
 
 	usb_autopm_put_interface(dev->intf);
 
diff --git a/include/linux/phy.h b/include/linux/phy.h
index e76e4ad..4ec07a6 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -844,8 +844,8 @@ void phy_stop_machine(struct phy_device *phydev);
 void phy_trigger_machine(struct phy_device *phydev, bool sync);
 int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd);
 int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd);
-int phy_ethtool_ksettings_get(struct phy_device *phydev,
-			      struct ethtool_link_ksettings *cmd);
+void phy_ethtool_ksettings_get(struct phy_device *phydev,
+			       struct ethtool_link_ksettings *cmd);
 int phy_ethtool_ksettings_set(struct phy_device *phydev,
 			      const struct ethtool_link_ksettings *cmd);
 int phy_mii_ioctl(struct phy_device *phydev, struct ifreq *ifr, int cmd);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 7693182..ba9f78b 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -689,12 +689,13 @@ dsa_slave_get_link_ksettings(struct net_device *dev,
 			     struct ethtool_link_ksettings *cmd)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	int err = -EOPNOTSUPP;
 
-	if (p->phy != NULL)
-		err = phy_ethtool_ksettings_get(p->phy, cmd);
+	if (!p->phy)
+		return -EOPNOTSUPP;
 
-	return err;
+	phy_ethtool_ksettings_get(p->phy, cmd);
+
+	return 0;
 }
 
 static int
-- 
2.9.4
