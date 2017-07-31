From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 11/11] net: dsa: rename switch EEE ops
Date: Mon, 31 Jul 2017 18:17:19 -0400
Message-ID: <20170731221719.16695-12-vivien.didelot@savoirfairelinux.com>
References: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To avoid confusion with the PHY EEE settings, rename the .set_eee and
.get_eee ops to respectively .set_mac_eee and .get_mac_eee.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/bcm_sf2.c | 12 ++++++------
 drivers/net/dsa/qca8k.c   |  4 ++--
 include/net/dsa.h         | 10 +++++-----
 net/dsa/slave.c           |  8 ++++----
 4 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index ce886345d8d2..6bbfa6ea1efb 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -338,8 +338,8 @@ static int bcm_sf2_eee_init(struct dsa_switch *ds, int port,
 	return 1;
 }
 
-static int bcm_sf2_sw_get_eee(struct dsa_switch *ds, int port,
-			      struct ethtool_eee *e)
+static int bcm_sf2_sw_get_mac_eee(struct dsa_switch *ds, int port,
+				  struct ethtool_eee *e)
 {
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	struct ethtool_eee *p = &priv->port_sts[port].eee;
@@ -352,8 +352,8 @@ static int bcm_sf2_sw_get_eee(struct dsa_switch *ds, int port,
 	return 0;
 }
 
-static int bcm_sf2_sw_set_eee(struct dsa_switch *ds, int port,
-			      struct ethtool_eee *e)
+static int bcm_sf2_sw_set_mac_eee(struct dsa_switch *ds, int port,
+				  struct ethtool_eee *e)
 {
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	struct ethtool_eee *p = &priv->port_sts[port].eee;
@@ -1011,8 +1011,8 @@ static const struct dsa_switch_ops bcm_sf2_ops = {
 	.set_wol		= bcm_sf2_sw_set_wol,
 	.port_enable		= bcm_sf2_port_setup,
 	.port_disable		= bcm_sf2_port_disable,
-	.get_eee		= bcm_sf2_sw_get_eee,
-	.set_eee		= bcm_sf2_sw_set_eee,
+	.get_mac_eee		= bcm_sf2_sw_get_mac_eee,
+	.set_mac_eee		= bcm_sf2_sw_set_mac_eee,
 	.port_bridge_join	= b53_br_join,
 	.port_bridge_leave	= b53_br_leave,
 	.port_stp_state_set	= b53_br_set_stp_state,
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index 400333077a9f..1f6cb107bc63 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -638,7 +638,7 @@ qca8k_get_sset_count(struct dsa_switch *ds)
 }
 
 static int
-qca8k_set_eee(struct dsa_switch *ds, int port, struct ethtool_eee *eee)
+qca8k_set_mac_eee(struct dsa_switch *ds, int port, struct ethtool_eee *eee)
 {
 	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
 	u32 lpi_en = QCA8K_REG_EEE_CTRL_LPI_EN(port);
@@ -855,7 +855,7 @@ static const struct dsa_switch_ops qca8k_switch_ops = {
 	.phy_write		= qca8k_phy_write,
 	.get_ethtool_stats	= qca8k_get_ethtool_stats,
 	.get_sset_count		= qca8k_get_sset_count,
-	.set_eee		= qca8k_set_eee,
+	.set_mac_eee		= qca8k_set_mac_eee,
 	.port_enable		= qca8k_port_enable,
 	.port_disable		= qca8k_port_disable,
 	.port_stp_state_set	= qca8k_port_stp_state_set,
diff --git a/include/net/dsa.h b/include/net/dsa.h
index ce46db323394..0b1a0622b33c 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -332,12 +332,12 @@ struct dsa_switch_ops {
 				struct phy_device *phy);
 
 	/*
-	 * EEE setttings
+	 * Port's MAC EEE settings
 	 */
-	int	(*set_eee)(struct dsa_switch *ds, int port,
-			   struct ethtool_eee *e);
-	int	(*get_eee)(struct dsa_switch *ds, int port,
-			   struct ethtool_eee *e);
+	int	(*set_mac_eee)(struct dsa_switch *ds, int port,
+			       struct ethtool_eee *e);
+	int	(*get_mac_eee)(struct dsa_switch *ds, int port,
+			       struct ethtool_eee *e);
 
 	/* EEPROM access */
 	int	(*get_eeprom_len)(struct dsa_switch *ds);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 6bc75ab438e8..832a54c94652 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -648,8 +648,8 @@ static int dsa_slave_set_eee(struct net_device *dev, struct ethtool_eee *e)
 	struct dsa_switch *ds = p->dp->ds;
 	int err = -ENODEV;
 
-	if (ds->ops->set_eee) {
-		err = ds->ops->set_eee(ds, p->dp->index, e);
+	if (ds->ops->set_mac_eee) {
+		err = ds->ops->set_mac_eee(ds, p->dp->index, e);
 		if (err)
 			return err;
 	}
@@ -675,8 +675,8 @@ static int dsa_slave_get_eee(struct net_device *dev, struct ethtool_eee *e)
 	struct dsa_switch *ds = p->dp->ds;
 	int err = -ENODEV;
 
-	if (ds->ops->get_eee) {
-		err = ds->ops->get_eee(ds, p->dp->index, e);
+	if (ds->ops->get_mac_eee) {
+		err = ds->ops->get_mac_eee(ds, p->dp->index, e);
 		if (err)
 			return err;
 	}
-- 
2.13.3
