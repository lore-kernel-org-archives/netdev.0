From: <Tristram.Ha@microchip.com>
Subject: [PATCH v1 RFC 3/7] Rename some functions with ksz9477 prefix
Date: Fri, 6 Oct 2017 13:33:01 -0700
Message-ID: <1507321985-15097-4-git-send-email-Tristram.Ha@microchip.com>
References: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tristram Ha <Tristram.Ha@microchip.com>, <muvarov@gmail.com>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>,
        <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Pavel Machek <pavel@ucw.cz>,
        Ruediger Schmitt <ruediger.schmitt@philips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@microchip.com>

Rename some functions with ksz9477 prefix to separate chip specific code
from common code.

Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
---
 drivers/net/dsa/microchip/ksz_common.c | 116 +++++++++++++++++----------------
 1 file changed, 59 insertions(+), 57 deletions(-)

diff --git a/drivers/net/dsa/microchip/ksz_common.c b/drivers/net/dsa/microchip/ksz_common.c
index d72aad7..7a0d10f 100644
--- a/drivers/net/dsa/microchip/ksz_common.c
+++ b/drivers/net/dsa/microchip/ksz_common.c
@@ -265,9 +265,8 @@ static int wait_alu_sta_ready(struct ksz_device *dev, u32 waiton, int timeout)
 	return 0;
 }
 
-static int ksz_reset_switch(struct dsa_switch *ds)
+static int ksz9477_reset_switch(struct ksz_device *dev)
 {
-	struct ksz_device *dev = ds->priv;
 	u8 data8;
 	u16 data16;
 	u32 data32;
@@ -300,7 +299,7 @@ static int ksz_reset_switch(struct dsa_switch *ds)
 	return 0;
 }
 
-static void port_setup(struct ksz_device *dev, int port, bool cpu_port)
+static void ksz9477_port_setup(struct ksz_device *dev, int port, bool cpu_port)
 {
 	u8 data8;
 	u16 data16;
@@ -346,7 +345,7 @@ static void port_setup(struct ksz_device *dev, int port, bool cpu_port)
 	ksz_pread16(dev, port, REG_PORT_PHY_INT_ENABLE, &data16);
 }
 
-static void ksz_config_cpu_port(struct dsa_switch *ds)
+static void ksz9477_config_cpu_port(struct dsa_switch *ds)
 {
 	struct ksz_device *dev = ds->priv;
 	int i;
@@ -358,12 +357,12 @@ static void ksz_config_cpu_port(struct dsa_switch *ds)
 			dev->cpu_port = i;
 
 			/* enable cpu port */
-			port_setup(dev, i, true);
+			ksz9477_port_setup(dev, i, true);
 		}
 	}
 }
 
