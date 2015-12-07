From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 09/26] phy: export phy_speed_to_str() for phylink
Date: Mon, 07 Dec 2015 17:37:57 +0000
Message-ID: <E1a5zjZ-00075I-Hc@rmk-PC.arm.linux.org.uk>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:60276 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932438AbbLGRiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 12:38:00 -0500
In-Reply-To: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phylink would like to reuse phy_speed_to_str() to convert the speed
to a string.  Add a prototype and export this helper function.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/phy/phy.c | 3 ++-
 include/linux/phy.h   | 1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index ec9953202f58..c1be21a84f1d 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -38,7 +38,7 @@
 
 #include <asm/irq.h>
 
-static const char *phy_speed_to_str(int speed)
+const char *phy_speed_to_str(int speed)
 {
 	switch (speed) {
 	case SPEED_10:
@@ -57,6 +57,7 @@ static const char *phy_speed_to_str(int speed)
 		return "Unsupported (update phy.c)";
 	}
 }
+EXPORT_SYMBOL_GPL(phy_speed_to_str);
 
 #define PHY_STATE_STR(_state)			\
 	case PHY_##_state:			\
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 63e52af00493..6b1ec2b99051 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -799,6 +799,7 @@ int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd);
 int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd);
 int phy_mii_ioctl(struct phy_device *phydev, struct ifreq *ifr, int cmd);
 int phy_start_interrupts(struct phy_device *phydev);
+const char *phy_speed_to_str(int speed);
 void phy_print_status(struct phy_device *phydev);
 void phy_device_free(struct phy_device *phydev);
 int phy_set_max_speed(struct phy_device *phydev, u32 max_speed);
-- 
2.1.0
