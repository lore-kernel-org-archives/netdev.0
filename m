From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 01/15] net: phy: Add phy_ethtool_nway_reset
Date: Tue, 15 Nov 2016 10:06:30 -0800
Message-ID: <20161115180644.3941-2-f.fainelli@gmail.com>
References: <20161115180644.3941-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, tremyfr@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36782 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753821AbcKOSHA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 13:07:00 -0500
In-Reply-To: <20161115180644.3941-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function just calls into genphy_restart_aneg() to perform an
autonegotation restart.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c | 11 +++++++++++
 include/linux/phy.h   |  1 +
 2 files changed, 12 insertions(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index e6dd222fddb1..73adbaa9ac86 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1441,3 +1441,14 @@ int phy_ethtool_set_link_ksettings(struct net_device *ndev,
 	return phy_ethtool_ksettings_set(phydev, cmd);
 }
 EXPORT_SYMBOL(phy_ethtool_set_link_ksettings);
+
+int phy_ethtool_nway_reset(struct net_device *ndev)
+{
+	struct phy_device *phydev = ndev->phydev;
+
+	if (!phydev)
+		return -ENODEV;
+
+	return genphy_restart_aneg(phydev);
+}
+EXPORT_SYMBOL(phy_ethtool_nway_reset);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 9880d73a2c3d..b9bd3b4f4ea1 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -860,6 +860,7 @@ int phy_ethtool_get_link_ksettings(struct net_device *ndev,
 				   struct ethtool_link_ksettings *cmd);
 int phy_ethtool_set_link_ksettings(struct net_device *ndev,
 				   const struct ethtool_link_ksettings *cmd);
+int phy_ethtool_nway_reset(struct net_device *ndev);
 
 int __init mdio_bus_init(void);
 void mdio_bus_exit(void);
-- 
2.9.3
