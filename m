From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH -next 5/8] bnx2: Report FTQ discard counter.
Date: Fri, 21 Aug 2009 19:20:47 -0700
Message-ID: <1250907650-24672-5-git-send-email-mchan@broadcom.com>
References: <1250907650-24672-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4820 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933144AbZHVCNr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2009 22:13:47 -0400
In-Reply-To: <1250907650-24672-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Report this counter to ethtool -S and include it in netstat.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 085c2dd..e025833 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6485,7 +6485,8 @@ bnx2_get_stats(struct net_device *dev)
 		stats_blk->stat_EtherStatsOverrsizePkts);
 
 	net_stats->rx_over_errors =
-		(unsigned long) stats_blk->stat_IfInMBUFDiscards;
+		(unsigned long) (stats_blk->stat_IfInFTQDiscards +
+		stats_blk->stat_IfInMBUFDiscards);
 
 	net_stats->rx_frame_errors =
 		(unsigned long) stats_blk->stat_Dot3StatsAlignmentErrors;
@@ -6518,8 +6519,8 @@ bnx2_get_stats(struct net_device *dev)
 		net_stats->tx_carrier_errors;
 
 	net_stats->rx_missed_errors =
-		(unsigned long) (stats_blk->stat_IfInMBUFDiscards +
-		stats_blk->stat_FwRxDrop);
+		(unsigned long) (stats_blk->stat_IfInFTQDiscards +
+		stats_blk->stat_IfInMBUFDiscards + stats_blk->stat_FwRxDrop);
 
 	return net_stats;
 }
@@ -7090,11 +7091,9 @@ bnx2_set_tso(struct net_device *dev, u32 data)
 	return 0;
 }
 
-#define BNX2_NUM_STATS 46
-
 static struct {
 	char string[ETH_GSTRING_LEN];
-} bnx2_stats_str_arr[BNX2_NUM_STATS] = {
+} bnx2_stats_str_arr[] = {
 	{ "rx_bytes" },
 	{ "rx_error_bytes" },
 	{ "tx_bytes" },
@@ -7139,10 +7138,14 @@ static struct {
 	{ "tx_xoff_frames" },
 	{ "rx_mac_ctrl_frames" },
 	{ "rx_filtered_packets" },
+	{ "rx_ftq_discards" },
 	{ "rx_discards" },
 	{ "rx_fw_discards" },
 };
 
+#define BNX2_NUM_STATS (sizeof(bnx2_stats_str_arr)/\
+			sizeof(bnx2_stats_str_arr[0]))
+
 #define STATS_OFFSET32(offset_name) (offsetof(struct statistics_block, offset_name) / 4)
 
 static const unsigned long bnx2_stats_offset_arr[BNX2_NUM_STATS] = {
@@ -7190,6 +7193,7 @@ static const unsigned long bnx2_stats_offset_arr[BNX2_NUM_STATS] = {
     STATS_OFFSET32(stat_OutXoffSent),
     STATS_OFFSET32(stat_MacControlFramesReceived),
     STATS_OFFSET32(stat_IfInFramesL2FilterDiscards),
+    STATS_OFFSET32(stat_IfInFTQDiscards),
     STATS_OFFSET32(stat_IfInMBUFDiscards),
     STATS_OFFSET32(stat_FwRxDrop),
 };
@@ -7202,7 +7206,7 @@ static u8 bnx2_5706_stats_len_arr[BNX2_NUM_STATS] = {
 	4,0,4,4,4,4,4,4,4,4,
 	4,4,4,4,4,4,4,4,4,4,
 	4,4,4,4,4,4,4,4,4,4,
-	4,4,4,4,4,4,
+	4,4,4,4,4,4,4,
 };
 
 static u8 bnx2_5708_stats_len_arr[BNX2_NUM_STATS] = {
@@ -7210,7 +7214,7 @@ static u8 bnx2_5708_stats_len_arr[BNX2_NUM_STATS] = {
 	4,4,4,4,4,4,4,4,4,4,
 	4,4,4,4,4,4,4,4,4,4,
 	4,4,4,4,4,4,4,4,4,4,
-	4,4,4,4,4,4,
+	4,4,4,4,4,4,4,
 };
 
 #define BNX2_NUM_TESTS 6
-- 
1.5.6.GIT


