From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 03/10] net: phy: display human readable PHY speed settings
Date: Tue, 11 Feb 2014 17:27:35 -0800
Message-ID: <1392168462-18888-4-git-send-email-f.fainelli@gmail.com>
References: <1392168462-18888-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:11050 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752179AbaBLB2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 20:28:19 -0500
In-Reply-To: <1392168462-18888-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use a convenience function: phy_speed_to_str() which will display human
readable speeds.

Suggested-by: Joe Perches <joe@perches.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c | 24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 8ae2260..36fc6e1 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -38,6 +38,26 @@
 
 #include <asm/irq.h>
 
+static const char *phy_speed_to_str(int speed)
+{
+	switch (speed) {
+	case SPEED_10:
+		return "10Mbps";
+	case SPEED_100:
+		return "100Mbps";
+	case SPEED_1000:
+		return "1Gbps";
+	case SPEED_2500:
+		return "2.5Gbps";
+	case SPEED_10000:
+		return "10Gbps";
+	case SPEED_UNKNOWN:
+		return "Unknown";
+	default:
+		return "Unsupported (update phy.c)";
+	}
+}
+
 /**
  * phy_print_status - Convenience function to print out the current phy status
  * @phydev: the phy_device struct
@@ -46,8 +66,8 @@ void phy_print_status(struct phy_device *phydev)
 {
 	if (phydev->link) {
 		netdev_info(phydev->attached_dev,
-			"Link is Up - %d/%s - flow control %s\n",
-			phydev->speed,
+			"Link is Up - %s/%s - flow control %s\n",
+			phy_speed_to_str(phydev->speed),
 			DUPLEX_FULL == phydev->duplex ? "Full" : "Half",
 			phydev->pause ? "rx/tx" : "off");
 	} else	{
-- 
1.8.3.2
