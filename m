From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 1/5] net/phy/marvell: Expose IDs and flags in a .h and add
 dns323 LEDs setup flag
Date: Sat, 22 May 2010 20:54:43 +1000
Message-ID: <1274525683.1931.139.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Wolfram Sang <w.sang@pengutronix.de>,
	Nicolas Pitre <nico@fluxnic.net>
To: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:45811 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754054Ab0EVKzA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 May 2010 06:55:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This moves the various known Marvell PHY IDs to include/linux/marvell_phy.h
along with dev_flags definitions for use by the driver.

I then added a flag that changes the PHY init code to setup the LEDs
config to the values needed to operate a dns323 rev C1 NAS.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: netdev@vger.kernel.org
CC: Wolfram Sang <w.sang@pengutronix.de>
---

Note: My subsequent DNS-323 rev C support patches depend on that one, so if
you (netdev) guys are ok with it, it could be merged via the ARM tree along
with the other stuff.

 drivers/net/phy/marvell.c   |   34 +++++++++++++++++++---------------
 include/linux/marvell_phy.h |   19 +++++++++++++++++++
 2 files changed, 38 insertions(+), 15 deletions(-)
 create mode 100644 include/linux/marvell_phy.h

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 64c7fbe..34447ef 100644	
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -29,6 +29,7 @@
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/phy.h>
+#include <linux/marvell_phy.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -350,7 +351,10 @@ static int m88e1118_config_init(struct phy_device *phydev)
 		return err;
 
 	/* Adjust LED Control */
-	err = phy_write(phydev, 0x10, 0x021e);
+	if (phydev->dev_flags & MARVELL_PHY_DNS323_LEDS)
+		err = phy_write(phydev, 0x10, 0x1100);
+	else
+		err = phy_write(phydev, 0x10, 0x021e);
 	if (err < 0)
 		return err;
 
@@ -529,8 +533,8 @@ static int m88e1121_did_interrupt(struct phy_device *phydev)
 
 static struct phy_driver marvell_drivers[] = {
 	{
-		.phy_id = 0x01410c60,
-		.phy_id_mask = 0xfffffff0,
+		.phy_id = MARVELL_PHY_ID_88E1101,
+		.phy_id_mask = MARVELL_PHY_ID_MASK,
 		.name = "Marvell 88E1101",
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
@@ -541,8 +545,8 @@ static struct phy_driver marvell_drivers[] = {
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
-		.phy_id = 0x01410c90,
-		.phy_id_mask = 0xfffffff0,
+		.phy_id = MARVELL_PHY_ID_88E1112,
+		.phy_id_mask = MARVELL_PHY_ID_MASK,
 		.name = "Marvell 88E1112",
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
@@ -554,8 +558,8 @@ static struct phy_driver marvell_drivers[] = {
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
-		.phy_id = 0x01410cc0,
-		.phy_id_mask = 0xfffffff0,
+		.phy_id = MARVELL_PHY_ID_88E1111,
+		.phy_id_mask = MARVELL_PHY_ID_MASK,
 		.name = "Marvell 88E1111",
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
@@ -567,8 +571,8 @@ static struct phy_driver marvell_drivers[] = {
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
-		.phy_id = 0x01410e10,
-		.phy_id_mask = 0xfffffff0,
+		.phy_id = MARVELL_PHY_ID_88E1118,
+		.phy_id_mask = MARVELL_PHY_ID_MASK,
 		.name = "Marvell 88E1118",
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
@@ -580,8 +584,8 @@ static struct phy_driver marvell_drivers[] = {
 		.driver = {.owner = THIS_MODULE,},
 	},
 	{
-		.phy_id = 0x01410cb0,
-		.phy_id_mask = 0xfffffff0,
+		.phy_id = MARVELL_PHY_ID_88E1121R,
+		.phy_id_mask = MARVELL_PHY_ID_MASK,
 		.name = "Marvell 88E1121R",
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
@@ -593,8 +597,8 @@ static struct phy_driver marvell_drivers[] = {
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
-		.phy_id = 0x01410cd0,
-		.phy_id_mask = 0xfffffff0,
+		.phy_id = MARVELL_PHY_ID_88E1145,
+		.phy_id_mask = MARVELL_PHY_ID_MASK,
 		.name = "Marvell 88E1145",
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
@@ -606,8 +610,8 @@ static struct phy_driver marvell_drivers[] = {
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
-		.phy_id = 0x01410e30,
-		.phy_id_mask = 0xfffffff0,
+		.phy_id = MARVELL_PHY_ID_88E1240,
+		.phy_id_mask = MARVELL_PHY_ID_MASK,
 		.name = "Marvell 88E1240",
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
diff --git a/include/linux/marvell_phy.h b/include/linux/marvell_phy.h
new file mode 100644
index 0000000..b5cb8c8
--- /dev/null
+++ b/include/linux/marvell_phy.h
@@ -0,0 +1,19 @@
+#ifndef _MARVELL_PHY_H
+#define _MARVELL_PHY_H
+
+/* Mask used for ID comparisons */
+#define MARVELL_PHY_ID_MASK		0xfffffff0
+
+/* Known PHY IDs */
+#define MARVELL_PHY_ID_88E1101		0x01410c60
+#define MARVELL_PHY_ID_88E1112		0x01410c90
+#define MARVELL_PHY_ID_88E1111		0x01410cc0
+#define MARVELL_PHY_ID_88E1118		0x01410e10
+#define MARVELL_PHY_ID_88E1121R		0x01410cb0
+#define MARVELL_PHY_ID_88E1145		0x01410cd0
+#define MARVELL_PHY_ID_88E1240		0x01410e30
+
+/* struct phy_device dev_flags definitions */
+#define MARVELL_PHY_DNS323_LEDS		0x00000001
+
+#endif /* _MARVELL_PHY_H */



