From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 03/10] net: phy: update port type for MoCA PHYs
Date: Tue, 11 Feb 2014 20:07:26 -0800
Message-ID: <1392178053-3143-4-git-send-email-f.fainelli@gmail.com>
References: <1392178053-3143-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <cernekee@gmail.com>,
	<devicetree@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:28286 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbaBLEIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 23:08:05 -0500
In-Reply-To: <1392178053-3143-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MoCA PHYs are using coaxial (BNC-like) connectors, update the
transceiver port type when replying to ethtool.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 19c9eca..a755fa2 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -283,7 +283,10 @@ int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 
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
