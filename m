From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/2] net: phy: Keep reporting transceiver type
Date: Wed, 20 Sep 2017 15:52:14 -0700
Message-ID: <20170920225214.21974-3-f.fainelli@gmail.com>
References: <20170920225214.21974-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, linville@tuxdriver.com, decot@googlers.com,
        tremyfr@gmail.com, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33445 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751988AbdITWwY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 18:52:24 -0400
Received: by mail-qt0-f196.google.com with SMTP id b1so2707348qtc.0
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 15:52:24 -0700 (PDT)
In-Reply-To: <20170920225214.21974-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With commit 2d55173e71b0 ("phy: add generic function to support
ksetting support"), we lost the ability to report the transceiver type
like we used to. Now that we have added back the transceiver type to
ethtool_link_settings, we can report it back like we used to and have no
loss of information.

Fixes: 3f1ac7a700d0 ("net: ethtool: add new ETHTOOL_xLINKSETTINGS API")
Fixes: 2d55173e71b0 ("phy: add generic function to support ksetting support")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index e842d2cd1ee7..2b1e67bc1e73 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -373,7 +373,8 @@ void phy_ethtool_ksettings_get(struct phy_device *phydev,
 		cmd->base.port = PORT_BNC;
 	else
 		cmd->base.port = PORT_MII;
-
+	cmd->base.transceiver = phy_is_internal(phydev) ?
+				XCVR_INTERNAL : XCVR_EXTERNAL;
 	cmd->base.phy_address = phydev->mdio.addr;
 	cmd->base.autoneg = phydev->autoneg;
 	cmd->base.eth_tp_mdix_ctrl = phydev->mdix_ctrl;
-- 
2.9.3
