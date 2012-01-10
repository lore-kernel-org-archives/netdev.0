From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 03/21] au1000-eth: use an unique MDIO bus name.
Date: Tue, 10 Jan 2012 10:59:09 +0100
Message-ID: <1326189567-21663-4-git-send-email-florian@openwrt.org>
References: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Cc: Florian Fainelli <florian@openwrt.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Wan ZongShun <mcuos.com@gmail.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:59633 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755983Ab2AJKAA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 05:00:00 -0500
In-Reply-To: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/amd/au1000_eth.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index cc9262b..8b95dd3 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -1171,7 +1171,8 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	aup->mii_bus->write = au1000_mdiobus_write;
 	aup->mii_bus->reset = au1000_mdiobus_reset;
 	aup->mii_bus->name = "au1000_eth_mii";
-	snprintf(aup->mii_bus->id, MII_BUS_ID_SIZE, "%x", aup->mac_id);
+	snprintf(aup->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
+		pdev->name, aup->mac_id);
 	aup->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
 	if (aup->mii_bus->irq == NULL)
 		goto err_out;
-- 
1.7.5.4
