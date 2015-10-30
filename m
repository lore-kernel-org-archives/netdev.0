From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: mv88e6xxx: lookup switch name
Date: Fri, 30 Oct 2015 16:36:56 -0400
Message-ID: <1446237416-5447-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All the mv88e6xxx drivers use the exact same code in their probe
function to lookup the switch name given its ID. Thus introduce a
mv88e6xxx_switch_id structure and a mv88e6xxx_lookup_name function in
the common mv88e6xxx code.

In the meantime make __mv88e6xxx_reg_{read,write} static since they we
do not to expose these low-level r/w routines anymore.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123_61_65.c | 45 +++++++++++------------------------
 drivers/net/dsa/mv88e6131.c       | 33 ++++++++------------------
 drivers/net/dsa/mv88e6171.c       | 28 +++++++---------------
 drivers/net/dsa/mv88e6352.c       | 49 +++++++++++++--------------------------
 drivers/net/dsa/mv88e6xxx.c       | 41 +++++++++++++++++++++++++++++---
 drivers/net/dsa/mv88e6xxx.h       | 13 ++++++++---
 6 files changed, 97 insertions(+), 112 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index 4bcfd68..d4fcf45 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -17,39 +17,22 @@
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
+static const struct mv88e6xxx_switch_id mv88e6123_61_65_table[] = {
+	{ PORT_SWITCH_ID_6123, "Marvell 88E6123" },
+	{ PORT_SWITCH_ID_6123_A1, "Marvell 88E6123 (A1)" },
+	{ PORT_SWITCH_ID_6123_A2, "Marvell 88E6123 (A2)" },
+	{ PORT_SWITCH_ID_6161, "Marvell 88E6161" },
+	{ PORT_SWITCH_ID_6161_A1, "Marvell 88E6161 (A1)" },
+	{ PORT_SWITCH_ID_6161_A2, "Marvell 88E6161 (A2)" },
+	{ PORT_SWITCH_ID_6165, "Marvell 88E6165" },
+	{ PORT_SWITCH_ID_6165_A1, "Marvell 88E6165 (A1)" },
+	{ PORT_SWITCH_ID_6165_A2, "Marvell 88e6165 (A2)" },
+};
+
 static char *mv88e6123_61_65_probe(struct device *host_dev, int sw_addr)
 {
-	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
-	int ret;
-
-	if (bus == NULL)
-		return NULL;
-
-	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
-	if (ret >= 0) {
-		if (ret == PORT_SWITCH_ID_6123_A1)
-			return "Marvell 88E6123 (A1)";
-		if (ret == PORT_SWITCH_ID_6123_A2)
-			return "Marvell 88E6123 (A2)";
-		if ((ret & 0xfff0) == PORT_SWITCH_ID_6123)
-			return "Marvell 88E6123";
-
-		if (ret == PORT_SWITCH_ID_6161_A1)
-			return "Marvell 88E6161 (A1)";
-		if (ret == PORT_SWITCH_ID_6161_A2)
-			return "Marvell 88E6161 (A2)";
-		if ((ret & 0xfff0) == PORT_SWITCH_ID_6161)
-			return "Marvell 88E6161";
-
-		if (ret == PORT_SWITCH_ID_6165_A1)
-			return "Marvell 88E6165 (A1)";
-		if (ret == PORT_SWITCH_ID_6165_A2)
-			return "Marvell 88e6165 (A2)";
-		if ((ret & 0xfff0) == PORT_SWITCH_ID_6165)
-			return "Marvell 88E6165";
-	}
-
-	return NULL;
+	return mv88e6xxx_lookup_name(host_dev, sw_addr, mv88e6123_61_65_table,
+				     ARRAY_SIZE(mv88e6123_61_65_table));
 }
 
 static int mv88e6123_61_65_setup_global(struct dsa_switch *ds)
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index c73121c..a92ca65 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -17,31 +17,18 @@
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
+static const struct mv88e6xxx_switch_id mv88e6131_table[] = {
+	{ PORT_SWITCH_ID_6085, "Marvell 88E6085" },
+	{ PORT_SWITCH_ID_6095, "Marvell 88E6095/88E6095F" },
+	{ PORT_SWITCH_ID_6131, "Marvell 88E6131" },
+	{ PORT_SWITCH_ID_6131_B2, "Marvell 88E6131 (B2)" },
+	{ PORT_SWITCH_ID_6185, "Marvell 88E6185" },
+};
+
 static char *mv88e6131_probe(struct device *host_dev, int sw_addr)
 {
-	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
-	int ret;
-
-	if (bus == NULL)
-		return NULL;
-
-	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
-	if (ret >= 0) {
-		int ret_masked = ret & 0xfff0;
-
-		if (ret_masked == PORT_SWITCH_ID_6085)
-			return "Marvell 88E6085";
-		if (ret_masked == PORT_SWITCH_ID_6095)
-			return "Marvell 88E6095/88E6095F";
-		if (ret == PORT_SWITCH_ID_6131_B2)
-			return "Marvell 88E6131 (B2)";
-		if (ret_masked == PORT_SWITCH_ID_6131)
-			return "Marvell 88E6131";
-		if (ret_masked == PORT_SWITCH_ID_6185)
-			return "Marvell 88E6185";
-	}
-
-	return NULL;
+	return mv88e6xxx_lookup_name(host_dev, sw_addr, mv88e6131_table,
+				     ARRAY_SIZE(mv88e6131_table));
 }
 
 static int mv88e6131_setup_global(struct dsa_switch *ds)
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 2c8eb6f..f858c1e 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -17,27 +17,17 @@
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
+static const struct mv88e6xxx_switch_id mv88e6171_table[] = {
+	{ PORT_SWITCH_ID_6171, "Marvell 88E6171" },
+	{ PORT_SWITCH_ID_6175, "Marvell 88E6175" },
+	{ PORT_SWITCH_ID_6350, "Marvell 88E6350" },
+	{ PORT_SWITCH_ID_6351, "Marvell 88E6351" },
+};
+
 static char *mv88e6171_probe(struct device *host_dev, int sw_addr)
 {
-	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
-	int ret;
-
-	if (bus == NULL)
-		return NULL;
-
-	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
-	if (ret >= 0) {
-		if ((ret & 0xfff0) == PORT_SWITCH_ID_6171)
-			return "Marvell 88E6171";
-		if ((ret & 0xfff0) == PORT_SWITCH_ID_6175)
-			return "Marvell 88E6175";
-		if ((ret & 0xfff0) == PORT_SWITCH_ID_6350)
-			return "Marvell 88E6350";
-		if ((ret & 0xfff0) == PORT_SWITCH_ID_6351)
-			return "Marvell 88E6351";
-	}
-
-	return NULL;
+	return mv88e6xxx_lookup_name(host_dev, sw_addr, mv88e6171_table,
+				     ARRAY_SIZE(mv88e6171_table));
 }
 
 static int mv88e6171_setup_global(struct dsa_switch *ds)
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index cbf4dd8..1ab49f6 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -22,41 +22,24 @@
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
+static const struct mv88e6xxx_switch_id mv88e6352_table[] = {
+	{ PORT_SWITCH_ID_6172, "Marvell 88E6172" },
+	{ PORT_SWITCH_ID_6176, "Marvell 88E6176" },
+	{ PORT_SWITCH_ID_6320, "Marvell 88E6320" },
+	{ PORT_SWITCH_ID_6320_A1, "Marvell 88E6320 (A1)" },
+	{ PORT_SWITCH_ID_6320_A2, "Marvell 88e6320 (A2)" },
+	{ PORT_SWITCH_ID_6321, "Marvell 88E6321" },
+	{ PORT_SWITCH_ID_6321_A1, "Marvell 88E6321 (A1)" },
+	{ PORT_SWITCH_ID_6321_A2, "Marvell 88e6321 (A2)" },
+	{ PORT_SWITCH_ID_6352, "Marvell 88E6352" },
+	{ PORT_SWITCH_ID_6352_A0, "Marvell 88E6352 (A0)" },
+	{ PORT_SWITCH_ID_6352_A1, "Marvell 88E6352 (A1)" },
+};
+
 static char *mv88e6352_probe(struct device *host_dev, int sw_addr)
 {
-	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
-	int ret;
-
-	if (bus == NULL)
-		return NULL;
-
-	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
-	if (ret >= 0) {
-		if ((ret & 0xfff0) == PORT_SWITCH_ID_6172)
-			return "Marvell 88E6172";
-		if ((ret & 0xfff0) == PORT_SWITCH_ID_6176)
-			return "Marvell 88E6176";
-		if (ret == PORT_SWITCH_ID_6320_A1)
-			return "Marvell 88E6320 (A1)";
-		if (ret == PORT_SWITCH_ID_6320_A2)
-			return "Marvell 88e6320 (A2)";
-		if ((ret & 0xfff0) == PORT_SWITCH_ID_6320)
-			return "Marvell 88E6320";
-		if (ret == PORT_SWITCH_ID_6321_A1)
-			return "Marvell 88E6321 (A1)";
-		if (ret == PORT_SWITCH_ID_6321_A2)
-			return "Marvell 88e6321 (A2)";
-		if ((ret & 0xfff0) == PORT_SWITCH_ID_6321)
-			return "Marvell 88E6321";
-		if (ret == PORT_SWITCH_ID_6352_A0)
-			return "Marvell 88E6352 (A0)";
-		if (ret == PORT_SWITCH_ID_6352_A1)
-			return "Marvell 88E6352 (A1)";
-		if ((ret & 0xfff0) == PORT_SWITCH_ID_6352)
-			return "Marvell 88E6352";
-	}
-
-	return NULL;
+	return mv88e6xxx_lookup_name(host_dev, sw_addr, mv88e6352_table,
+				     ARRAY_SIZE(mv88e6352_table));
 }
 
 static int mv88e6352_setup_global(struct dsa_switch *ds)
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 70a0106..eaba946 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -59,7 +59,8 @@ static int mv88e6xxx_reg_wait_ready(struct mii_bus *bus, int sw_addr)
 	return -ETIMEDOUT;
 }
 
