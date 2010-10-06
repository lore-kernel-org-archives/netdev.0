From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 18/19] bnx2x: properly initialize FW stats
Date: Wed, 6 Oct 2010 15:35:03 +0200
Message-ID: <1286372103.30552.62.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4218 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932359Ab0JFNkt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 09:40:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Client statistics need to be initialized to -1

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_stats.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_stats.c b/drivers/net/bnx2x/bnx2x_stats.c
index 5644bdd..4733c83 100644
--- a/drivers/net/bnx2x/bnx2x_stats.c
+++ b/drivers/net/bnx2x/bnx2x_stats.c
@@ -1339,6 +1339,7 @@ void bnx2x_stats_init(struct bnx2x *bp)
 	int port = BP_PORT(bp);
 	int mb_idx = BP_FW_MB_IDX(bp);
 	int i;
+	struct eth_stats_query *stats = bnx2x_sp(bp, fw_stats);
 
 	bp->stats_pending = 0;
 	bp->executer_idx = 0;
@@ -1380,6 +1381,18 @@ void bnx2x_stats_init(struct bnx2x *bp)
 		memset(&fp->eth_q_stats, 0, sizeof(struct bnx2x_eth_q_stats));
 	}
 
+	for_each_queue(bp, i) {
+		/* Set initial stats counter in the stats ramrod data to -1 */
+		int cl_id = bp->fp[i].cl_id;
+
+		stats->xstorm_common.client_statistics[cl_id].
+			stats_counter = 0xffff;
+		stats->ustorm_common.client_statistics[cl_id].
+			stats_counter = 0xffff;
+		stats->tstorm_common.client_statistics[cl_id].
+			stats_counter = 0xffff;
+	}
+
 	memset(&bp->dev->stats, 0, sizeof(struct net_device_stats));
 	memset(&bp->eth_stats, 0, sizeof(struct bnx2x_eth_stats));
 
-- 
1.7.1




