From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 19/21] net: dsa: mv88e6xxx: factorize switch setup
Date: Fri,  6 May 2016 17:57:21 -0400
Message-ID: <1462571843-14397-20-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1462571843-14397-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462571843-14397-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Provide a shared mv88e6xxx_setup function to the drivers.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c | 16 +----------
 drivers/net/dsa/mv88e6131.c | 16 +----------
 drivers/net/dsa/mv88e6171.c | 16 +----------
 drivers/net/dsa/mv88e6352.c | 16 +----------
 drivers/net/dsa/mv88e6xxx.c | 69 ++++++++++++++++++++++-----------------------
 drivers/net/dsa/mv88e6xxx.h |  3 +-
 6 files changed, 38 insertions(+), 98 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 8f3a7c5..2bc407b 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -51,24 +51,10 @@ static const char *mv88e6123_drv_probe(struct device *dsa_dev,
 				   ARRAY_SIZE(mv88e6123_table));
 }
 
-static int mv88e6123_setup(struct dsa_switch *ds)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int ret;
-
-	ps->ds = ds;
-
-	ret = mv88e6xxx_setup_common(ps);
-	if (ret < 0)
-		return ret;
-
-	return mv88e6xxx_setup_ports(ds);
-}
-
 struct dsa_switch_driver mv88e6123_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
 	.probe			= mv88e6123_drv_probe,
-	.setup			= mv88e6123_setup,
+	.setup			= mv88e6xxx_setup,
 	.set_addr		= mv88e6xxx_set_addr,
 	.phy_read		= mv88e6xxx_phy_read,
 	.phy_write		= mv88e6xxx_phy_write,
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index da28327..22952be 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -58,24 +58,10 @@ static const char *mv88e6131_drv_probe(struct device *dsa_dev,
 				   ARRAY_SIZE(mv88e6131_table));
 }
 
-static int mv88e6131_setup(struct dsa_switch *ds)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int ret;
-
-	ps->ds = ds;
-
-	ret = mv88e6xxx_setup_common(ps);
-	if (ret < 0)
-		return ret;
-
-	return mv88e6xxx_setup_ports(ds);
-}
-
 struct dsa_switch_driver mv88e6131_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_DSA,
 	.probe			= mv88e6131_drv_probe,
-	.setup			= mv88e6131_setup,
+	.setup			= mv88e6xxx_setup,
 	.set_addr		= mv88e6xxx_set_addr,
 	.phy_read		= mv88e6xxx_phy_read,
 	.phy_write		= mv88e6xxx_phy_write,
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 83678ad..4bf517a 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -58,24 +58,10 @@ static const char *mv88e6171_drv_probe(struct device *dsa_dev,
 				   ARRAY_SIZE(mv88e6171_table));
 }
 
-static int mv88e6171_setup(struct dsa_switch *ds)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int ret;
-
-	ps->ds = ds;
-
-	ret = mv88e6xxx_setup_common(ps);
-	if (ret < 0)
-		return ret;
-
-	return mv88e6xxx_setup_ports(ds);
-}
-
 struct dsa_switch_driver mv88e6171_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
 	.probe			= mv88e6171_drv_probe,
-	.setup			= mv88e6171_setup,
+	.setup			= mv88e6xxx_setup,
 	.set_addr		= mv88e6xxx_set_addr,
 	.phy_read		= mv88e6xxx_phy_read,
 	.phy_write		= mv88e6xxx_phy_write,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 81810dd..d65a90d 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -77,24 +77,10 @@ static const char *mv88e6352_drv_probe(struct device *dsa_dev,
 				   ARRAY_SIZE(mv88e6352_table));
 }
 
-static int mv88e6352_setup(struct dsa_switch *ds)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int ret;
-
-	ps->ds = ds;
-
-	ret = mv88e6xxx_setup_common(ps);
-	if (ret < 0)
-		return ret;
-
-	return mv88e6xxx_setup_ports(ds);
-}
-
 struct dsa_switch_driver mv88e6352_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
 	.probe			= mv88e6352_drv_probe,
-	.setup			= mv88e6352_setup,
+	.setup			= mv88e6xxx_setup,
 	.set_addr		= mv88e6xxx_set_addr,
 	.phy_read		= mv88e6xxx_phy_read,
 	.phy_write		= mv88e6xxx_phy_write,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 261ca9a..328349b 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2632,14 +2632,12 @@ static int mv88e6xxx_power_on_serdes(struct mv88e6xxx_priv_state *ps)
 	return ret;
 }
 
-static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
+static int _mv88e6xxx_setup_port(struct mv88e6xxx_priv_state *ps, int port)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct dsa_switch *ds = ps->ds;
 	int ret;
 	u16 reg;
 
-	mutex_lock(&ps->smi_mutex);
-
 	if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
 	    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
 	    mv88e6xxx_6185_family(ps) || mv88e6xxx_6095_family(ps) ||
@@ -2668,7 +2666,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
 					   PORT_PCS_CTRL, reg);
 		if (ret)
