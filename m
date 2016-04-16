From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 6/8] net: dsa: mv88e6xxx: add number of ports to info
Date: Sat, 16 Apr 2016 18:41:43 -0400
Message-ID: <1460846505-20305-7-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1460846505-20305-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460846505-20305-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drop the ps->num_ports variable in favor of a new member of the info
structure. This removes the need to assign it at setup time.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6123.c | 16 +++-------------
 drivers/net/dsa/mv88e6131.c | 22 +++++-----------------
 drivers/net/dsa/mv88e6171.c |  7 ++++---
 drivers/net/dsa/mv88e6352.c |  8 ++++++--
 drivers/net/dsa/mv88e6xxx.c | 38 +++++++++++++++++++-------------------
 drivers/net/dsa/mv88e6xxx.h |  3 +--
 6 files changed, 38 insertions(+), 56 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 93429d2..e3802b4 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -22,14 +22,17 @@ static const struct mv88e6xxx_info mv88e6123_table[] = {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6123,
 		.family = MV88E6XXX_FAMILY_6165,
 		.name = "Marvell 88E6123",
+		.num_ports = 3,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6161,
 		.family = MV88E6XXX_FAMILY_6165,
 		.name = "Marvell 88E6161",
+		.num_ports = 6,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6165,
 		.family = MV88E6XXX_FAMILY_6165,
 		.name = "Marvell 88E6165",
+		.num_ports = 6,
 	}
 };
 
@@ -77,25 +80,12 @@ static int mv88e6123_setup_global(struct dsa_switch *ds)
 
 static int mv88e6123_setup(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
 	ret = mv88e6xxx_setup_common(ds);
 	if (ret < 0)
 		return ret;
 
-	switch (ps->id) {
-	case PORT_SWITCH_ID_6123:
-		ps->num_ports = 3;
-		break;
-	case PORT_SWITCH_ID_6161:
-	case PORT_SWITCH_ID_6165:
-		ps->num_ports = 6;
-		break;
-	default:
-		return -ENODEV;
-	}
-
 	ret = mv88e6xxx_switch_reset(ds, false);
 	if (ret < 0)
 		return ret;
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index ec06321..f6b465b 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -22,18 +22,22 @@ static const struct mv88e6xxx_info mv88e6131_table[] = {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6095,
 		.family = MV88E6XXX_FAMILY_6095,
 		.name = "Marvell 88E6095/88E6095F",
+		.num_ports = 11,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6085,
 		.family = MV88E6XXX_FAMILY_6097,
 		.name = "Marvell 88E6085",
+		.num_ports = 10,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6131,
 		.family = MV88E6XXX_FAMILY_6185,
 		.name = "Marvell 88E6131",
+		.num_ports = 8,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6185,
 		.family = MV88E6XXX_FAMILY_6185,
 		.name = "Marvell 88E6185",
+		.num_ports = 10,
 	}
 };
 
@@ -103,7 +107,6 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 
 static int mv88e6131_setup(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
 	ret = mv88e6xxx_setup_common(ds);
@@ -112,21 +115,6 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 
 	mv88e6xxx_ppu_state_init(ds);
 
-	switch (ps->id) {
-	case PORT_SWITCH_ID_6085:
-	case PORT_SWITCH_ID_6185:
-		ps->num_ports = 10;
-		break;
-	case PORT_SWITCH_ID_6095:
-		ps->num_ports = 11;
-		break;
-	case PORT_SWITCH_ID_6131:
-		ps->num_ports = 8;
-		break;
-	default:
-		return -ENODEV;
-	}
-
 	ret = mv88e6xxx_switch_reset(ds, false);
 	if (ret < 0)
 		return ret;
@@ -142,7 +130,7 @@ static int mv88e6131_port_to_phy_addr(struct dsa_switch *ds, int port)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
-	if (port >= 0 && port < ps->num_ports)
+	if (port >= 0 && port < ps->info->num_ports)
 		return port;
 
 	return -EINVAL;
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index efe3c0f..cdfa899 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -22,18 +22,22 @@ static const struct mv88e6xxx_info mv88e6171_table[] = {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6171,
 		.family = MV88E6XXX_FAMILY_6351,
 		.name = "Marvell 88E6171",
+		.num_ports = 7,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6175,
 		.family = MV88E6XXX_FAMILY_6351,
 		.name = "Marvell 88E6175",
+		.num_ports = 7,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6350,
 		.family = MV88E6XXX_FAMILY_6351,
 		.name = "Marvell 88E6350",
+		.num_ports = 7,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6351,
 		.family = MV88E6XXX_FAMILY_6351,
 		.name = "Marvell 88E6351",
+		.num_ports = 7,
 	}
 };
 
