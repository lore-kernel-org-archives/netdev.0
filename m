From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 10/20] net: dsa: mv88e6xxx: factorize ATU access
Date: Thu,  5 May 2016 18:40:54 -0400
Message-ID: <1462488064-1841-11-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a MV88E6XXX_FLAG_ATU flag to identify switch models with an Address
Translation Unit.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c |  4 ++++
 drivers/net/dsa/mv88e6131.c | 12 ++++++++----
 drivers/net/dsa/mv88e6171.c | 12 ++++++++----
 drivers/net/dsa/mv88e6352.c | 18 ++++++++++++------
 drivers/net/dsa/mv88e6xxx.c | 14 ++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  6 ++++++
 6 files changed, 52 insertions(+), 14 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 3992f4f..c562c4a 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -144,6 +144,10 @@ struct dsa_switch_driver mv88e6123_switch_driver = {
 	.port_vlan_add		= mv88e6xxx_port_vlan_add,
 	.port_vlan_del		= mv88e6xxx_port_vlan_del,
 	.port_vlan_dump		= mv88e6xxx_port_vlan_dump,
+	.port_fdb_prepare       = mv88e6xxx_port_fdb_prepare,
+	.port_fdb_add           = mv88e6xxx_port_fdb_add,
+	.port_fdb_del           = mv88e6xxx_port_fdb_del,
+	.port_fdb_dump          = mv88e6xxx_port_fdb_dump,
 };
 
 MODULE_ALIAS("platform:mv88e6123");
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index d99ebad..655781f 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -24,7 +24,8 @@ static const struct mv88e6xxx_info mv88e6131_table[] = {
 		.name = "Marvell 88E6095/88E6095F",
 		.num_databases = 256,
 		.num_ports = 11,
-		.flags = MV88E6XXX_FLAG_PPU |
+		.flags = MV88E6XXX_FLAG_ATU |
+			MV88E6XXX_FLAG_PPU |
 			MV88E6XXX_FLAG_VLANTABLE |
 			MV88E6XXX_FLAG_VTU,
 	}, {
@@ -33,7 +34,8 @@ static const struct mv88e6xxx_info mv88e6131_table[] = {
 		.name = "Marvell 88E6085",
 		.num_databases = 4096,
 		.num_ports = 10,
-		.flags = MV88E6XXX_FLAG_PPU |
+		.flags = MV88E6XXX_FLAG_ATU |
+			MV88E6XXX_FLAG_PPU |
 			MV88E6XXX_FLAG_VLANTABLE |
 			MV88E6XXX_FLAG_VTU,
 	}, {
@@ -42,7 +44,8 @@ static const struct mv88e6xxx_info mv88e6131_table[] = {
 		.name = "Marvell 88E6131",
 		.num_databases = 256,
 		.num_ports = 8,
-		.flags = MV88E6XXX_FLAG_PPU |
+		.flags = MV88E6XXX_FLAG_ATU |
+			MV88E6XXX_FLAG_PPU |
 			MV88E6XXX_FLAG_VLANTABLE |
 			MV88E6XXX_FLAG_VTU,
 	}, {
@@ -51,7 +54,8 @@ static const struct mv88e6xxx_info mv88e6131_table[] = {
 		.name = "Marvell 88E6185",
 		.num_databases = 256,
 		.num_ports = 10,
-		.flags = MV88E6XXX_FLAG_PPU |
+		.flags = MV88E6XXX_FLAG_ATU |
+			MV88E6XXX_FLAG_PPU |
 			MV88E6XXX_FLAG_VLANTABLE |
 			MV88E6XXX_FLAG_VTU,
 	}
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index bbea365..66e581f 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -24,7 +24,8 @@ static const struct mv88e6xxx_info mv88e6171_table[] = {
 		.name = "Marvell 88E6171",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_PORTSTATE |
+		.flags = MV88E6XXX_FLAG_ATU |
+			MV88E6XXX_FLAG_PORTSTATE |
 			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
@@ -36,7 +37,8 @@ static const struct mv88e6xxx_info mv88e6171_table[] = {
 		.name = "Marvell 88E6175",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_PORTSTATE |
+		.flags = MV88E6XXX_FLAG_ATU |
+			MV88E6XXX_FLAG_PORTSTATE |
 			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
@@ -48,7 +50,8 @@ static const struct mv88e6xxx_info mv88e6171_table[] = {
 		.name = "Marvell 88E6350",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_PORTSTATE |
+		.flags = MV88E6XXX_FLAG_ATU |
+			MV88E6XXX_FLAG_PORTSTATE |
 			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
@@ -60,7 +63,8 @@ static const struct mv88e6xxx_info mv88e6171_table[] = {
 		.name = "Marvell 88E6351",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_PORTSTATE |
+		.flags = MV88E6XXX_FLAG_ATU |
+			MV88E6XXX_FLAG_PORTSTATE |
 			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 0ed4172..f10aaee 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -29,7 +29,8 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.name = "Marvell 88E6320",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_EEE |
+		.flags = MV88E6XXX_FLAG_ATU |
+			MV88E6XXX_FLAG_EEE |
 			MV88E6XXX_FLAG_EEPROM |
 			MV88E6XXX_FLAG_PORTSTATE |
 			MV88E6XXX_FLAG_SMI_PHY |
@@ -44,7 +45,8 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.name = "Marvell 88E6321",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_EEE |
+		.flags = MV88E6XXX_FLAG_ATU |
+			MV88E6XXX_FLAG_EEE |
 			MV88E6XXX_FLAG_EEPROM |
 			MV88E6XXX_FLAG_PORTSTATE |
 			MV88E6XXX_FLAG_SMI_PHY |
@@ -59,7 +61,8 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.name = "Marvell 88E6172",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_EEE |
+		.flags = MV88E6XXX_FLAG_ATU |
+			MV88E6XXX_FLAG_EEE |
 			MV88E6XXX_FLAG_EEPROM |
 			MV88E6XXX_FLAG_PORTSTATE |
 			MV88E6XXX_FLAG_SMI_PHY |
@@ -74,7 +77,8 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.name = "Marvell 88E6176",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_EEE |
+		.flags = MV88E6XXX_FLAG_ATU |
+			MV88E6XXX_FLAG_EEE |
 			MV88E6XXX_FLAG_EEPROM |
 			MV88E6XXX_FLAG_PORTSTATE |
 			MV88E6XXX_FLAG_SMI_PHY |
@@ -89,7 +93,8 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.name = "Marvell 88E6240",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_EEE |
+		.flags = MV88E6XXX_FLAG_ATU |
+			MV88E6XXX_FLAG_EEE |
 			MV88E6XXX_FLAG_EEPROM |
 			MV88E6XXX_FLAG_PORTSTATE |
 			MV88E6XXX_FLAG_SMI_PHY |
@@ -104,7 +109,8 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.name = "Marvell 88E6352",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_EEE |
+		.flags = MV88E6XXX_FLAG_ATU |
+			MV88E6XXX_FLAG_EEE |
 			MV88E6XXX_FLAG_EEPROM |
 			MV88E6XXX_FLAG_PORTSTATE |
 			MV88E6XXX_FLAG_SMI_PHY |
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 805bd0f..810226d 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2265,6 +2265,11 @@ int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
 			       const struct switchdev_obj_port_fdb *fdb,
 			       struct switchdev_trans *trans)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_ATU))
+		return -EOPNOTSUPP;
+
 	/* We don't need any dynamic resource from the kernel (yet),
 	 * so skip the prepare phase.
 	 */
@@ -2280,6 +2285,9 @@ void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 		GLOBAL_ATU_DATA_STATE_UC_STATIC;
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_ATU))
+		return;
+
 	mutex_lock(&ps->smi_mutex);
 	if (_mv88e6xxx_port_fdb_load(ps, port, fdb->addr, fdb->vid, state))
 		netdev_err(ds->ports[port], "failed to load MAC address\n");
@@ -2292,6 +2300,9 @@ int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_ATU))
+		return -EOPNOTSUPP;
+
 	mutex_lock(&ps->smi_mutex);
 	ret = _mv88e6xxx_port_fdb_load(ps, port, fdb->addr, fdb->vid,
 				       GLOBAL_ATU_DATA_STATE_UNUSED);
