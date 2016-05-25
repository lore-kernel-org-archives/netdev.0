From: Marek Vasut <marex@denx.de>
Subject: [PATCH] net: stmmac: Fix incorrect memcpy source memory
Date: Thu, 26 May 2016 00:40:23 +0200
Message-ID: <1464216023-6428-1-git-send-email-marex@denx.de>
Cc: Marek Vasut <marex@denx.de>,
	"David S . Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Alexandre Torgue <alexandre.torgue@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:54819 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492AbcEYWk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 18:40:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memcpy() currently copies mdio_bus_data into new_bus->irq, which
makes no sense, since the mdio_bus_data structure contains more than
just irqs. The code was likely supposed to copy mdio_bus_data->irqs
into the new_bus->irq instead, so fix this.

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: David S. Miller <davem@davemloft.net>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Alexandre Torgue <alexandre.torgue@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index 3f83c36..ec29585 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -297,7 +297,7 @@ int stmmac_mdio_register(struct net_device *ndev)
 		return -ENOMEM;
 
 	if (mdio_bus_data->irqs)
-		memcpy(new_bus->irq, mdio_bus_data, sizeof(new_bus->irq));
+		memcpy(new_bus->irq, mdio_bus_data->irqs, sizeof(new_bus->irq));
 
 #ifdef CONFIG_OF
 	if (priv->device->of_node)
-- 
2.7.0
