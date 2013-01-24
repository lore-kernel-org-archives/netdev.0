From: "Choi, David" <David.Choi@Micrel.Com>
Subject: [PATCH net-next] drivers/net/phy/micrel_phy: Add support for new
 PHYs
Date: Thu, 24 Jan 2013 00:05:15 +0000
Message-ID: <FD9AD8C5375B924CABC56D982DB3A802079D346F@EXMB1.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Doong, Ping" <Ping.Doong@Micrel.Com>,
	"Choi, David" <David.Choi@Micrel.Com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c12o142.mxlogic.net ([208.65.145.65]:35827 "EHLO
	p01c12o142.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812Ab3AXAFR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 19:05:17 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David J. Choi <david.choi@micrel.com>

Summary of changes:
.Newly added phys 
	-KSZ8081/KSZ8091, which has some phy ids.
	-KSZ8061
	-KSZ9031, which is Gigabit phy.
	-KSZ886X, which has a switch function.
	-KSZ8031, which has a same phy ids with KSZ8021.
 
Signed-off-by: David J. Choi <david.choi@micrel.com>
---

--- net-next/drivers/net/phy/micrel.c.orig	2013-01-22 16:40:38.000000000 -0800
+++ net-next/drivers/net/phy/micrel.c	2013-01-23 16:00:17.000000000 -0800
@@ -5,15 +5,20 @@
  *
  * Author: David J. Choi
  *
- * Copyright (c) 2010 Micrel, Inc.
+ * Copyright (c) 2010-2013 Micrel, Inc.
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
  * Free Software Foundation;  either version 2 of the  License, or (at your
  * option) any later version.
  *
- * Support : ksz9021 1000/100/10 phy from Micrel
- *		ks8001, ks8737, ks8721, ks8041, ks8051 100/10 phy
+ * Support : Micrel Phys:
+ *		Giga phys: ksz9021, ksz9031
+ *		100/10 Phys : ksz8001, ksz8721, ksz8737, ksz8041
+ *			   ksz8021, ksz8031, ksz8051,
+ *			   ksz8081, ksz8091,
+ *			   ksz8061,
+ *		Switch : ksz8873, ksz886x
  */
 
 #include <linux/kernel.h>
@@ -176,7 +181,7 @@ static struct phy_driver ksphy_driver[] 
 }, {
 	.phy_id		= PHY_ID_KSZ8021,
 	.phy_id_mask	= 0x00ffffff,
-	.name		= "Micrel KSZ8021",
+	.name		= "Micrel KSZ8021 or KSZ8031",
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
 			   SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
@@ -225,6 +230,30 @@ static struct phy_driver ksphy_driver[] 
 	.config_intr	= kszphy_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
 }, {
+	.phy_id		= PHY_ID_KSZ8081,
+	.name		= "Micrel KSZ8081 or KSZ8091",
+	.phy_id_mask	= 0x00fffff0,
+	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= kszphy_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= kszphy_ack_interrupt,
+	.config_intr	= kszphy_config_intr,
+	.driver		= { .owner = THIS_MODULE,},
+}, {
+	.phy_id		= PHY_ID_KSZ8061,
+	.name		= "Micrel KSZ8061",
+	.phy_id_mask	= 0x00fffff0,
+	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= kszphy_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= kszphy_ack_interrupt,
+	.config_intr	= kszphy_config_intr,
+	.driver		= { .owner = THIS_MODULE,},
+}, {
 	.phy_id		= PHY_ID_KSZ9021,
 	.phy_id_mask	= 0x000ffffe,
 	.name		= "Micrel KSZ9021 Gigabit PHY",
@@ -238,6 +267,19 @@ static struct phy_driver ksphy_driver[] 
 	.config_intr	= ksz9021_config_intr,
 	.driver		= { .owner = THIS_MODULE, },
 }, {
+	.phy_id		= PHY_ID_KSZ9031,
+	.phy_id_mask	= 0x00fffff0,
+	.name		= "Micrel KSZ9031 Gigabit PHY",
+	.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause
+				| SUPPORTED_Asym_Pause),
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= kszphy_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= kszphy_ack_interrupt,
+	.config_intr	= ksz9021_config_intr,
+	.driver		= { .owner = THIS_MODULE, },
+}, {
 	.phy_id		= PHY_ID_KSZ8873MLL,
 	.phy_id_mask	= 0x00fffff0,
 	.name		= "Micrel KSZ8873MLL Switch",
@@ -247,6 +289,16 @@ static struct phy_driver ksphy_driver[] 
 	.config_aneg	= ksz8873mll_config_aneg,
 	.read_status	= ksz8873mll_read_status,
 	.driver		= { .owner = THIS_MODULE, },
+}, {
+	.phy_id		= PHY_ID_KSZ886X,
+	.phy_id_mask	= 0x00fffff0,
+	.name		= "Micrel KSZ886X Switch",
+	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= kszphy_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.driver		= { .owner = THIS_MODULE, },
 } };
 
 static int __init ksphy_init(void)
@@ -270,12 +322,16 @@ MODULE_LICENSE("GPL");
 
 static struct mdio_device_id __maybe_unused micrel_tbl[] = {
 	{ PHY_ID_KSZ9021, 0x000ffffe },
+	{ PHY_ID_KSZ9031, 0x00fffff0 },
 	{ PHY_ID_KSZ8001, 0x00ffffff },
 	{ PHY_ID_KS8737, 0x00fffff0 },
 	{ PHY_ID_KSZ8021, 0x00ffffff },
 	{ PHY_ID_KSZ8041, 0x00fffff0 },
 	{ PHY_ID_KSZ8051, 0x00fffff0 },
+	{ PHY_ID_KSZ8061, 0x00fffff0 },
+	{ PHY_ID_KSZ8081, 0x00fffff0 },
 	{ PHY_ID_KSZ8873MLL, 0x00fffff0 },
+	{ PHY_ID_KSZ886X, 0x00fffff0 },
 	{ }
 };
 
--- net-next/include/linux/micrel_phy.h.orig	2013-01-22 16:42:34.000000000 -0800
+++ net-next/include/linux/micrel_phy.h	2013-01-23 15:32:51.000000000 -0800
@@ -21,8 +21,15 @@
 #define PHY_ID_KSZ8021		0x00221555
 #define PHY_ID_KSZ8041		0x00221510
 #define PHY_ID_KSZ8051		0x00221550
-/* both for ks8001 Rev. A/B, and for ks8721 Rev 3. */
+/* same id: ks8001 Rev. A/B, and ks8721 Rev 3. */
 #define PHY_ID_KSZ8001		0x0022161A
+/* same id: KS8081, KS8091 */
+#define PHY_ID_KSZ8081		0x00221560
+#define PHY_ID_KSZ8061		0x00221570
+#define PHY_ID_KSZ9031		0x00221620
+
+#define PHY_ID_KSZ886X		0x00221430
+#define PHY_ID_KSZ8863		0x00221435
 
 /* struct phy_device dev_flags definitions */
 #define MICREL_PHY_50MHZ_CLK	0x00000001

---