-int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg)
+static int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr,
+				int reg)
 {
 	int ret;
 
@@ -123,8 +124,8 @@ int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
 	return ret;
 }
 
-int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
-			  int reg, u16 val)
+static int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
+				 int reg, u16 val)
 {
 	int ret;
 
@@ -2482,6 +2483,40 @@ int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 }
 #endif /* CONFIG_NET_DSA_HWMON */
 
+char *mv88e6xxx_lookup_name(struct device *host_dev, int sw_addr,
+			    const struct mv88e6xxx_switch_id *table,
+			    unsigned int num)
+{
+	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
+	int i, ret;
+
+	if (!bus)
+		return NULL;
+
+	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
+	if (ret < 0)
+		return NULL;
+
+	/* Look up the exact switch ID */
+	for (i = 0; i < num; ++i) {
+		if (table[i].id == ret) {
+			pr_info("found switch 0x%x\n", ret);
+			return table[i].name;
+		}
+	}
+
+	/* Look up only the product number */
+	for (i = 0; i < num; ++i) {
+		if (table[i].id == (ret & PORT_SWITCH_ID_PROD_NUM_MASK)) {
+			pr_warn("found switch 0x%x, maybe register rev %d?\n",
+				ret, ret & PORT_SWITCH_ID_REV_MASK);
+			return table[i].name;
+		}
+	}
+
+	return NULL;
+}
+
 static int __init mv88e6xxx_init(void)
 {
 #if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 6f9ed5d..83fde17 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -60,6 +60,8 @@
 #define PORT_PCS_CTRL_UNFORCED		0x03
 #define PORT_PAUSE_CTRL		0x02
 #define PORT_SWITCH_ID		0x03
+#define PORT_SWITCH_ID_PROD_NUM_MASK	0xfff0
+#define PORT_SWITCH_ID_REV_MASK		0x000f
 #define PORT_SWITCH_ID_6031	0x0310
 #define PORT_SWITCH_ID_6035	0x0350
 #define PORT_SWITCH_ID_6046	0x0480
@@ -347,6 +349,11 @@
 #define GLOBAL2_QOS_WEIGHT	0x1c
 #define GLOBAL2_MISC		0x1d
 
+struct mv88e6xxx_switch_id {
+	u16 id;
+	char *name;
+};
+
 struct mv88e6xxx_atu_entry {
 	u16	fid;
 	u8	state;
@@ -415,13 +422,13 @@ struct mv88e6xxx_hw_stat {
 };
 
 int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active);
+char *mv88e6xxx_lookup_name(struct device *host_dev, int sw_addr,
+			    const struct mv88e6xxx_switch_id *table,
+			    unsigned int num);
 int mv88e6xxx_setup_ports(struct dsa_switch *ds);
 int mv88e6xxx_setup_common(struct dsa_switch *ds);
 int mv88e6xxx_setup_global(struct dsa_switch *ds);
-int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg);
 int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg);
-int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
-			  int reg, u16 val);
 int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val);
 int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr);
 int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr);
-- 
2.6.2
