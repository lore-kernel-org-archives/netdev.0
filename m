From: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Subject: [RFC PATCH 17/17] phy_device: Rename phy_start_aneg() to
	phy_start_link()
Date: Thu, 20 Oct 2011 17:00:24 -0400
Message-ID: <1319144425-15547-18-git-send-email-Kyle.D.Moffett@boeing.com>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-doc@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	David Decotigny <decot@google.com>, devel@driverdev.osuosl.org,
	Matt Carlson <mcarlson@broadcom.com>,
	Kyle Moffett <Kyle.D.Moffett@boeing.com>,
	Kuninori Morimoto <morimoto.kuninori@renesas.com>,
	Li Yang <leoli@freescale.com>, Alexey Dobriyan <adobriyan@gmail.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Mike Frysinger <vapier@gentoo.org>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Michael Chan <mchan@broadcom.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	John Crispin <blogic@openwrt.org>,
	Kristoffer Glembo <kristoffer@gaisler.com>, Ilya Yanok <yanok@emcraft.com>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>,
	Greg Kroah-Hartman <gregkh@suse.de>, Ralf Baechle <ralf@linux-mips.org>,
	Christian Dietrich <christ
To: linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

The name of the "phy_start_aneg()" function is very confusing, because
it also handles forced-mode (AUTONEG_DISABLE) links.

Rename the function to phy_start_link() and fix up all users.

Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>
---
 Documentation/networking/phy.txt       |    2 +-
 drivers/net/arm/ixp4xx_eth.c           |    2 +-
 drivers/net/dnet.c                     |    2 +-
 drivers/net/greth.c                    |    2 +-
 drivers/net/lantiq_etop.c              |    2 +-
 drivers/net/mv643xx_eth.c              |    2 +-
 drivers/net/octeon/octeon_mgmt.c       |    2 +-
 drivers/net/phy/phy.c                  |   12 ++++++------
 drivers/net/pxa168_eth.c               |    2 +-
 drivers/net/sh_eth.c                   |    2 +-
 drivers/net/smsc911x.c                 |    2 +-
 drivers/net/smsc9420.c                 |    2 +-
 drivers/net/stmmac/stmmac_ethtool.c    |    2 +-
 drivers/net/tg3.c                      |    8 ++++----
 drivers/net/ucc_geth_ethtool.c         |    2 +-
 drivers/staging/octeon/ethernet-mdio.c |    4 ++--
 include/linux/phy.h                    |    2 +-
 net/dsa/slave.c                        |    2 +-
 18 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index 0db8c81..6f862e5 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -190,7 +190,7 @@ Doing it all yourself
    driver if none was found during bus initialization.  Passes in
    any phy-specific flags as needed.
 
- int phy_start_aneg(struct phy_device *phydev);
+ int phy_start_link(struct phy_device *phydev);
    
    Using variables inside the phydev structure, either configures advertising
    and resets autonegotiation, or disables autonegotiation, and configures
diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
index de51e84..8864be5 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -998,7 +998,7 @@ static int ixp4xx_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 static int ixp4xx_nway_reset(struct net_device *dev)
 {
 	struct port *port = netdev_priv(dev);
-	return phy_start_aneg(port->phydev);
+	return phy_start_link(port->phydev);
 }
 
 static const struct ethtool_ops ixp4xx_ethtool_ops = {
diff --git a/drivers/net/dnet.c b/drivers/net/dnet.c
index c1063d1..edb4635 100644
--- a/drivers/net/dnet.c
+++ b/drivers/net/dnet.c
@@ -669,7 +669,7 @@ static int dnet_open(struct net_device *dev)
 	napi_enable(&bp->napi);
 	dnet_init_hw(bp);
 
-	phy_start_aneg(bp->phy_dev);
+	phy_start_link(bp->phy_dev);
 
 	/* schedule a link state check */
 	phy_start(bp->phy_dev);
diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index e7f268f..0ad3f14 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -1363,7 +1363,7 @@ static int greth_mdio_init(struct greth_private *greth)
 
 	/* If Ethernet debug link is used make autoneg happen right away */
 	if (greth->edcl && greth_edcl == 1) {
-		phy_start_aneg(greth->phy);
+		phy_start_link(greth->phy);
 		timeout = jiffies + 6*HZ;
 		while (!phy_aneg_done(greth->phy) && time_before(jiffies, timeout)) {
 		}
diff --git a/drivers/net/lantiq_etop.c b/drivers/net/lantiq_etop.c
index 45f252b..c8795aa 100644
--- a/drivers/net/lantiq_etop.c
+++ b/drivers/net/lantiq_etop.c
@@ -326,7 +326,7 @@ ltq_etop_nway_reset(struct net_device *dev)
 {
 	struct ltq_etop_priv *priv = netdev_priv(dev);
 
-	return phy_start_aneg(priv->phydev);
+	return phy_start_link(priv->phydev);
 }
 
 static const struct ethtool_ops ltq_etop_ethtool_ops = {
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index d3e223c..0ce514c 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2775,7 +2775,7 @@ static void phy_init(struct mv643xx_eth_private *mp, int speed, int duplex)
 		phy->speed = speed;
 		phy->duplex = duplex;
 	}
-	phy_start_aneg(phy);
+	phy_start_link(phy);
 }
 
 static void init_pscr(struct mv643xx_eth_private *mp, int speed, int duplex)
diff --git a/drivers/net/octeon/octeon_mgmt.c b/drivers/net/octeon/octeon_mgmt.c
index 429e08c..fcdf28a 100644
--- a/drivers/net/octeon/octeon_mgmt.c
+++ b/drivers/net/octeon/octeon_mgmt.c
@@ -686,7 +686,7 @@ static int octeon_mgmt_init_phy(struct net_device *netdev)
 		return -1;
 	}
 
