From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v2 05/14] net: ethernet: ti: cpsw: don't check slave num in runtime
Date: Sat,  6 Aug 2016 13:48:35 +0300
Message-ID: <1470480524-6851-6-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
	dlide@ti.com, Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No need to check const slave num in runtime for every packet,
and ndev for slaves w/o ndev is anyway NULL. So remove redundant
check.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 70a9570..19aa4bb 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -498,8 +498,7 @@ static const struct cpsw_stats cpsw_gstrings_stats[] = {
 				(func)(slave++, ##arg);			\
 	} while (0)
 #define cpsw_get_slave_ndev(priv, __slave_no__)				\
-	((__slave_no__ < priv->data.slaves) ?				\
-		priv->slaves[__slave_no__].ndev : NULL)
+		priv->slaves[__slave_no__].ndev
 #define cpsw_get_slave_priv(priv, __slave_no__)				\
 	(((__slave_no__ < priv->data.slaves) &&				\
 		(priv->slaves[__slave_no__].ndev)) ?			\
-- 
1.9.1
