From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 06/21] dnet: use an unique MDIO bus name.
Date: Tue, 10 Jan 2012 10:59:12 +0100
Message-ID: <1326189567-21663-7-git-send-email-florian@openwrt.org>
References: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Cc: Florian Fainelli <florian@openwrt.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Rick Jones <rick.jones2@hp.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:59777 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754617Ab2AJKAl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 05:00:41 -0500
In-Reply-To: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/dnet.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index ce88c0f..925c9ba 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -325,7 +325,8 @@ static int dnet_mii_init(struct dnet *bp)
 	bp->mii_bus->write = &dnet_mdio_write;
 	bp->mii_bus->reset = &dnet_mdio_reset;
 
-	snprintf(bp->mii_bus->id, MII_BUS_ID_SIZE, "%x", 0);
+	snprintf(bp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
+		bp->pdev->name, bp->pdev->id);
 
 	bp->mii_bus->priv = bp;
 
-- 
1.7.5.4