-static int ksz_setup(struct dsa_switch *ds)
+static int ksz9477_setup(struct dsa_switch *ds)
 {
 	struct ksz_device *dev = ds->priv;
 	int ret = 0;
@@ -373,7 +372,7 @@ static int ksz_setup(struct dsa_switch *ds)
 	if (!dev->vlan_cache)
 		return -ENOMEM;
 
-	ret = ksz_reset_switch(ds);
+	ret = ksz9477_reset_switch(dev);
 	if (ret) {
 		dev_err(ds->dev, "failed to reset switch\n");
 		return ret;
@@ -382,7 +381,7 @@ static int ksz_setup(struct dsa_switch *ds)
 	/* accept packet up to 2000bytes */
 	ksz_cfg(dev, REG_SW_MAC_CTRL_1, SW_LEGAL_PACKET_DISABLE, true);
 
-	ksz_config_cpu_port(ds);
+	ksz9477_config_cpu_port(ds);
 
 	ksz_cfg(dev, REG_SW_MAC_CTRL_1, MULTICAST_STORM_DISABLE, true);
 
@@ -395,12 +394,12 @@ static int ksz_setup(struct dsa_switch *ds)
 	return 0;
 }
 
-static enum dsa_tag_protocol ksz_get_tag_protocol(struct dsa_switch *ds)
+static enum dsa_tag_protocol ksz9477_get_tag_protocol(struct dsa_switch *ds)
 {
 	return DSA_TAG_PROTO_KSZ;
 }
 
-static int ksz_phy_read16(struct dsa_switch *ds, int addr, int reg)
+static int ksz9477_phy_read16(struct dsa_switch *ds, int addr, int reg)
 {
 	struct ksz_device *dev = ds->priv;
 	u16 val = 0;
@@ -410,7 +409,8 @@ static int ksz_phy_read16(struct dsa_switch *ds, int addr, int reg)
 	return val;
 }
 
-static int ksz_phy_write16(struct dsa_switch *ds, int addr, int reg, u16 val)
+static int ksz9477_phy_write16(struct dsa_switch *ds, int addr, int reg,
+			       u16 val)
 {
 	struct ksz_device *dev = ds->priv;
 
@@ -425,7 +425,7 @@ static int ksz_enable_port(struct dsa_switch *ds, int port,
 	struct ksz_device *dev = ds->priv;
 
 	/* setup slave port */
-	port_setup(dev, port, false);
+	ksz9477_port_setup(dev, port, false);
 
 	return 0;
 }
@@ -444,7 +444,7 @@ static int ksz_sset_count(struct dsa_switch *ds)
 	return TOTAL_SWITCH_COUNTER_NUM;
 }
 
-static void ksz_get_strings(struct dsa_switch *ds, int port, uint8_t *buf)
+static void ksz9477_get_strings(struct dsa_switch *ds, int port, uint8_t *buf)
 {
 	int i;
 
@@ -494,7 +494,8 @@ static void ksz_get_ethtool_stats(struct dsa_switch *ds, int port,
 	mutex_unlock(&dev->stats_mutex);
 }
 
-static void ksz_port_stp_state_set(struct dsa_switch *ds, int port, u8 state)
+static void ksz9477_port_stp_state_set(struct dsa_switch *ds, int port,
+				       u8 state)
 {
 	struct ksz_device *dev = ds->priv;
 	u8 data;
@@ -539,7 +540,8 @@ static void ksz_port_fast_age(struct dsa_switch *ds, int port)
 	ksz_write8(dev, REG_SW_LUE_CTRL_1, data8);
 }
 
-static int ksz_port_vlan_filtering(struct dsa_switch *ds, int port, bool flag)
+static int ksz9477_port_vlan_filtering(struct dsa_switch *ds, int port,
+				       bool flag)
 {
 	struct ksz_device *dev = ds->priv;
 
@@ -567,9 +569,9 @@ static int ksz_port_vlan_prepare(struct dsa_switch *ds, int port,
 	return 0;
 }
 
-static void ksz_port_vlan_add(struct dsa_switch *ds, int port,
-			      const struct switchdev_obj_port_vlan *vlan,
-			      struct switchdev_trans *trans)
+static void ksz9477_port_vlan_add(struct dsa_switch *ds, int port,
+				  const struct switchdev_obj_port_vlan *vlan,
+				  struct switchdev_trans *trans)
 {
 	struct ksz_device *dev = ds->priv;
 	u32 vlan_table[3];
@@ -602,8 +604,8 @@ static void ksz_port_vlan_add(struct dsa_switch *ds, int port,
 	}
 }
 
-static int ksz_port_vlan_del(struct dsa_switch *ds, int port,
-			     const struct switchdev_obj_port_vlan *vlan)
+static int ksz9477_port_vlan_del(struct dsa_switch *ds, int port,
+				 const struct switchdev_obj_port_vlan *vlan)
 {
 	struct ksz_device *dev = ds->priv;
 	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
@@ -658,8 +660,8 @@ struct alu_struct {
 	u8	mac[ETH_ALEN];
 };
 
-static int ksz_port_fdb_add(struct dsa_switch *ds, int port,
-			    const unsigned char *addr, u16 vid)
+static int ksz9477_port_fdb_add(struct dsa_switch *ds, int port,
+				const unsigned char *addr, u16 vid)
 {
 	struct ksz_device *dev = ds->priv;
 	u32 alu_table[4];
@@ -715,8 +717,8 @@ static int ksz_port_fdb_add(struct dsa_switch *ds, int port,
 	return ret;
 }
 
-static int ksz_port_fdb_del(struct dsa_switch *ds, int port,
-			    const unsigned char *addr, u16 vid)
+static int ksz9477_port_fdb_del(struct dsa_switch *ds, int port,
+				const unsigned char *addr, u16 vid)
 {
 	struct ksz_device *dev = ds->priv;
 	u32 alu_table[4];
@@ -805,8 +807,8 @@ static void convert_alu(struct alu_struct *alu, u32 *alu_table)
 	alu->mac[5] = alu_table[3] & 0xFF;
 }
 
-static int ksz_port_fdb_dump(struct dsa_switch *ds, int port,
-			     dsa_fdb_dump_cb_t *cb, void *data)
+static int ksz9477_port_fdb_dump(struct dsa_switch *ds, int port,
+				 dsa_fdb_dump_cb_t *cb, void *data)
 {
 	struct ksz_device *dev = ds->priv;
 	int ret = 0;
@@ -865,9 +867,9 @@ static int ksz_port_mdb_prepare(struct dsa_switch *ds, int port,
 	return 0;
 }
 
-static void ksz_port_mdb_add(struct dsa_switch *ds, int port,
-			     const struct switchdev_obj_port_mdb *mdb,
-			     struct switchdev_trans *trans)
+static void ksz9477_port_mdb_add(struct dsa_switch *ds, int port,
+				 const struct switchdev_obj_port_mdb *mdb,
+				 struct switchdev_trans *trans)
 {
 	struct ksz_device *dev = ds->priv;
 	u32 static_table[4];
@@ -936,8 +938,8 @@ static void ksz_port_mdb_add(struct dsa_switch *ds, int port,
 	mutex_unlock(&dev->alu_mutex);
 }
 
-static int ksz_port_mdb_del(struct dsa_switch *ds, int port,
-			    const struct switchdev_obj_port_mdb *mdb)
+static int ksz9477_port_mdb_del(struct dsa_switch *ds, int port,
+				const struct switchdev_obj_port_mdb *mdb)
 {
 	struct ksz_device *dev = ds->priv;
 	u32 static_table[4];
@@ -1013,9 +1015,9 @@ static int ksz_port_mdb_del(struct dsa_switch *ds, int port,
 	return ret;
 }
 
-static int ksz_port_mirror_add(struct dsa_switch *ds, int port,
-			       struct dsa_mall_mirror_tc_entry *mirror,
-			       bool ingress)
+static int ksz9477_port_mirror_add(struct dsa_switch *ds, int port,
+				   struct dsa_mall_mirror_tc_entry *mirror,
+				   bool ingress)
 {
 	struct ksz_device *dev = ds->priv;
 
@@ -1035,8 +1037,8 @@ static int ksz_port_mirror_add(struct dsa_switch *ds, int port,
 	return 0;
 }
 
-static void ksz_port_mirror_del(struct dsa_switch *ds, int port,
-				struct dsa_mall_mirror_tc_entry *mirror)
+static void ksz9477_port_mirror_del(struct dsa_switch *ds, int port,
+				    struct dsa_mall_mirror_tc_entry *mirror)
 {
 	struct ksz_device *dev = ds->priv;
 	u8 data;
@@ -1054,29 +1056,29 @@ static void ksz_port_mirror_del(struct dsa_switch *ds, int port,
 }
 
 static const struct dsa_switch_ops ksz_switch_ops = {
-	.get_tag_protocol	= ksz_get_tag_protocol,
-	.setup			= ksz_setup,
-	.phy_read		= ksz_phy_read16,
-	.phy_write		= ksz_phy_write16,
+	.get_tag_protocol	= ksz9477_get_tag_protocol,
+	.setup			= ksz9477_setup,
+	.phy_read		= ksz9477_phy_read16,
+	.phy_write		= ksz9477_phy_write16,
 	.port_enable		= ksz_enable_port,
 	.port_disable		= ksz_disable_port,
-	.get_strings		= ksz_get_strings,
+	.get_strings		= ksz9477_get_strings,
 	.get_ethtool_stats	= ksz_get_ethtool_stats,
 	.get_sset_count		= ksz_sset_count,
-	.port_stp_state_set	= ksz_port_stp_state_set,
+	.port_stp_state_set	= ksz9477_port_stp_state_set,
 	.port_fast_age		= ksz_port_fast_age,
-	.port_vlan_filtering	= ksz_port_vlan_filtering,
+	.port_vlan_filtering	= ksz9477_port_vlan_filtering,
 	.port_vlan_prepare	= ksz_port_vlan_prepare,
-	.port_vlan_add		= ksz_port_vlan_add,
-	.port_vlan_del		= ksz_port_vlan_del,
-	.port_fdb_dump		= ksz_port_fdb_dump,
-	.port_fdb_add		= ksz_port_fdb_add,
-	.port_fdb_del		= ksz_port_fdb_del,
+	.port_vlan_add		= ksz9477_port_vlan_add,
+	.port_vlan_del		= ksz9477_port_vlan_del,
+	.port_fdb_dump		= ksz9477_port_fdb_dump,
+	.port_fdb_add		= ksz9477_port_fdb_add,
+	.port_fdb_del		= ksz9477_port_fdb_del,
 	.port_mdb_prepare       = ksz_port_mdb_prepare,
-	.port_mdb_add           = ksz_port_mdb_add,
-	.port_mdb_del           = ksz_port_mdb_del,
-	.port_mirror_add	= ksz_port_mirror_add,
-	.port_mirror_del	= ksz_port_mirror_del,
+	.port_mdb_add           = ksz9477_port_mdb_add,
+	.port_mdb_del           = ksz9477_port_mdb_del,
+	.port_mirror_add	= ksz9477_port_mirror_add,
+	.port_mirror_del	= ksz9477_port_mirror_del,
 };
 
 struct ksz_chip_data {
@@ -1089,7 +1091,7 @@ struct ksz_chip_data {
 	int port_cnt;
 };
 
-static const struct ksz_chip_data ksz_switch_chips[] = {
+static const struct ksz_chip_data ksz9477_switch_chips[] = {
 	{
 		.chip_id = 0x00947700,
 		.dev_name = "KSZ9477",
@@ -1101,7 +1103,7 @@ struct ksz_chip_data {
 	},
 };
 
-static int ksz_switch_init(struct ksz_device *dev)
+static int ksz9477_switch_init(struct ksz_device *dev)
 {
 	int i;
 
@@ -1112,8 +1114,8 @@ static int ksz_switch_init(struct ksz_device *dev)
 
 	dev->ds->ops = &ksz_switch_ops;
 
-	for (i = 0; i < ARRAY_SIZE(ksz_switch_chips); i++) {
-		const struct ksz_chip_data *chip = &ksz_switch_chips[i];
+	for (i = 0; i < ARRAY_SIZE(ksz9477_switch_chips); i++) {
+		const struct ksz_chip_data *chip = &ksz9477_switch_chips[i];
 
 		if (dev->chip_id == chip->chip_id) {
 			dev->name = chip->dev_name;
@@ -1197,7 +1199,7 @@ int ksz_switch_register(struct ksz_device *dev)
 	if (ksz_switch_detect(dev))
 		return -EINVAL;
 
-	ret = ksz_switch_init(dev);
+	ret = ksz9477_switch_init(dev);
 	if (ret)
 		return ret;
 
-- 
1.9.1
