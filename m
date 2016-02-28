From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 16/32] dsa: mv88e6xxx: Use bus in mv88e6xxx_lookup_name()
Date: Sun, 28 Feb 2016 17:41:24 +0100
Message-ID: <1456677700-23027-17-git-send-email-andrew@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44944 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758779AbcB1Qm2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:42:28 -0500
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mv88e6xxx_lookup_name() returns the model name of a switch at a given
address on an MII bus. Using mii_bus to identify the bus rather than
the host device is more logical, so change the parameter.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
v2: Check bus is valid before dereferencing it.
---
 drivers/net/dsa/mv88e6123.c | 4 +++-
 drivers/net/dsa/mv88e6131.c | 4 +++-
 drivers/net/dsa/mv88e6171.c | 4 +++-
 drivers/net/dsa/mv88e6352.c | 4 +++-
 drivers/net/dsa/mv88e6xxx.c | 6 +++---
 drivers/net/dsa/mv88e6xxx.h | 2 +-
 6 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 6d6fca62e8b1..2c23762cbed8 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -31,7 +31,9 @@ static const struct mv88e6xxx_switch_id mv88e6123_table[] = {
 
 static char *mv88e6123_drv_probe(struct device *host_dev, int sw_addr)
 {
-	return mv88e6xxx_lookup_name(host_dev, sw_addr, mv88e6123_table,
+	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
+
+	return mv88e6xxx_lookup_name(bus, sw_addr, mv88e6123_table,
 				     ARRAY_SIZE(mv88e6123_table));
 }
 
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index e0aa3be7f5a9..02d2bca095af 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -27,7 +27,9 @@ static const struct mv88e6xxx_switch_id mv88e6131_table[] = {
 
 static char *mv88e6131_drv_probe(struct device *host_dev, int sw_addr)
 {
-	return mv88e6xxx_lookup_name(host_dev, sw_addr, mv88e6131_table,
+	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
+
+	return mv88e6xxx_lookup_name(bus, sw_addr, mv88e6131_table,
 				     ARRAY_SIZE(mv88e6131_table));
 }
 
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 8fc4db23744e..d557be12feb7 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -26,7 +26,9 @@ static const struct mv88e6xxx_switch_id mv88e6171_table[] = {
 
 static char *mv88e6171_drv_probe(struct device *host_dev, int sw_addr)
 {
-	return mv88e6xxx_lookup_name(host_dev, sw_addr, mv88e6171_table,
+	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
+
+	return mv88e6xxx_lookup_name(bus, sw_addr, mv88e6171_table,
 				     ARRAY_SIZE(mv88e6171_table));
 }
 
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 2877ad8acefa..959835d69af6 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -38,7 +38,9 @@ static const struct mv88e6xxx_switch_id mv88e6352_table[] = {
 
 static char *mv88e6352_drv_probe(struct device *host_dev, int sw_addr)
 {
-	return mv88e6xxx_lookup_name(host_dev, sw_addr, mv88e6352_table,
+	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
+
+	return mv88e6xxx_lookup_name(bus, sw_addr, mv88e6352_table,
 				     ARRAY_SIZE(mv88e6352_table));
 }
 
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 2e945f325db1..7f67bf47cdb6 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2622,11 +2622,10 @@ int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 }
 #endif /* CONFIG_NET_DSA_HWMON */
 
-char *mv88e6xxx_lookup_name(struct device *host_dev, int sw_addr,
+char *mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
 			    const struct mv88e6xxx_switch_id *table,
 			    unsigned int num)
 {
-	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
 	int i, ret;
 
 	if (!bus)
@@ -2644,7 +2643,8 @@ char *mv88e6xxx_lookup_name(struct device *host_dev, int sw_addr,
 	/* Look up only the product number */
 	for (i = 0; i < num; ++i) {
 		if (table[i].id == (ret & PORT_SWITCH_ID_PROD_NUM_MASK)) {
-			dev_warn(host_dev, "unknown revision %d, using base switch 0x%x\n",
+			dev_warn(&bus->dev,
+				 "unknown revision %d, using base switch 0x%x\n",
 				 ret & PORT_SWITCH_ID_REV_MASK,
 				 ret & PORT_SWITCH_ID_PROD_NUM_MASK);
 			return table[i].name;
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 53f2fc82069b..dce72d1007c2 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -444,7 +444,7 @@ struct mv88e6xxx_hw_stat {
 };
 
 int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active);
-char *mv88e6xxx_lookup_name(struct device *host_dev, int sw_addr,
+char *mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
 			    const struct mv88e6xxx_switch_id *table,
 			    unsigned int num);
 int mv88e6xxx_setup_ports(struct dsa_switch *ds);
-- 
2.7.0
