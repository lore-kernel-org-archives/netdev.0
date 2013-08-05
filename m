From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net v4 1/6] bnx2x: properly initialize statistic
 counters
Date: Tue, 6 Aug 2013 00:35:39 +0300
Message-ID: <1375738544-8695-2-git-send-email-dmitry@broadcom.com>
References: <1375738544-8695-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1133 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753126Ab3HEVgD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 17:36:03 -0400
In-Reply-To: <1375738544-8695-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This prevent second statistics query be sent before first one is complete.
This is required since two outstanding queries may cause FW assert.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 98366ab..a22ad61 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -1589,12 +1589,17 @@ void bnx2x_memset_stats(struct bnx2x *bp)
 
 void bnx2x_stats_init(struct bnx2x *bp)
 {
-	int /*abs*/port = BP_PORT(bp);
+	struct stats_counter *counters = &bp->fw_stats_data->storm_counters;
 	int mb_idx = BP_FW_MB_IDX(bp);
+	int port = BP_PORT(bp);
 
 	bp->stats_pending = 0;
 	bp->executer_idx = 0;
 	bp->stats_counter = 0;
+	counters->xstats_counter = cpu_to_le16(0xFFFF);
+	counters->tstats_counter = cpu_to_le16(0xFFFF);
+	counters->ustats_counter = cpu_to_le16(0xFFFF);
+	counters->cstats_counter = cpu_to_le16(0xFFFF);
 
 	/* port and func stats for management */
 	if (!BP_NOMCP(bp)) {
-- 
1.8.1.4
