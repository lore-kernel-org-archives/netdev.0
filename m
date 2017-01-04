From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH] stmmac: Enable Clause 45 PHYs in GAMC4
Date: Wed,  4 Jan 2017 14:35:26 +0000
Message-ID: <14201d58c172f7a65b03510d36d55170f4d16cd5.1483540094.git.jpinto@synopsys.com>
Cc: hock.leong.kweh@intel.com, netdev@vger.kernel.org,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.47.9]:60040 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031063AbdADOfc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 09:35:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The eQOS IP Core (best known in stmmac as gmac4) has a register that must be
set if using a Clause 45 PHY. If this register is not set, the PHY won't work.
This patch will have no impact in setups using Clause 22 PHYs.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index b0344c2..676ae3c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -41,6 +41,7 @@
 #define MII_GMAC4_GOC_SHIFT		2
 #define MII_GMAC4_WRITE			(1 << MII_GMAC4_GOC_SHIFT)
 #define MII_GMAC4_READ			(3 << MII_GMAC4_GOC_SHIFT)
+#define MII_CLAUSE45_PHY		(1 << 1)
 
 static int stmmac_mdio_busy_wait(void __iomem *ioaddr, unsigned int mii_addr)
 {
@@ -125,7 +126,7 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
 	value |= (priv->clk_csr << priv->hw->mii.clk_csr_shift)
 		& priv->hw->mii.clk_csr_mask;
 	if (priv->plat->has_gmac4)
-		value |= MII_GMAC4_WRITE;
+		value |= MII_GMAC4_WRITE | MII_CLAUSE45_PHY;
 	else
 		value |= MII_WRITE;
 
-- 
2.9.3
