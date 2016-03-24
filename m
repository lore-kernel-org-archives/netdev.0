From: John Keeping <john@metanate.com>
Subject: [PATCH] stmmac: Fix phy without MDIO subnode
Date: Thu, 24 Mar 2016 10:56:52 +0000
Message-ID: <1458817012-14293-1-git-send-email-john@metanate.com>
Cc: Gabriel Fernandez <gabriel.fernandez@linaro.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	John Keeping <john@metanate.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit 88f8b1bb41c6 ("stmmac: Fix 'eth0: No PHY found'
regression") we no longer allocate mdio_bus_data unless there is a MDIO
subnode.  This breaks the ethernet on the Radxa Rock2 (using
rk3288-rock2-square.dts) which does not have an MDIO subnode.

That commit was correct that the phy_bus_name test is unhelpful since we
allocate "plat" in the same function and never set phy_bus_name so let's
just drop the test which restores the previous behaviour.

Fixes: 88f8b1bb41c6 ("stmmac: Fix 'eth0: No PHY found' regression")
Signed-off-by: John Keeping <john@metanate.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index dcbd2a1..e0fa060 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -189,7 +189,7 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 	if (of_property_read_u32(np, "snps,phy-addr", &plat->phy_addr) == 0)
 		dev_warn(&pdev->dev, "snps,phy-addr property is deprecated\n");
 
-	if ((plat->phy_node && !of_phy_is_fixed_link(np)) || !plat->mdio_node)
+	if ((plat->phy_node && !of_phy_is_fixed_link(np)))
 		plat->mdio_bus_data = NULL;
 	else
 		plat->mdio_bus_data =
-- 
2.7.0.226.gfe986fe
