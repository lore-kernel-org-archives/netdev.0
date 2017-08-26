From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v4 1/5] net: stmmac: Handle possible fixed-link with need_mdio_ids
Date: Sat, 26 Aug 2017 09:33:07 +0200
Message-ID: <20170826073311.25612-2-clabbe.montjoie@gmail.com>
References: <20170826073311.25612-1-clabbe.montjoie@gmail.com>
Cc: icenowy@aosc.io, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, andrew@lunn.ch, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170826073311.25612-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case of fixed link, there are no mdio node.
This patch add a test for fixed-link for bypassing MDIO node register
that match need_mdio_ids.

Note that this do not change behaviour for MDIO snps,dwmac-mdio nodes.

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
