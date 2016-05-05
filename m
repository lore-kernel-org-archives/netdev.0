From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 09/20] net: dsa: mv88e6xxx: factorize VTU access
Date: Thu,  5 May 2016 18:40:53 -0400
Message-ID: <1462488064-1841-10-git-send-email-vivien.didelot@savoirfairelinux.com>
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

Add a MV88E6XXX_FLAG_VTU flag to indentify switch models with a VLAN
Table Unit.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c |  5 +++++
 drivers/net/dsa/mv88e6131.c | 12 ++++++++----
 drivers/net/dsa/mv88e6171.c | 12 ++++++++----
 drivers/net/dsa/mv88e6352.c | 18 ++++++++++++------
 drivers/net/dsa/mv88e6xxx.c | 16 ++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  6 ++++++
 6 files changed, 55 insertions(+), 14 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 05d5196..3992f4f 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -139,6 +139,11 @@ struct dsa_switch_driver mv88e6123_switch_driver = {
 	.port_bridge_join	= mv88e6xxx_port_bridge_join,
 	.port_bridge_leave	= mv88e6xxx_port_bridge_leave,
 	.port_stp_state_set	= mv88e6xxx_port_stp_state_set,
+	.port_vlan_filtering	= mv88e6xxx_port_vlan_filtering,
+	.port_vlan_prepare	= mv88e6xxx_port_vlan_prepare,
+	.port_vlan_add		= mv88e6xxx_port_vlan_add,
+	.port_vlan_del		= mv88e6xxx_port_vlan_del,
+	.port_vlan_dump		= mv88e6xxx_port_vlan_dump,
 };
 
 MODULE_ALIAS("platform:mv88e6123");
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 125fbbb..d99ebad 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -25,7 +25,8 @@ static const struct mv88e6xxx_info mv88e6131_table[] = {
 		.num_databases = 256,
 		.num_ports = 11,
 		.flags = MV88E6XXX_FLAG_PPU |
-			MV88E6XXX_FLAG_VLANTABLE,
+			MV88E6XXX_FLAG_VLANTABLE |
+			MV88E6XXX_FLAG_VTU,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6085,
 		.family = MV88E6XXX_FAMILY_6097,
@@ -33,7 +34,8 @@ static const struct mv88e6xxx_info mv88e6131_table[] = {
 		.num_databases = 4096,
 		.num_ports = 10,
 		.flags = MV88E6XXX_FLAG_PPU |
-			MV88E6XXX_FLAG_VLANTABLE,
+			MV88E6XXX_FLAG_VLANTABLE |
+			MV88E6XXX_FLAG_VTU,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6131,
 		.family = MV88E6XXX_FAMILY_6185,
@@ -41,7 +43,8 @@ static const struct mv88e6xxx_info mv88e6131_table[] = {
 		.num_databases = 256,
 		.num_ports = 8,
 		.flags = MV88E6XXX_FLAG_PPU |
-			MV88E6XXX_FLAG_VLANTABLE,
+			MV88E6XXX_FLAG_VLANTABLE |
+			MV88E6XXX_FLAG_VTU,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6185,
 		.family = MV88E6XXX_FAMILY_6185,
@@ -49,7 +52,8 @@ static const struct mv88e6xxx_info mv88e6131_table[] = {
 		.num_databases = 256,
 		.num_ports = 10,
 		.flags = MV88E6XXX_FLAG_PPU |
-			MV88E6XXX_FLAG_VLANTABLE,
+			MV88E6XXX_FLAG_VLANTABLE |
+			MV88E6XXX_FLAG_VTU,
 	}
 };
 
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 8ba338d..bbea365 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -28,7 +28,8 @@ static const struct mv88e6xxx_info mv88e6171_table[] = {
 			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
-			MV88E6XXX_FLAG_VLANTABLE,
+			MV88E6XXX_FLAG_VLANTABLE |
+			MV88E6XXX_FLAG_VTU,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6175,
 		.family = MV88E6XXX_FAMILY_6351,
@@ -39,7 +40,8 @@ static const struct mv88e6xxx_info mv88e6171_table[] = {
 			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
-			MV88E6XXX_FLAG_VLANTABLE,
+			MV88E6XXX_FLAG_VLANTABLE |
+			MV88E6XXX_FLAG_VTU,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6350,
 		.family = MV88E6XXX_FAMILY_6351,
@@ -50,7 +52,8 @@ static const struct mv88e6xxx_info mv88e6171_table[] = {
 			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
-			MV88E6XXX_FLAG_VLANTABLE,
+			MV88E6XXX_FLAG_VLANTABLE |
+			MV88E6XXX_FLAG_VTU,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6351,
 		.family = MV88E6XXX_FAMILY_6351,
@@ -61,7 +64,8 @@ static const struct mv88e6xxx_info mv88e6171_table[] = {
 			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
-			MV88E6XXX_FLAG_VLANTABLE,
+			MV88E6XXX_FLAG_VLANTABLE |
+			MV88E6XXX_FLAG_VTU,
 	}
 };
 
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index a67dcf9..0ed4172 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -36,7 +36,8 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
 			MV88E6XXX_FLAG_TEMP_LIMIT |
-			MV88E6XXX_FLAG_VLANTABLE,
+			MV88E6XXX_FLAG_VLANTABLE |
+			MV88E6XXX_FLAG_VTU,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6321,
 		.family = MV88E6XXX_FAMILY_6320,
@@ -50,7 +51,8 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
 			MV88E6XXX_FLAG_TEMP_LIMIT |
-			MV88E6XXX_FLAG_VLANTABLE,
+			MV88E6XXX_FLAG_VLANTABLE |
+			MV88E6XXX_FLAG_VTU,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6172,
 		.family = MV88E6XXX_FAMILY_6352,
@@ -64,7 +66,8 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
 			MV88E6XXX_FLAG_TEMP_LIMIT |
-			MV88E6XXX_FLAG_VLANTABLE,
+			MV88E6XXX_FLAG_VLANTABLE |
+			MV88E6XXX_FLAG_VTU,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6176,
 		.family = MV88E6XXX_FAMILY_6352,
@@ -78,7 +81,8 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
 			MV88E6XXX_FLAG_TEMP_LIMIT |
-			MV88E6XXX_FLAG_VLANTABLE,
+			MV88E6XXX_FLAG_VLANTABLE |
+			MV88E6XXX_FLAG_VTU,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6240,
 		.family = MV88E6XXX_FAMILY_6352,
@@ -92,7 +96,8 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
 			MV88E6XXX_FLAG_TEMP_LIMIT |
-			MV88E6XXX_FLAG_VLANTABLE,
+			MV88E6XXX_FLAG_VLANTABLE |
+			MV88E6XXX_FLAG_VTU,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6352,
 		.family = MV88E6XXX_FAMILY_6352,
@@ -106,7 +111,8 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
 			MV88E6XXX_FLAG_TEMP_LIMIT |
-			MV88E6XXX_FLAG_VLANTABLE,
+			MV88E6XXX_FLAG_VLANTABLE |
+			MV88E6XXX_FLAG_VTU,
 	}
 };
 
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index c6e4254e..805bd0f 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1586,6 +1586,9 @@ int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 	u16 pvid;
 	int err;
 
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_VTU))
+		return -EOPNOTSUPP;
+
 	mutex_lock(&ps->smi_mutex);
 
 	err = _mv88e6xxx_port_pvid_get(ps, port, &pvid);