@@ -82,15 +86,12 @@ static int mv88e6171_setup_global(struct dsa_switch *ds)
 
 static int mv88e6171_setup(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
 	ret = mv88e6xxx_setup_common(ds);
 	if (ret < 0)
 		return ret;
 
-	ps->num_ports = 7;
-
 	ret = mv88e6xxx_switch_reset(ds, true);
 	if (ret < 0)
 		return ret;
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index c051c02..9aaddca 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -27,26 +27,32 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6320,
 		.family = MV88E6XXX_FAMILY_6320,
 		.name = "Marvell 88E6320",
+		.num_ports = 7,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6321,
 		.family = MV88E6XXX_FAMILY_6320,
 		.name = "Marvell 88E6321",
+		.num_ports = 7,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6172,
 		.family = MV88E6XXX_FAMILY_6352,
 		.name = "Marvell 88E6172",
+		.num_ports = 7,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6176,
 		.family = MV88E6XXX_FAMILY_6352,
 		.name = "Marvell 88E6176",
+		.num_ports = 7,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6240,
 		.family = MV88E6XXX_FAMILY_6352,
 		.name = "Marvell 88E6240",
+		.num_ports = 7,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6352,
 		.family = MV88E6XXX_FAMILY_6352,
 		.name = "Marvell 88E6352",
+		.num_ports = 7,
 	}
 };
 
@@ -101,8 +107,6 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	ps->num_ports = 7;
-
 	mutex_init(&ps->eeprom_mutex);
 
 	ret = mv88e6xxx_switch_reset(ds, true);
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index b3f0fd5..e9985dad 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -518,7 +518,7 @@ void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 		reg |= PORT_PCS_CTRL_DUPLEX_FULL;
 
 	if ((mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds)) &&
-	    (port >= ps->num_ports - 2)) {
+	    (port >= ps->info->num_ports - 2)) {
 		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID)
 			reg |= PORT_PCS_CTRL_RGMII_DELAY_RXCLK;
 		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)
@@ -1099,7 +1099,7 @@ static int _mv88e6xxx_port_based_vlan_map(struct dsa_switch *ds, int port)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	struct net_device *bridge = ps->ports[port].bridge_dev;
-	const u16 mask = (1 << ps->num_ports) - 1;
+	const u16 mask = (1 << ps->info->num_ports) - 1;
 	u16 output_ports = 0;
 	int reg;
 	int i;
