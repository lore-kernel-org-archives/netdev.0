From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 2/3] net: ethernet: ti: cpsw: remove redundant check in napi poll
Date: Fri,  5 Aug 2016 00:14:31 +0300
Message-ID: <1470345272-874-3-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1470345272-874-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, grygorii.strashko@ti.com,
	linux-kernel@vger.kernel.org,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:34073 "EHLO
	mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966638AbcHDVOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 17:14:44 -0400
Received: by mail-lf0-f48.google.com with SMTP id l69so190482136lfg.1
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2016 14:14:43 -0700 (PDT)
In-Reply-To: <1470345272-874-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to check number of handled packets, when in most cases (> 99%)
it's not 0. It can be 0 only in rarely cases, even in this case
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
