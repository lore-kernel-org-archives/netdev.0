From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 02/17] net: stmmac: Remove the bus_setup function pointer
Date: Tue, 31 Jan 2017 10:11:37 +0100
Message-ID: <20170131091152.13842-3-clabbe.montjoie@gmail.com>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The bus_setup function pointer is not used at all, this patch remove it.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 4 ----
 include/linux/stmmac.h                            | 1 -
 2 files changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index e3f6389..bf2d8e6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1671,10 +1671,6 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 	/* Copy the MAC addr into the HW  */
 	priv->hw->mac->set_umac_addr(priv->hw, dev->dev_addr, 0);
 
-	/* If required, perform hw setup of the bus. */
-	if (priv->plat->bus_setup)
-		priv->plat->bus_setup(priv->ioaddr);
-
 	/* PS and related bits will be programmed according to the speed */
 	if (priv->hw->pcs) {
 		int speed = priv->plat->mac_port_sel_speed;
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 266dab9..2d82df9 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -135,7 +135,6 @@ struct plat_stmmacenet_data {
 	int tx_fifo_size;
 	int rx_fifo_size;
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
-	void (*bus_setup)(void __iomem *ioaddr);
 	int (*init)(struct platform_device *pdev, void *priv);
 	void (*exit)(struct platform_device *pdev, void *priv);
 	void *bsp_priv;
-- 
2.10.2
