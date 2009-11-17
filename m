From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [net-next] bnx2x: Don't set netdev->trans_start
Date: Tue, 17 Nov 2009 18:16:35 +0200
Message-ID: <1258474595.32030.1.camel@lb-tlvb-vladz.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4404 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751788AbZKQQ2u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2009 11:28:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Setting dev->trans_start caused spurious watchdog warnings.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index bdecd42..77ba135 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -2557,7 +2557,6 @@ static void bnx2x_e1h_disable(struct bnx2x *bp)
 	int port = BP_PORT(bp);
 
 	netif_tx_disable(bp->dev);
-	bp->dev->trans_start = jiffies;	/* prevent tx timeout */
 
 	REG_WR(bp, NIG_REG_LLH0_FUNC_EN + port*8, 0);
 
@@ -7098,7 +7097,6 @@ static void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw)
 	bnx2x_int_disable_sync(bp, disable_hw);
 	bnx2x_napi_disable(bp);
 	netif_tx_disable(bp->dev);
-	bp->dev->trans_start = jiffies;	/* prevent tx timeout */
 }
 
 /*
@@ -10282,7 +10280,6 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 
 	num_pkts++;
 	fp_tx->tx_bd_prod += 2; /* start + pbd */
-	bp->dev->trans_start = jiffies;
 
 	udelay(100);
 
-- 
1.6.3.3




