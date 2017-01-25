From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net] net: dsa: Mop up remaining NET_DSA_HWMON references
Date: Wed, 25 Jan 2017 15:04:17 +0100
Message-ID: <1485353057-4612-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, valentinrothberg@gmail.com,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45363 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752021AbdAYOEk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Jan 2017 09:04:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previous patches have moved the temperature sensor code into the
Marvell PHYs. A few now dead references to NET_DSA_HWMON were left
behind. Go reap them.

Reported-by: Valentin Rothberg <valentinrothberg@gmail.com>
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 Documentation/networking/dsa/dsa.txt | 24 ------------------------
 include/net/dsa.h                    |  8 --------
 2 files changed, 32 deletions(-)

diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/networking/dsa/dsa.txt
index 63912ef34606..b8b40753133e 100644
--- a/Documentation/networking/dsa/dsa.txt
+++ b/Documentation/networking/dsa/dsa.txt
@@ -295,7 +295,6 @@ DSA currently leverages the following subsystems:
 - MDIO/PHY library: drivers/net/phy/phy.c, mdio_bus.c
 - Switchdev: net/switchdev/*
 - Device Tree for various of_* functions
-- HWMON: drivers/hwmon/*
 
 MDIO/PHY library
 ----------------
@@ -349,12 +348,6 @@ Documentation/devicetree/bindings/net/dsa/dsa.txt. PHY/MDIO library helper
 functions such as of_get_phy_mode(), of_phy_connect() are also used to query
 per-port PHY specific details: interface connection, MDIO bus location etc..
 
-HWMON
------
-
-Some switch drivers feature internal temperature sensors which are exposed as
-regular HWMON devices in /sys/class/hwmon/.
-
 Driver development
 ==================
 
@@ -495,23 +488,6 @@ Power management
   BR_STATE_DISABLED and propagating changes to the hardware if this port is
   disabled while being a bridge member
 
-Hardware monitoring
--------------------
-
-These callbacks are only available if CONFIG_NET_DSA_HWMON is enabled:
-
-- get_temp: this function queries the given switch for its temperature
-
-- get_temp_limit: this function returns the switch current maximum temperature
-  limit
-
-- set_temp_limit: this function configures the maximum temperature limit allowed
-
-- get_temp_alarm: this function returns the critical temperature threshold
-  returning an alarm notification
-
-See Documentation/hwmon/sysfs-interface for details.
-
 Bridge layer
 ------------
 
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 9d6cd923c48c..08b340403927 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -178,14 +178,6 @@ struct dsa_switch {
 	 */
 	s8		rtable[DSA_MAX_SWITCHES];
 
-#ifdef CONFIG_NET_DSA_HWMON
-	/*
-	 * Hardware monitoring information
-	 */
-	char			hwmon_name[IFNAMSIZ + 8];
-	struct device		*hwmon_dev;
-#endif
-
 	/*
 	 * The lower device this switch uses to talk to the host
 	 */
-- 
2.11.0
