From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 4/5] net-next: stmmac: Convert old_link to bool
Date: Wed, 24 May 2017 09:16:46 +0200
Message-ID: <20170524071647.7921-5-clabbe.montjoie@gmail.com>
References: <20170524071647.7921-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170524071647.7921-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch convert old_link from int to bool since it store only 1 or 0

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      | 2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 33efe7038cab..a916e13624eb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -104,7 +104,7 @@ struct stmmac_priv {
 	/* TX Queue */
 	struct stmmac_tx_queue tx_queue[MTL_MAX_TX_QUEUES];
 
-	int oldlink;
+	bool oldlink;
 	int speed;
 	int oldduplex;
 	unsigned int flow_ctrl;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 5643a5c916b6..4bd83a29cbd5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -851,11 +851,11 @@ static void stmmac_adjust_link(struct net_device *dev)
 
 		if (!priv->oldlink) {
 			new_state = true;
-			priv->oldlink = 1;
+			priv->oldlink = true;
 		}
 	} else if (priv->oldlink) {
 		new_state = true;
-		priv->oldlink = 0;
+		priv->oldlink = false;
 		priv->speed = SPEED_UNKNOWN;
 		priv->oldduplex = DUPLEX_UNKNOWN;
 	}
@@ -918,7 +918,7 @@ static int stmmac_init_phy(struct net_device *dev)
 	char bus_id[MII_BUS_ID_SIZE];
 	int interface = priv->plat->interface;
 	int max_speed = priv->plat->max_speed;
-	priv->oldlink = 0;
+	priv->oldlink = false;
 	priv->speed = SPEED_UNKNOWN;
 	priv->oldduplex = DUPLEX_UNKNOWN;
 
@@ -4308,7 +4308,7 @@ int stmmac_suspend(struct device *dev)
 	}
 	spin_unlock_irqrestore(&priv->lock, flags);
 
-	priv->oldlink = 0;
+	priv->oldlink = false;
 	priv->speed = SPEED_UNKNOWN;
 	priv->oldduplex = DUPLEX_UNKNOWN;
 	return 0;
-- 
2.13.0
