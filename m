From: David Decotigny <decot@google.com>
Subject: [PATCHv2 4/4] ethtool: cosmetic: Use ethtool ethtool_cmd_speed API
Date: Wed, 27 Apr 2011 11:34:49 -0700
Message-ID: <1303929290-21037-5-git-send-email-decot__22597.9731687859$1303929374$gmane$org@google.com>
References: <1303001651-4074-1-git-send-email-decot@google.com>
Cc: David Decotigny <decot@google.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	mirq-linux@rere.qmqm.pl, Stanislaw Gruszka <sgruszka@redhat.com>,
	Alexander Duyck <alexander.h.duyc
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:61145 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756538Ab1D0Sf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 14:35:26 -0400
In-Reply-To: <1303001651-4074-1-git-send-email-decot@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This updates the network drivers so that they don't access the
ethtool_cmd::speed field directly, but use ethtoo_cmd_speed() instead.

For most of the drivers, these changes are purely cosmetic and don't
fix any problem, such as for those 1GbE/10GbE drivers that indirectly
call their own ethtool get_settings()/mii_ethtool_gset(). The changes
are meant to enforce code consistency and provide robustness with
future larger throughputs, at the expense of a few CPU cycles for each
ethtool operation.

All the drivers compiled with make allyesconfig ion x86_64 have been
updated.

Tested: make allyesconfig on x86_64 + e1000e/bnx2x work
Signed-off-by: David Decotigny <decot@google.com>
---
 drivers/infiniband/hw/nes/nes_nic.c     |    4 ++--
 drivers/net/3c509.c                     |    2 +-
 drivers/net/acenic.c                    |    8 ++++----
 drivers/net/arm/etherh.c                |    5 +++--
 drivers/net/arm/ks8695net.c             |    7 ++++---
 drivers/net/atl1c/atl1c_ethtool.c       |    4 ++--
 drivers/net/atl1e/atl1e_ethtool.c       |    4 ++--
 drivers/net/atlx/atl1.c                 |    4 ++--
 drivers/net/atlx/atl2.c                 |    4 ++--
 drivers/net/b44.c                       |    6 +++---
 drivers/net/bcm63xx_enet.c              |    3 ++-
 drivers/net/benet/be_ethtool.c          |   16 ++++++++--------
 drivers/net/bna/bnad_ethtool.c          |    4 ++--
 drivers/net/bnx2.c                      |    7 +++----
 drivers/net/cassini.c                   |   25 ++++++++++++-------------
 drivers/net/chelsio/cxgb2.c             |    4 ++--
 drivers/net/cxgb3/cxgb3_main.c          |    4 ++--
 drivers/net/cxgb4/cxgb4_main.c          |    3 ++-
 drivers/net/cxgb4vf/cxgb4vf_main.c      |    3 ++-
 drivers/net/dl2k.c                      |    4 ++--
 drivers/net/e1000/e1000_ethtool.c       |    4 ++--
 drivers/net/e1000e/ethtool.c            |   12 +++++++-----
 drivers/net/eepro.c                     |    2 +-
 drivers/net/ehea/ehea_ethtool.c         |   23 ++++++++++++++++++-----
 drivers/net/enc28j60.c                  |    2 +-
 drivers/net/enic/enic_main.c            |    4 ++--
 drivers/net/ewrk3.c                     |    2 +-
 drivers/net/forcedeth.c                 |   14 +++++++++-----
 drivers/net/ibmveth.c                   |    2 +-
 drivers/net/igb/igb_ethtool.c           |    8 ++++----
 drivers/net/igbvf/ethtool.c             |    8 ++++----
 drivers/net/ixgb/ixgb_ethtool.c         |    4 ++--
 drivers/net/ixgbe/ixgbe_ethtool.c       |    8 ++++----
 drivers/net/ixgbevf/ethtool.c           |    8 +++++---
 drivers/net/mdio.c                      |   19 +++++++++++--------
 drivers/net/mii.c                       |   15 +++++++++------
 drivers/net/mlx4/en_ethtool.c           |    4 ++--
 drivers/net/mv643xx_eth.c               |    6 +++---
 drivers/net/myri10ge/myri10ge.c         |    2 +-
 drivers/net/natsemi.c                   |    6 +++---
 drivers/net/netxen/netxen_nic_ethtool.c |   10 +++++-----
 drivers/net/niu.c                       |    2 +-
 drivers/net/ns83820.c                   |    8 ++++----
 drivers/net/pch_gbe/pch_gbe_ethtool.c   |    2 +-
 drivers/net/pch_gbe/pch_gbe_phy.c       |    2 +-
 drivers/net/pcmcia/smc91c92_cs.c        |    2 +-
 drivers/net/phy/phy.c                   |    2 +-
 drivers/net/ps3_gelic_net.c             |    8 ++++----
 drivers/net/qla3xxx.c                   |    2 +-
 drivers/net/qlcnic/qlcnic_ethtool.c     |    8 ++++----
 drivers/net/qlge/qlge_ethtool.c         |    2 +-
 drivers/net/r8169.c                     |    2 +-
 drivers/net/s2io.c                      |    4 ++--
 drivers/net/sc92031.c                   |    3 ++-
 drivers/net/sfc/ethtool.c               |    2 +-
 drivers/net/sfc/mcdi_phy.c              |    2 +-
 drivers/net/sfc/tenxpress.c             |    2 +-
 drivers/net/skge.c                      |    2 +-
 drivers/net/sky2.c                      |    4 ++--
 drivers/net/smc911x.c                   |    4 ++--
 drivers/net/smc91x.c                    |    4 ++--
 drivers/net/spider_net_ethtool.c        |    2 +-
 drivers/net/sungem.c                    |    6 +++---
 drivers/net/sunhme.c                    |   13 ++++++-------
 drivers/net/tehuti.c                    |    2 +-
 drivers/net/tg3.c                       |    4 ++--
 drivers/net/tulip/de2104x.c             |    6 +++---
 drivers/net/tulip/uli526x.c             |    6 +++---
 drivers/net/tun.c                       |    2 +-
 drivers/net/typhoon.c                   |    2 +-
 drivers/net/usb/catc.c                  |    2 +-
 drivers/net/usb/rtl8150.c               |   11 ++++++-----
 drivers/net/veth.c                      |    2 +-
 drivers/net/via-velocity.c              |   11 +++++++----
 drivers/net/vmxnet3/vmxnet3_ethtool.c   |    4 ++--
 drivers/net/vxge/vxge-ethtool.c         |    4 ++--
 net/batman-adv/soft-interface.c         |    2 +-
 77 files changed, 232 insertions(+), 198 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index d2e67c4..d3a1c41 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -1493,7 +1493,7 @@ static int nes_netdev_get_settings(struct net_device *netdev, struct ethtool_cmd
 	et_cmd->maxrxpkt = 511;
 
 	if (nesadapter->OneG_Mode) {
-		et_cmd->speed = SPEED_1000;
+		ethtool_cmd_speed_set(et_cmd, SPEED_1000);
 		if (phy_type == NES_PHY_TYPE_PUMA_1G) {
 			et_cmd->supported   = SUPPORTED_1000baseT_Full;
 			et_cmd->advertising = ADVERTISED_1000baseT_Full;
@@ -1532,7 +1532,7 @@ static int nes_netdev_get_settings(struct net_device *netdev, struct ethtool_cmd
 		et_cmd->advertising = ADVERTISED_10000baseT_Full;
 		et_cmd->phy_address = mac_index;
 	}
-	et_cmd->speed = SPEED_10000;
+	ethtool_cmd_speed_set(et_cmd, SPEED_10000);
 	et_cmd->autoneg = AUTONEG_DISABLE;
 	return 0;
 }
diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index cb39ded..5f25889 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -1207,7 +1207,7 @@ el3_netdev_get_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd)
 			ecmd->duplex = DUPLEX_FULL;
 	}
 
-	ecmd->speed = SPEED_10;
+	ethtool_cmd_speed_set(ecmd, SPEED_10);
 	EL3WINDOW(1);
 	return 0;
 }
diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 0b4d8d1..a579899 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -2658,15 +2658,15 @@ static int ace_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 
 	link = readl(&regs->GigLnkState);
 	if (link & LNK_1000MB)
-		ecmd->speed = SPEED_1000;
+		ethtool_cmd_speed_set(ecmd, SPEED_1000);
 	else {
 		link = readl(&regs->FastLnkState);
 		if (link & LNK_100MB)
-			ecmd->speed = SPEED_100;
+			ethtool_cmd_speed_set(ecmd, SPEED_100);
 		else if (link & LNK_10MB)
-			ecmd->speed = SPEED_10;
+			ethtool_cmd_speed_set(ecmd, SPEED_10);
 		else
-			ecmd->speed = 0;
+			ethtool_cmd_speed_set(ecmd, 0);
 	}
 	if (link & LNK_FULL_DUPLEX)
 		ecmd->duplex = DUPLEX_FULL;
diff --git a/drivers/net/arm/etherh.c b/drivers/net/arm/etherh.c
index 4af235d..e252cd5 100644
--- a/drivers/net/arm/etherh.c
+++ b/drivers/net/arm/etherh.c
@@ -591,10 +591,11 @@ static void etherh_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *i
 static int etherh_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	cmd->supported	= etherh_priv(dev)->supported;
