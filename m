From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 2/4] net: ethernet: ti: cpsw: don't disable interrupts in ndo_open
Date: Sun,  8 Jan 2017 18:41:01 +0200
Message-ID: <1483893663-15673-3-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1483893663-15673-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, grygorii.strashko@ti.com,
        linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483893663-15673-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If any interface is running the interrupts are disabled anyway.
It make sense to disable interrupts if any of interfaces is running,
but in this place, obviously, it didn't have any effect. So, no need
in redundant check and interrupt disable.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index d261024..40d7fc9 100644
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
