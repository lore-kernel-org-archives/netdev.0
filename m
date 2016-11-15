From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 12/15] net: ethernet: ucc: Utilize phy_ethtool_nway_reset
Date: Tue, 15 Nov 2016 10:06:41 -0800
Message-ID: <20161115180644.3941-13-f.fainelli@gmail.com>
References: <20161115180644.3941-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, tremyfr@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Li Yang <leoli@freescale.com>,
        linuxppc-dev@lists.ozlabs.org (open list:FREESCALE QUICC ENGINE UCC
        ETHERNET DRIVER), linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33579 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754105AbcKOSHX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 13:07:23 -0500
In-Reply-To: <20161115180644.3941-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/freescale/ucc_geth_ethtool.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth_ethtool.c b/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
index 812a968a78e9..8ba636f61b50 100644
--- a/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
+++ b/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
@@ -332,13 +332,6 @@ static void uec_get_ethtool_stats(struct net_device *netdev,
 	}
 }
 
-static int uec_nway_reset(struct net_device *netdev)
-{
-	struct ucc_geth_private *ugeth = netdev_priv(netdev);
-
-	return phy_start_aneg(ugeth->phydev);
-}
-
 /* Report driver information */
 static void
 uec_get_drvinfo(struct net_device *netdev,
@@ -394,7 +387,7 @@ static const struct ethtool_ops uec_ethtool_ops = {
 	.get_regs               = uec_get_regs,
 	.get_msglevel           = uec_get_msglevel,
 	.set_msglevel           = uec_set_msglevel,
-	.nway_reset             = uec_nway_reset,
+	.nway_reset             = phy_ethtool_nway_reset,
 	.get_link               = ethtool_op_get_link,
 	.get_ringparam          = uec_get_ringparam,
 	.set_ringparam          = uec_set_ringparam,
-- 
2.9.3
