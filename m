From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: remove ds_to_priv
Date: Wed, 31 Aug 2016 18:06:13 -0400
Message-ID: <20160831220613.8727-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Access the priv member of the dsa_switch structure directly, instead of
having an unnecessary helper.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/b53/b53_common.c | 42 +++++++++++------------
 drivers/net/dsa/bcm_sf2.h        |  2 +-
 drivers/net/dsa/mv88e6060.c      |  4 +--
 drivers/net/dsa/mv88e6xxx/chip.c | 72 ++++++++++++++++++++--------------------
 include/net/dsa.h                |  5 ---
 5 files changed, 60 insertions(+), 65 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 1299104..0afc2e5 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -477,7 +477,7 @@ static int b53_fast_age_vlan(struct b53_device *dev, u16 vid)
 
 static void b53_imp_vlan_setup(struct dsa_switch *ds, int cpu_port)
 {
-	struct b53_device *dev = ds_to_priv(ds);
+	struct b53_device *dev = ds->priv;
 	unsigned int i;
 	u16 pvlan;
 
@@ -495,7 +495,7 @@ static void b53_imp_vlan_setup(struct dsa_switch *ds, int cpu_port)
 static int b53_enable_port(struct dsa_switch *ds, int port,
 			   struct phy_device *phy)
 {
-	struct b53_device *dev = ds_to_priv(ds);
+	struct b53_device *dev = ds->priv;
 	unsigned int cpu_port = dev->cpu_port;
 	u16 pvlan;
 
@@ -520,7 +520,7 @@ static int b53_enable_port(struct dsa_switch *ds, int port,
 static void b53_disable_port(struct dsa_switch *ds, int port,
 			     struct phy_device *phy)
 {
-	struct b53_device *dev = ds_to_priv(ds);
+	struct b53_device *dev = ds->priv;
 	u8 reg;
 
 	/* Disable Tx/Rx for the port */
@@ -629,7 +629,7 @@ static int b53_switch_reset(struct b53_device *dev)
 
 static int b53_phy_read16(struct dsa_switch *ds, int addr, int reg)
 {
-	struct b53_device *priv = ds_to_priv(ds);
+	struct b53_device *priv = ds->priv;
 	u16 value = 0;
 	int ret;
 
@@ -644,7 +644,7 @@ static int b53_phy_read16(struct dsa_switch *ds, int addr, int reg)
 
 static int b53_phy_write16(struct dsa_switch *ds, int addr, int reg, u16 val)
 {
-	struct b53_device *priv = ds_to_priv(ds);
+	struct b53_device *priv = ds->priv;
 
 	if (priv->ops->phy_write16)
 		return priv->ops->phy_write16(priv, addr, reg, val);
@@ -714,7 +714,7 @@ static unsigned int b53_get_mib_size(struct b53_device *dev)
 
 static void b53_get_strings(struct dsa_switch *ds, int port, uint8_t *data)
 {
-	struct b53_device *dev = ds_to_priv(ds);
+	struct b53_device *dev = ds->priv;
 	const struct b53_mib_desc *mibs = b53_get_mib(dev);
 	unsigned int mib_size = b53_get_mib_size(dev);
 	unsigned int i;
@@ -727,7 +727,7 @@ static void b53_get_strings(struct dsa_switch *ds, int port, uint8_t *data)
 static void b53_get_ethtool_stats(struct dsa_switch *ds, int port,
 				  uint64_t *data)
 {
-	struct b53_device *dev = ds_to_priv(ds);
+	struct b53_device *dev = ds->priv;
 	const struct b53_mib_desc *mibs = b53_get_mib(dev);
 	unsigned int mib_size = b53_get_mib_size(dev);
 	const struct b53_mib_desc *s;
@@ -759,7 +759,7 @@ static void b53_get_ethtool_stats(struct dsa_switch *ds, int port,
 
 static int b53_get_sset_count(struct dsa_switch *ds)
 {
-	struct b53_device *dev = ds_to_priv(ds);
+	struct b53_device *dev = ds->priv;
 
 	return b53_get_mib_size(dev);
 }
@@ -771,7 +771,7 @@ static int b53_set_addr(struct dsa_switch *ds, u8 *addr)
 
 static int b53_setup(struct dsa_switch *ds)
 {
-	struct b53_device *dev = ds_to_priv(ds);
+	struct b53_device *dev = ds->priv;
 	unsigned int port;
 	int ret;
 
@@ -802,7 +802,7 @@ static int b53_setup(struct dsa_switch *ds)
 static void b53_adjust_link(struct dsa_switch *ds, int port,
 			    struct phy_device *phydev)
 {
-	struct b53_device *dev = ds_to_priv(ds);
+	struct b53_device *dev = ds->priv;
 	u8 rgmii_ctrl = 0, reg = 0, off;
 
 	if (!phy_is_pseudo_fixed_link(phydev))
@@ -936,7 +936,7 @@ static int b53_vlan_prepare(struct dsa_switch *ds, int port,
 			    const struct switchdev_obj_port_vlan *vlan,
 			    struct switchdev_trans *trans)
 {
-	struct b53_device *dev = ds_to_priv(ds);
+	struct b53_device *dev = ds->priv;
 
 	if ((is5325(dev) || is5365(dev)) && vlan->vid_begin == 0)
 		return -EOPNOTSUPP;
@@ -953,7 +953,7 @@ static void b53_vlan_add(struct dsa_switch *ds, int port,
 			 const struct switchdev_obj_port_vlan *vlan,
 			 struct switchdev_trans *trans)
 {
-	struct b53_device *dev = ds_to_priv(ds);
+	struct b53_device *dev = ds->priv;
 	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
 	bool pvid = vlan->flags & BRIDGE_VLAN_INFO_PVID;
 	unsigned int cpu_port = dev->cpu_port;
@@ -987,7 +987,7 @@ static void b53_vlan_add(struct dsa_switch *ds, int port,
 static int b53_vlan_del(struct dsa_switch *ds, int port,
 			const struct switchdev_obj_port_vlan *vlan)
 {
-	struct b53_device *dev = ds_to_priv(ds);
+	struct b53_device *dev = ds->priv;
 	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
 	unsigned int cpu_port = dev->cpu_port;
 	struct b53_vlan *vl;
@@ -1033,7 +1033,7 @@ static int b53_vlan_dump(struct dsa_switch *ds, int port,
 			 struct switchdev_obj_port_vlan *vlan,
 			 int (*cb)(struct switchdev_obj *obj))
 {
-	struct b53_device *dev = ds_to_priv(ds);
+	struct b53_device *dev = ds->priv;
 	u16 vid, vid_start = 0, pvid;
 	struct b53_vlan *vl;
 	int err = 0;
@@ -1192,7 +1192,7 @@ static int b53_fdb_prepare(struct dsa_switch *ds, int port,
 			   const struct switchdev_obj_port_fdb *fdb,
 			   struct switchdev_trans *trans)
 {
-	struct b53_device *priv = ds_to_priv(ds);
+	struct b53_device *priv = ds->priv;
 
 	/* 5325 and 5365 require some more massaging, but could
 	 * be supported eventually
@@ -1207,7 +1207,7 @@ static void b53_fdb_add(struct dsa_switch *ds, int port,
 			const struct switchdev_obj_port_fdb *fdb,
 			struct switchdev_trans *trans)
 {
-	struct b53_device *priv = ds_to_priv(ds);
+	struct b53_device *priv = ds->priv;
 
 	if (b53_arl_op(priv, 0, port, fdb->addr, fdb->vid, true))
 		pr_err("%s: failed to add MAC address\n", __func__);
@@ -1216,7 +1216,7 @@ static void b53_fdb_add(struct dsa_switch *ds, int port,
 static int b53_fdb_del(struct dsa_switch *ds, int port,
 		       const struct switchdev_obj_port_fdb *fdb)
 {
-	struct b53_device *priv = ds_to_priv(ds);
+	struct b53_device *priv = ds->priv;
 
 	return b53_arl_op(priv, 0, port, fdb->addr, fdb->vid, false);
 }
@@ -1275,7 +1275,7 @@ static int b53_fdb_dump(struct dsa_switch *ds, int port,
 			struct switchdev_obj_port_fdb *fdb,
 			int (*cb)(struct switchdev_obj *obj))
 {
-	struct b53_device *priv = ds_to_priv(ds);
+	struct b53_device *priv = ds->priv;
 	struct net_device *dev = ds->ports[port].netdev;
 	struct b53_arl_entry results[2];
 	unsigned int count = 0;
@@ -1314,7 +1314,7 @@ static int b53_fdb_dump(struct dsa_switch *ds, int port,
 static int b53_br_join(struct dsa_switch *ds, int port,
 		       struct net_device *bridge)
 {
-	struct b53_device *dev = ds_to_priv(ds);
+	struct b53_device *dev = ds->priv;
 	s8 cpu_port = ds->dst->cpu_port;
 	u16 pvlan, reg;
 	unsigned int i;
@@ -1359,7 +1359,7 @@ static int b53_br_join(struct dsa_switch *ds, int port,
 
 static void b53_br_leave(struct dsa_switch *ds, int port)
 {
-	struct b53_device *dev = ds_to_priv(ds);
+	struct b53_device *dev = ds->priv;
 	struct net_device *bridge = dev->ports[port].bridge_dev;
 	struct b53_vlan *vl = &dev->vlans[0];
 	s8 cpu_port = ds->dst->cpu_port;
@@ -1410,7 +1410,7 @@ static void b53_br_leave(struct dsa_switch *ds, int port)
 static void b53_br_set_stp_state(struct dsa_switch *ds, int port,
 				 u8 state)
 {
-	struct b53_device *dev = ds_to_priv(ds);
+	struct b53_device *dev = ds->priv;
 	u8 hw_state, cur_hw_state;
 	u8 reg;
 
diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index afe5668..46c4ea7 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -101,7 +101,7 @@ struct bcm_sf2_priv {
 
 static inline struct bcm_sf2_priv *bcm_sf2_to_priv(struct dsa_switch *ds)
 {
-	struct b53_device *dev = ds_to_priv(ds);
+	struct b53_device *dev = ds->priv;
 
 	return dev->priv;
 }
diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index 7ff9d37..7ce36db 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -19,7 +19,7 @@
 
 static int reg_read(struct dsa_switch *ds, int addr, int reg)
 {
-	struct mv88e6060_priv *priv = ds_to_priv(ds);
+	struct mv88e6060_priv *priv = ds->priv;
 
 	return mdiobus_read_nested(priv->bus, priv->sw_addr + addr, reg);
 }
@@ -37,7 +37,7 @@ static int reg_read(struct dsa_switch *ds, int addr, int reg)
 
 static int reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
 {
-	struct mv88e6060_priv *priv = ds_to_priv(ds);
+	struct mv88e6060_priv *priv = ds->priv;
 
 	return mdiobus_write_nested(priv->bus, priv->sw_addr + addr, reg, val);
 }
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index e2a953e..d6b0f78 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -586,7 +586,7 @@ static bool mv88e6xxx_has_fid_reg(struct mv88e6xxx_chip *chip)
 static void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 				  struct phy_device *phydev)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	u32 reg;
 	int ret;
 
@@ -832,7 +832,7 @@ static uint64_t _mv88e6xxx_get_ethtool_stat(struct mv88e6xxx_chip *chip,
 static void mv88e6xxx_get_strings(struct dsa_switch *ds, int port,
 				  uint8_t *data)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	struct mv88e6xxx_hw_stat *stat;
 	int i, j;
 
@@ -848,7 +848,7 @@ static void mv88e6xxx_get_strings(struct dsa_switch *ds, int port,
 
 static int mv88e6xxx_get_sset_count(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	struct mv88e6xxx_hw_stat *stat;
 	int i, j;
 
@@ -863,7 +863,7 @@ static int mv88e6xxx_get_sset_count(struct dsa_switch *ds)
 static void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds, int port,
 					uint64_t *data)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	struct mv88e6xxx_hw_stat *stat;
 	int ret;
 	int i, j;
@@ -894,7 +894,7 @@ static int mv88e6xxx_get_regs_len(struct dsa_switch *ds, int port)
 static void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 			       struct ethtool_regs *regs, void *_p)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	u16 *p = _p;
 	int i;
 
@@ -924,7 +924,7 @@ static int _mv88e6xxx_atu_wait(struct mv88e6xxx_chip *chip)
 static int mv88e6xxx_get_eee(struct dsa_switch *ds, int port,
 			     struct ethtool_eee *e)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	u16 reg;
 	int err;
 
@@ -954,7 +954,7 @@ out:
 static int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 			     struct phy_device *phydev, struct ethtool_eee *e)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	u16 reg;
 	int err;
 
@@ -1185,7 +1185,7 @@ static int _mv88e6xxx_port_based_vlan_map(struct mv88e6xxx_chip *chip, int port)
 static void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port,
 					 u8 state)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	int stp_state;
 	int err;
 
@@ -1434,7 +1434,7 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 				    struct switchdev_obj_port_vlan *vlan,
 				    int (*cb)(struct switchdev_obj *obj))
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	struct mv88e6xxx_vtu_stu_entry next;
 	u16 pvid;
 	int err;
@@ -1803,7 +1803,7 @@ static int _mv88e6xxx_vtu_get(struct mv88e6xxx_chip *chip, u16 vid,
 static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 					u16 vid_begin, u16 vid_end)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	struct mv88e6xxx_vtu_stu_entry vlan;
 	int i, err;
 
@@ -1864,7 +1864,7 @@ static const char * const mv88e6xxx_port_8021q_mode_names[] = {
 static int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
 					 bool vlan_filtering)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	u16 old, new = vlan_filtering ? PORT_CONTROL_2_8021Q_SECURE :
 		PORT_CONTROL_2_8021Q_DISABLED;
 	int ret;
@@ -1906,7 +1906,7 @@ mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
 			    const struct switchdev_obj_port_vlan *vlan,
 			    struct switchdev_trans *trans)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
 
 	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VTU))
@@ -1947,7 +1947,7 @@ static void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
 				    const struct switchdev_obj_port_vlan *vlan,
 				    struct switchdev_trans *trans)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
 	bool pvid = vlan->flags & BRIDGE_VLAN_INFO_PVID;
 	u16 vid;
@@ -2009,7 +2009,7 @@ static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_chip *chip,
 static int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
 				   const struct switchdev_obj_port_vlan *vlan)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	u16 pvid, vid;
 	int err = 0;
 
@@ -2134,7 +2134,7 @@ static void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 				   const struct switchdev_obj_port_fdb *fdb,
 				   struct switchdev_trans *trans)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 
 	mutex_lock(&chip->reg_lock);
 	if (mv88e6xxx_port_db_load_purge(chip, port, fdb->addr, fdb->vid,
@@ -2146,7 +2146,7 @@ static void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 static int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 				  const struct switchdev_obj_port_fdb *fdb)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
 
 	mutex_lock(&chip->reg_lock);
@@ -2306,7 +2306,7 @@ static int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
 				   struct switchdev_obj_port_fdb *fdb,
 				   int (*cb)(struct switchdev_obj *obj))
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
 
 	mutex_lock(&chip->reg_lock);
@@ -2319,7 +2319,7 @@ static int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
 static int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
 				      struct net_device *bridge)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	int i, err = 0;
 
 	mutex_lock(&chip->reg_lock);
@@ -2342,7 +2342,7 @@ static int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
 
 static void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	struct net_device *bridge = chip->ports[port].bridge_dev;
 	int i;
 
@@ -2763,7 +2763,7 @@ static int mv88e6xxx_g1_set_age_time(struct mv88e6xxx_chip *chip,
 static int mv88e6xxx_set_ageing_time(struct dsa_switch *ds,
 				     unsigned int ageing_time)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
 
 	mutex_lock(&chip->reg_lock);
@@ -3204,7 +3204,7 @@ static int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 
 static int mv88e6xxx_setup(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
 	int i;
 
@@ -3244,7 +3244,7 @@ unlock:
 
 static int mv88e6xxx_set_addr(struct dsa_switch *ds, u8 *addr)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
 
 	mutex_lock(&chip->reg_lock);
@@ -3352,7 +3352,7 @@ static void mv88e6xxx_mdio_unregister(struct mv88e6xxx_chip *chip)
 
 static int mv88e61xx_get_temp(struct dsa_switch *ds, int *temp)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	u16 val;
 	int ret;
 
@@ -3395,7 +3395,7 @@ error:
 
 static int mv88e63xx_get_temp(struct dsa_switch *ds, int *temp)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	int phy = mv88e6xxx_6320_family(chip) ? 3 : 0;
 	u16 val;
 	int ret;
@@ -3415,7 +3415,7 @@ static int mv88e63xx_get_temp(struct dsa_switch *ds, int *temp)
 
 static int mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 
 	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_TEMP))
 		return -EOPNOTSUPP;
@@ -3428,7 +3428,7 @@ static int mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp)
 
 static int mv88e6xxx_get_temp_limit(struct dsa_switch *ds, int *temp)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	int phy = mv88e6xxx_6320_family(chip) ? 3 : 0;
 	u16 val;
 	int ret;
@@ -3451,7 +3451,7 @@ static int mv88e6xxx_get_temp_limit(struct dsa_switch *ds, int *temp)
 
 static int mv88e6xxx_set_temp_limit(struct dsa_switch *ds, int temp)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	int phy = mv88e6xxx_6320_family(chip) ? 3 : 0;
 	u16 val;
 	int err;
@@ -3474,7 +3474,7 @@ unlock:
 
 static int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	int phy = mv88e6xxx_6320_family(chip) ? 3 : 0;
 	u16 val;
 	int ret;
@@ -3498,7 +3498,7 @@ static int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 
 static int mv88e6xxx_get_eeprom_len(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 
 	return chip->eeprom_len;
 }
@@ -3556,7 +3556,7 @@ static int mv88e6xxx_get_eeprom16(struct mv88e6xxx_chip *chip,
 static int mv88e6xxx_get_eeprom(struct dsa_switch *ds,
 				struct ethtool_eeprom *eeprom, u8 *data)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
 
 	mutex_lock(&chip->reg_lock);
@@ -3645,7 +3645,7 @@ static int mv88e6xxx_set_eeprom16(struct mv88e6xxx_chip *chip,
 static int mv88e6xxx_set_eeprom(struct dsa_switch *ds,
 				struct ethtool_eeprom *eeprom, u8 *data)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
 
 	if (eeprom->magic != 0xc3ec4951)
@@ -3953,7 +3953,7 @@ static int mv88e6xxx_smi_init(struct mv88e6xxx_chip *chip,
 
 static enum dsa_tag_protocol mv88e6xxx_get_tag_protocol(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 
 	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_EDSA))
 		return DSA_TAG_PROTO_EDSA;
@@ -4018,7 +4018,7 @@ static void mv88e6xxx_port_mdb_add(struct dsa_switch *ds, int port,
 				   const struct switchdev_obj_port_mdb *mdb,
 				   struct switchdev_trans *trans)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 
 	mutex_lock(&chip->reg_lock);
 	if (mv88e6xxx_port_db_load_purge(chip, port, mdb->addr, mdb->vid,
@@ -4030,7 +4030,7 @@ static void mv88e6xxx_port_mdb_add(struct dsa_switch *ds, int port,
 static int mv88e6xxx_port_mdb_del(struct dsa_switch *ds, int port,
 				  const struct switchdev_obj_port_mdb *mdb)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
 
 	mutex_lock(&chip->reg_lock);
@@ -4045,7 +4045,7 @@ static int mv88e6xxx_port_mdb_dump(struct dsa_switch *ds, int port,
 				   struct switchdev_obj_port_mdb *mdb,
 				   int (*cb)(struct switchdev_obj *obj))
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
 
 	mutex_lock(&chip->reg_lock);
@@ -4173,7 +4173,7 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 static void mv88e6xxx_remove(struct mdio_device *mdiodev)
 {
 	struct dsa_switch *ds = dev_get_drvdata(&mdiodev->dev);
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	struct mv88e6xxx_chip *chip = ds->priv;
 
 	mv88e6xxx_phy_destroy(chip);
 	mv88e6xxx_unregister_switch(chip);
diff --git a/include/net/dsa.h b/include/net/dsa.h
index e3eb230..9d97c52 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -391,11 +391,6 @@ void register_switch_driver(struct dsa_switch_ops *type);
 void unregister_switch_driver(struct dsa_switch_ops *type);
 struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
 
-static inline void *ds_to_priv(struct dsa_switch *ds)
-{
-	return ds->priv;
-}
-
 static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
 {
 	return dst->rcv != NULL;
-- 
2.9.3
