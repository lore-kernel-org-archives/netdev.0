From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 3/5] fec: fix PHY name to match fixed MDIO bus name
Date: Mon, 13 Feb 2012 12:23:22 +0100
Message-ID: <1329132204-27946-4-git-send-email-florian@openwrt.org>
References: <1329132204-27946-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>,
	stable@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:36784 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754759Ab2BMLX6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 06:23:58 -0500
In-Reply-To: <1329132204-27946-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit "391420f7: fec: use an unique MDIO bus name" first modified
the MDIO bus name to include the platform name, then in commit
"a7ed07d5: net: fec: correct phy_name buffer length when init phy_name"
the PHY name formatting was fixed in the case the PHY matches a PHY
driver.

The FEC driver however, also handles the case where we want to attach
to the fixed MDIO bus name, which was previously named "0", and now
"fixed-0". Change the PHY formatting logic to account for that.

CC: stable@vger.kernel.org
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/freescale/fec.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 0ee2ca7..a12b3f5 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -986,7 +986,7 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 		printk(KERN_INFO
 			"%s: no PHY, assuming direct connection to switch\n",
 			ndev->name);
-		strncpy(mdio_bus_id, "0", MII_BUS_ID_SIZE);
+		strncpy(mdio_bus_id, "fixed-0", MII_BUS_ID_SIZE);
 		phy_id = 0;
 	}
 
-- 
1.7.5.4
