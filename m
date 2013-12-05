From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 4/7] net: phy: breakdown PHY_*_FEATURES defines
Date: Thu, 5 Dec 2013 14:52:13 -0800
Message-ID: <1386283936-26104-5-git-send-email-florian@openwrt.org>
References: <1386283936-26104-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <grant.likely@linaro.org>,
	<devicetree@vger.kernel.org>, <abrodkin@synopsys.com>,
	<rob.herring@calxeda.com>, <mark.rutland@arm.com>,
	<sebastian.hesselbarth@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:8568 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754586Ab3LEXCF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:02:05 -0500
In-Reply-To: <1386283936-26104-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>

Breakdown the PHY_*_FEATURES into per speed defines such that we can
easily re-use them individually.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/phy.h | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 48a4dc3..7ff751a 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -27,18 +27,27 @@
 
 #include <linux/atomic.h>
 
-#define PHY_BASIC_FEATURES	(SUPPORTED_10baseT_Half | \
-				 SUPPORTED_10baseT_Full | \
-				 SUPPORTED_100baseT_Half | \
-				 SUPPORTED_100baseT_Full | \
-				 SUPPORTED_Autoneg | \
+#define PHY_DEFAULT_FEATURES	(SUPPORTED_Autoneg | \
 				 SUPPORTED_TP | \
 				 SUPPORTED_MII)
 
-#define PHY_GBIT_FEATURES	(PHY_BASIC_FEATURES | \
-				 SUPPORTED_1000baseT_Half | \
+#define PHY_10BT_FEATURES	(SUPPORTED_10baseT_Half | \
+				 SUPPORTED_10baseT_Full)
+
+#define PHY_100BT_FEATURES	(SUPPORTED_100baseT_Half | \
+				 SUPPORTED_100baseT_Full)
+
+#define PHY_1000BT_FEATURES	(SUPPORTED_1000baseT_Half | \
 				 SUPPORTED_1000baseT_Full)
 
+#define PHY_BASIC_FEATURES	(PHY_10BT_FEATURES | \
+				 PHY_100BT_FEATURES | \
+				 PHY_DEFAULT_FEATURES)
+
+#define PHY_GBIT_FEATURES	(PHY_BASIC_FEATURES | \
+				 PHY_1000BT_FEATURES)
+
+
 /*
  * Set phydev->irq to PHY_POLL if interrupts are not supported,
  * or not desired for this PHY.  Set to PHY_IGNORE_INTERRUPT if
-- 
1.8.3.2
