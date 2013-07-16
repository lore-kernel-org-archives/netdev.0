From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net 1/6] bnx2x: properly initialize statistic counters
Date: Tue, 16 Jul 2013 18:21:42 +0300
Message-ID: <1373988107-305-2-git-send-email-dmitry@broadcom.com>
References: <1373988107-305-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3189 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932727Ab3GPPWC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jul 2013 11:22:02 -0400
In-Reply-To: <1373988107-305-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This prevent second statistics query be sent before first one is complete.
This is required since two outstanding queries may cause FW assert.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 98366ab..69c4cb6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -1591,10 +1591,16 @@ void bnx2x_stats_init(struct bnx2x *bp)
 {
 	int /*abs*/port = BP_PORT(bp);
 	int mb_idx = BP_FW_MB_IDX(bp);
+	__le16 init_fw_counter = le16_to_cpu(0xFFFF);
+	struct stats_counter *counters = &bp->fw_stats_data->storm_counters;
 
 	bp->stats_pending = 0;
 	bp->executer_idx = 0;
 	bp->stats_counter = 0;
+	counters->xstats_counter = init_fw_counter;
+	counters->tstats_counter = init_fw_counter;
+	counters->ustats_counter = init_fw_counter;
+	counters->cstats_counter = init_fw_counter;
 
 	/* port and func stats for management */
 	if (!BP_NOMCP(bp)) {
-- 
1.8.1.4
