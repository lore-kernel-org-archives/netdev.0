From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 8/8] net: stmmac: invert the logic for dumping regs
Date: Tue, 14 Feb 2017 20:54:41 +0100
Message-ID: <20170214195441.30425-9-clabbe.montjoie@gmail.com>
References: <20170214195441.30425-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170214195441.30425-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is easier to follow the logic by removing the not operator

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index aab895d..5ff6bc4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -442,24 +442,24 @@ static void stmmac_ethtool_gregs(struct net_device *dev,
 
 	memset(reg_space, 0x0, REG_SPACE_SIZE);
 
-	if (!(priv->plat->has_gmac || priv->plat->has_gmac4)) {
+	if (priv->plat->has_gmac || priv->plat->has_gmac4) {
 		/* MAC registers */
-		for (i = 0; i < 12; i++)
+		for (i = 0; i < 55; i++)
 			reg_space[i] = readl(priv->ioaddr + (i * 4));
 		/* DMA registers */
-		for (i = 0; i < 9; i++)
-			reg_space[i + 12] =
+		for (i = 0; i < 22; i++)
+			reg_space[i + 55] =
 			    readl(priv->ioaddr + (DMA_BUS_MODE + (i * 4)));
-		reg_space[22] = readl(priv->ioaddr + DMA_CUR_TX_BUF_ADDR);
-		reg_space[23] = readl(priv->ioaddr + DMA_CUR_RX_BUF_ADDR);
 	} else {
 		/* MAC registers */
-		for (i = 0; i < 55; i++)
+		for (i = 0; i < 12; i++)
 			reg_space[i] = readl(priv->ioaddr + (i * 4));
 		/* DMA registers */
-		for (i = 0; i < 22; i++)
-			reg_space[i + 55] =
+		for (i = 0; i < 9; i++)
+			reg_space[i + 12] =
 			    readl(priv->ioaddr + (DMA_BUS_MODE + (i * 4)));
+		reg_space[22] = readl(priv->ioaddr + DMA_CUR_TX_BUF_ADDR);
+		reg_space[23] = readl(priv->ioaddr + DMA_CUR_RX_BUF_ADDR);
 	}
 }
 
-- 
2.10.2
