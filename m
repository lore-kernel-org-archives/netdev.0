From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 07/21] fec: use an unique MDIO bus name.
Date: Tue, 10 Jan 2012 10:59:13 +0100
Message-ID: <1326189567-21663-8-git-send-email-florian@openwrt.org>
References: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Cc: Florian Fainelli <florian@openwrt.org>,
	"David S. Miller" <davem@davemloft.net>,
	Shawn Guo <shawn.guo@linaro.org>,
	=?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	Xiao Jiang <jgq516@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:59781 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755321Ab2AJKAm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 05:00:42 -0500
In-Reply-To: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/freescale/fec.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 20c2e3f..c6aa641 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1077,7 +1077,8 @@ static int fec_enet_mii_init(struct platform_device *pdev)
 	fep->mii_bus->read = fec_enet_mdio_read;
 	fep->mii_bus->write = fec_enet_mdio_write;
 	fep->mii_bus->reset = fec_enet_mdio_reset;
-	snprintf(fep->mii_bus->id, MII_BUS_ID_SIZE, "%x", fep->dev_id + 1);
+	snprintf(fep->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
+		pdev->name, fep->dev_id + 1);
 	fep->mii_bus->priv = fep;
 	fep->mii_bus->parent = &pdev->dev;
 
-- 
1.7.5.4
