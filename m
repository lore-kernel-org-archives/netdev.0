From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH] net: stmmac: Handle possible fixed-link with need_mdio_ids
Date: Fri, 25 Aug 2017 16:42:08 +0200
Message-ID: <20170825144208.24503-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case of fixed link, there are no mdio node.
This patch add a test for fixed-link for bypassing MDIO node register.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index a366b3747eeb..e1be5735365b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -332,7 +332,7 @@ static int stmmac_dt_phy(struct plat_stmmacenet_data *plat,
 		mdio = false;
 	}
 
-	if (of_match_node(need_mdio_ids, np)) {
+	if (of_match_node(need_mdio_ids, np) && !of_phy_is_fixed_link(np)) {
 		plat->mdio_node = of_get_child_by_name(np, "mdio");
 	} else {
 		/**
-- 
2.13.5