@@ -1108,7 +1108,7 @@ static int _mv88e6xxx_port_based_vlan_map(struct dsa_switch *ds, int port)
 	if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) {
 		output_ports = mask;
 	} else {
-		for (i = 0; i < ps->num_ports; ++i) {
+		for (i = 0; i < ps->info->num_ports; ++i) {
 			/* allow sending frames to every group member */
 			if (bridge && ps->ports[i].bridge_dev == bridge)
 				output_ports |= BIT(i);
@@ -1249,7 +1249,7 @@ static int _mv88e6xxx_vtu_stu_data_read(struct dsa_switch *ds,
 		regs[i] = ret;
 	}
 
-	for (i = 0; i < ps->num_ports; ++i) {
+	for (i = 0; i < ps->info->num_ports; ++i) {
 		unsigned int shift = (i % 4) * 4 + nibble_offset;
 		u16 reg = regs[i / 4];
 
@@ -1268,7 +1268,7 @@ static int _mv88e6xxx_vtu_stu_data_write(struct dsa_switch *ds,
 	int i;
 	int ret;
 
-	for (i = 0; i < ps->num_ports; ++i) {
+	for (i = 0; i < ps->info->num_ports; ++i) {
 		unsigned int shift = (i % 4) * 4 + nibble_offset;
 		u8 data = entry->data[i];
 
@@ -1600,7 +1600,7 @@ static int _mv88e6xxx_fid_new(struct dsa_switch *ds, u16 *fid)
 	bitmap_zero(fid_bitmap, MV88E6XXX_N_FID);
 
 	/* Set every FID bit used by the (un)bridged ports */
-	for (i = 0; i < ps->num_ports; ++i) {
+	for (i = 0; i < ps->info->num_ports; ++i) {
 		err = _mv88e6xxx_port_fid_get(ds, i, fid);
 		if (err)
 			return err;
@@ -1650,7 +1650,7 @@ static int _mv88e6xxx_vtu_new(struct dsa_switch *ds, u16 vid,
 		return err;
 
 	/* exclude all ports except the CPU and DSA ports */
-	for (i = 0; i < ps->num_ports; ++i)
+	for (i = 0; i < ps->info->num_ports; ++i)
 		vlan.data[i] = dsa_is_cpu_port(ds, i) || dsa_is_dsa_port(ds, i)
 			? GLOBAL_VTU_DATA_MEMBER_TAG_UNMODIFIED
 			: GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
@@ -1739,7 +1739,7 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 		if (vlan.vid > vid_end)
 			break;
 
-		for (i = 0; i < ps->num_ports; ++i) {
+		for (i = 0; i < ps->info->num_ports; ++i) {
 			if (dsa_is_dsa_port(ds, i) || dsa_is_cpu_port(ds, i))
 				continue;
 
@@ -1888,7 +1888,7 @@ static int _mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid)
 
 	/* keep the VLAN unless all ports are excluded */
 	vlan.valid = false;
-	for (i = 0; i < ps->num_ports; ++i) {
+	for (i = 0; i < ps->info->num_ports; ++i) {
 		if (dsa_is_cpu_port(ds, i) || dsa_is_dsa_port(ds, i))
 			continue;
 
@@ -2197,11 +2197,11 @@ int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
 	mutex_lock(&ps->smi_mutex);
 
 	/* Get or create the bridge FID and assign it to the port */
-	for (i = 0; i < ps->num_ports; ++i)
+	for (i = 0; i < ps->info->num_ports; ++i)
 		if (ps->ports[i].bridge_dev == bridge)
 			break;
 
-	if (i < ps->num_ports)
+	if (i < ps->info->num_ports)
 		err = _mv88e6xxx_port_fid_get(ds, i, &fid);
 	else
 		err = _mv88e6xxx_fid_new(ds, &fid);
@@ -2215,7 +2215,7 @@ int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
 	/* Assign the bridge and remap each port's VLANTable */
 	ps->ports[port].bridge_dev = bridge;
 
-	for (i = 0; i < ps->num_ports; ++i) {
+	for (i = 0; i < ps->info->num_ports; ++i) {
 		if (ps->ports[i].bridge_dev == bridge) {
 			err = _mv88e6xxx_port_based_vlan_map(ds, i);
 			if (err)
@@ -2246,7 +2246,7 @@ void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 	/* Unassign the bridge and remap each port's VLANTable */
 	ps->ports[port].bridge_dev = NULL;
 
-	for (i = 0; i < ps->num_ports; ++i)
+	for (i = 0; i < ps->info->num_ports; ++i)
 		if (i == port || ps->ports[i].bridge_dev == bridge)
 			if (_mv88e6xxx_port_based_vlan_map(ds, i))
 				netdev_warn(ds->ports[i], "failed to remap\n");
@@ -2265,7 +2265,7 @@ static void mv88e6xxx_bridge_work(struct work_struct *work)
 
 	mutex_lock(&ps->smi_mutex);
 
-	for (port = 0; port < ps->num_ports; ++port)
+	for (port = 0; port < ps->info->num_ports; ++port)
 		if (test_and_clear_bit(port, ps->port_state_update_mask) &&
 		    _mv88e6xxx_port_state(ds, port, ps->ports[port].state))
 			netdev_warn(ds->ports[port], "failed to update state to %s\n",
@@ -2597,7 +2597,7 @@ int mv88e6xxx_setup_ports(struct dsa_switch *ds)
 	int ret;
 	int i;
 
-	for (i = 0; i < ps->num_ports; i++) {
+	for (i = 0; i < ps->info->num_ports; i++) {
 		ret = mv88e6xxx_setup_port(ds, i);
 		if (ret < 0)
 			return ret;
@@ -2675,7 +2675,7 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 	for (i = 0; i < 8; i++)
 		REG_WRITE(REG_GLOBAL2, GLOBAL2_TRUNK_MASK,
 			  0x8000 | (i << GLOBAL2_TRUNK_MASK_NUM_SHIFT) |
-			  ((1 << ps->num_ports) - 1));
+			  ((1 << ps->info->num_ports) - 1));
 
 	/* Clear all trunk mappings. */
 	for (i = 0; i < 16; i++)
@@ -2710,7 +2710,7 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 		 * ingress rate limit registers to their initial
 		 * state.
 		 */
-		for (i = 0; i < ps->num_ports; i++)
+		for (i = 0; i < ps->info->num_ports; i++)
 			REG_WRITE(REG_GLOBAL2, GLOBAL2_INGRESS_OP,
 				  0x9000 | (i << 8));
 	}
@@ -2747,7 +2747,7 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
 	int i;
 
 	/* Set all ports to the disabled state. */
-	for (i = 0; i < ps->num_ports; i++) {
+	for (i = 0; i < ps->info->num_ports; i++) {
 		ret = REG_READ(REG_PORT(i), PORT_CONTROL);
 		REG_WRITE(REG_PORT(i), PORT_CONTROL, ret & 0xfffc);
 	}
@@ -2815,7 +2815,7 @@ static int mv88e6xxx_port_to_phy_addr(struct dsa_switch *ds, int port)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
-	if (port >= 0 && port < ps->num_ports)
+	if (port >= 0 && port < ps->info->num_ports)
 		return port;
 	return -EINVAL;
 }
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 8bb2586..1f3ab6f 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -385,6 +385,7 @@ struct mv88e6xxx_info {
 	enum mv88e6xxx_family family;
 	u16 prod_num;
 	const char *name;
+	unsigned int num_ports;
 };
 
 struct mv88e6xxx_atu_entry {
@@ -456,8 +457,6 @@ struct mv88e6xxx_priv_state {
 	struct mutex eeprom_mutex;
 
 	int		id; /* switch product id */
-	int		num_ports;	/* number of switch ports */
-
 	struct mv88e6xxx_priv_port	ports[DSA_MAX_PORTS];
 
 	DECLARE_BITMAP(port_state_update_mask, DSA_MAX_PORTS);
-- 
2.8.0
