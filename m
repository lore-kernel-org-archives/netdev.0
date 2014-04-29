From: <dinguyen@altera.com>
Subject: [PATCH net-next] net: stmmac: set phy to use polling by default
Date: Tue, 29 Apr 2014 12:56:21 -0500
Message-ID: <1398794181-17852-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dinh.linux@gmail.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <vbridger@altera.com>,
	Dinh Nguyen <dinguyen@altera.com>
To: <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0144.outbound.protection.outlook.com ([65.55.169.144]:18084
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933160AbaD2R7N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2014 13:59:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dinh Nguyen <dinguyen@altera.com>

mii_irq[] array is never initialized anywhere in the driver, thus mii_irq[]
will always equate to zero. So, for the case where the PHY does not have an
irq, we should use PHY_POLL for that situation.

Signed-off-by: Dinh Nguyen <dinguyen@altera.com>
Tested-by: Vince Bridgers <vbridger@altera.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index a468eb1..a5b1e1b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -205,10 +205,13 @@ int stmmac_mdio_register(struct net_device *ndev)
 	if (new_bus == NULL)
 		return -ENOMEM;
 
-	if (mdio_bus_data->irqs)
+	if (mdio_bus_data->irqs) {
 		irqlist = mdio_bus_data->irqs;
-	else
+	} else {
+		for (addr = 0; addr < PHY_MAX_ADDR; addr++)
+			priv->mii_irq[addr] = PHY_POLL;
 		irqlist = priv->mii_irq;
+	}
 
 #ifdef CONFIG_OF
 	if (priv->device->of_node)
-- 
1.7.9.5
