From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCHv2 3/4] net: phy: at803x: Clean up duplicate register definitions
Date: Fri, 15 Jan 2016 01:55:23 +0100
Message-ID: <1452819324-4527-3-git-send-email-martin.blumenstingl@googlemail.com>
References: <1452819324-4527-1-git-send-email-martin.blumenstingl@googlemail.com>
Cc: f.fainelli@gmail.com, daniel@zonque.org, festevam@gmail.com,
	mans@mansr.com,
	Martin Blumenstingl <martin.blumenstingl@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:34038 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757315AbcAOAzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 19:55:47 -0500
Received: by mail-wm0-f50.google.com with SMTP id u188so4511561wmu.1
        for <netdev@vger.kernel.org>; Thu, 14 Jan 2016 16:55:46 -0800 (PST)
In-Reply-To: <1452819324-4527-1-git-send-email-martin.blumenstingl@googlemail.com>
In-Reply-To: 1451089622-14957-4-git-send-email-martin.blumenstingl@googlemail.com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
---
v2: refreshed patch

 drivers/net/phy/at803x.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index 333c1bc..f2c4e8d 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -20,9 +20,12 @@
 #include <linux/gpio/consumer.h>
 
 #define AT803X_INTR_ENABLE			0x12
+#define AT803X_INTR_ENABLE_INIT			0xec00
 #define AT803X_INTR_STATUS			0x13
+
 #define AT803X_SMART_SPEED			0x14
 #define AT803X_LED_CONTROL			0x18
+
 #define AT803X_WOL_ENABLE			0x01
 #define AT803X_DEVICE_ADDR			0x03
 #define AT803X_LOC_MAC_ADDR_0_15_OFFSET		0x804C
@@ -31,13 +34,13 @@
 #define AT803X_MMD_ACCESS_CONTROL		0x0D
 #define AT803X_MMD_ACCESS_CONTROL_DATA		0x0E
 #define AT803X_FUNC_DATA			0x4003
-#define AT803X_INER				0x0012
-#define AT803X_INER_INIT			0xec00
-#define AT803X_INSR				0x0013
+
 #define AT803X_DEBUG_ADDR			0x1D
 #define AT803X_DEBUG_DATA			0x1E
+
 #define AT803X_DEBUG_REG_0			0x00
 #define AT803X_DEBUG_RX_CLK_DLY_EN		BIT(15)
+
 #define AT803X_DEBUG_REG_5			0x05
 #define AT803X_DEBUG_TX_CLK_DLY_EN		BIT(8)
 
@@ -280,7 +283,7 @@ static int at803x_ack_interrupt(struct phy_device *phydev)
 {
 	int err;
 
-	err = phy_read(phydev, AT803X_INSR);
+	err = phy_read(phydev, AT803X_INTR_STATUS);
 
 	return (err < 0) ? err : 0;
 }
@@ -290,13 +293,13 @@ static int at803x_config_intr(struct phy_device *phydev)
 	int err;
 	int value;
 
-	value = phy_read(phydev, AT803X_INER);
+	value = phy_read(phydev, AT803X_INTR_ENABLE);
 
 	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
-		err = phy_write(phydev, AT803X_INER,
-				value | AT803X_INER_INIT);
+		err = phy_write(phydev, AT803X_INTR_ENABLE,
+				value | AT803X_INTR_ENABLE_INIT);
 	else
-		err = phy_write(phydev, AT803X_INER, 0);
+		err = phy_write(phydev, AT803X_INTR_ENABLE, 0);
 
 	return err;
 }
-- 
2.7.0
