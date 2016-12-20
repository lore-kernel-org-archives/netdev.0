From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH] stmmac: CSR clock configuration fix
Date: Tue, 20 Dec 2016 11:21:47 +0000
Message-ID: <6d4c6d15a60c93a8aef5e3e03b9cd64cdcf232c8.1482232420.git.jpinto@synopsys.com>
Cc: hock.leong.kweh@intel.com, niklas.cassel@axis.com, pavel@ucw.cz,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: peppe.cavallaro@st.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When testing stmmac with my QoS reference design I checked a problem in the
CSR clock configuration that was impossibilitating the phy discovery, since
every read operation returned 0x0000ffff. This patch fixes the issue.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index 23322fd..fda01f7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -81,8 +81,8 @@ static int stmmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
 	value |= (phyaddr << priv->hw->mii.addr_shift)
 		& priv->hw->mii.addr_mask;
 	value |= (phyreg << priv->hw->mii.reg_shift) & priv->hw->mii.reg_mask;
-	value |= (priv->clk_csr & priv->hw->mii.clk_csr_mask)
-		<< priv->hw->mii.clk_csr_shift;
+	value |= (priv->clk_csr << priv->hw->mii.clk_csr_shift)
+		& priv->hw->mii.clk_csr_mask;
 	if (priv->plat->has_gmac4)
 		value |= MII_GMAC4_READ;
 
@@ -122,8 +122,8 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
 		& priv->hw->mii.addr_mask;
 	value |= (phyreg << priv->hw->mii.reg_shift) & priv->hw->mii.reg_mask;
 
-	value |= ((priv->clk_csr & priv->hw->mii.clk_csr_mask)
-		<< priv->hw->mii.clk_csr_shift);
+	value |= (priv->clk_csr << priv->hw->mii.clk_csr_shift)
+		& priv->hw->mii.clk_csr_mask;
 	if (priv->plat->has_gmac4)
 		value |= MII_GMAC4_WRITE;
 
-- 
2.9.3
