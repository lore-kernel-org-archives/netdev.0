From: "Andrew F. Davis" <afd@ti.com>
Subject: [PATCH v2 1/5] net: phy: dp83848: Add macro for dp83848 compatible devices
Date: Sun, 7 Feb 2016 11:47:17 -0600
Message-ID: <1454867241-20928-2-git-send-email-afd@ti.com>
References: <1454867241-20928-1-git-send-email-afd@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"Andrew F. Davis" <afd@ti.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454867241-20928-1-git-send-email-afd@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a helper macro for defining dp83848 compatible phy devices.
Update copyright info.

Signed-off-by: Andrew F. Davis <afd@ti.com>
---
 drivers/net/phy/dp83848.c | 41 ++++++++++++++++++++++-------------------
 1 file changed, 22 insertions(+), 19 deletions(-)

diff --git a/drivers/net/phy/dp83848.c b/drivers/net/phy/dp83848.c
index 5e14e62..4e78f54 100644
--- a/drivers/net/phy/dp83848.c
+++ b/drivers/net/phy/dp83848.c
@@ -1,7 +1,7 @@
 /*
  * Driver for the Texas Instruments DP83848 PHY
  *
- * Copyright (C) 2015 Texas Instruments Inc.
+ * Copyright (C) 2015-2016 Texas Instruments Incorporated - http://www.ti.com/
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -70,25 +70,28 @@ static struct mdio_device_id __maybe_unused dp83848_tbl[] = {
 };
 MODULE_DEVICE_TABLE(mdio, dp83848_tbl);
 
-static struct phy_driver dp83848_driver[] = {
-	{
-		.phy_id		= DP83848_PHY_ID,
-		.phy_id_mask	= 0xfffffff0,
-		.name		= "TI DP83848",
-		.features	= PHY_BASIC_FEATURES,
-		.flags		= PHY_HAS_INTERRUPT,
-
-		.soft_reset	= genphy_soft_reset,
-		.config_init	= genphy_config_init,
-		.suspend	= genphy_suspend,
-		.resume		= genphy_resume,
-		.config_aneg	= genphy_config_aneg,
-		.read_status	= genphy_read_status,
+#define DP83848_PHY_DRIVER(_id, _name)				\
+	{							\
+		.phy_id		= _id,				\
+		.phy_id_mask	= 0xfffffff0,			\
+		.name		= _name,			\
+		.features	= PHY_BASIC_FEATURES,		\
+		.flags		= PHY_HAS_INTERRUPT,		\
+								\
+		.soft_reset	= genphy_soft_reset,		\
+		.config_init	= genphy_config_init,		\
+		.suspend	= genphy_suspend,		\
+		.resume		= genphy_resume,		\
+		.config_aneg	= genphy_config_aneg,		\
+		.read_status	= genphy_read_status,		\
+								\
+		/* IRQ related */				\
+		.ack_interrupt	= dp83848_ack_interrupt,	\
+		.config_intr	= dp83848_config_intr,		\
+	}
 
-		/* IRQ related */
-		.ack_interrupt	= dp83848_ack_interrupt,
-		.config_intr	= dp83848_config_intr,
-	},
+static struct phy_driver dp83848_driver[] = {
+	DP83848_PHY_DRIVER(DP83848_PHY_ID, "TI DP83848 10/100 Mbps PHY"),
 };
 module_phy_driver(dp83848_driver);
 
-- 
2.7.0
