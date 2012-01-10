From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 11/21] sh-eth: use an unique MDIO bus name.
Date: Tue, 10 Jan 2012 10:59:17 +0100
Message-ID: <1326189567-21663-12-git-send-email-florian@openwrt.org>
References: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Cc: Florian Fainelli <florian@openwrt.org>,
	"David S. Miller" <davem@davemloft.net>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:59802 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756018Ab2AJKAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 05:00:50 -0500
In-Reply-To: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/renesas/sh_eth.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index fc9bda9..6ece429 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1702,7 +1702,8 @@ static int sh_mdio_init(struct net_device *ndev, int id,
 	/* Hook up MII support for ethtool */
 	mdp->mii_bus->name = "sh_mii";
 	mdp->mii_bus->parent = &ndev->dev;
-	snprintf(mdp->mii_bus->id, MII_BUS_ID_SIZE, "%x", id);
+	snprintf(mdp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
+		mdp->pdev->name, pdid);
 
 	/* PHY IRQ */
 	mdp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
-- 
1.7.5.4
