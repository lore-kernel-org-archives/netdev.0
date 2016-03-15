From: Phil Reid <preid@electromag.com.au>
Subject: [PATCH 1/1] net: stmmac: Don't search for phys if mdio node is defined.
Date: Tue, 15 Mar 2016 15:34:33 +0800
Message-ID: <1458027273-127737-2-git-send-email-preid@electromag.com.au>
References: <1458027273-127737-1-git-send-email-preid@electromag.com.au>
Cc: Phil Reid <preid@electromag.com.au>
To: peppe.cavallaro@st.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.59.230.133] ([203.59.230.133]:40279 "EHLO
	preid-centos7.electromag.com.au" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S934112AbcCOHoa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 03:44:30 -0400
In-Reply-To: <1458027273-127737-1-git-send-email-preid@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a dt mdio entry has been added least assume that we wont
search for phys attached. The DT and of_mdiobus_register already do
this. This stops DSA phys being found and phys created for them, as
this is handled by the DSA driver.

Signed-off-by: Phil Reid <preid@electromag.com.au>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index 3f5512f..06704ca 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -235,6 +235,9 @@ int stmmac_mdio_register(struct net_device *ndev)
 		goto bus_register_fail;
 	}
 
+	if (priv->plat->phy_node || mdio_node)
+		goto bus_register_done;
+
 	found = 0;
 	for (addr = 0; addr < PHY_MAX_ADDR; addr++) {
 		struct phy_device *phydev = mdiobus_get_phy(new_bus, addr);
@@ -290,6 +293,7 @@ int stmmac_mdio_register(struct net_device *ndev)
 		return -ENODEV;
 	}
 
+bus_register_done:
 	priv->mii = new_bus;
 
 	return 0;
-- 
1.8.3.1
