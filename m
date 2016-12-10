From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 2/5] net: ethernet: ti: cpsw: don't start queue twice
Date: Sat, 10 Dec 2016 14:23:47 +0200
Message-ID: <1481372630-14914-3-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1481372630-14914-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com, grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481372630-14914-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No need to start queues after cpsw is started as it will be done
while cpsw_adjust_link(), after phy connection.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index c45f7d2..23213a3 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1506,8 +1506,6 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	if (cpsw->data.dual_emac)
 		cpsw->slaves[priv->emac_port].open_stat = true;
 
-	netif_tx_start_all_queues(ndev);
-
 	return 0;
 
 err_cleanup:
-- 
2.7.4