-	cmd->speed	= SPEED_10;
+	ethtool_cmd_speed_set(cmd, SPEED_10);
 	cmd->duplex	= DUPLEX_HALF;
 	cmd->port	= dev->if_port == IF_PORT_10BASET ? PORT_TP : PORT_BNC;
-	cmd->autoneg	= dev->flags & IFF_AUTOMEDIA ? AUTONEG_ENABLE : AUTONEG_DISABLE;
+	cmd->autoneg	= (dev->flags & IFF_AUTOMEDIA ?
+			   AUTONEG_ENABLE : AUTONEG_DISABLE);
 	return 0;
 }
 
diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
index aa07657..a7b0caa 100644
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -891,15 +891,16 @@ ks8695_wan_get_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
 			cmd->advertising |= ADVERTISED_Pause;
 		cmd->autoneg = AUTONEG_ENABLE;
 
-		cmd->speed = (ctrl & WMC_WSS) ? SPEED_100 : SPEED_10;
+		ethtool_cmd_speed_set(cmd,
+				      (ctrl & WMC_WSS) ? SPEED_100 : SPEED_10);
 		cmd->duplex = (ctrl & WMC_WDS) ?
 			DUPLEX_FULL : DUPLEX_HALF;
 	} else {
 		/* auto-negotiation is disabled */
 		cmd->autoneg = AUTONEG_DISABLE;
 
-		cmd->speed = (ctrl & WMC_WANF100) ?
-			SPEED_100 : SPEED_10;
+		ethtool_cmd_speed_set(cmd, ((ctrl & WMC_WANF100) ?
+					    SPEED_100 : SPEED_10));
 		cmd->duplex = (ctrl & WMC_WANFF) ?
 			DUPLEX_FULL : DUPLEX_HALF;
 	}
