From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/7] net: dsa: mv88e6xxx: add switch info
Date: Fri, 15 Apr 2016 14:25:46 -0400
Message-ID: <1460744750-13896-4-git-send-email-vivien.didelot@savoirfairelinux.com>
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

Add a new switch info structure which will be later extended to store
switch models static information, such as product number, name, number
of ports, number of databases, etc.

Merge the lookup function in the probing code, so that we avoid multiple
checking of the MII bus, as well a multiple ID reading.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c |  8 +++---
 drivers/net/dsa/mv88e6131.c | 10 +++----
 drivers/net/dsa/mv88e6171.c | 10 +++----
 drivers/net/dsa/mv88e6352.c | 14 +++++-----
 drivers/net/dsa/mv88e6xxx.c | 67 +++++++++++++++++++--------------------------
 drivers/net/dsa/mv88e6xxx.h | 14 ++++++----
 6 files changed, 58 insertions(+), 65 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 00c1121..02bf16c 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -17,10 +17,10 @@
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
-static const struct mv88e6xxx_switch_id mv88e6123_table[] = {
-	{ PORT_SWITCH_ID_6123, "Marvell 88E6123" },
-	{ PORT_SWITCH_ID_6161, "Marvell 88E6161" },
-	{ PORT_SWITCH_ID_6165, "Marvell 88E6165" },
+static const struct mv88e6xxx_info mv88e6123_table[] = {
+	{ MV88E6XXX_INFO(0x121, "Marvell 88E6123") },
+	{ MV88E6XXX_INFO(0x161, "Marvell 88E6161") },
+	{ MV88E6XXX_INFO(0x165, "Marvell 88E6165") },
 };
 
 static char *mv88e6123_drv_probe(struct device *dsa_dev,
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index df534da..27dd102 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -17,11 +17,11 @@
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
-static const struct mv88e6xxx_switch_id mv88e6131_table[] = {
-	{ PORT_SWITCH_ID_6085, "Marvell 88E6085" },
-	{ PORT_SWITCH_ID_6095, "Marvell 88E6095/88E6095F" },
-	{ PORT_SWITCH_ID_6131, "Marvell 88E6131" },
-	{ PORT_SWITCH_ID_6185, "Marvell 88E6185" },
+static const struct mv88e6xxx_info mv88e6131_table[] = {
+	{ MV88E6XXX_INFO(0x095, "Marvell 88E6095/88E6095F") },
+	{ MV88E6XXX_INFO(0x04a, "Marvell 88E6085") },
+	{ MV88E6XXX_INFO(0x106, "Marvell 88E6131") },
+	{ MV88E6XXX_INFO(0x1a7, "Marvell 88E6185") },
 };
 
 static char *mv88e6131_drv_probe(struct device *dsa_dev,
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 40222b0..334e097 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -17,11 +17,11 @@
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
-static const struct mv88e6xxx_switch_id mv88e6171_table[] = {
-	{ PORT_SWITCH_ID_6171, "Marvell 88E6171" },
-	{ PORT_SWITCH_ID_6175, "Marvell 88E6175" },
-	{ PORT_SWITCH_ID_6350, "Marvell 88E6350" },
-	{ PORT_SWITCH_ID_6351, "Marvell 88E6351" },
+static const struct mv88e6xxx_info mv88e6171_table[] = {
+	{ MV88E6XXX_INFO(0x171, "Marvell 88E6171") },
+	{ MV88E6XXX_INFO(0x175, "Marvell 88E6175") },
+	{ MV88E6XXX_INFO(0x371, "Marvell 88E6350") },
+	{ MV88E6XXX_INFO(0x375, "Marvell 88E6351") },
 };
 
 static char *mv88e6171_drv_probe(struct device *dsa_dev,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 30fc5f6..371edd7 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -22,13 +22,13 @@
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
-static const struct mv88e6xxx_switch_id mv88e6352_table[] = {
-	{ PORT_SWITCH_ID_6172, "Marvell 88E6172" },
-	{ PORT_SWITCH_ID_6176, "Marvell 88E6176" },
-	{ PORT_SWITCH_ID_6240, "Marvell 88E6240" },
-	{ PORT_SWITCH_ID_6320, "Marvell 88E6320" },
-	{ PORT_SWITCH_ID_6321, "Marvell 88E6321" },
-	{ PORT_SWITCH_ID_6352, "Marvell 88E6352" },
+static const struct mv88e6xxx_info mv88e6352_table[] = {
+	{ MV88E6XXX_INFO(0x115, "Marvell 88E6320") },
+	{ MV88E6XXX_INFO(0x310, "Marvell 88E6321") },
+	{ MV88E6XXX_INFO(0x172, "Marvell 88E6172") },
+	{ MV88E6XXX_INFO(0x176, "Marvell 88E6176") },
+	{ MV88E6XXX_INFO(0x240, "Marvell 88E6240") },
+	{ MV88E6XXX_INFO(0x352, "Marvell 88E6352") },
 };
 
 static char *mv88e6352_drv_probe(struct device *dsa_dev,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index ad29040..48fd1f4 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2663,16 +2663,10 @@ int mv88e6xxx_setup_ports(struct dsa_switch *ds)
 int mv88e6xxx_setup_common(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int id;
 
 	ps->ds = ds;
 	mutex_init(&ps->smi_mutex);
 
-	id = REG_READ(REG_PORT(0), PORT_SWITCH_ID);
-
-	ps->id = id & 0xfff0;
-	ps->rev = id & 0xf;
-
 	INIT_WORK(&ps->bridge_work, mv88e6xxx_bridge_work);
 
 	return 0;
@@ -3072,51 +3066,46 @@ int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 }
 #endif /* CONFIG_NET_DSA_HWMON */
 
-static char *mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
-				   const struct mv88e6xxx_switch_id *table,
-				   unsigned int num)
+char *mv88e6xxx_drv_probe(struct device *dsa_dev, struct device *host_dev,
+			  int sw_addr, void **priv,
+			  const struct mv88e6xxx_info *table, unsigned int num)
 {
-	int i, ret;
+	const struct mv88e6xxx_info *info;
+	struct mv88e6xxx_priv_state *ps;
+	struct mii_bus *bus;
+	int id, i;
 
+	bus = dsa_host_dev_to_mii_bus(host_dev);
 	if (!bus)
 		return NULL;
 
-	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
-	if (ret < 0)
+	id = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
+	if (id < 0)
 		return NULL;
 
-	/* Look up the exact switch ID */
-	for (i = 0; i < num; ++i)
-		if (table[i].id == (ret & 0xfff0))
-			return table[i].name;
+	for (i = 0, info = &table[i]; i < num; info = &table[++i])
+		if (info->prod_num == (id & 0xfff0) >> 4)
+			goto found;
 
 	return NULL;
-}
 
-char *mv88e6xxx_drv_probe(struct device *dsa_dev, struct device *host_dev,
-			  int sw_addr, void **priv,
-			  const struct mv88e6xxx_switch_id *table,
-			  unsigned int num)
-{
-	struct mv88e6xxx_priv_state *ps;
-	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
-	char *name;
-
-	if (!bus)
+found:
+	ps = devm_kzalloc(dsa_dev, sizeof(*ps), GFP_KERNEL);
+	if (!ps)
 		return NULL;
 
-	name = mv88e6xxx_lookup_name(bus, sw_addr, table, num);
-	if (name) {
-		ps = devm_kzalloc(dsa_dev, sizeof(*ps), GFP_KERNEL);
-		if (!ps)
-			return NULL;
-		*priv = ps;
-		ps->bus = dsa_host_dev_to_mii_bus(host_dev);
-		if (!ps->bus)
-			return NULL;
-		ps->sw_addr = sw_addr;
-	}
-	return name;
+	*priv = ps;
+
+	ps->bus = bus;
+	ps->sw_addr = sw_addr;
+	ps->info = info;
+	ps->id = id & 0xfff0;
+	ps->rev = id & 0xf;
+
+	dev_info(&ps->bus->dev, "found switch %s, revision %u\n",
+		 ps->info->name, ps->rev);
+
+	return (char *) ps->info->name;
 }
 
 static int __init mv88e6xxx_init(void)
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 7304f88..5556098 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -354,11 +354,15 @@
 
 #define MV88E6XXX_N_FID		4096
 
-struct mv88e6xxx_switch_id {
-	u16 id;
-	char *name;
+struct mv88e6xxx_info {
+	u16 prod_num;
+	const char *name;
 };
 
+#define MV88E6XXX_INFO(_prod_num, _name) \
+	.prod_num = _prod_num, \
+	.name = _name, \
+
 struct mv88e6xxx_atu_entry {
 	u16	fid;
 	u8	state;
@@ -384,6 +388,7 @@ struct mv88e6xxx_priv_port {
 };
 
 struct mv88e6xxx_priv_state {
+	const struct mv88e6xxx_info *info;
 	int rev;
 
 	/* The dsa_switch this private structure is related to */
@@ -453,8 +458,7 @@ struct mv88e6xxx_hw_stat {
 int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active);
 char *mv88e6xxx_drv_probe(struct device *dsa_dev, struct device *host_dev,
 			  int sw_addr, void **priv,
-			  const struct mv88e6xxx_switch_id *table,
-			  unsigned int num);
+			  const struct mv88e6xxx_info *table, unsigned int num);
 
 int mv88e6xxx_setup_ports(struct dsa_switch *ds);
 int mv88e6xxx_setup_common(struct dsa_switch *ds);
-- 
2.8.0
