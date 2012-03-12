From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net 1/4] bnx2x: pfc statistics counts pfc events twice
Date: Mon, 12 Mar 2012 17:22:04 -0400
Message-ID: <1331587327-26279-2-git-send-email-yuvalmin@broadcom.com>
References: <1331587327-26279-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4772 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753012Ab2CLO2S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 10:28:18 -0400
In-Reply-To: <1331587327-26279-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When pfc statistics were counted, the delta change from last count
was summed twice. This fixes the issue.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c |   12 ------------
 1 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 1adef26..a766b25 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -554,23 +554,11 @@ static void bnx2x_bmac_stats_update(struct bnx2x *bp)
 		UPDATE_STAT64(tx_stat_gtufl, tx_stat_mac_ufl);
 
 		/* collect PFC stats */
-		DIFF_64(diff.hi, new->tx_stat_gtpp_hi,
-			pstats->pfc_frames_tx_hi,
-			diff.lo, new->tx_stat_gtpp_lo,
-			pstats->pfc_frames_tx_lo);
 		pstats->pfc_frames_tx_hi = new->tx_stat_gtpp_hi;
 		pstats->pfc_frames_tx_lo = new->tx_stat_gtpp_lo;
-		ADD_64(pstats->pfc_frames_tx_hi, diff.hi,
-			pstats->pfc_frames_tx_lo, diff.lo);
 
-		DIFF_64(diff.hi, new->rx_stat_grpp_hi,
-			pstats->pfc_frames_rx_hi,
-			diff.lo, new->rx_stat_grpp_lo,
-			pstats->pfc_frames_rx_lo);
 		pstats->pfc_frames_rx_hi = new->rx_stat_grpp_hi;
 		pstats->pfc_frames_rx_lo = new->rx_stat_grpp_lo;
-		ADD_64(pstats->pfc_frames_rx_hi, diff.hi,
-			pstats->pfc_frames_rx_lo, diff.lo);
 	}
 
 	estats->pause_frames_received_hi =
-- 
1.7.9.rc2