diff --git a/drivers/net/atl1c/atl1c_ethtool.c b/drivers/net/atl1c/atl1c_ethtool.c
index b1eceee..7be884d 100644
--- a/drivers/net/atl1c/atl1c_ethtool.c
+++ b/drivers/net/atl1c/atl1c_ethtool.c
@@ -50,13 +50,13 @@ static int atl1c_get_settings(struct net_device *netdev,
 	ecmd->transceiver = XCVR_INTERNAL;
 
 	if (adapter->link_speed != SPEED_0) {
-		ecmd->speed = adapter->link_speed;
+		ethtool_cmd_speed_set(ecmd, adapter->link_speed);
 		if (adapter->link_duplex == FULL_DUPLEX)
 			ecmd->duplex = DUPLEX_FULL;
 		else
 			ecmd->duplex = DUPLEX_HALF;
 	} else {
-		ecmd->speed = -1;
+		ethtool_cmd_speed_set(ecmd, -1);
 		ecmd->duplex = -1;
 	}
 
diff --git a/drivers/net/atl1e/atl1e_ethtool.c b/drivers/net/atl1e/atl1e_ethtool.c
index 4778374..6269438 100644
--- a/drivers/net/atl1e/atl1e_ethtool.c
+++ b/drivers/net/atl1e/atl1e_ethtool.c
@@ -51,13 +51,13 @@ static int atl1e_get_settings(struct net_device *netdev,
 	ecmd->transceiver = XCVR_INTERNAL;
 
 	if (adapter->link_speed != SPEED_0) {
-		ecmd->speed = adapter->link_speed;
+		ethtool_cmd_speed_set(ecmd, adapter->link_speed);
 		if (adapter->link_duplex == FULL_DUPLEX)
 			ecmd->duplex = DUPLEX_FULL;
 		else
 			ecmd->duplex = DUPLEX_HALF;
 	} else {
-		ecmd->speed = -1;
+		ethtool_cmd_speed_set(ecmd, -1);
 		ecmd->duplex = -1;
 	}
 
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 37a092f..c5298d1 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -3231,13 +3231,13 @@ static int atl1_get_settings(struct net_device *netdev,
 	if (netif_carrier_ok(adapter->netdev)) {
 		u16 link_speed, link_duplex;
 		atl1_get_speed_and_duplex(hw, &link_speed, &link_duplex);
-		ecmd->speed = link_speed;
+		ethtool_cmd_speed_set(ecmd, link_speed);
 		if (link_duplex == FULL_DUPLEX)
 			ecmd->duplex = DUPLEX_FULL;
 		else
 			ecmd->duplex = DUPLEX_HALF;
 	} else {
-		ecmd->speed = -1;
+		ethtool_cmd_speed_set(ecmd, -1);
 		ecmd->duplex = -1;
 	}
 	if (hw->media_type == MEDIA_TYPE_AUTO_SENSOR ||
diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index b75aa29..16249e9 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -1769,13 +1769,13 @@ static int atl2_get_settings(struct net_device *netdev,
 	ecmd->transceiver = XCVR_INTERNAL;
 
 	if (adapter->link_speed != SPEED_0) {
-		ecmd->speed = adapter->link_speed;
+		ethtool_cmd_speed_set(ecmd, adapter->link_speed);
 		if (adapter->link_duplex == FULL_DUPLEX)
 			ecmd->duplex = DUPLEX_FULL;
 		else
 			ecmd->duplex = DUPLEX_HALF;
 	} else {
-		ecmd->speed = -1;
+		ethtool_cmd_speed_set(ecmd, -1);
 		ecmd->duplex = -1;
 	}
 
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 909cc4b..a69331e 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1807,8 +1807,8 @@ static int b44_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if (bp->flags & B44_FLAG_ADV_100FULL)
 		cmd->advertising |= ADVERTISED_100baseT_Full;
 	cmd->advertising |= ADVERTISED_Pause | ADVERTISED_Asym_Pause;
-	cmd->speed = (bp->flags & B44_FLAG_100_BASE_T) ?
-		SPEED_100 : SPEED_10;
+	ethtool_cmd_speed_set(cmd, ((bp->flags & B44_FLAG_100_BASE_T) ?
+				    SPEED_100 : SPEED_10));
 	cmd->duplex = (bp->flags & B44_FLAG_FULL_DUPLEX) ?
 		DUPLEX_FULL : DUPLEX_HALF;
 	cmd->port = 0;
@@ -1820,7 +1820,7 @@ static int b44_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if (cmd->autoneg == AUTONEG_ENABLE)
 		cmd->advertising |= ADVERTISED_Autoneg;
 	if (!netif_running(dev)){
-		cmd->speed = 0;
+		ethtool_cmd_speed_set(cmd, 0);
 		cmd->duplex = 0xff;
 	}
 	cmd->maxtxpkt = 0;
diff --git a/drivers/net/bcm63xx_enet.c b/drivers/net/bcm63xx_enet.c
index e68ffe6..f1573d4 100644
--- a/drivers/net/bcm63xx_enet.c
+++ b/drivers/net/bcm63xx_enet.c
@@ -1346,7 +1346,8 @@ static int bcm_enet_get_settings(struct net_device *dev,
 		return phy_ethtool_gset(priv->phydev, cmd);
 	} else {
 		cmd->autoneg = 0;
-		cmd->speed = (priv->force_speed_100) ? SPEED_100 : SPEED_10;
+		ethtool_cmd_speed_set(cmd, ((priv->force_speed_100)
+					    ? SPEED_100 : SPEED_10));
 		cmd->duplex = (priv->force_duplex_full) ?
 			DUPLEX_FULL : DUPLEX_HALF;
 		cmd->supported = ADVERTISED_10baseT_Half  |
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 6565f3e..8e770e8 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -381,23 +381,23 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		be_link_status_update(adapter, link_up);
 		/* link_speed is in units of 10 Mbps */
 		if (link_speed) {
-			ecmd->speed = link_speed*10;
+			ethtool_cmd_speed_set(ecmd, link_speed*10);
 		} else {
 			switch (mac_speed) {
 			case PHY_LINK_SPEED_10MBPS:
-				ecmd->speed = SPEED_10;
+				ethtool_cmd_speed_set(ecmd, SPEED_10);
 				break;
 			case PHY_LINK_SPEED_100MBPS:
-				ecmd->speed = SPEED_100;
+				ethtool_cmd_speed_set(ecmd, SPEED_100);
 				break;
 			case PHY_LINK_SPEED_1GBPS:
-				ecmd->speed = SPEED_1000;
+				ethtool_cmd_speed_set(ecmd, SPEED_1000);
 				break;
 			case PHY_LINK_SPEED_10GBPS:
-				ecmd->speed = SPEED_10000;
+				ethtool_cmd_speed_set(ecmd, SPEED_10000);
 				break;
 			case PHY_LINK_SPEED_ZERO:
-				ecmd->speed = 0;
+				ethtool_cmd_speed_set(ecmd, 0);
 				break;
 			}
 		}
@@ -440,14 +440,14 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		}
 
 		/* Save for future use */
-		adapter->link_speed = ecmd->speed;
+		adapter->link_speed = ethtool_cmd_speed(ecmd);
 		adapter->port_type = ecmd->port;
 		adapter->transceiver = ecmd->transceiver;
 		adapter->autoneg = ecmd->autoneg;
 		dma_free_coherent(&adapter->pdev->dev, phy_cmd.size, phy_cmd.va,
 				  phy_cmd.dma);
 	} else {
-		ecmd->speed = adapter->link_speed;
+		ethtool_cmd_speed_set(ecmd, adapter->link_speed);
 		ecmd->port = adapter->port_type;
 		ecmd->transceiver = adapter->transceiver;
 		ecmd->autoneg = adapter->autoneg;
diff --git a/drivers/net/bna/bnad_ethtool.c b/drivers/net/bna/bnad_ethtool.c
index ae1e118..3330cd7 100644
--- a/drivers/net/bna/bnad_ethtool.c
+++ b/drivers/net/bna/bnad_ethtool.c
@@ -237,10 +237,10 @@ bnad_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 	cmd->phy_address = 0;
 
 	if (netif_carrier_ok(netdev)) {
-		cmd->speed = SPEED_10000;
+		ethtool_cmd_speed_set(cmd, SPEED_10000);
 		cmd->duplex = DUPLEX_FULL;
 	} else {
-		cmd->speed = -1;
+		ethtool_cmd_speed_set(cmd, -1);
 		cmd->duplex = -1;
 	}
 	cmd->transceiver = XCVR_EXTERNAL;
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index e43efd8..1bebdfb 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6696,17 +6696,16 @@ bnx2_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	if (bp->autoneg & AUTONEG_SPEED) {
 		cmd->autoneg = AUTONEG_ENABLE;
-	}
-	else {
+	} else {
 		cmd->autoneg = AUTONEG_DISABLE;
 	}
 
 	if (netif_carrier_ok(dev)) {
-		cmd->speed = bp->line_speed;
+		ethtool_cmd_speed_set(cmd, bp->line_speed);
 		cmd->duplex = bp->duplex;
 	}
 	else {
-		cmd->speed = -1;
+		ethtool_cmd_speed_set(cmd, -1);
 		cmd->duplex = -1;
 	}
 	spin_unlock_bh(&bp->phy_lock);
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index a6c3f8c..22ce03e 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -4606,18 +4606,17 @@ static int cas_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if (bmcr & BMCR_ANENABLE) {
 		cmd->advertising |= ADVERTISED_Autoneg;
 		cmd->autoneg = AUTONEG_ENABLE;
-		cmd->speed = ((speed == 10) ?
-			      SPEED_10 :
-			      ((speed == 1000) ?
-			       SPEED_1000 : SPEED_100));
+		ethtool_cmd_speed_set(cmd, ((speed == 10) ?
+					    SPEED_10 :
+					    ((speed == 1000) ?
+					     SPEED_1000 : SPEED_100)));
 		cmd->duplex = full_duplex ? DUPLEX_FULL : DUPLEX_HALF;
 	} else {
 		cmd->autoneg = AUTONEG_DISABLE;
-		cmd->speed =
-			(bmcr & CAS_BMCR_SPEED1000) ?
-			SPEED_1000 :
-			((bmcr & BMCR_SPEED100) ? SPEED_100:
-			 SPEED_10);
+		ethtool_cmd_speed_set(cmd, ((bmcr & CAS_BMCR_SPEED1000) ?
+					    SPEED_1000 :
+					    ((bmcr & BMCR_SPEED100) ?
+					     SPEED_100 : SPEED_10)));
 		cmd->duplex =
 			(bmcr & BMCR_FULLDPLX) ?
 			DUPLEX_FULL : DUPLEX_HALF;
@@ -4634,14 +4633,14 @@ static int cas_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		 * settings that we configured.
 		 */
 		if (cp->link_cntl & BMCR_ANENABLE) {
-			cmd->speed = 0;
+			ethtool_cmd_speed_set(cmd, 0);
 			cmd->duplex = 0xff;
 		} else {
-			cmd->speed = SPEED_10;
+			ethtool_cmd_speed_set(cmd, SPEED_10);
 			if (cp->link_cntl & BMCR_SPEED100) {
-				cmd->speed = SPEED_100;
+				ethtool_cmd_speed_set(cmd, SPEED_100);
 			} else if (cp->link_cntl & CAS_BMCR_SPEED1000) {
-				cmd->speed = SPEED_1000;
+				ethtool_cmd_speed_set(cmd, SPEED_1000);
 			}
 			cmd->duplex = (cp->link_cntl & BMCR_FULLDPLX)?
 				DUPLEX_FULL : DUPLEX_HALF;
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 8e14d65..b422d83 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -577,10 +577,10 @@ static int get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	cmd->advertising = p->link_config.advertising;
 
 	if (netif_carrier_ok(dev)) {
-		cmd->speed = p->link_config.speed;
+		ethtool_cmd_speed_set(cmd, p->link_config.speed);
 		cmd->duplex = p->link_config.duplex;
 	} else {
-		cmd->speed = -1;
+		ethtool_cmd_speed_set(cmd, -1);
 		cmd->duplex = -1;
 	}
 
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 0526715..9081ce0 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1759,10 +1759,10 @@ static int get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	cmd->advertising = p->link_config.advertising;
 
 	if (netif_carrier_ok(dev)) {
-		cmd->speed = p->link_config.speed;
+		ethtool_cmd_speed_set(cmd, p->link_config.speed);
 		cmd->duplex = p->link_config.duplex;
 	} else {
-		cmd->speed = -1;
+		ethtool_cmd_speed_set(cmd, -1);
 		cmd->duplex = -1;
 	}
 
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 73565f3..bb24261 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -1436,7 +1436,8 @@ static int get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	cmd->supported = from_fw_linkcaps(p->port_type, p->link_cfg.supported);
 	cmd->advertising = from_fw_linkcaps(p->port_type,
 					    p->link_cfg.advertising);
-	cmd->speed = netif_carrier_ok(dev) ? p->link_cfg.speed : 0;
+	ethtool_cmd_speed_set(cmd,
+			      netif_carrier_ok(dev) ? p->link_cfg.speed : 0);
 	cmd->duplex = DUPLEX_FULL;
 	cmd->autoneg = p->link_cfg.autoneg;
 	cmd->maxtxpkt = 0;
diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index 8cf9890..e71c08e 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -1167,7 +1167,8 @@ static int cxgb4vf_get_settings(struct net_device *dev,
 
 	cmd->supported = pi->link_cfg.supported;
 	cmd->advertising = pi->link_cfg.advertising;
-	cmd->speed = netif_carrier_ok(dev) ? pi->link_cfg.speed : -1;
+	ethtool_cmd_speed_set(cmd,
+			      netif_carrier_ok(dev) ? pi->link_cfg.speed : -1);
 	cmd->duplex = DUPLEX_FULL;
 
 	cmd->port = (cmd->supported & SUPPORTED_TP) ? PORT_TP : PORT_FIBRE;
diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index ed3cb6a..1f61100 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -1189,10 +1189,10 @@ static int rio_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		cmd->transceiver = XCVR_INTERNAL;
 	}
 	if ( np->link_status ) {
-		cmd->speed = np->speed;
+		ethtool_cmd_speed_set(cmd, np->speed);
 		cmd->duplex = np->full_duplex ? DUPLEX_FULL : DUPLEX_HALF;
 	} else {
-		cmd->speed = -1;
+		ethtool_cmd_speed_set(cmd, -1);
 		cmd->duplex = -1;
 	}
 	if ( np->an_enable)
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index a53629d..127fef4 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -158,7 +158,7 @@ static int e1000_get_settings(struct net_device *netdev,
 
 		e1000_get_speed_and_duplex(hw, &adapter->link_speed,
 		                                   &adapter->link_duplex);
-		ecmd->speed = adapter->link_speed;
+		ethtool_cmd_speed_set(ecmd, adapter->link_speed);
 
 		/* unfortunately FULL_DUPLEX != DUPLEX_FULL
 		 *          and HALF_DUPLEX != DUPLEX_HALF */
@@ -168,7 +168,7 @@ static int e1000_get_settings(struct net_device *netdev,
 		else
 			ecmd->duplex = DUPLEX_HALF;
 	} else {
-		ecmd->speed = -1;
+		ethtool_cmd_speed_set(ecmd, -1);
 		ecmd->duplex = -1;
 	}
 
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 1dd81b2..2f369ed 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -122,6 +122,7 @@ static int e1000_get_settings(struct net_device *netdev,
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	u32 speed;
 
 	if (hw->phy.media_type == e1000_media_type_copper) {
 
@@ -159,23 +160,23 @@ static int e1000_get_settings(struct net_device *netdev,
 		ecmd->transceiver = XCVR_EXTERNAL;
 	}
 
-	ecmd->speed = -1;
+	speed = -1;
 	ecmd->duplex = -1;
 
 	if (netif_running(netdev)) {
 		if (netif_carrier_ok(netdev)) {
-			ecmd->speed = adapter->link_speed;
+			speed = adapter->link_speed;
 			ecmd->duplex = adapter->link_duplex - 1;
 		}
 	} else {
 		u32 status = er32(STATUS);
 		if (status & E1000_STATUS_LU) {
 			if (status & E1000_STATUS_SPEED_1000)
-				ecmd->speed = 1000;
+				speed = SPEED_1000;
 			else if (status & E1000_STATUS_SPEED_100)
-				ecmd->speed = 100;
+				speed = SPEED_100;
 			else
-				ecmd->speed = 10;
+				speed = SPEED_10;
 
 			if (status & E1000_STATUS_FD)
 				ecmd->duplex = DUPLEX_FULL;
@@ -184,6 +185,7 @@ static int e1000_get_settings(struct net_device *netdev,
 		}
 	}
 
+	ethtool_cmd_speed_set(ecmd, speed);
 	ecmd->autoneg = ((hw->phy.media_type == e1000_media_type_fiber) ||
 			 hw->mac.autoneg) ? AUTONEG_ENABLE : AUTONEG_DISABLE;
 
diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index eb35951..dfeb006 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -1703,7 +1703,7 @@ static int eepro_ethtool_get_settings(struct net_device *dev,
 		cmd->advertising |= ADVERTISED_AUI;
 	}
 
-	cmd->speed = SPEED_10;
+	ethtool_cmd_speed_set(cmd, SPEED_10);
 
 	if (dev->if_port == TPE && lp->word[1] & ee_Duplex) {
 		cmd->duplex = DUPLEX_FULL;
diff --git a/drivers/net/ehea/ehea_ethtool.c b/drivers/net/ehea/ehea_ethtool.c
index 5f13491..1df5f40 100644
--- a/drivers/net/ehea/ehea_ethtool.c
+++ b/drivers/net/ehea/ehea_ethtool.c
@@ -34,6 +34,7 @@
 static int ehea_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct ehea_port *port = netdev_priv(dev);
+	u32 speed;
 	int ret;
 
 	ret = ehea_sense_port_attr(port);
@@ -43,17 +44,29 @@ static int ehea_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	if (netif_carrier_ok(dev)) {
 		switch (port->port_speed) {
-		case EHEA_SPEED_10M: cmd->speed = SPEED_10; break;
-		case EHEA_SPEED_100M: cmd->speed = SPEED_100; break;
-		case EHEA_SPEED_1G: cmd->speed = SPEED_1000; break;
-		case EHEA_SPEED_10G: cmd->speed = SPEED_10000; break;
+		case EHEA_SPEED_10M:
+			speed = SPEED_10;
+			break;
+		case EHEA_SPEED_100M:
+			speed = SPEED_100;
+			break;
+		case EHEA_SPEED_1G:
+			speed = SPEED_1000;
+			break;
+		case EHEA_SPEED_10G:
+			speed = SPEED_10000;
+			break;
+		default:
+			speed = -1;
+			break; /* BUG */
 		}
 		cmd->duplex = port->full_duplex == 1 ?
 						     DUPLEX_FULL : DUPLEX_HALF;
 	} else {
-		cmd->speed = -1;
+		speed = ~0;
 		cmd->duplex = -1;
 	}
+	ethtool_cmd_speed_set(cmd, speed);
 
 	cmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_1000baseT_Full
 		       | SUPPORTED_100baseT_Full |  SUPPORTED_100baseT_Half
diff --git a/drivers/net/enc28j60.c b/drivers/net/enc28j60.c
index 81a7937..2837ce2 100644
--- a/drivers/net/enc28j60.c
+++ b/drivers/net/enc28j60.c
@@ -1488,7 +1488,7 @@ enc28j60_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	cmd->supported	= SUPPORTED_10baseT_Half
 			| SUPPORTED_10baseT_Full
 			| SUPPORTED_TP;
-	cmd->speed	= SPEED_10;
+	ethtool_cmd_speed_set(cmd,  SPEED_10);
 	cmd->duplex	= priv->full_duplex ? DUPLEX_FULL : DUPLEX_HALF;
 	cmd->port	= PORT_TP;
 	cmd->autoneg	= AUTONEG_DISABLE;
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index b224551..3d99b0f 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -180,10 +180,10 @@ static int enic_get_settings(struct net_device *netdev,
 	ecmd->transceiver = XCVR_EXTERNAL;
 
 	if (netif_carrier_ok(netdev)) {
-		ecmd->speed = vnic_dev_port_speed(enic->vdev);
+		ethtool_cmd_speed_set(ecmd, vnic_dev_port_speed(enic->vdev));
 		ecmd->duplex = DUPLEX_FULL;
 	} else {
-		ecmd->speed = -1;
+		ethtool_cmd_speed_set(ecmd, -1);
 		ecmd->duplex = -1;
 	}
 
diff --git a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
index 17b6027..b5f6173 100644
--- a/drivers/net/ewrk3.c
+++ b/drivers/net/ewrk3.c
@@ -1545,7 +1545,7 @@ static int ewrk3_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	}
 
 	ecmd->supported |= SUPPORTED_10baseT_Half;
-	ecmd->speed = SPEED_10;
+	ethtool_cmd_speed_set(ecmd, SPEED_10);
 	ecmd->duplex = DUPLEX_HALF;
 	return 0;
 }
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index d24b3f3..d09e8b0 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -3955,6 +3955,7 @@ static int nv_set_wol(struct net_device *dev, struct ethtool_wolinfo *wolinfo)
 static int nv_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	struct fe_priv *np = netdev_priv(dev);
+	u32 speed;
 	int adv;
 
 	spin_lock_irq(&np->lock);
@@ -3974,23 +3975,26 @@ static int nv_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	if (netif_carrier_ok(dev)) {
 		switch (np->linkspeed & (NVREG_LINKSPEED_MASK)) {
 		case NVREG_LINKSPEED_10:
-			ecmd->speed = SPEED_10;
+			speed = SPEED_10;
 			break;
 		case NVREG_LINKSPEED_100:
-			ecmd->speed = SPEED_100;
+			speed = SPEED_100;
 			break;
 		case NVREG_LINKSPEED_1000:
-			ecmd->speed = SPEED_1000;
+			speed = SPEED_1000;
+			break;
+		default:
+			speed = -1;
 			break;
 		}
 		ecmd->duplex = DUPLEX_HALF;
 		if (np->duplex)
 			ecmd->duplex = DUPLEX_FULL;
 	} else {
-		ecmd->speed = -1;
+		speed = -1;
 		ecmd->duplex = -1;
 	}
-
+	ethtool_cmd_speed_set(ecmd, speed);
 	ecmd->autoneg = np->autoneg;
 
 	ecmd->advertising = ADVERTISED_MII;
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 4855f1f..52542de 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -710,7 +710,7 @@ static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 				SUPPORTED_FIBRE);
 	cmd->advertising = (ADVERTISED_1000baseT_Full | ADVERTISED_Autoneg |
 				ADVERTISED_FIBRE);
-	cmd->speed = SPEED_1000;
+	ethtool_cmd_speed_set(cmd, SPEED_1000);
 	cmd->duplex = DUPLEX_FULL;
 	cmd->port = PORT_FIBRE;
 	cmd->phy_address = 0;
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 2cc221b..023aa9b 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -178,11 +178,11 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 
 		if ((status & E1000_STATUS_SPEED_1000) ||
 		    hw->phy.media_type != e1000_media_type_copper)
-			ecmd->speed = SPEED_1000;
+			ethtool_cmd_speed_set(ecmd, SPEED_1000);
 		else if (status & E1000_STATUS_SPEED_100)
-			ecmd->speed = SPEED_100;
+			ethtool_cmd_speed_set(ecmd, SPEED_100);
 		else
-			ecmd->speed = SPEED_10;
+			ethtool_cmd_speed_set(ecmd, SPEED_10);
 
 		if ((status & E1000_STATUS_FD) ||
 		    hw->phy.media_type != e1000_media_type_copper)
@@ -190,7 +190,7 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		else
 			ecmd->duplex = DUPLEX_HALF;
 	} else {
-		ecmd->speed = -1;
+		ethtool_cmd_speed_set(ecmd, -1);
 		ecmd->duplex = -1;
 	}
 
diff --git a/drivers/net/igbvf/ethtool.c b/drivers/net/igbvf/ethtool.c
index 1d943aa..112ae15 100644
--- a/drivers/net/igbvf/ethtool.c
+++ b/drivers/net/igbvf/ethtool.c
@@ -90,18 +90,18 @@ static int igbvf_get_settings(struct net_device *netdev,
 	status = er32(STATUS);
 	if (status & E1000_STATUS_LU) {
 		if (status & E1000_STATUS_SPEED_1000)
-			ecmd->speed = 1000;
+			ethtool_cmd_speed_set(ecmd, SPEED_1000);
 		else if (status & E1000_STATUS_SPEED_100)
-			ecmd->speed = 100;
+			ethtool_cmd_speed_set(ecmd, SPEED_100);
 		else
-			ecmd->speed = 10;
+			ethtool_cmd_speed_set(ecmd, SPEED_10);
 
 		if (status & E1000_STATUS_FD)
 			ecmd->duplex = DUPLEX_FULL;
 		else
 			ecmd->duplex = DUPLEX_HALF;
 	} else {
-		ecmd->speed = -1;
+		ethtool_cmd_speed_set(ecmd, -1);
 		ecmd->duplex = -1;
 	}
 
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index edb3d7e..5f224c3 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -104,10 +104,10 @@ ixgb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	ecmd->transceiver = XCVR_EXTERNAL;
 
 	if (netif_carrier_ok(adapter->netdev)) {
-		ecmd->speed = SPEED_10000;
+		ethtool_cmd_speed_set(ecmd, SPEED_10000);
 		ecmd->duplex = DUPLEX_FULL;
 	} else {
-		ecmd->speed = -1;
+		ethtool_cmd_speed_set(ecmd, -1);
 		ecmd->duplex = -1;
 	}
 
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index e1c3576..01ea04c 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -288,20 +288,20 @@ static int ixgbe_get_settings(struct net_device *netdev,
 	if (link_up) {
 		switch (link_speed) {
 		case IXGBE_LINK_SPEED_10GB_FULL:
-			ecmd->speed = SPEED_10000;
+			ethtool_cmd_speed_set(ecmd, SPEED_10000);
 			break;
 		case IXGBE_LINK_SPEED_1GB_FULL:
-			ecmd->speed = SPEED_1000;
+			ethtool_cmd_speed_set(ecmd, SPEED_1000);
 			break;
 		case IXGBE_LINK_SPEED_100_FULL:
-			ecmd->speed = SPEED_100;
+			ethtool_cmd_speed_set(ecmd, SPEED_100);
 			break;
 		default:
 			break;
 		}
 		ecmd->duplex = DUPLEX_FULL;
 	} else {
-		ecmd->speed = -1;
+		ethtool_cmd_speed_set(ecmd, -1);
 		ecmd->duplex = -1;
 	}
 
diff --git a/drivers/net/ixgbevf/ethtool.c b/drivers/net/ixgbevf/ethtool.c
index 0563ab2..deee375 100644
--- a/drivers/net/ixgbevf/ethtool.c
+++ b/drivers/net/ixgbevf/ethtool.c
@@ -104,11 +104,13 @@ static int ixgbevf_get_settings(struct net_device *netdev,
 	hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
 
 	if (link_up) {
-		ecmd->speed = (link_speed == IXGBE_LINK_SPEED_10GB_FULL) ?
-			       SPEED_10000 : SPEED_1000;
+		ethtool_cmd_speed_set(
+			ecmd,
+			(link_speed == IXGBE_LINK_SPEED_10GB_FULL) ?
+			SPEED_10000 : SPEED_1000);
 		ecmd->duplex = DUPLEX_FULL;
 	} else {
-		ecmd->speed = -1;
+		ethtool_cmd_speed_set(ecmd, -1);
 		ecmd->duplex = -1;
 	}
 
diff --git a/drivers/net/mdio.c b/drivers/net/mdio.c
index 2e717a2..a5039d8 100644
--- a/drivers/net/mdio.c
+++ b/drivers/net/mdio.c
@@ -290,33 +290,36 @@ void mdio45_ethtool_gset_npage(const struct mdio_if_info *mdio,
 		if (modes & (ADVERTISED_10000baseT_Full |
 			     ADVERTISED_10000baseKX4_Full |
 			     ADVERTISED_10000baseKR_Full)) {
-			ecmd->speed = SPEED_10000;
+			ethtool_cmd_speed_set(ecmd, SPEED_10000);
 			ecmd->duplex = DUPLEX_FULL;
 		} else if (modes & (ADVERTISED_1000baseT_Full |
 				    ADVERTISED_1000baseT_Half |
 				    ADVERTISED_1000baseKX_Full)) {
-			ecmd->speed = SPEED_1000;
+			ethtool_cmd_speed_set(ecmd, SPEED_1000);
 			ecmd->duplex = !(modes & ADVERTISED_1000baseT_Half);
 		} else if (modes & (ADVERTISED_100baseT_Full |
 				    ADVERTISED_100baseT_Half)) {
-			ecmd->speed = SPEED_100;
+			ethtool_cmd_speed_set(ecmd, SPEED_100);
 			ecmd->duplex = !!(modes & ADVERTISED_100baseT_Full);
 		} else {
-			ecmd->speed = SPEED_10;
+			ethtool_cmd_speed_set(ecmd, SPEED_10);
 			ecmd->duplex = !!(modes & ADVERTISED_10baseT_Full);
 		}
 	} else {
 		/* Report forced settings */
+		u32 speed;
 		reg = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_PMAPMD,
 				      MDIO_CTRL1);
-		ecmd->speed = (((reg & MDIO_PMA_CTRL1_SPEED1000) ? 100 : 1) *
-			       ((reg & MDIO_PMA_CTRL1_SPEED100) ? 100 : 10));
+		speed = (((reg & MDIO_PMA_CTRL1_SPEED1000) ? 100 : 1)
+			 * ((reg & MDIO_PMA_CTRL1_SPEED100) ? 100 : 10));
 		ecmd->duplex = (reg & MDIO_CTRL1_FULLDPLX ||
-				ecmd->speed == SPEED_10000);
+				speed == SPEED_10000);
+		ethtool_cmd_speed_set(ecmd, speed);
 	}
 
 	/* 10GBASE-T MDI/MDI-X */
-	if (ecmd->port == PORT_TP && ecmd->speed == SPEED_10000) {
+	if (ecmd->port == PORT_TP
+	    && (ethtool_cmd_speed(ecmd) == SPEED_10000)) {
 		switch (mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_PMAPMD,
 					MDIO_PMA_10GBT_SWAPPOL)) {
 		case MDIO_PMA_10GBT_SWAPPOL_ABNX | MDIO_PMA_10GBT_SWAPPOL_CDNX:
diff --git a/drivers/net/mii.c b/drivers/net/mii.c
index e8198ed..4fbc816 100644
--- a/drivers/net/mii.c
+++ b/drivers/net/mii.c
@@ -121,22 +121,25 @@ int mii_ethtool_gset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
 
 		if (nego & (ADVERTISED_1000baseT_Full |
 			    ADVERTISED_1000baseT_Half)) {
-			ecmd->speed = SPEED_1000;
+			ethtool_cmd_speed_set(ecmd, SPEED_1000);
 			ecmd->duplex = !!(nego & ADVERTISED_1000baseT_Full);
 		} else if (nego & (ADVERTISED_100baseT_Full |
 				   ADVERTISED_100baseT_Half)) {
-			ecmd->speed = SPEED_100;
+			ethtool_cmd_speed_set(ecmd, SPEED_100);
 			ecmd->duplex = !!(nego & ADVERTISED_100baseT_Full);
 		} else {
-			ecmd->speed = SPEED_10;
+			ethtool_cmd_speed_set(ecmd, SPEED_10);
 			ecmd->duplex = !!(nego & ADVERTISED_10baseT_Full);
 		}
 	} else {
 		ecmd->autoneg = AUTONEG_DISABLE;
 
-		ecmd->speed = ((bmcr & BMCR_SPEED1000 &&
-				(bmcr & BMCR_SPEED100) == 0) ? SPEED_1000 :
-			       (bmcr & BMCR_SPEED100) ? SPEED_100 : SPEED_10);
+		ethtool_cmd_speed_set(ecmd,
+				      ((bmcr & BMCR_SPEED1000 &&
+					(bmcr & BMCR_SPEED100) == 0) ?
+				       SPEED_1000 :
+				       ((bmcr & BMCR_SPEED100) ?
+					SPEED_100 : SPEED_10)));
 		ecmd->duplex = (bmcr & BMCR_FULLDPLX) ? DUPLEX_FULL : DUPLEX_HALF;
 	}
 
diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/mlx4/en_ethtool.c
index be4a9e0..2e858e4 100644
--- a/drivers/net/mlx4/en_ethtool.c
+++ b/drivers/net/mlx4/en_ethtool.c
@@ -265,10 +265,10 @@ static int mlx4_en_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	trans_type = priv->port_state.transciver;
 	if (netif_carrier_ok(dev)) {
-		cmd->speed = priv->port_state.link_speed;
+		ethtool_cmd_speed_set(cmd, priv->port_state.link_speed);
 		cmd->duplex = DUPLEX_FULL;
 	} else {
-		cmd->speed = -1;
+		ethtool_cmd_speed_set(cmd, -1);
 		cmd->duplex = -1;
 	}
 
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 57c2ac0..a5d9b1c 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1444,13 +1444,13 @@ mv643xx_eth_get_settings_phyless(struct mv643xx_eth_private *mp,
 	cmd->advertising = ADVERTISED_MII;
 	switch (port_status & PORT_SPEED_MASK) {
 	case PORT_SPEED_10:
-		cmd->speed = SPEED_10;
+		ethtool_cmd_speed_set(cmd, SPEED_10);
 		break;
 	case PORT_SPEED_100:
-		cmd->speed = SPEED_100;
+		ethtool_cmd_speed_set(cmd, SPEED_100);
 		break;
 	case PORT_SPEED_1000:
-		cmd->speed = SPEED_1000;
+		ethtool_cmd_speed_set(cmd, SPEED_1000);
 		break;
 	default:
 		cmd->speed = -1;
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index e7f80164..b1358f7 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1644,7 +1644,7 @@ myri10ge_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 	int i;
 
 	cmd->autoneg = AUTONEG_DISABLE;
-	cmd->speed = SPEED_10000;
+	ethtool_cmd_speed_set(cmd, SPEED_10000);
 	cmd->duplex = DUPLEX_FULL;
 
 	/*
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 7633c67..b78be08 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -2820,7 +2820,7 @@ static int netdev_get_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd)
 	u32 tmp;
 
 	ecmd->port        = dev->if_port;
-	ecmd->speed       = np->speed;
+	ethtool_cmd_speed_set(ecmd, np->speed);
 	ecmd->duplex      = np->duplex;
 	ecmd->autoneg     = np->autoneg;
 	ecmd->advertising = 0;
@@ -2878,9 +2878,9 @@ static int netdev_get_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd)
 		tmp = mii_nway_result(
 			np->advertising & mdio_read(dev, MII_LPA));
 		if (tmp == LPA_100FULL || tmp == LPA_100HALF)
-			ecmd->speed  = SPEED_100;
+			ethtool_cmd_speed_set(ecmd, SPEED_100);
 		else
-			ecmd->speed  = SPEED_10;
+			ethtool_cmd_speed_set(ecmd, SPEED_10);
 		if (tmp == LPA_100FULL || tmp == LPA_10FULL)
 			ecmd->duplex = DUPLEX_FULL;
 		else
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index e8d16f6..b34fb74 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -117,7 +117,7 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 
 		ecmd->port = PORT_TP;
 
-		ecmd->speed = adapter->link_speed;
+		ethtool_cmd_speed_set(ecmd, adapter->link_speed);
 		ecmd->duplex = adapter->link_duplex;
 		ecmd->autoneg = adapter->link_autoneg;
 
@@ -134,7 +134,7 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		}
 
 		if (netif_running(dev) && adapter->has_link_events) {
-			ecmd->speed = adapter->link_speed;
+			ethtool_cmd_speed_set(ecmd, adapter->link_speed);
 			ecmd->autoneg = adapter->link_autoneg;
 			ecmd->duplex = adapter->link_duplex;
 			goto skip;
@@ -146,10 +146,10 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 			u16 pcifn = adapter->ahw.pci_func;
 
 			val = NXRD32(adapter, P3_LINK_SPEED_REG(pcifn));
-			ecmd->speed = P3_LINK_SPEED_MHZ *
-					P3_LINK_SPEED_VAL(pcifn, val);
+			ethtool_cmd_speed_set(ecmd, P3_LINK_SPEED_MHZ *
+					      P3_LINK_SPEED_VAL(pcifn, val));
 		} else
-			ecmd->speed = SPEED_10000;
+			ethtool_cmd_speed_set(ecmd, SPEED_10000);
 
 		ecmd->duplex = DUPLEX_FULL;
 		ecmd->autoneg = AUTONEG_DISABLE;
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 524e800..cc25bff 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6844,7 +6844,7 @@ static int niu_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	cmd->supported = lp->supported;
 	cmd->advertising = lp->active_advertising;
 	cmd->autoneg = lp->active_autoneg;
-	cmd->speed = lp->active_speed;
+	ethtool_cmd_speed_set(cmd, lp->active_speed);
 	cmd->duplex = lp->active_duplex;
 	cmd->port = (np->flags & NIU_FLAGS_FIBER) ? PORT_FIBRE : PORT_TP;
 	cmd->transceiver = (np->flags & NIU_FLAGS_XCVR_SERDES) ?
diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index 6667e06..3e4040f 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -1251,7 +1251,7 @@ static int ns83820_get_settings(struct net_device *ndev,
 	/*
 	 * Here's the list of available ethtool commands from other drivers:
 	 *	cmd->advertising =
-	 *	cmd->speed =
+	 *	ethtool_cmd_speed_set(cmd, ...)
 	 *	cmd->duplex =
 	 *	cmd->port = 0;
 	 *	cmd->phy_address =
@@ -1289,13 +1289,13 @@ static int ns83820_get_settings(struct net_device *ndev,
 	cmd->duplex = fullduplex ? DUPLEX_FULL : DUPLEX_HALF;
 	switch (cfg / CFG_SPDSTS0 & 3) {
 	case 2:
-		cmd->speed = SPEED_1000;
+		ethtool_cmd_speed_set(cmd, SPEED_1000);
 		break;
 	case 1:
-		cmd->speed = SPEED_100;
+		ethtool_cmd_speed_set(cmd, SPEED_100);
 		break;
 	default:
-		cmd->speed = SPEED_10;
+		ethtool_cmd_speed_set(cmd, SPEED_10);
 		break;
 	}
 	cmd->autoneg = (tbicr & TBICR_MR_AN_ENABLE)
diff --git a/drivers/net/pch_gbe/pch_gbe_ethtool.c b/drivers/net/pch_gbe/pch_gbe_ethtool.c
index 98587dc..f3556e2 100644
--- a/drivers/net/pch_gbe/pch_gbe_ethtool.c
+++ b/drivers/net/pch_gbe/pch_gbe_ethtool.c
@@ -92,7 +92,7 @@ static int pch_gbe_get_settings(struct net_device *netdev,
 	ecmd->advertising &= ~(ADVERTISED_TP | ADVERTISED_1000baseT_Half);
 
 	if (!netif_carrier_ok(adapter->netdev))
-		ecmd->speed = -1;
+		ethtool_cmd_speed_set(ecmd, -1);
 	return ret;
 }
 
diff --git a/drivers/net/pch_gbe/pch_gbe_phy.c b/drivers/net/pch_gbe/pch_gbe_phy.c
index 9a8207f..28bb960 100644
--- a/drivers/net/pch_gbe/pch_gbe_phy.c
+++ b/drivers/net/pch_gbe/pch_gbe_phy.c
@@ -256,7 +256,7 @@ void pch_gbe_phy_init_setting(struct pch_gbe_hw *hw)
 	if (ret)
 		pr_err("Error: mii_ethtool_gset\n");
 
-	cmd.speed = hw->mac.link_speed;
+	ethtool_cmd_speed_set(&cmd, hw->mac.link_speed);
 	cmd.duplex = hw->mac.link_duplex;
 	cmd.advertising = hw->phy.autoneg_advertised;
 	cmd.autoneg = hw->mac.autoneg;
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index bc71cb2..288e4f1 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -1860,7 +1860,7 @@ static int smc_netdev_get_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd)
     tmp = inw(ioaddr + CONFIG);
     ecmd->port = (tmp & CFG_AUI_SELECT) ? PORT_AUI : PORT_TP;
     ecmd->transceiver = XCVR_INTERNAL;
-    ecmd->speed = SPEED_10;
+    ethtool_cmd_speed_set(ecmd, SPEED_10);
     ecmd->phy_address = ioaddr + MGMT;
 
     SMC_SELECT_BANK(0);
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index e3f3501..a475957 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -288,7 +288,7 @@ int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 
 	cmd->advertising = phydev->advertising;
 
-	cmd->speed = phydev->speed;
+	ethtool_cmd_speed_set(cmd, phydev->speed);
 	cmd->duplex = phydev->duplex;
 	cmd->port = PORT_MII;
 	cmd->phy_address = phydev->addr;
diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index 4383ed2..b1f251d 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -1243,17 +1243,17 @@ static int gelic_ether_get_settings(struct net_device *netdev,
 
 	switch (card->ether_port_status & GELIC_LV1_ETHER_SPEED_MASK) {
 	case GELIC_LV1_ETHER_SPEED_10:
-		cmd->speed = SPEED_10;
+		ethtool_cmd_speed_set(cmd, SPEED_10);
 		break;
 	case GELIC_LV1_ETHER_SPEED_100:
-		cmd->speed = SPEED_100;
+		ethtool_cmd_speed_set(cmd, SPEED_100);
 		break;
 	case GELIC_LV1_ETHER_SPEED_1000:
-		cmd->speed = SPEED_1000;
+		ethtool_cmd_speed_set(cmd, SPEED_1000);
 		break;
 	default:
 		pr_info("%s: speed unknown\n", __func__);
-		cmd->speed = SPEED_10;
+		ethtool_cmd_speed_set(cmd, SPEED_10);
 		break;
 	}
 
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index f3f737b..d495a68 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -1725,7 +1725,7 @@ static int ql_get_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 	}
 	ecmd->advertising = ql_supported_modes(qdev);
 	ecmd->autoneg = ql_get_auto_cfg_status(qdev);
-	ecmd->speed = ql_get_speed(qdev);
+	ethtool_cmd_speed_set(ecmd, ql_get_speed(qdev));
 	ecmd->duplex = ql_get_full_dup(qdev);
 	return 0;
 }
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 61a4a7a..5a69284 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -166,7 +166,7 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 				     ADVERTISED_1000baseT_Half |
 				     ADVERTISED_1000baseT_Full);
 
-		ecmd->speed = adapter->link_speed;
+		ethtool_cmd_speed_set(ecmd, adapter->link_speed);
 		ecmd->duplex = adapter->link_duplex;
 		ecmd->autoneg = adapter->link_autoneg;
 
@@ -183,15 +183,15 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		}
 
 		if (netif_running(dev) && adapter->has_link_events) {
-			ecmd->speed = adapter->link_speed;
+			ethtool_cmd_speed_set(ecmd, adapter->link_speed);
 			ecmd->autoneg = adapter->link_autoneg;
 			ecmd->duplex = adapter->link_duplex;
 			goto skip;
 		}
 
 		val = QLCRD32(adapter, P3P_LINK_SPEED_REG(pcifn));
-		ecmd->speed = P3P_LINK_SPEED_MHZ *
-			P3P_LINK_SPEED_VAL(pcifn, val);
+		ethtool_cmd_speed_set(ecmd, P3P_LINK_SPEED_MHZ *
+				      P3P_LINK_SPEED_VAL(pcifn, val));
 		ecmd->duplex = DUPLEX_FULL;
 		ecmd->autoneg = AUTONEG_DISABLE;
 	} else
diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_ethtool.c
index 78dc40c..19b00fa 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -356,7 +356,7 @@ static int ql_get_settings(struct net_device *ndev,
 		ecmd->port = PORT_FIBRE;
 	}
 
-	ecmd->speed = SPEED_10000;
+	ethtool_cmd_speed_set(ecmd, SPEED_10000);
 	ecmd->duplex = DUPLEX_FULL;
 
 	return 0;
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 7bfcf95..57e0636 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1423,7 +1423,7 @@ static int rtl8169_gset_tbi(struct net_device *dev, struct ethtool_cmd *cmd)
 	cmd->advertising = (status & TBINwEnable) ?  ADVERTISED_Autoneg : 0;
 	cmd->autoneg = !!(status & TBINwEnable);
 
-	cmd->speed = SPEED_1000;
+	ethtool_cmd_speed_set(cmd, SPEED_1000);
 	cmd->duplex = DUPLEX_FULL; /* Always set */
 
 	return 0;
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 5443985..89cfee7 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -5414,10 +5414,10 @@ static int s2io_ethtool_gset(struct net_device *dev, struct ethtool_cmd *info)
 	info->transceiver = XCVR_EXTERNAL;
 
 	if (netif_carrier_ok(sp->dev)) {
-		info->speed = 10000;
+		ethtool_cmd_speed_set(info, SPEED_10000);
 		info->duplex = DUPLEX_FULL;
 	} else {
-		info->speed = -1;
+		ethtool_cmd_speed_set(info, -1);
 		info->duplex = -1;
 	}
 
diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index f3ffc1d..fa74314 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -1173,7 +1173,8 @@ static int sc92031_ethtool_get_settings(struct net_device *dev,
 	if (phy_ctrl & PhyCtrlAne)
 		cmd->advertising |= ADVERTISED_Autoneg;
 
-	cmd->speed = (output_status & 0x2) ? SPEED_100 : SPEED_10;
+	ethtool_cmd_speed_set(cmd,
+			      (output_status & 0x2) ? SPEED_100 : SPEED_10);
 	cmd->duplex = (output_status & 0x4) ? DUPLEX_FULL : DUPLEX_HALF;
 	cmd->port = PORT_MII;
 	cmd->phy_address = phy_address;
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 10b160a..8c5e005 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -219,7 +219,7 @@ static int efx_ethtool_get_settings(struct net_device *net_dev,
 	ecmd->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
 
 	if (LOOPBACK_INTERNAL(efx)) {
-		ecmd->speed = link_state->speed;
+		ethtool_cmd_speed_set(ecmd, link_state->speed);
 		ecmd->duplex = link_state->fd ? DUPLEX_FULL : DUPLEX_HALF;
 	}
 
diff --git a/drivers/net/sfc/mcdi_phy.c b/drivers/net/sfc/mcdi_phy.c
index 6c5fccb..6c63ab0 100644
--- a/drivers/net/sfc/mcdi_phy.c
+++ b/drivers/net/sfc/mcdi_phy.c
@@ -513,7 +513,7 @@ static void efx_mcdi_phy_get_settings(struct efx_nic *efx, struct ethtool_cmd *e
 	ecmd->supported =
 		mcdi_to_ethtool_cap(phy_cfg->media, phy_cfg->supported_cap);
 	ecmd->advertising = efx->link_advertising;
-	ecmd->speed = efx->link_state.speed;
+	ethtool_cmd_speed_set(ecmd, efx->link_state.speed);
 	ecmd->duplex = efx->link_state.fd;
 	ecmd->port = mcdi_to_ethtool_media(phy_cfg->media);
 	ecmd->phy_address = phy_cfg->port;
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 204ecda..7b0fd89 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -460,7 +460,7 @@ tenxpress_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 	/* In loopback, the PHY automatically brings up the correct interface,
 	 * but doesn't advertise the correct speed. So override it */
 	if (LOOPBACK_EXTERNAL(efx))
-		ecmd->speed = SPEED_10000;
+		ethtool_cmd_speed_set(ecmd, SPEED_10000);
 }
 
 static int tenxpress_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index b0fa999..56a1899 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -303,7 +303,7 @@ static int skge_get_settings(struct net_device *dev,
 
 	ecmd->advertising = skge->advertising;
 	ecmd->autoneg = skge->autoneg;
-	ecmd->speed = skge->speed;
+	ethtool_cmd_speed_set(ecmd, skge->speed);
 	ecmd->duplex = skge->duplex;
 	return 0;
 }
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 40afe07..66f5db6 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3413,10 +3413,10 @@ static int sky2_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	ecmd->phy_address = PHY_ADDR_MARV;
 	if (sky2_is_copper(hw)) {
 		ecmd->port = PORT_TP;
-		ecmd->speed = sky2->speed;
+		ethtool_cmd_speed_set(ecmd, sky2->speed);
 		ecmd->supported |=  SUPPORTED_Autoneg | SUPPORTED_TP;
 	} else {
-		ecmd->speed = SPEED_1000;
+		ethtool_cmd_speed_set(ecmd, SPEED_1000);
 		ecmd->port = PORT_FIBRE;
 		ecmd->supported |=  SUPPORTED_Autoneg | SUPPORTED_FIBRE;
 	}
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 66831f3..053863a 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -1488,9 +1488,9 @@ smc911x_ethtool_getsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 				SUPPORTED_TP | SUPPORTED_AUI;
 
 		if (lp->ctl_rspeed == 10)
-			cmd->speed = SPEED_10;
+			ethtool_cmd_speed_set(cmd, SPEED_10);
 		else if (lp->ctl_rspeed == 100)
-			cmd->speed = SPEED_100;
+			ethtool_cmd_speed_set(cmd, SPEED_100);
 
 		cmd->autoneg = AUTONEG_DISABLE;
 		if (lp->mii.phy_id==1)
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 43654a3..dc4805f 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -1565,9 +1565,9 @@ smc_ethtool_getsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 				 SUPPORTED_TP | SUPPORTED_AUI;
 
 		if (lp->ctl_rspeed == 10)
-			cmd->speed = SPEED_10;
+			ethtool_cmd_speed_set(cmd, SPEED_10);
 		else if (lp->ctl_rspeed == 100)
-			cmd->speed = SPEED_100;
+			ethtool_cmd_speed_set(cmd, SPEED_100);
 
 		cmd->autoneg = AUTONEG_DISABLE;
 		cmd->transceiver = XCVR_INTERNAL;
diff --git a/drivers/net/spider_net_ethtool.c b/drivers/net/spider_net_ethtool.c
index d723fca..9c288cd 100644
--- a/drivers/net/spider_net_ethtool.c
+++ b/drivers/net/spider_net_ethtool.c
@@ -58,7 +58,7 @@ spider_net_ethtool_get_settings(struct net_device *netdev,
 	cmd->advertising = (ADVERTISED_1000baseT_Full |
 			     ADVERTISED_FIBRE);
 	cmd->port = PORT_FIBRE;
-	cmd->speed = card->phy.speed;
+	ethtool_cmd_speed_set(cmd, card->phy.speed);
 	cmd->duplex = DUPLEX_FULL;
 
 	return 0;
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 40a755d..ab59300 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -2642,7 +2642,7 @@ static int gem_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		/* Return current PHY settings */
 		spin_lock_irq(&gp->lock);
 		cmd->autoneg = gp->want_autoneg;
-		cmd->speed = gp->phy_mii.speed;
+		ethtool_cmd_speed_set(cmd, gp->phy_mii.speed);
 		cmd->duplex = gp->phy_mii.duplex;
 		cmd->advertising = gp->phy_mii.advertising;
 
@@ -2659,7 +2659,7 @@ static int gem_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			 SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
 			 SUPPORTED_Autoneg);
 		cmd->advertising = cmd->supported;
-		cmd->speed = 0;
+		ethtool_cmd_speed_set(cmd, 0);
 		cmd->duplex = cmd->port = cmd->phy_address =
 			cmd->transceiver = cmd->autoneg = 0;
 
@@ -2673,7 +2673,7 @@ static int gem_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			cmd->advertising = cmd->supported;
 			cmd->transceiver = XCVR_INTERNAL;
 			if (gp->lstate == link_up)
-				cmd->speed = SPEED_1000;
+				ethtool_cmd_speed_set(cmd, SPEED_1000);
 			cmd->duplex = DUPLEX_FULL;
 			cmd->autoneg = 1;
 		}
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 8f3f028..d381a0f 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2401,6 +2401,7 @@ static void happy_meal_set_multicast(struct net_device *dev)
 static int hme_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct happy_meal *hp = netdev_priv(dev);
+	u32 speed;
 
 	cmd->supported =
 		(SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
@@ -2420,10 +2421,9 @@ static int hme_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	if (hp->sw_bmcr & BMCR_ANENABLE) {
 		cmd->autoneg = AUTONEG_ENABLE;
-		cmd->speed =
-			(hp->sw_lpa & (LPA_100HALF | LPA_100FULL)) ?
-			SPEED_100 : SPEED_10;
-		if (cmd->speed == SPEED_100)
+		speed = ((hp->sw_lpa & (LPA_100HALF | LPA_100FULL)) ?
+			 SPEED_100 : SPEED_10);
+		if (speed == SPEED_100)
 			cmd->duplex =
 				(hp->sw_lpa & (LPA_100FULL)) ?
 				DUPLEX_FULL : DUPLEX_HALF;
@@ -2433,13 +2433,12 @@ static int hme_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 				DUPLEX_FULL : DUPLEX_HALF;
 	} else {
 		cmd->autoneg = AUTONEG_DISABLE;
-		cmd->speed =
-			(hp->sw_bmcr & BMCR_SPEED100) ?
-			SPEED_100 : SPEED_10;
+		speed = (hp->sw_bmcr & BMCR_SPEED100) ? SPEED_100 : SPEED_10;
 		cmd->duplex =
 			(hp->sw_bmcr & BMCR_FULLDPLX) ?
 			DUPLEX_FULL : DUPLEX_HALF;
 	}
+	ethtool_cmd_speed_set(cmd, speed);
 	return 0;
 }
 
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 8be71de..80fbee0 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -2151,7 +2151,7 @@ static int bdx_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 
 	ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
 	ecmd->advertising = (ADVERTISED_10000baseT_Full | ADVERTISED_FIBRE);
-	ecmd->speed = SPEED_10000;
+	ethtool_cmd_speed_set(ecmd, SPEED_10000);
 	ecmd->duplex = DUPLEX_FULL;
 	ecmd->port = PORT_FIBRE;
 	ecmd->transceiver = XCVR_EXTERNAL;	/* what does it mean? */
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 84f62af..e8141c4 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10027,10 +10027,10 @@ static int tg3_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	cmd->advertising = tp->link_config.advertising;
 	if (netif_running(dev)) {
-		cmd->speed = tp->link_config.active_speed;
+		ethtool_cmd_speed_set(cmd, tp->link_config.active_speed);
 		cmd->duplex = tp->link_config.active_duplex;
 	} else {
-		cmd->speed = SPEED_INVALID;
+		ethtool_cmd_speed_set(cmd, SPEED_INVALID);
 		cmd->duplex = DUPLEX_INVALID;
 	}
 	cmd->phy_address = tp->phy_addr;
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index f8d26bf..ab78e1d 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -1518,15 +1518,15 @@ static int __de_get_settings(struct de_private *de, struct ethtool_cmd *ecmd)
 	switch (de->media_type) {
 	case DE_MEDIA_AUI:
 		ecmd->port = PORT_AUI;
-		ecmd->speed = 5;
+		ethtool_cmd_speed_set(ecmd, 5);
 		break;
 	case DE_MEDIA_BNC:
 		ecmd->port = PORT_BNC;
-		ecmd->speed = 2;
+		ethtool_cmd_speed_set(ecmd, 2);
 		break;
 	default:
 		ecmd->port = PORT_TP;
-		ecmd->speed = SPEED_10;
+		ethtool_cmd_speed_set(ecmd, SPEED_10);
 		break;
 	}
 
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index 74217db..a4375c4 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -945,12 +945,12 @@ ULi_ethtool_gset(struct uli526x_board_info *db, struct ethtool_cmd *ecmd)
 
 	ecmd->transceiver = XCVR_EXTERNAL;
 
-	ecmd->speed = 10;
+	ethtool_cmd_speed_set(ecmd, SPEED_10);
 	ecmd->duplex = DUPLEX_HALF;
 
 	if(db->op_mode==ULI526X_100MHF || db->op_mode==ULI526X_100MFD)
 	{
-		ecmd->speed = 100;
+		ethtool_cmd_speed_set(ecmd, SPEED_100);
 	}
 	if(db->op_mode==ULI526X_10MFD || db->op_mode==ULI526X_100MFD)
 	{
@@ -958,7 +958,7 @@ ULi_ethtool_gset(struct uli526x_board_info *db, struct ethtool_cmd *ecmd)
 	}
 	if(db->link_failed)
 	{
-		ecmd->speed = -1;
+		ethtool_cmd_speed_set(ecmd, -1);
 		ecmd->duplex = -1;
 	}
 
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index ade3cf9..0636f70 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1553,7 +1553,7 @@ static int tun_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	cmd->supported		= 0;
 	cmd->advertising	= 0;
-	cmd->speed		= SPEED_10;
+	ethtool_cmd_speed_set(cmd, SPEED_10);
 	cmd->duplex		= DUPLEX_FULL;
 	cmd->port		= PORT_TP;
 	cmd->phy_address	= 0;
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 9f11c11..3de4283 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1050,7 +1050,7 @@ typhoon_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	/* need to get stats to make these link speed/duplex valid */
 	typhoon_do_get_stats(tp);
-	cmd->speed = tp->speed;
+	ethtool_cmd_speed_set(cmd, tp->speed);
 	cmd->duplex = tp->duplex;
 	cmd->phy_address = 0;
 	cmd->transceiver = XCVR_INTERNAL;
diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index 97687d3..d7221c4 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -686,7 +686,7 @@ static int catc_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	cmd->supported = SUPPORTED_10baseT_Half | SUPPORTED_TP;
 	cmd->advertising = ADVERTISED_10baseT_Half | ADVERTISED_TP;
-	cmd->speed = SPEED_10;
+	ethtool_cmd_speed_set(cmd, SPEED_10);
 	cmd->duplex = DUPLEX_HALF;
 	cmd->port = PORT_TP; 
 	cmd->phy_address = 0;
diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index e85c89c..041fb7d 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -843,10 +843,11 @@ static int rtl8150_get_settings(struct net_device *netdev, struct ethtool_cmd *e
 	get_registers(dev, BMCR, 2, &bmcr);
 	get_registers(dev, ANLP, 2, &lpa);
 	if (bmcr & BMCR_ANENABLE) {
+		u32 speed = ((lpa & (LPA_100HALF | LPA_100FULL)) ?
+			     SPEED_100 : SPEED_10);
+		ethtool_cmd_speed_set(ecmd, speed);
 		ecmd->autoneg = AUTONEG_ENABLE;
-		ecmd->speed = (lpa & (LPA_100HALF | LPA_100FULL)) ?
-			     SPEED_100 : SPEED_10;
-		if (ecmd->speed == SPEED_100)
+		if (speed == SPEED_100)
 			ecmd->duplex = (lpa & LPA_100FULL) ?
 			    DUPLEX_FULL : DUPLEX_HALF;
 		else
@@ -854,8 +855,8 @@ static int rtl8150_get_settings(struct net_device *netdev, struct ethtool_cmd *e
 			    DUPLEX_FULL : DUPLEX_HALF;
 	} else {
 		ecmd->autoneg = AUTONEG_DISABLE;
-		ecmd->speed = (bmcr & BMCR_SPEED100) ?
-		    SPEED_100 : SPEED_10;
+		ethtool_cmd_speed_set(ecmd, ((bmcr & BMCR_SPEED100) ?
+					     SPEED_100 : SPEED_10));
 		ecmd->duplex = (bmcr & BMCR_FULLDPLX) ?
 		    DUPLEX_FULL : DUPLEX_HALF;
 	}
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 6542288..cbe953a 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -52,7 +52,7 @@ static int veth_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	cmd->supported		= 0;
 	cmd->advertising	= 0;
-	cmd->speed		= SPEED_10000;
+	ethtool_cmd_speed_set(cmd, SPEED_10000);
 	cmd->duplex		= DUPLEX_FULL;
 	cmd->port		= PORT_TP;
 	cmd->phy_address	= 0;
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 9a8f116..06daa9d 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -3182,7 +3182,8 @@ static void velocity_ethtool_down(struct net_device *dev)
 		pci_set_power_state(vptr->pdev, PCI_D3hot);
 }
 
-static int velocity_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int velocity_get_settings(struct net_device *dev,
+				 struct ethtool_cmd *cmd)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
 	struct mac_regs __iomem *regs = vptr->mac_regs;
@@ -3228,12 +3229,14 @@ static int velocity_get_settings(struct net_device *dev, struct ethtool_cmd *cmd
 			break;
 		}
 	}
+
 	if (status & VELOCITY_SPEED_1000)
-		cmd->speed = SPEED_1000;
+		ethtool_cmd_speed_set(cmd, SPEED_1000);
 	else if (status & VELOCITY_SPEED_100)
-		cmd->speed = SPEED_100;
+		ethtool_cmd_speed_set(cmd, SPEED_100);
 	else
-		cmd->speed = SPEED_10;
+		ethtool_cmd_speed_set(cmd, SPEED_10);
+
 	cmd->autoneg = (status & VELOCITY_AUTONEG_ENABLE) ? AUTONEG_ENABLE : AUTONEG_DISABLE;
 	cmd->port = PORT_TP;
 	cmd->transceiver = XCVR_INTERNAL;
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index 70c1ab9..64303eb 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -424,10 +424,10 @@ vmxnet3_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	ecmd->transceiver = XCVR_INTERNAL;
 
 	if (adapter->link_speed) {
-		ecmd->speed = adapter->link_speed;
+		ethtool_cmd_speed_set(ecmd, adapter->link_speed);
 		ecmd->duplex = DUPLEX_FULL;
 	} else {
-		ecmd->speed = -1;
+		ethtool_cmd_speed_set(ecmd, -1);
 		ecmd->duplex = -1;
 	}
 	return 0;
diff --git a/drivers/net/vxge/vxge-ethtool.c b/drivers/net/vxge/vxge-ethtool.c
index a70874e..92dd72d 100644
--- a/drivers/net/vxge/vxge-ethtool.c
+++ b/drivers/net/vxge/vxge-ethtool.c
@@ -59,10 +59,10 @@ static int vxge_ethtool_gset(struct net_device *dev, struct ethtool_cmd *info)
 	info->transceiver = XCVR_EXTERNAL;
 
 	if (netif_carrier_ok(dev)) {
-		info->speed = SPEED_10000;
+		ethtool_cmd_speed_set(info, SPEED_10000);
 		info->duplex = DUPLEX_FULL;
 	} else {
-		info->speed = -1;
+		ethtool_cmd_speed_set(info, -1);
 		info->duplex = -1;
 	}
 
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index f4d80ad..eeabbb8 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -697,7 +697,7 @@ static int bat_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	cmd->supported = 0;
 	cmd->advertising = 0;
-	cmd->speed = SPEED_10;
+	ethtool_cmd_speed_set(cmd, SPEED_10);
 	cmd->duplex = DUPLEX_FULL;
 	cmd->port = PORT_TP;
 	cmd->phy_address = 0;
-- 
1.7.3.1

