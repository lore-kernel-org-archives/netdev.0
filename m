From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 14/28] net: dsa: Rename DSA probe function.
Date: Wed, 23 Dec 2015 13:56:28 +0100
Message-ID: <1450875402-20740-15-git-send-email-andrew@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48789 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757202AbbLWM6p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:58:45 -0500
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename the function called from the DSA to perform a probe for the
switch. This makes the normal _probe() name available for a standard
Linux device driver probe function.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/bcm_sf2.c   | 4 ++--
 drivers/net/dsa/mv88e6060.c | 4 ++--
 drivers/net/dsa/mv88e6123.c | 4 ++--
 drivers/net/dsa/mv88e6131.c | 4 ++--
 drivers/net/dsa/mv88e6171.c | 4 ++--
 drivers/net/dsa/mv88e6352.c | 4 ++--
 6 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 23326c2a01b8..a0222ebd31c6 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -135,7 +135,7 @@ static int bcm_sf2_sw_get_sset_count(struct dsa_switch *ds)
 	return BCM_SF2_STATS_SIZE;
 }
 
-static char *bcm_sf2_sw_probe(struct device *host_dev, int sw_addr)
+static char *bcm_sf2_sw_drv_probe(struct device *host_dev, int sw_addr)
 {
 	return "Broadcom Starfighter 2";
 }
@@ -1369,7 +1369,7 @@ static int bcm_sf2_sw_set_wol(struct dsa_switch *ds, int port,
 
 static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_BRCM,
-	.probe			= bcm_sf2_sw_probe,
+	.probe			= bcm_sf2_sw_drv_probe,
 	.setup			= bcm_sf2_sw_setup,
 	.set_addr		= bcm_sf2_sw_set_addr,
 	.get_phy_flags		= bcm_sf2_sw_get_phy_flags,
diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index d48708dfd963..02810a50825b 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -51,7 +51,7 @@ static int reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
 			return __ret;				\
 	})
 
-static char *mv88e6060_probe(struct device *host_dev, int sw_addr)
+static char *mv88e6060_drv_probe(struct device *host_dev, int sw_addr)
 {
 	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
 	int ret;
@@ -241,7 +241,7 @@ mv88e6060_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
 
 static struct dsa_switch_driver mv88e6060_switch_driver = {
 	.tag_protocol	= DSA_TAG_PROTO_TRAILER,
-	.probe		= mv88e6060_probe,
+	.probe		= mv88e6060_drv_probe,
 	.setup		= mv88e6060_setup,
 	.set_addr	= mv88e6060_set_addr,
 	.phy_read	= mv88e6060_phy_read,
diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 9d39f108793b..6d6fca62e8b1 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -29,7 +29,7 @@ static const struct mv88e6xxx_switch_id mv88e6123_table[] = {
 	{ PORT_SWITCH_ID_6165_A2, "Marvell 88e6165 (A2)" },
 };
 
-static char *mv88e6123_probe(struct device *host_dev, int sw_addr)
+static char *mv88e6123_drv_probe(struct device *host_dev, int sw_addr)
 {
 	return mv88e6xxx_lookup_name(host_dev, sw_addr, mv88e6123_table,
 				     ARRAY_SIZE(mv88e6123_table));
@@ -103,7 +103,7 @@ static int mv88e6123_setup(struct dsa_switch *ds, struct device *dev)
 
 struct dsa_switch_driver mv88e6123_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
-	.probe			= mv88e6123_probe,
+	.probe			= mv88e6123_drv_probe,
 	.setup			= mv88e6123_setup,
 	.set_addr		= mv88e6xxx_set_addr_indirect,
 	.phy_read		= mv88e6xxx_phy_read,
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 3103b4953af4..e0aa3be7f5a9 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -25,7 +25,7 @@ static const struct mv88e6xxx_switch_id mv88e6131_table[] = {
 	{ PORT_SWITCH_ID_6185, "Marvell 88E6185" },
 };
 
-static char *mv88e6131_probe(struct device *host_dev, int sw_addr)
+static char *mv88e6131_drv_probe(struct device *host_dev, int sw_addr)
 {
 	return mv88e6xxx_lookup_name(host_dev, sw_addr, mv88e6131_table,
 				     ARRAY_SIZE(mv88e6131_table));
@@ -160,7 +160,7 @@ mv88e6131_phy_write(struct dsa_switch *ds,
 
 struct dsa_switch_driver mv88e6131_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_DSA,
-	.probe			= mv88e6131_probe,
+	.probe			= mv88e6131_drv_probe,
 	.setup			= mv88e6131_setup,
 	.set_addr		= mv88e6xxx_set_addr_direct,
 	.phy_read		= mv88e6131_phy_read,
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 29a77366afc6..8fc4db23744e 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -24,7 +24,7 @@ static const struct mv88e6xxx_switch_id mv88e6171_table[] = {
 	{ PORT_SWITCH_ID_6351, "Marvell 88E6351" },
 };
 
-static char *mv88e6171_probe(struct device *host_dev, int sw_addr)
+static char *mv88e6171_drv_probe(struct device *host_dev, int sw_addr)
 {
 	return mv88e6xxx_lookup_name(host_dev, sw_addr, mv88e6171_table,
 				     ARRAY_SIZE(mv88e6171_table));
@@ -89,7 +89,7 @@ static int mv88e6171_setup(struct dsa_switch *ds, struct device *dev)
 
 struct dsa_switch_driver mv88e6171_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
-	.probe			= mv88e6171_probe,
+	.probe			= mv88e6171_drv_probe,
 	.setup			= mv88e6171_setup,
 	.set_addr		= mv88e6xxx_set_addr_indirect,
 	.phy_read		= mv88e6xxx_phy_read_indirect,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index eb57a379b9cc..2877ad8acefa 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -36,7 +36,7 @@ static const struct mv88e6xxx_switch_id mv88e6352_table[] = {
 	{ PORT_SWITCH_ID_6352_A1, "Marvell 88E6352 (A1)" },
 };
 
-static char *mv88e6352_probe(struct device *host_dev, int sw_addr)
+static char *mv88e6352_drv_probe(struct device *host_dev, int sw_addr)
 {
 	return mv88e6xxx_lookup_name(host_dev, sw_addr, mv88e6352_table,
 				     ARRAY_SIZE(mv88e6352_table));
@@ -302,7 +302,7 @@ static int mv88e6352_set_eeprom(struct dsa_switch *ds,
 
 struct dsa_switch_driver mv88e6352_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
-	.probe			= mv88e6352_probe,
+	.probe			= mv88e6352_drv_probe,
 	.setup			= mv88e6352_setup,
 	.set_addr		= mv88e6xxx_set_addr_indirect,
 	.phy_read		= mv88e6xxx_phy_read_indirect,
-- 
2.6.3