-	phy_start_aneg(p->phydev);
+	phy_start_link(p->phydev);
 
 	return 0;
 }
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 5f72055..fc486fe 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -232,7 +232,7 @@ static void phy_sanitize_settings(struct phy_device *phydev)
  * A few notes about parameter checking:
  * - We don't set port or transceiver, so we don't care what they
  *   were set to.
- * - phy_start_aneg() will make sure forced settings are sane, and
+ * - phy_start_link() will make sure forced settings are sane, and
  *   choose the next best ones from the ones selected, so we don't
  *   care if ethtool tries to give us bad values.
  */
@@ -276,7 +276,7 @@ int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 	phydev->duplex = cmd->duplex;
 
 	/* Restart the PHY */
-	phy_start_aneg(phydev);
+	phy_start_link(phydev);
 
 	return 0;
 }
@@ -384,7 +384,7 @@ int phy_mii_ioctl(struct phy_device *phydev,
 EXPORT_SYMBOL(phy_mii_ioctl);
 
 /**
- * phy_start_aneg - start auto-negotiation for this PHY device
+ * phy_start_link - start auto-negotiation for this PHY device
  * @phydev: the phy_device struct
  *
  * Description: Sanitizes the settings (if we're not autonegotiating
@@ -392,7 +392,7 @@ EXPORT_SYMBOL(phy_mii_ioctl);
  *   If the PHYCONTROL Layer is operating, we change the state to
  *   reflect the beginning of Auto-negotiation or forcing.
  */
-int phy_start_aneg(struct phy_device *phydev)
+int phy_start_link(struct phy_device *phydev)
 {
 	int err;
 
@@ -423,7 +423,7 @@ out_unlock:
 	mutex_unlock(&phydev->lock);
 	return err;
 }
-EXPORT_SYMBOL(phy_start_aneg);
+EXPORT_SYMBOL(phy_start_link);
 
 
 static void phy_change(struct work_struct *work);
@@ -970,7 +970,7 @@ void phy_state_machine(struct work_struct *work)
 	mutex_unlock(&phydev->lock);
 
 	if (needs_aneg)
-		err = phy_start_aneg(phydev);
+		err = phy_start_link(phydev);
 
 	if (err < 0)
 		phy_error(phydev);
diff --git a/drivers/net/pxa168_eth.c b/drivers/net/pxa168_eth.c
index ab3bca9..8f3d751 100644
--- a/drivers/net/pxa168_eth.c
+++ b/drivers/net/pxa168_eth.c
@@ -1390,7 +1390,7 @@ static void phy_init(struct pxa168_eth_private *pep, int speed, int duplex)
 		phy->speed = speed;
 		phy->duplex = duplex;
 	}
-	phy_start_aneg(phy);
+	phy_start_link(phy);
 }
 
 static int ethernet_phy_setup(struct net_device *dev)
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 7ef4378..0927b1b 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -1291,7 +1291,7 @@ static int sh_eth_nway_reset(struct net_device *ndev)
 	int ret;
 
 	spin_lock_irqsave(&mdp->lock, flags);
-	ret = phy_start_aneg(mdp->phydev);
+	ret = phy_start_link(mdp->phydev);
 	spin_unlock_irqrestore(&mdp->lock, flags);
 
 	return ret;
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index b9016a3..0b5bb15 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1712,7 +1712,7 @@ static int smsc911x_ethtool_nwayreset(struct net_device *dev)
 {
 	struct smsc911x_data *pdata = netdev_priv(dev);
 
-	return phy_start_aneg(pdata->phy_dev);
+	return phy_start_link(pdata->phy_dev);
 }
 
 static u32 smsc911x_ethtool_getmsglevel(struct net_device *dev)
diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index 459726f..fb9e160 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -302,7 +302,7 @@ static int smsc9420_ethtool_nway_reset(struct net_device *netdev)
 	if (!pd->phy_dev)
 		return -ENODEV;
 
-	return phy_start_aneg(pd->phy_dev);
+	return phy_start_link(pd->phy_dev);
 }
 
 static int smsc9420_ethtool_getregslen(struct net_device *dev)
diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/stmmac_ethtool.c
index 7ed8fb6..68e107b 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -240,7 +240,7 @@ stmmac_set_pauseparam(struct net_device *netdev,
 
 	if (phy->autoneg) {
 		if (netif_running(netdev))
-			ret = phy_start_aneg(phy);
+			ret = phy_start_link(phy);
 	} else
 		priv->hw->mac->flow_ctrl(priv->ioaddr, phy->duplex,
 					 priv->flow_ctrl, priv->pause);
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4a1374d..a317d11 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1661,7 +1661,7 @@ static void tg3_phy_start(struct tg3 *tp)
 
 	phy_start(phydev);
 
-	phy_start_aneg(phydev);
+	phy_start_link(phydev);
 }
 
 static void tg3_phy_stop(struct tg3 *tp)
@@ -2848,7 +2848,7 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 
 			phydev->advertising = advertising;
 
-			phy_start_aneg(phydev);
+			phy_start_link(phydev);
 
 			phyid = phydev->drv->phy_id & phydev->drv->phy_id_mask;
 			if (phyid != PHY_ID_BCMAC131) {
@@ -10340,7 +10340,7 @@ static int tg3_nway_reset(struct net_device *dev)
 	if (tg3_flag(tp, USE_PHYLIB)) {
 		if (!(tp->phy_flags & TG3_PHYFLG_IS_CONNECTED))
 			return -EAGAIN;
-		r = phy_start_aneg(tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR]);
+		r = phy_start_link(tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR]);
 	} else {
 		u32 bmcr;
 
@@ -10500,7 +10500,7 @@ static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam
 					 * tg3_adjust_link() do the final
 					 * flow control setup.
 					 */
-					return phy_start_aneg(phydev);
+					return phy_start_link(phydev);
 				}
 			}
 
diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
index a97257f..68a8743 100644
--- a/drivers/net/ucc_geth_ethtool.c
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -342,7 +342,7 @@ static int uec_nway_reset(struct net_device *netdev)
 {
 	struct ucc_geth_private *ugeth = netdev_priv(netdev);
 
-	return phy_start_aneg(ugeth->phydev);
+	return phy_start_link(ugeth->phydev);
 }
 
 /* Report driver information */
diff --git a/drivers/staging/octeon/ethernet-mdio.c b/drivers/staging/octeon/ethernet-mdio.c
index f18e3e1..dc152dd 100644
--- a/drivers/staging/octeon/ethernet-mdio.c
+++ b/drivers/staging/octeon/ethernet-mdio.c
@@ -81,7 +81,7 @@ static int cvm_oct_nway_reset(struct net_device *dev)
 		return -EPERM;
 
 	if (priv->phydev)
-		return phy_start_aneg(priv->phydev);
+		return phy_start_link(priv->phydev);
 
 	return -EINVAL;
 }
@@ -176,7 +176,7 @@ int cvm_oct_phy_setup_device(struct net_device *dev)
 			return -1;
 		}
 		priv->last_link = 0;
-		phy_start_aneg(priv->phydev);
+		phy_start_link(priv->phydev);
 	}
 	return 0;
 }
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 3713c8d..45f6ee8 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -511,7 +511,7 @@ void phy_disconnect(struct phy_device *phydev);
 void phy_detach(struct phy_device *phydev);
 void phy_start(struct phy_device *phydev);
 void phy_stop(struct phy_device *phydev);
-int phy_start_aneg(struct phy_device *phydev);
+int phy_start_link(struct phy_device *phydev);
 
 int phy_stop_interrupts(struct phy_device *phydev);
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 0a47b6c..90ff96d 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -400,7 +400,7 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		p->phy->speed = 0;
 		p->phy->duplex = 0;
 		p->phy->advertising = p->phy->supported | ADVERTISED_Autoneg;
-		phy_start_aneg(p->phy);
+		phy_start_link(p->phy);
 	}
 
 	return slave_dev;
-- 
1.7.2.5