@@ -2009,6 +2012,9 @@ int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
 		PORT_CONTROL_2_8021Q_DISABLED;
 	int ret;
 
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_VTU))
+		return -EOPNOTSUPP;
+
 	mutex_lock(&ps->smi_mutex);
 
 	ret = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_CONTROL_2);
@@ -2042,8 +2048,12 @@ int mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
 				const struct switchdev_obj_port_vlan *vlan,
 				struct switchdev_trans *trans)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int err;
 
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_VTU))
+		return -EOPNOTSUPP;
+
 	/* If the requested port doesn't belong to the same bridge as the VLAN
 	 * members, do not support it (yet) and fallback to software VLAN.
 	 */
@@ -2084,6 +2094,9 @@ void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
 	bool pvid = vlan->flags & BRIDGE_VLAN_INFO_PVID;
 	u16 vid;
 
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_VTU))
+		return;
+
 	mutex_lock(&ps->smi_mutex);
 
 	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid)
@@ -2141,6 +2154,9 @@ int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
 	u16 pvid, vid;
 	int err = 0;
 
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_VTU))
+		return -EOPNOTSUPP;
+
 	mutex_lock(&ps->smi_mutex);
 
 	err = _mv88e6xxx_port_pvid_get(ps, port, &pvid);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index bf8475b..9de6ae9 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -394,6 +394,11 @@ enum mv88e6xxx_cap {
 	 * the output (or egress) ports to which it is allowed to send frames.
 	 */
 	MV88E6XXX_CAP_VLANTABLE,
+
+	/* VLAN Table Unit.
+	 * The VTU is used to program 802.1Q VLANs. See GLOBAL_VTU_OP.
+	 */
+	MV88E6XXX_CAP_VTU,
 };
 
 /* Bitmask of capabilities */
@@ -406,6 +411,7 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_TEMP		BIT(MV88E6XXX_CAP_TEMP)
 #define MV88E6XXX_FLAG_TEMP_LIMIT	BIT(MV88E6XXX_CAP_TEMP_LIMIT)
 #define MV88E6XXX_FLAG_VLANTABLE	BIT(MV88E6XXX_CAP_VLANTABLE)
+#define MV88E6XXX_FLAG_VTU		BIT(MV88E6XXX_CAP_VTU)
 
 struct mv88e6xxx_info {
 	enum mv88e6xxx_family family;
-- 
2.8.2
