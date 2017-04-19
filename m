From: Alexander Kochetkov <al.kochet@gmail.com>
Subject: [PATCH] net: arc_emac: switch to phy_start()/phy_stop()
Date: Wed, 19 Apr 2017 17:29:55 +0300
Message-ID: <1492612195-16601-1-git-send-email-al.kochet@gmail.com>
Cc: Alexander Kochetkov <al.kochet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Peter Chen <peter.chen@nxp.com>,
        Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch replace phy_start_aneg() with phy_start(). phy_start() call
phy_start_aneg() as a part of startup sequence and allow recover from
error (PHY_HALTED) state.

Also added call phy_stop() to arc_emac_remove() to stop PHY state machine
when MAC is down.

Signed-off-by: Alexander Kochetkov <al.kochet@gmail.com>
---
 drivers/net/ethernet/arc/emac_main.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index abc9f2a..188676d 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -434,7 +434,7 @@ static int arc_emac_open(struct net_device *ndev)
 	/* Enable EMAC */
 	arc_reg_or(priv, R_CTRL, EN_MASK);
 
-	phy_start_aneg(ndev->phydev);
+	phy_start(ndev->phydev);
 
 	netif_start_queue(ndev);
 
@@ -556,6 +556,8 @@ static int arc_emac_stop(struct net_device *ndev)
 	napi_disable(&priv->napi);
 	netif_stop_queue(ndev);
 
+	phy_stop(ndev->phydev);
+
 	/* Disable interrupts */
 	arc_reg_clr(priv, R_ENABLE, RXINT_MASK | TXINT_MASK | ERR_MASK);
 
-- 
1.7.9.5
