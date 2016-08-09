From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v3 02/13] net: ethernet: ti: cpsw: remove intr dbg msg from poll handlers
Date: Wed, 10 Aug 2016 02:22:33 +0300
Message-ID: <1470784964-26440-3-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1470784964-26440-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
	dlide@ti.com, Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470784964-26440-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At poll handler no possibility to figure out which network device is
handling packets, as cpdma channels are common for both network
devices in dual_emac mode. Currently, the messages are printed only
for one device, in fact, there is two. This print msg is incorrect
and seems is not very useful, so drop it from poll handler.

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>
Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 8972bf6..21cf367 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -793,9 +793,6 @@ static int cpsw_tx_poll(struct napi_struct *napi_tx, int budget)
 		}
 	}
 
-	if (num_tx)
-		cpsw_dbg(priv, intr, "poll %d tx pkts\n", num_tx);
-
 	return num_tx;
 }
 
@@ -814,9 +811,6 @@ static int cpsw_rx_poll(struct napi_struct *napi_rx, int budget)
 		}
 	}
 
-	if (num_rx)
-		cpsw_dbg(priv, intr, "poll %d rx pkts\n", num_rx);
-
 	return num_rx;
 }
 
-- 
1.9.1
