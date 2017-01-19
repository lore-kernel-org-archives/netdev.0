From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v2 2/5] net: ethernet: ti: cpsw: don't disable interrupts in ndo_open
Date: Thu, 19 Jan 2017 18:58:24 +0200
Message-ID: <1484845107-30331-3-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1484845107-30331-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, netdev@vger.kernel.org,
        linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484845107-30331-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No need to disable interrupts if no open devices,
they are disabled anyway.

Even no need to disable interrupts if some ndev is opened, In this
case shared resources are not touched, only parameters of ndev shell,
so no reason to disable them also. Removed lines have proved it.

So, no need in redundant check and interrupt disable.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 296ddf2..f798905 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1480,8 +1480,6 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		return ret;
 	}
 
-	if (!cpsw_common_res_usage_state(cpsw))
-		cpsw_intr_disable(cpsw);
 	netif_carrier_off(ndev);
 
 	/* Notify the stack of the actual queue counts. */
-- 
2.7.4
