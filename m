From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 02/10] net: phy: update port type for MoCA PHYs
Date: Thu, 13 Feb 2014 14:53:41 -0800
Message-ID: <1392332029-24669-3-git-send-email-f.fainelli@gmail.com>
References: <1392332029-24669-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree@vger.kernel.org>,
	<cernekee@gmail.com>, <mark.rutland@arm.com>,
	<romieu@fr.zoreil.com>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:57032 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932AbaBMWzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:55:22 -0500
In-Reply-To: <1392332029-24669-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MoCA PHYs are using coaxial (BNC-like) connectors, update the
transceiver port type when replying to ethtool.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v1 and v2:
- rebased against latest net-next/master

 drivers/net/phy/phy.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index fc918b6..643b5d6 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -305,7 +305,10 @@ int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 
 	ethtool_cmd_speed_set(cmd, phydev->speed);
 	cmd->duplex = phydev->duplex;
-	cmd->port = PORT_MII;
+	if (phydev->interface == PHY_INTERFACE_MODE_MOCA)
+		cmd->port = PORT_BNC;
+	else
+		cmd->port = PORT_MII;
 	cmd->phy_address = phydev->addr;
 	cmd->transceiver = phy_is_internal(phydev) ?
 		XCVR_INTERNAL : XCVR_EXTERNAL;
-- 
1.8.3.2