@@ -2397,6 +2408,9 @@ int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
 	u16 fid;
 	int err;
 
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_ATU))
+		return -EOPNOTSUPP;
+
 	mutex_lock(&ps->smi_mutex);
 
 	/* Dump port's default Filtering Information Database (VLAN ID 0) */
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 9de6ae9..e639de7 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -351,6 +351,11 @@ enum mv88e6xxx_family {
 };
 
 enum mv88e6xxx_cap {
+	/* Address Translation Unit.
+	 * The ATU is used to lookup and learn MAC addresses. See GLOBAL_ATU_OP.
+	 */
+	MV88E6XXX_CAP_ATU,
+
 	/* Energy Efficient Ethernet.
 	 */
 	MV88E6XXX_CAP_EEE,
@@ -402,6 +407,7 @@ enum mv88e6xxx_cap {
 };
 
 /* Bitmask of capabilities */
+#define MV88E6XXX_FLAG_ATU		BIT(MV88E6XXX_CAP_ATU)
 #define MV88E6XXX_FLAG_EEE		BIT(MV88E6XXX_CAP_EEE)
 #define MV88E6XXX_FLAG_EEPROM		BIT(MV88E6XXX_CAP_EEPROM)
 #define MV88E6XXX_FLAG_PORTSTATE	BIT(MV88E6XXX_CAP_PORTSTATE)
-- 
2.8.2