-			goto abort;
+			return ret;
 	}
 
 	/* Port Control: disable Drop-on-Unlock, disable Drop-on-Lock,
@@ -2732,7 +2730,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
 					   PORT_CONTROL, reg);
 		if (ret)
-			goto abort;
+			return ret;
 	}
 
 	/* If this port is connected to a SerDes, make sure the SerDes is not
@@ -2741,14 +2739,14 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	if (mv88e6xxx_6352_family(ps)) {
 		ret = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_STATUS);
 		if (ret < 0)
-			goto abort;
+			return ret;
 		ret &= PORT_STATUS_CMODE_MASK;
 		if ((ret == PORT_STATUS_CMODE_100BASE_X) ||
 		    (ret == PORT_STATUS_CMODE_1000BASE_X) ||
 		    (ret == PORT_STATUS_CMODE_SGMII)) {
 			ret = mv88e6xxx_power_on_serdes(ps);
 			if (ret < 0)
-				goto abort;
+				return ret;
 		}
 	}
 
@@ -2785,7 +2783,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
 					   PORT_CONTROL_2, reg);
 		if (ret)
-			goto abort;
+			return ret;
 	}
 
 	/* Port Association Vector: when learning source addresses
@@ -2800,13 +2798,13 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 
 	ret = _mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_ASSOC_VECTOR, reg);
 	if (ret)
-		goto abort;
+		return ret;
 
 	/* Egress rate control 2: disable egress rate control. */
 	ret = _mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_RATE_CONTROL_2,
 				   0x0000);
 	if (ret)
-		goto abort;
+		return ret;
 
 	if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
 	    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
@@ -2818,7 +2816,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
 					   PORT_PAUSE_CTRL, 0x0000);
 		if (ret)
-			goto abort;
+			return ret;
 
 		/* Port ATU control: disable limiting the number of
 		 * address database entries that this port is allowed
@@ -2832,7 +2830,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
 					   PORT_PRI_OVERRIDE, 0x0000);
 		if (ret)
-			goto abort;
+			return ret;
 
 		/* Port Ethertype: use the Ethertype DSA Ethertype
 		 * value.
@@ -2840,14 +2838,14 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
 					   PORT_ETH_TYPE, ETH_P_EDSA);
 		if (ret)
-			goto abort;
+			return ret;
 		/* Tag Remap: use an identity 802.1p prio -> switch
 		 * prio mapping.
 		 */
 		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
 					   PORT_TAG_REGMAP_0123, 0x3210);
 		if (ret)
-			goto abort;
+			return ret;
 
 		/* Tag Remap 2: use an identity 802.1p prio -> switch
 		 * prio mapping.
@@ -2855,7 +2853,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
 					   PORT_TAG_REGMAP_4567, 0x7654);
 		if (ret)
-			goto abort;
+			return ret;
 	}
 
 	if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
@@ -2866,7 +2864,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
 					   PORT_RATE_CONTROL, 0x0001);
 		if (ret)
-			goto abort;
+			return ret;
 	}
 
 	/* Port Control 1: disable trunking, disable sending
@@ -2874,7 +2872,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	 */
 	ret = _mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_CONTROL_1, 0x0000);
 	if (ret)
-		goto abort;
+		return ret;
 
 	/* Port based VLAN map: give each port the same default address
 	 * database, and allow bidirectional communication between the
@@ -2882,33 +2880,20 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	 */
 	ret = _mv88e6xxx_port_fid_set(ps, port, 0);
 	if (ret)
-		goto abort;
+		return ret;
 
 	ret = _mv88e6xxx_port_based_vlan_map(ps, port);
 	if (ret)
-		goto abort;
+		return ret;
 
 	/* Default VLAN ID and priority: don't set a default VLAN
 	 * ID, and set the default packet priority to zero.
 	 */
 	ret = _mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_DEFAULT_VLAN,
 				   0x0000);
-abort:
-	mutex_unlock(&ps->smi_mutex);
-	return ret;
-}
-
-int mv88e6xxx_setup_ports(struct dsa_switch *ds)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int ret;
-	int i;
+	if (ret)
+		return ret;
 
-	for (i = 0; i < ps->info->num_ports; i++) {
-		ret = mv88e6xxx_setup_port(ds, i);
-		if (ret < 0)
-			return ret;
-	}
 	return 0;
 }
 
@@ -3123,9 +3108,13 @@ static int _mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
 	return err;
 }
 
-int mv88e6xxx_setup_common(struct mv88e6xxx_priv_state *ps)
+int mv88e6xxx_setup(struct dsa_switch *ds)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int err;
+	int i;
+
+	ps->ds = ds;
 
 	mutex_init(&ps->smi_mutex);
 
@@ -3144,6 +3133,14 @@ int mv88e6xxx_setup_common(struct mv88e6xxx_priv_state *ps)
 		goto unlock;
 
 	err = _mv88e6xxx_setup_global(ps);
+	if (err)
+		goto unlock;
+
+	for (i = 0; i < ps->info->num_ports; i++) {
+		err = _mv88e6xxx_setup_port(ps, i);
+		if (err)
+			goto unlock;
+	}
 
 unlock:
 	mutex_unlock(&ps->smi_mutex);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 555903f..c2801ff 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -598,8 +598,7 @@ const char *mv88e6xxx_drv_probe(struct device *dsa_dev, struct device *host_dev,
 				const struct mv88e6xxx_info *table,
 				unsigned int num);
 
-int mv88e6xxx_setup_ports(struct dsa_switch *ds);
-int mv88e6xxx_setup_common(struct mv88e6xxx_priv_state *ps);
+int mv88e6xxx_setup(struct dsa_switch *ds);
 int mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps, int addr, int reg);
 int mv88e6xxx_reg_write(struct mv88e6xxx_priv_state *ps, int addr,
 			int reg, u16 val);
-- 
2.8.2
