From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 5/7] net: dsa: mv88e6xxx: add number of ports to info
Date: Fri, 15 Apr 2016 14:25:48 -0400
Message-ID: <1460744750-13896-6-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1460744750-13896-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460744750-13896-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drop the ps->num_ports variable for a new member of the info structure.
This removes the need to assign it at setup time.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c | 19 +++----------------
 drivers/net/dsa/mv88e6131.c | 26 +++++---------------------
 drivers/net/dsa/mv88e6171.c | 11 ++++-------
 drivers/net/dsa/mv88e6352.c | 14 ++++++--------
 drivers/net/dsa/mv88e6xxx.c | 38 +++++++++++++++++++-------------------
 drivers/net/dsa/mv88e6xxx.h |  6 +++---
 6 files changed, 40 insertions(+), 74 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 36a0340..2048719 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -18,9 +18,9 @@
 #include "mv88e6xxx.h"
 
 static const struct mv88e6xxx_info mv88e6123_table[] = {
-	{ MV88E6XXX_INFO(6165, 0x121, "Marvell 88E6123") },
-	{ MV88E6XXX_INFO(6165, 0x161, "Marvell 88E6161") },
-	{ MV88E6XXX_INFO(6165, 0x165, "Marvell 88E6165") },
+	{ MV88E6XXX_INFO(6165, 0x121, 3, "Marvell 88E6123") },
+	{ MV88E6XXX_INFO(6165, 0x161, 6, "Marvell 88E6161") },
+	{ MV88E6XXX_INFO(6165, 0x165, 6, "Marvell 88E6165") },
 };
 
 static char *mv88e6123_drv_probe(struct device *dsa_dev,
@@ -67,25 +67,12 @@ static int mv88e6123_setup_global(struct dsa_switch *ds)
 
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
index f75d2dd..2eb9fa3 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -18,10 +18,10 @@
 #include "mv88e6xxx.h"
 
 static const struct mv88e6xxx_info mv88e6131_table[] = {
-	{ MV88E6XXX_INFO(6095, 0x095, "Marvell 88E6095/88E6095F") },
-	{ MV88E6XXX_INFO(6097, 0x04a, "Marvell 88E6085") },
-	{ MV88E6XXX_INFO(6185, 0x106, "Marvell 88E6131") },
-	{ MV88E6XXX_INFO(6185, 0x1a7, "Marvell 88E6185") },
+	{ MV88E6XXX_INFO(6095, 0x095, 11, "Marvell 88E6095/88E6095F") },
+	{ MV88E6XXX_INFO(6097, 0x04a, 10, "Marvell 88E6085") },
+	{ MV88E6XXX_INFO(6185, 0x106, 8,  "Marvell 88E6131") },
+	{ MV88E6XXX_INFO(6185, 0x1a7, 10, "Marvell 88E6185") },
 };
 
 static char *mv88e6131_drv_probe(struct device *dsa_dev,
@@ -90,7 +90,6 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 
 static int mv88e6131_setup(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
 	ret = mv88e6xxx_setup_common(ds);
@@ -99,21 +98,6 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 
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
@@ -129,7 +113,7 @@ static int mv88e6131_port_to_phy_addr(struct dsa_switch *ds, int port)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
-	if (port >= 0 && port < ps->num_ports)
+	if (port >= 0 && port < ps->info->num_ports)
 		return port;
 
 	return -EINVAL;
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index cb5bb19..d5f33d7 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -18,10 +18,10 @@
 #include "mv88e6xxx.h"
 
 static const struct mv88e6xxx_info mv88e6171_table[] = {
-	{ MV88E6XXX_INFO(6351, 0x171, "Marvell 88E6171") },
-	{ MV88E6XXX_INFO(6351, 0x175, "Marvell 88E6175") },
-	{ MV88E6XXX_INFO(6351, 0x371, "Marvell 88E6350") },
-	{ MV88E6XXX_INFO(6351, 0x375, "Marvell 88E6351") },
+	{ MV88E6XXX_INFO(6351, 0x171, 7, "Marvell 88E6171") },
+	{ MV88E6XXX_INFO(6351, 0x175, 7, "Marvell 88E6175") },
+	{ MV88E6XXX_INFO(6351, 0x371, 7, "Marvell 88E6350") },
+	{ MV88E6XXX_INFO(6351, 0x375, 7, "Marvell 88E6351") },
 };
 
 static char *mv88e6171_drv_probe(struct device *dsa_dev,
@@ -69,15 +69,12 @@ static int mv88e6171_setup_global(struct dsa_switch *ds)
 
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
index 94db0c3..e529c18 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -23,12 +23,12 @@
 #include "mv88e6xxx.h"
 
 static const struct mv88e6xxx_info mv88e6352_table[] = {
-	{ MV88E6XXX_INFO(6320, 0x115, "Marvell 88E6320") },
-	{ MV88E6XXX_INFO(6320, 0x310, "Marvell 88E6321") },
-	{ MV88E6XXX_INFO(6352, 0x172, "Marvell 88E6172") },
-	{ MV88E6XXX_INFO(6352, 0x176, "Marvell 88E6176") },
-	{ MV88E6XXX_INFO(6352, 0x240, "Marvell 88E6240") },
-	{ MV88E6XXX_INFO(6352, 0x352, "Marvell 88E6352") },
+	{ MV88E6XXX_INFO(6320, 0x115, 7, "Marvell 88E6320") },
+	{ MV88E6XXX_INFO(6320, 0x310, 7, "Marvell 88E6321") },
+	{ MV88E6XXX_INFO(6352, 0x172, 7, "Marvell 88E6172") },
+	{ MV88E6XXX_INFO(6352, 0x176, 7, "Marvell 88E6176") },
+	{ MV88E6XXX_INFO(6352, 0x240, 7, "Marvell 88E6240") },
+	{ MV88E6XXX_INFO(6352, 0x352, 7, "Marvell 88E6352") },
 };
 
 static char *mv88e6352_drv_probe(struct device *dsa_dev,
@@ -82,8 +82,6 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	ps->num_ports = 7;
-
 	mutex_init(&ps->eeprom_mutex);
 
 	ret = mv88e6xxx_switch_reset(ds, true);
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 05d59f9..f3e8c68 100644
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
index 3d2a186..6b2d62e 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -369,12 +369,14 @@ enum mv88e6xxx_family {
 struct mv88e6xxx_info {
 	enum mv88e6xxx_family family;
 	u16 prod_num;
+	unsigned int num_ports;
 	const char *name;
 };
 
-#define MV88E6XXX_INFO(_family, _prod_num, _name) \
+#define MV88E6XXX_INFO(_family, _prod_num, _num_ports, _name) \
 	.family = MV88E6XXX_FAMILY_##_family, \
 	.prod_num = _prod_num, \
+	.num_ports = _num_ports, \
 	.name = _name, \
 
 struct mv88e6xxx_atu_entry {
@@ -447,8 +449,6 @@ struct mv88e6xxx_priv_state {
 	struct mutex eeprom_mutex;
 
 	int		id; /* switch product id */
-	int		num_ports;	/* number of switch ports */
-
 	struct mv88e6xxx_priv_port	ports[DSA_MAX_PORTS];
 
 	DECLARE_BITMAP(port_state_update_mask, DSA_MAX_PORTS);
-- 
2.8.0
