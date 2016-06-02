From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH] net: ethernet: ti: cpsw: remove unused priv lock
Date: Fri,  3 Jun 2016 01:37:08 +0300
Message-ID: <1464907028-19622-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no reason in this lock. At least for now.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---

Based on master

 drivers/net/ethernet/ti/cpsw.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 9919cb3..8d1d373 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -365,7 +365,6 @@ static inline void slave_write(struct cpsw_slave *slave, u32 val, u32 offset)
 }
 
 struct cpsw_priv {
-	spinlock_t			lock;
 	struct platform_device		*pdev;
 	struct net_device		*ndev;
 	struct napi_struct		napi_rx;
@@ -2413,7 +2412,6 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
 	}
 
 	priv_sl2 = netdev_priv(ndev);
-	spin_lock_init(&priv_sl2->lock);
 	priv_sl2->data = *data;
 	priv_sl2->pdev = pdev;
 	priv_sl2->ndev = ndev;
@@ -2533,7 +2531,6 @@ static int cpsw_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, ndev);
 	priv = netdev_priv(ndev);
-	spin_lock_init(&priv->lock);
 	priv->pdev = pdev;
 	priv->ndev = ndev;
 	priv->dev  = &ndev->dev;
-- 
1.9.1
