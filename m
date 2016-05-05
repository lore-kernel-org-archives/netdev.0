From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 06/20] net: dsa: mv88e6xxx: factorize EEE access
Date: Thu,  5 May 2016 18:40:50 -0400
Message-ID: <1462488064-1841-7-git-send-email-vivien.didelot@savoirfairelinux.com>
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

Add a MV88E6XXX_FLAG_EEE flag to describe switch models featuring Energy
Efficient Ethernet. Use it to conditionally support such access in the
common code.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c |  2 ++
 drivers/net/dsa/mv88e6131.c |  2 ++
 drivers/net/dsa/mv88e6171.c |  2 ++
 drivers/net/dsa/mv88e6352.c | 18 ++++++++++++------
 drivers/net/dsa/mv88e6xxx.c |  6 ++++++
 drivers/net/dsa/mv88e6xxx.h |  5 +++++
 6 files changed, 29 insertions(+), 6 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 57a6d76..e5335c2 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -120,6 +120,8 @@ struct dsa_switch_driver mv88e6123_switch_driver = {
 	.set_addr		= mv88e6xxx_set_addr,
 	.phy_read		= mv88e6xxx_phy_read,
 	.phy_write		= mv88e6xxx_phy_write,
+	.set_eee		= mv88e6xxx_set_eee,
+	.get_eee		= mv88e6xxx_get_eee,
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
 	.get_sset_count		= mv88e6xxx_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 519d1eb..73cf879 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -150,6 +150,8 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.set_addr		= mv88e6xxx_set_addr,
 	.phy_read		= mv88e6xxx_phy_read,
 	.phy_write		= mv88e6xxx_phy_write,
+	.set_eee		= mv88e6xxx_set_eee,
+	.get_eee		= mv88e6xxx_get_eee,
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
 	.get_sset_count		= mv88e6xxx_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index f947950..6953d12 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -134,6 +134,8 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.set_addr		= mv88e6xxx_set_addr,
 	.phy_read		= mv88e6xxx_phy_read,
 	.phy_write		= mv88e6xxx_phy_write,
+	.set_eee		= mv88e6xxx_set_eee,
+	.get_eee		= mv88e6xxx_get_eee,
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
 	.get_sset_count		= mv88e6xxx_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 90732da..d4ebfb3 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -29,7 +29,8 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.name = "Marvell 88E6320",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_EEPROM |
+		.flags = MV88E6XXX_FLAG_EEE |
+			MV88E6XXX_FLAG_EEPROM |
 			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
@@ -40,7 +41,8 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.name = "Marvell 88E6321",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_EEPROM |
+		.flags = MV88E6XXX_FLAG_EEE |
+			MV88E6XXX_FLAG_EEPROM |
 			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
@@ -51,7 +53,8 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.name = "Marvell 88E6172",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_EEPROM |
+		.flags = MV88E6XXX_FLAG_EEE |
+			MV88E6XXX_FLAG_EEPROM |
 			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
@@ -62,7 +65,8 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.name = "Marvell 88E6176",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_EEPROM |
+		.flags = MV88E6XXX_FLAG_EEE |
+			MV88E6XXX_FLAG_EEPROM |
 			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
@@ -73,7 +77,8 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.name = "Marvell 88E6240",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_EEPROM |
+		.flags = MV88E6XXX_FLAG_EEE |
+			MV88E6XXX_FLAG_EEPROM |
 			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
@@ -84,7 +89,8 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.name = "Marvell 88E6352",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_EEPROM |
+		.flags = MV88E6XXX_FLAG_EEE |
+			MV88E6XXX_FLAG_EEPROM |
 			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 5483e69..1fbd6d2 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1032,6 +1032,9 @@ int mv88e6xxx_get_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e)
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int reg;
 
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEE))
+		return -EOPNOTSUPP;
+
 	mutex_lock(&ps->smi_mutex);
 
 	reg = _mv88e6xxx_phy_read_indirect(ps, port, 16);
@@ -1060,6 +1063,9 @@ int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 	int reg;
 	int ret;
 
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEE))
+		return -EOPNOTSUPP;
+
 	mutex_lock(&ps->smi_mutex);
 
 	ret = _mv88e6xxx_phy_read_indirect(ps, port, 16);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 72b563e..305bccf 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -351,6 +351,10 @@ enum mv88e6xxx_family {
 };
 
 enum mv88e6xxx_cap {
+	/* Energy Efficient Ethernet.
+	 */
+	MV88E6XXX_CAP_EEE,
+
 	/* EEPROM Command and Data registers.
 	 * See GLOBAL2_EEPROM_OP and GLOBAL2_EEPROM_DATA.
 	 */
@@ -382,6 +386,7 @@ enum mv88e6xxx_cap {
 };
 
 /* Bitmask of capabilities */
+#define MV88E6XXX_FLAG_EEE		BIT(MV88E6XXX_CAP_EEE)
 #define MV88E6XXX_FLAG_EEPROM		BIT(MV88E6XXX_CAP_EEPROM)
 #define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
 #define MV88E6XXX_FLAG_SMI_PHY		BIT(MV88E6XXX_CAP_SMI_PHY)
-- 
2.8.2
