From: David Thomson <david.thomson@alliedtelesis.co.nz>
Subject: [PATCH] net: phy: Pass mdix ethtool setting through to phy driver
Date: Fri, 10 Jul 2015 13:56:54 +1200
Message-ID: <1436493414-16248-1-git-send-email-david.thomson@alliedtelesis.co.nz>
Cc: netdev@vger.kernel.org,
	David Thomson <david.thomson@alliedtelesis.co.nz>
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:45126 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750948AbbGJB5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 21:57:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass the mdix setting from ethtool down to the phy driver, to allow
driver specific implementations of manually setting the polarity.

Signed-off-by: David Thomson <david.thomson@alliedtelesis.co.nz>
---
 drivers/net/phy/phy.c | 2 ++
 include/linux/phy.h   | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index b2197b5..47693a9 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -353,6 +353,8 @@ int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 
 	phydev->duplex = cmd->duplex;
 
+	phydev->mdix = cmd->eth_tp_mdix_ctrl;
+
 	/* Restart the PHY */
 	phy_start_aneg(phydev);
 
diff --git a/include/linux/phy.h b/include/linux/phy.h
index a26c3f8..e5fb1d4 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -424,6 +424,8 @@ struct phy_device {
 
 	struct net_device *attached_dev;
 
+	u8 mdix;
+
 	void (*adjust_link)(struct net_device *dev);
 };
 #define to_phy_device(d) container_of(d, struct phy_device, dev)
-- 
1.9.1
