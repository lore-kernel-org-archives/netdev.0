From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 11/11] net: dsa: rename switch EEE ops
Date: Tue,  1 Aug 2017 16:32:41 -0400
Message-ID: <20170801203241.22294-12-vivien.didelot@savoirfairelinux.com>
References: <20170801203241.22294-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:44766 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752303AbdHAUgp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 16:36:45 -0400
In-Reply-To: <20170801203241.22294-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To avoid confusion with the PHY EEE settings, rename the .set_eee and
.get_eee ops to respectively .set_mac_eee and .get_mac_eee.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/bcm_sf2.c        | 12 ++++++------
 drivers/net/dsa/mv88e6xxx/chip.c | 12 ++++++------
 drivers/net/dsa/qca8k.c          |  9 ++++-----
 include/net/dsa.h                | 10 +++++-----
 net/dsa/slave.c                  |  8 ++++----
 5 files changed, 25 insertions(+), 26 deletions(-)

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
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index aa0c5493fb9d..521738c4cd17 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -810,15 +810,15 @@ static void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 	mutex_unlock(&chip->reg_lock);
 }
 
-static int mv88e6xxx_get_eee(struct dsa_switch *ds, int port,
-			     struct ethtool_eee *e)
+static int mv88e6xxx_get_mac_eee(struct dsa_switch *ds, int port,
+				 struct ethtool_eee *e)
 {
 	/* Nothing to do on the port's MAC */
 	return 0;
 }
 
-static int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
-			     struct ethtool_eee *e)
+static int mv88e6xxx_set_mac_eee(struct dsa_switch *ds, int port,
+				 struct ethtool_eee *e)
 {
 	/* Nothing to do on the port's MAC */
 	return 0;
@@ -3890,8 +3890,8 @@ static const struct dsa_switch_ops mv88e6xxx_switch_ops = {
 	.get_sset_count		= mv88e6xxx_get_sset_count,
 	.port_enable		= mv88e6xxx_port_enable,
 	.port_disable		= mv88e6xxx_port_disable,
-	.set_eee		= mv88e6xxx_set_eee,
-	.get_eee		= mv88e6xxx_get_eee,
+	.get_mac_eee		= mv88e6xxx_get_mac_eee,
+	.set_mac_eee		= mv88e6xxx_set_mac_eee,
 	.get_eeprom_len		= mv88e6xxx_get_eeprom_len,
 	.get_eeprom		= mv88e6xxx_get_eeprom,
 	.set_eeprom		= mv88e6xxx_set_eeprom,
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index e209e229ed4c..36c169b0c705 100644
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
@@ -657,8 +657,7 @@ qca8k_set_eee(struct dsa_switch *ds, int port, struct ethtool_eee *eee)
 }
 
 static int
-qca8k_get_eee(struct dsa_switch *ds, int port,
-	      struct ethtool_eee *e)
+qca8k_get_mac_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e)
 {
 	/* Nothing to do on the port's MAC */
 	return 0;
@@ -863,8 +862,8 @@ static const struct dsa_switch_ops qca8k_switch_ops = {
 	.phy_write		= qca8k_phy_write,
 	.get_ethtool_stats	= qca8k_get_ethtool_stats,
 	.get_sset_count		= qca8k_get_sset_count,
-	.get_eee		= qca8k_get_eee,
-	.set_eee		= qca8k_set_eee,
+	.get_mac_eee		= qca8k_get_mac_eee,
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
index 9ddc584e70b0..cc4bad3dadb4 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -652,10 +652,10 @@ static int dsa_slave_set_eee(struct net_device *dev, struct ethtool_eee *e)
 	if (!p->phy)
 		return -ENODEV;
 
-	if (!ds->ops->set_eee)
+	if (!ds->ops->set_mac_eee)
 		return -EOPNOTSUPP;
 
-	ret = ds->ops->set_eee(ds, p->dp->index, e);
+	ret = ds->ops->set_mac_eee(ds, p->dp->index, e);
 	if (ret)
 		return ret;
 
@@ -678,10 +678,10 @@ static int dsa_slave_get_eee(struct net_device *dev, struct ethtool_eee *e)
 	if (!p->phy)
 		return -ENODEV;
 
-	if (!ds->ops->get_eee)
+	if (!ds->ops->get_mac_eee)
 		return -EOPNOTSUPP;
 
-	ret = ds->ops->get_eee(ds, p->dp->index, e);
+	ret = ds->ops->get_mac_eee(ds, p->dp->index, e);
 	if (ret)
 		return ret;
 
-- 
2.13.3
