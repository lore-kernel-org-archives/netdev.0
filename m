From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 7/8] dsa: mv88e6xxx: Use the name table to determine number of ports
Date: Thu, 14 Apr 2016 01:59:57 +0200
Message-ID: <1460591998-20598-8-git-send-email-andrew@lunn.ch>
References: <1460591998-20598-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55210 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932075AbcDNACl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 20:02:41 -0400
In-Reply-To: <1460591998-20598-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend the ID to name table to also include the number of ports.
Saves a few switch statements and it is likely other entries will be
added to the table later.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6123.c | 30 +++++++++---------------------
 drivers/net/dsa/mv88e6131.c | 25 +++++--------------------
 drivers/net/dsa/mv88e6171.c | 10 ++++------
 drivers/net/dsa/mv88e6352.c | 26 ++++++++++++--------------
 drivers/net/dsa/mv88e6xxx.c | 35 +++++++++++++++++++++--------------
 drivers/net/dsa/mv88e6xxx.h |  1 +
 6 files changed, 52 insertions(+), 75 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index b4dd7ef039da..ac2e6609367d 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -20,15 +20,15 @@
 #include "mv88e6xxx.h"
 
 static const struct mv88e6xxx_switch_id mv88e6123_table[] = {
-	{ PORT_SWITCH_ID_6123, "Marvell 88E6123" },
-	{ PORT_SWITCH_ID_6123_A1, "Marvell 88E6123 (A1)" },
-	{ PORT_SWITCH_ID_6123_A2, "Marvell 88E6123 (A2)" },
-	{ PORT_SWITCH_ID_6161, "Marvell 88E6161" },
-	{ PORT_SWITCH_ID_6161_A1, "Marvell 88E6161 (A1)" },
-	{ PORT_SWITCH_ID_6161_A2, "Marvell 88E6161 (A2)" },
-	{ PORT_SWITCH_ID_6165, "Marvell 88E6165" },
-	{ PORT_SWITCH_ID_6165_A1, "Marvell 88E6165 (A1)" },
-	{ PORT_SWITCH_ID_6165_A2, "Marvell 88e6165 (A2)" },
+	{ PORT_SWITCH_ID_6123,		"Marvell 88E6123",		3 },
+	{ PORT_SWITCH_ID_6123_A1,	"Marvell 88E6123 (A1)",		3 },
+	{ PORT_SWITCH_ID_6123_A2,	"Marvell 88E6123 (A2)",		3 },
+	{ PORT_SWITCH_ID_6161,		"Marvell 88E6161",		6 },
+	{ PORT_SWITCH_ID_6161_A1,	"Marvell 88E6161 (A1)",		6 },
+	{ PORT_SWITCH_ID_6161_A2,	"Marvell 88E6161 (A2)",		6 },
+	{ PORT_SWITCH_ID_6165,		"Marvell 88E6165",		6 },
+	{ PORT_SWITCH_ID_6165_A1,	"Marvell 88E6165 (A1)",		6 },
+	{ PORT_SWITCH_ID_6165_A2,	"Marvell 88e6165 (A2)",		6 },
 };
 
 static char *mv88e6123_drv_probe(struct device *dsa_dev,
@@ -88,18 +88,6 @@ static int mv88e6123_setup(struct dsa_switch *ds)
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
 	ret = mv88e6xxx_switch_reset(ps, false);
 	if (ret < 0)
 		return ret;
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 1659d4dc93c0..969f67c77835 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -20,11 +20,11 @@
 #include "mv88e6xxx.h"
 
 static const struct mv88e6xxx_switch_id mv88e6131_table[] = {
-	{ PORT_SWITCH_ID_6085, "Marvell 88E6085" },
-	{ PORT_SWITCH_ID_6095, "Marvell 88E6095/88E6095F" },
-	{ PORT_SWITCH_ID_6131, "Marvell 88E6131" },
-	{ PORT_SWITCH_ID_6131_B2, "Marvell 88E6131 (B2)" },
-	{ PORT_SWITCH_ID_6185, "Marvell 88E6185" },
+	{ PORT_SWITCH_ID_6085,		"Marvell 88E6085",		10 },
+	{ PORT_SWITCH_ID_6095,		"Marvell 88E6095/88E6095F",	11 },
+	{ PORT_SWITCH_ID_6131,		"Marvell 88E6131",		8 },
+	{ PORT_SWITCH_ID_6131_B2,	"Marvell 88E6131 (B2)",		8 },
+	{ PORT_SWITCH_ID_6185,		"Marvell 88E6185",		10 },
 };
 
 static char *mv88e6131_drv_probe(struct device *dsa_dev,
@@ -112,21 +112,6 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 
 	mv88e6xxx_ppu_state_init(ps);
 
-	switch (ps->id) {
-	case PORT_SWITCH_ID_6085:
-	case PORT_SWITCH_ID_6185:
-		ps->num_ports = 10;
-		break;
-	case PORT_SWITCH_ID_6095:
-		ps->num_ports = 11;
-		break;
-	case PORT_SWITCH_ID_6131:
-	case PORT_SWITCH_ID_6131_B2:
-		ps->num_ports = 8;
-		break;
-	default:
-		return -ENODEV;
-	}
 
 	ret = mv88e6xxx_switch_reset(ps, false);
 	if (ret < 0)
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 0b934b3008ca..8044927590a4 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -20,10 +20,10 @@
 #include "mv88e6xxx.h"
 
 static const struct mv88e6xxx_switch_id mv88e6171_table[] = {
-	{ PORT_SWITCH_ID_6171, "Marvell 88E6171" },
-	{ PORT_SWITCH_ID_6175, "Marvell 88E6175" },
-	{ PORT_SWITCH_ID_6350, "Marvell 88E6350" },
-	{ PORT_SWITCH_ID_6351, "Marvell 88E6351" },
+	{ PORT_SWITCH_ID_6171,	"Marvell 88E6171",	7 },
+	{ PORT_SWITCH_ID_6175,	"Marvell 88E6175",	7 },
+	{ PORT_SWITCH_ID_6350,	"Marvell 88E6350",	7 },
+	{ PORT_SWITCH_ID_6351,	"Marvell 88E6351",	7 },
 };
 
 static char *mv88e6171_drv_probe(struct device *dsa_dev,
@@ -85,8 +85,6 @@ static int mv88e6171_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	ps->num_ports = 7;
-
 	ret = mv88e6xxx_switch_reset(ps, true);
 	if (ret < 0)
 		return ret;
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index b745a1f36a1f..e5541cd66e86 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -24,18 +24,18 @@
 #include "mv88e6xxx.h"
 
 static const struct mv88e6xxx_switch_id mv88e6352_table[] = {
-	{ PORT_SWITCH_ID_6172, "Marvell 88E6172" },
-	{ PORT_SWITCH_ID_6176, "Marvell 88E6176" },
-	{ PORT_SWITCH_ID_6240, "Marvell 88E6240" },
-	{ PORT_SWITCH_ID_6320, "Marvell 88E6320" },
-	{ PORT_SWITCH_ID_6320_A1, "Marvell 88E6320 (A1)" },
-	{ PORT_SWITCH_ID_6320_A2, "Marvell 88e6320 (A2)" },
-	{ PORT_SWITCH_ID_6321, "Marvell 88E6321" },
-	{ PORT_SWITCH_ID_6321_A1, "Marvell 88E6321 (A1)" },
-	{ PORT_SWITCH_ID_6321_A2, "Marvell 88e6321 (A2)" },
-	{ PORT_SWITCH_ID_6352, "Marvell 88E6352" },
-	{ PORT_SWITCH_ID_6352_A0, "Marvell 88E6352 (A0)" },
-	{ PORT_SWITCH_ID_6352_A1, "Marvell 88E6352 (A1)" },
+	{ PORT_SWITCH_ID_6172,		"Marvell 88E6172",	7 },
+	{ PORT_SWITCH_ID_6176,		"Marvell 88E6176",	7 },
+	{ PORT_SWITCH_ID_6240,		"Marvell 88E6240",	7 },
+	{ PORT_SWITCH_ID_6320,		"Marvell 88E6320",	7 },
+	{ PORT_SWITCH_ID_6320_A1,	"Marvell 88E6320 (A1)", 7 },
+	{ PORT_SWITCH_ID_6320_A2,	"Marvell 88e6320 (A2)", 7 },
+	{ PORT_SWITCH_ID_6321,		"Marvell 88E6321",	7 },
+	{ PORT_SWITCH_ID_6321_A1,	"Marvell 88E6321 (A1)", 7 },
+	{ PORT_SWITCH_ID_6321_A2,	"Marvell 88e6321 (A2)", 7 },
+	{ PORT_SWITCH_ID_6352,		"Marvell 88E6352",	7 },
+	{ PORT_SWITCH_ID_6352_A0,	"Marvell 88E6352 (A0)", 7 },
+	{ PORT_SWITCH_ID_6352_A1,	"Marvell 88E6352 (A1)", 7 },
 };
 
 static char *mv88e6352_drv_probe(struct device *dsa_dev,
@@ -95,8 +95,6 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	ps->num_ports = 7;
-
 	mutex_init(&ps->eeprom_mutex);
 
 	ret = mv88e6xxx_switch_reset(ps, true);
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index b8db7ed12005..9bf20c6d8aac 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3206,23 +3206,23 @@ int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 EXPORT_SYMBOL_GPL(mv88e6xxx_get_temp_alarm);
 #endif /* CONFIG_NET_DSA_HWMON */
 
-static char *mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
-				   const struct mv88e6xxx_switch_id *table,
-				   unsigned int num)
+static int mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
+				 const struct mv88e6xxx_switch_id *table,
+				 unsigned int num)
 {
 	int i, ret;
 
 	if (!bus)
-		return NULL;
+		return -EINVAL;
 
 	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
 	if (ret < 0)
-		return NULL;
+		return ret;
 
 	/* Look up the exact switch ID */
 	for (i = 0; i < num; ++i)
 		if (table[i].id == ret)
-			return table[i].name;
+			return i;
 
 	/* Look up only the product number */
 	for (i = 0; i < num; ++i) {
@@ -3231,11 +3231,11 @@ static char *mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
 				 "unknown revision %d, using base switch 0x%x\n",
 				 ret & PORT_SWITCH_ID_REV_MASK,
 				 ret & PORT_SWITCH_ID_PROD_NUM_MASK);
-			return table[i].name;
+			return i;
 		}
 	}
 
-	return NULL;
+	return -ENODEV;
 }
 
 char *mv88e6xxx_drv_probe(struct device *dsa_dev, struct device *host_dev,
@@ -3245,13 +3245,14 @@ char *mv88e6xxx_drv_probe(struct device *dsa_dev, struct device *host_dev,
 {
 	struct mv88e6xxx_priv_state *ps;
 	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
-	char *name;
+	char *name = NULL;
+	int entry;
 
 	if (!bus)
 		return NULL;
 
-	name = mv88e6xxx_lookup_name(bus, sw_addr, table, num);
-	if (name) {
+	entry = mv88e6xxx_lookup_name(bus, sw_addr, table, num);
+	if (entry >= 0) {
 		ps = devm_kzalloc(dsa_dev, sizeof(*ps), GFP_KERNEL);
 		if (!ps)
 			return NULL;
@@ -3260,6 +3261,9 @@ char *mv88e6xxx_drv_probe(struct device *dsa_dev, struct device *host_dev,
 		if (!ps->bus)
 			return NULL;
 		ps->sw_addr = sw_addr;
+
+		name = table[entry].name;
+		ps->num_ports = table[entry].num_ports;
 	}
 	return name;
 }
@@ -3273,6 +3277,7 @@ int mv88e6xxx_probe(struct mdio_device *mdiodev, struct dsa_switch_driver *ops,
 	struct mv88e6xxx_priv_state *ps;
 	struct dsa_switch *ds;
 	const char *name;
+	int entry;
 	int err;
 
 	ds = devm_kzalloc(dev, sizeof(*ds) + sizeof(*ps), GFP_KERNEL);
@@ -3290,11 +3295,13 @@ int mv88e6xxx_probe(struct mdio_device *mdiodev, struct dsa_switch_driver *ops,
 
 	ds->drv = ops;
 
-	name = mv88e6xxx_lookup_name(ps->bus, ps->sw_addr, table, table_size);
-	if (!name) {
+	entry = mv88e6xxx_lookup_name(ps->bus, ps->sw_addr, table, table_size);
+	if (entry < 0) {
 		dev_err(dev, "Failed to find switch");
-		return -ENODEV;
+		return entry;
 	}
+	name = table[entry].name;
+	ps->num_ports = table[entry].num_ports;
 
 	ps->reset = devm_gpiod_get(&mdiodev->dev, "reset", GPIOD_ASIS);
 	err = PTR_ERR(ps->reset);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 3f7a432c9050..1621e400ef5b 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -371,6 +371,7 @@
 struct mv88e6xxx_switch_id {
 	u16 id;
 	char *name;
+	int num_ports;
 };
 
 struct mv88e6xxx_atu_entry {
-- 
2.7.0
