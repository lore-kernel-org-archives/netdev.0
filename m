From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 02/20] net: dsa: mv88e6xxx: factorize PHY indirect access
Date: Thu,  5 May 2016 18:40:46 -0400
Message-ID: <1462488064-1841-3-git-send-email-vivien.didelot@savoirfairelinux.com>
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

Some switch has dedicated SMI PHY Command and Data registers, used to
indirectly access the PHYs, instead of direct access.

Identify these switch models and make mv88e6xxx_phy_{read,write} generic
enough to support every models.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6171.c |  8 ++++++--
 drivers/net/dsa/mv88e6352.c | 10 ++++++++--
 drivers/net/dsa/mv88e6xxx.c | 37 ++++---------------------------------
 drivers/net/dsa/mv88e6xxx.h | 10 +++++++---
 4 files changed, 25 insertions(+), 40 deletions(-)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index f75164d..304e25e 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -24,24 +24,28 @@ static const struct mv88e6xxx_info mv88e6171_table[] = {
 		.name = "Marvell 88E6171",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.flags = MV88E6XXX_FLAG_SMI_PHY,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6175,
 		.family = MV88E6XXX_FAMILY_6351,
 		.name = "Marvell 88E6175",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.flags = MV88E6XXX_FLAG_SMI_PHY,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6350,
 		.family = MV88E6XXX_FAMILY_6351,
 		.name = "Marvell 88E6350",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.flags = MV88E6XXX_FLAG_SMI_PHY,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6351,
 		.family = MV88E6XXX_FAMILY_6351,
 		.name = "Marvell 88E6351",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.flags = MV88E6XXX_FLAG_SMI_PHY,
 	}
 };
 
@@ -120,8 +124,8 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.probe			= mv88e6171_drv_probe,
 	.setup			= mv88e6171_setup,
 	.set_addr		= mv88e6xxx_set_addr_indirect,
-	.phy_read		= mv88e6xxx_phy_read_indirect,
-	.phy_write		= mv88e6xxx_phy_write_indirect,
+	.phy_read		= mv88e6xxx_phy_read,
+	.phy_write		= mv88e6xxx_phy_write,
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
 	.get_sset_count		= mv88e6xxx_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index c622a1d..df9f944 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -29,36 +29,42 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.name = "Marvell 88E6320",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.flags = MV88E6XXX_FLAG_SMI_PHY,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6321,
 		.family = MV88E6XXX_FAMILY_6320,
 		.name = "Marvell 88E6321",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.flags = MV88E6XXX_FLAG_SMI_PHY,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6172,
 		.family = MV88E6XXX_FAMILY_6352,
 		.name = "Marvell 88E6172",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.flags = MV88E6XXX_FLAG_SMI_PHY,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6176,
 		.family = MV88E6XXX_FAMILY_6352,
 		.name = "Marvell 88E6176",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.flags = MV88E6XXX_FLAG_SMI_PHY,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6240,
 		.family = MV88E6XXX_FAMILY_6352,
 		.name = "Marvell 88E6240",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.flags = MV88E6XXX_FLAG_SMI_PHY,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6352,
 		.family = MV88E6XXX_FAMILY_6352,
 		.name = "Marvell 88E6352",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.flags = MV88E6XXX_FLAG_SMI_PHY,
 	}
 };
 
@@ -338,8 +344,8 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.probe			= mv88e6352_drv_probe,
 	.setup			= mv88e6352_setup,
 	.set_addr		= mv88e6xxx_set_addr_indirect,
-	.phy_read		= mv88e6xxx_phy_read_indirect,
-	.phy_write		= mv88e6xxx_phy_write_indirect,
+	.phy_read		= mv88e6xxx_phy_read,
+	.phy_write		= mv88e6xxx_phy_write,
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
 	.get_sset_count		= mv88e6xxx_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 4e031aa..e48271c 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2868,6 +2868,8 @@ mv88e6xxx_phy_read(struct dsa_switch *ds, int port, int regnum)
 
 	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU))
 		ret = _mv88e6xxx_phy_read_ppu(ps, addr, regnum);
+	else if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_SMI_PHY))
+		ret = _mv88e6xxx_phy_read_indirect(ps, addr, regnum);
 	else
 		ret = _mv88e6xxx_phy_read(ps, addr, regnum);
 
@@ -2891,6 +2893,8 @@ mv88e6xxx_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
 
 	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU))
 		err = _mv88e6xxx_phy_write_ppu(ps, addr, regnum, val);
+	else if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_SMI_PHY))
+		err = _mv88e6xxx_phy_write_indirect(ps, addr, regnum, val);
 	else
 		err = _mv88e6xxx_phy_write(ps, addr, regnum, val);
 
@@ -2899,39 +2903,6 @@ mv88e6xxx_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
 	return err;
 }
 
-int
-mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int port, int regnum)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int addr = mv88e6xxx_port_to_phy_addr(ps, port);
-	int ret;
-
-	if (addr < 0)
-		return 0xffff;
-
-	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_phy_read_indirect(ps, addr, regnum);
-	mutex_unlock(&ps->smi_mutex);
-	return ret;
-}
-
-int
-mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int port, int regnum,
-			     u16 val)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int addr = mv88e6xxx_port_to_phy_addr(ps, port);
-	int ret;
-
-	if (addr < 0)
-		return addr;
-
-	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_phy_write_indirect(ps, addr, regnum, val);
-	mutex_unlock(&ps->smi_mutex);
-	return ret;
-}
-
 #ifdef CONFIG_NET_DSA_HWMON
 
 static int mv88e61xx_get_temp(struct dsa_switch *ds, int *temp)
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 3e77985..95cbb8b 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -355,10 +355,17 @@ enum mv88e6xxx_cap {
 	 * See GLOBAL_CONTROL_PPU_ENABLE and GLOBAL_STATUS_PPU_POLLING.
 	 */
 	MV88E6XXX_CAP_PPU,
+
+	/* SMI PHY Command and Data registers.
+	 * This requires an indirect access to PHY registers through
+	 * GLOBAL2_SMI_OP, otherwise direct access to PHY registers is done.
+	 */
+	MV88E6XXX_CAP_SMI_PHY,
 };
 
 /* Bitmask of capabilities */
 #define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
+#define MV88E6XXX_FLAG_SMI_PHY		BIT(MV88E6XXX_CAP_SMI_PHY)
 
 struct mv88e6xxx_info {
 	enum mv88e6xxx_family family;
@@ -480,9 +487,6 @@ int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr);
 int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr);
 int mv88e6xxx_phy_read(struct dsa_switch *ds, int port, int regnum);
 int mv88e6xxx_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val);
-int mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int port, int regnum);
-int mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int port, int regnum,
-				 u16 val);
 void mv88e6xxx_get_strings(struct dsa_switch *ds, int port, uint8_t *data);
 void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds, int port,
 				 uint64_t *data);
-- 
2.8.2
