From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v2 02/14] net: ethernet: ti: cpsw: remove redundant check in napi poll
Date: Sat,  6 Aug 2016 13:48:32 +0300
Message-ID: <1470480524-6851-3-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
	dlide@ti.com, Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No need to check number of handled packets, when in most cases (> 99%)
it's not 0. It can be 0 only in rare cases, even in this case
it's not bad to print just 0.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 8972bf6..85ee9f5 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -793,9 +793,7 @@ static int cpsw_tx_poll(struct napi_struct *napi_tx, int budget)
 		}
 	}
 
-	if (num_tx)
-		cpsw_dbg(priv, intr, "poll %d tx pkts\n", num_tx);
-
+	cpsw_dbg(priv, intr, "poll %d tx pkts\n", num_tx);
 	return num_tx;
 }
 
@@ -814,9 +812,7 @@ static int cpsw_rx_poll(struct napi_struct *napi_rx, int budget)
 		}
 	}
 
-	if (num_rx)
-		cpsw_dbg(priv, intr, "poll %d rx pkts\n", num_rx);
-
+	cpsw_dbg(priv, intr, "poll %d rx pkts\n", num_rx);
 	return num_rx;
 }
 
-- 
1.9.1
