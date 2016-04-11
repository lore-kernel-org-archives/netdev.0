From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 5/7] net: dsa: Rename DSA probe function.
Date: Mon, 11 Apr 2016 21:50:07 +0200
Message-ID: <1460404209-32083-6-git-send-email-andrew@lunn.ch>
References: <1460404209-32083-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53438 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753825AbcDKTwO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2016 15:52:14 -0400
In-Reply-To: <1460404209-32083-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename the function called from the DSA to perform a probe for the
switch. This makes the normal _probe() name available for a standard
Linux device driver probe function.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/bcm_sf2.c   | 7 ++++---
 drivers/net/dsa/mv88e6060.c | 7 ++++---
 drivers/net/dsa/mv88e6123.c | 7 ++++---
 drivers/net/dsa/mv88e6131.c | 7 ++++---
 drivers/net/dsa/mv88e6171.c | 7 ++++---
 drivers/net/dsa/mv88e6352.c | 7 ++++---
 6 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 7d62802a66d5..50caa525cda3 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -135,8 +135,9 @@ static int bcm_sf2_sw_get_sset_count(struct dsa_switch *ds)
 	return BCM_SF2_STATS_SIZE;
 }
 
-static char *bcm_sf2_sw_probe(struct device *dsa_dev, struct device *host_dev,
-			      int sw_addr, void **_priv)
+static char *bcm_sf2_sw_drv_probe(struct device *dsa_dev,
+				  struct device *host_dev,
+				  int sw_addr, void **_priv)
 {
 	struct bcm_sf2_priv *priv;
 
@@ -1370,7 +1371,7 @@ static int bcm_sf2_sw_set_wol(struct dsa_switch *ds, int port,
 
 static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_BRCM,
-	.probe			= bcm_sf2_sw_probe,
+	.probe			= bcm_sf2_sw_drv_probe,
 	.setup			= bcm_sf2_sw_setup,
 	.set_addr		= bcm_sf2_sw_set_addr,
 	.get_phy_flags		= bcm_sf2_sw_get_phy_flags,
diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index 46fe5dc65a99..adb608ccd9aa 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -69,8 +69,9 @@ static char *mv88e6060_get_name(struct mii_bus *bus, int sw_addr)
 	return NULL;
 }
 
-static char *mv88e6060_probe(struct device *dsa_dev, struct device *host_dev,
-			     int sw_addr, void **_priv)
+static char *mv88e6060_drv_probe(struct device *dsa_dev,
+				 struct device *host_dev,
+				 int sw_addr, void **_priv)
 {
 	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
 	struct mv88e6060_priv *priv;
@@ -248,7 +249,7 @@ mv88e6060_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
 
 static struct dsa_switch_driver mv88e6060_switch_driver = {
 	.tag_protocol	= DSA_TAG_PROTO_TRAILER,
-	.probe		= mv88e6060_probe,
+	.probe		= mv88e6060_drv_probe,
 	.setup		= mv88e6060_setup,
 	.set_addr	= mv88e6060_set_addr,
 	.phy_read	= mv88e6060_phy_read,
diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 8aaac0894752..c34283d929c4 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -29,8 +29,9 @@ static const struct mv88e6xxx_switch_id mv88e6123_table[] = {
 	{ PORT_SWITCH_ID_6165_A2, "Marvell 88e6165 (A2)" },
 };
 
-static char *mv88e6123_probe(struct device *dsa_dev, struct device *host_dev,
-			     int sw_addr, void **priv)
+static char *mv88e6123_drv_probe(struct device *dsa_dev,
+				 struct device *host_dev,
+				 int sw_addr, void **priv)
 {
 	return mv88e6xxx_drv_probe(dsa_dev, host_dev, sw_addr, priv,
 				   mv88e6123_table,
@@ -106,7 +107,7 @@ static int mv88e6123_setup(struct dsa_switch *ds)
 
 struct dsa_switch_driver mv88e6123_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
-	.probe			= mv88e6123_probe,
+	.probe			= mv88e6123_drv_probe,
 	.setup			= mv88e6123_setup,
 	.set_addr		= mv88e6xxx_set_addr_indirect,
 	.phy_read		= mv88e6xxx_phy_read,
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 9e6edf94a855..f5d75fce1e96 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -25,8 +25,9 @@ static const struct mv88e6xxx_switch_id mv88e6131_table[] = {
 	{ PORT_SWITCH_ID_6185, "Marvell 88E6185" },
 };
 
-static char *mv88e6131_probe(struct device *dsa_dev, struct device *host_dev,
-			     int sw_addr, void **priv)
+static char *mv88e6131_drv_probe(struct device *dsa_dev,
+				 struct device *host_dev,
+				 int sw_addr, void **priv)
 {
 	return mv88e6xxx_drv_probe(dsa_dev, host_dev, sw_addr, priv,
 				   mv88e6131_table,
@@ -163,7 +164,7 @@ mv88e6131_phy_write(struct dsa_switch *ds,
 
 struct dsa_switch_driver mv88e6131_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_DSA,
-	.probe			= mv88e6131_probe,
+	.probe			= mv88e6131_drv_probe,
 	.setup			= mv88e6131_setup,
 	.set_addr		= mv88e6xxx_set_addr_direct,
 	.phy_read		= mv88e6131_phy_read,
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 6ab86071391f..f5622506cdfa 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -24,8 +24,9 @@ static const struct mv88e6xxx_switch_id mv88e6171_table[] = {
 	{ PORT_SWITCH_ID_6351, "Marvell 88E6351" },
 };
 
-static char *mv88e6171_probe(struct device *dsa_dev, struct device *host_dev,
-			     int sw_addr, void **priv)
+static char *mv88e6171_drv_probe(struct device *dsa_dev,
+				 struct device *host_dev,
+				 int sw_addr, void **priv)
 {
 	return mv88e6xxx_drv_probe(dsa_dev, host_dev, sw_addr, priv,
 				   mv88e6171_table,
@@ -92,7 +93,7 @@ static int mv88e6171_setup(struct dsa_switch *ds)
 
 struct dsa_switch_driver mv88e6171_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
-	.probe			= mv88e6171_probe,
+	.probe			= mv88e6171_drv_probe,
 	.setup			= mv88e6171_setup,
 	.set_addr		= mv88e6xxx_set_addr_indirect,
 	.phy_read		= mv88e6xxx_phy_read_indirect,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 764b10ffb631..e54ee27db129 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -37,8 +37,9 @@ static const struct mv88e6xxx_switch_id mv88e6352_table[] = {
 	{ PORT_SWITCH_ID_6352_A1, "Marvell 88E6352 (A1)" },
 };
 
-static char *mv88e6352_probe(struct device *dsa_dev, struct device *host_dev,
-			     int sw_addr, void **priv)
+static char *mv88e6352_drv_probe(struct device *dsa_dev,
+				 struct device *host_dev,
+				 int sw_addr, void **priv)
 {
 	return mv88e6xxx_drv_probe(dsa_dev, host_dev, sw_addr, priv,
 				   mv88e6352_table,
@@ -306,7 +307,7 @@ static int mv88e6352_set_eeprom(struct dsa_switch *ds,
 
 struct dsa_switch_driver mv88e6352_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
-	.probe			= mv88e6352_probe,
+	.probe			= mv88e6352_drv_probe,
 	.setup			= mv88e6352_setup,
 	.set_addr		= mv88e6xxx_set_addr_indirect,
 	.phy_read		= mv88e6xxx_phy_read_indirect,
-- 
2.7.0
