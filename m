From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 3/7] net: dsa: mv88e6xxx: add switch info
Date: Fri, 15 Apr 2016 19:21:24 -0400
Message-ID: <1460762488-2633-4-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1460762488-2633-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460762488-2633-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new switch info structure which will be later extended to store
switch models static information, such as product number, name, number
of ports, number of databases, etc.

Merge the lookup function in the probing code, so that we avoid multiple
checking of the MII bus, as well a multiple ID reading.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c | 15 +++++++++---
 drivers/net/dsa/mv88e6131.c | 19 ++++++++++----
 drivers/net/dsa/mv88e6171.c | 19 ++++++++++----
 drivers/net/dsa/mv88e6352.c | 27 ++++++++++++++------
 drivers/net/dsa/mv88e6xxx.c | 60 ++++++++++++++++++++-------------------------
 drivers/net/dsa/mv88e6xxx.h | 28 +++++++++++++++++----
 6 files changed, 109 insertions(+), 59 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 00c1121..9120fcf 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -17,10 +17,17 @@
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
-static const struct mv88e6xxx_switch_id mv88e6123_table[] = {
-	{ PORT_SWITCH_ID_6123, "Marvell 88E6123" },
-	{ PORT_SWITCH_ID_6161, "Marvell 88E6161" },
-	{ PORT_SWITCH_ID_6165, "Marvell 88E6165" },
+static const struct mv88e6xxx_info mv88e6123_table[] = {
+	{
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6123,
+		.name = "Marvell 88E6123",
+	}, {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6161,
+		.name = "Marvell 88E6161",
+	}, {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6165,
+		.name = "Marvell 88E6165",
+	}
 };
 
 static char *mv88e6123_drv_probe(struct device *dsa_dev,
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index df534da..82ff0c4 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -17,11 +17,20 @@
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
-static const struct mv88e6xxx_switch_id mv88e6131_table[] = {
-	{ PORT_SWITCH_ID_6085, "Marvell 88E6085" },
-	{ PORT_SWITCH_ID_6095, "Marvell 88E6095/88E6095F" },
-	{ PORT_SWITCH_ID_6131, "Marvell 88E6131" },
-	{ PORT_SWITCH_ID_6185, "Marvell 88E6185" },
+static const struct mv88e6xxx_info mv88e6131_table[] = {
+	{
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6095,
+		.name = "Marvell 88E6095/88E6095F",
+	}, {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6085,
+		.name = "Marvell 88E6085",
+	}, {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6131,
+		.name = "Marvell 88E6131",
+	}, {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6185,
+		.name = "Marvell 88E6185",
+	}
 };
 
 static char *mv88e6131_drv_probe(struct device *dsa_dev,
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 40222b0..5e9eb8c 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -17,11 +17,20 @@
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
-static const struct mv88e6xxx_switch_id mv88e6171_table[] = {
-	{ PORT_SWITCH_ID_6171, "Marvell 88E6171" },
-	{ PORT_SWITCH_ID_6175, "Marvell 88E6175" },
-	{ PORT_SWITCH_ID_6350, "Marvell 88E6350" },
-	{ PORT_SWITCH_ID_6351, "Marvell 88E6351" },
+static const struct mv88e6xxx_info mv88e6171_table[] = {
+	{
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6171,
+		.name = "Marvell 88E6171",
+	}, {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6175,
+		.name = "Marvell 88E6175",
+	}, {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6350,
+		.name = "Marvell 88E6350",
+	}, {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6351,
+		.name = "Marvell 88E6351",
+	}
 };
 
 static char *mv88e6171_drv_probe(struct device *dsa_dev,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 30fc5f6..3a53cfb 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -22,13 +22,26 @@
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
+	{
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6320,
+		.name = "Marvell 88E6320",
+	}, {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6321,
+		.name = "Marvell 88E6321",
+	}, {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6172,
+		.name = "Marvell 88E6172",
+	}, {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6176,
+		.name = "Marvell 88E6176",
+	}, {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6240,
+		.name = "Marvell 88E6240",
+	}, {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6352,
+		.name = "Marvell 88E6352",
+	}
 };
 
 static char *mv88e6352_drv_probe(struct device *dsa_dev,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index d7e309d..c9d016c 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3068,51 +3068,45 @@ int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
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
+
+	dev_info(&ps->bus->dev, "found switch %s, revision %u\n",
+		 ps->info->name, id & 0xf);
+
+	return (char *) ps->info->name;
 }
 
 static int __init mv88e6xxx_init(void)
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 9242aea..52c7e03 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -68,6 +68,23 @@
 #define PORT_PCS_CTRL_UNFORCED		0x03
 #define PORT_PAUSE_CTRL		0x02
 #define PORT_SWITCH_ID		0x03
+#define PORT_SWITCH_ID_PROD_NUM_6085	0x04a
+#define PORT_SWITCH_ID_PROD_NUM_6095	0x095
+#define PORT_SWITCH_ID_PROD_NUM_6131	0x106
+#define PORT_SWITCH_ID_PROD_NUM_6320	0x115
+#define PORT_SWITCH_ID_PROD_NUM_6123	0x121
+#define PORT_SWITCH_ID_PROD_NUM_6161	0x161
+#define PORT_SWITCH_ID_PROD_NUM_6165	0x165
+#define PORT_SWITCH_ID_PROD_NUM_6171	0x171
+#define PORT_SWITCH_ID_PROD_NUM_6172	0x172
+#define PORT_SWITCH_ID_PROD_NUM_6175	0x175
+#define PORT_SWITCH_ID_PROD_NUM_6176	0x176
+#define PORT_SWITCH_ID_PROD_NUM_6185	0x1a7
+#define PORT_SWITCH_ID_PROD_NUM_6240	0x240
+#define PORT_SWITCH_ID_PROD_NUM_6321	0x310
+#define PORT_SWITCH_ID_PROD_NUM_6352	0x352
+#define PORT_SWITCH_ID_PROD_NUM_6350	0x371
+#define PORT_SWITCH_ID_PROD_NUM_6351	0x375
 #define PORT_SWITCH_ID_6031	0x0310
 #define PORT_SWITCH_ID_6035	0x0350
 #define PORT_SWITCH_ID_6046	0x0480
@@ -352,9 +369,9 @@
 
 #define MV88E6XXX_N_FID		4096
 
-struct mv88e6xxx_switch_id {
-	u16 id;
-	char *name;
+struct mv88e6xxx_info {
+	u16 prod_num;
+	const char *name;
 };
 
 struct mv88e6xxx_atu_entry {
@@ -382,6 +399,8 @@ struct mv88e6xxx_priv_port {
 };
 
 struct mv88e6xxx_priv_state {
+	const struct mv88e6xxx_info *info;
+
 	/* The dsa_switch this private structure is related to */
 	struct dsa_switch *ds;
 
@@ -449,8 +468,7 @@ struct mv88e6xxx_hw_stat {
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
