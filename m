From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 01/11] net/mlx4_en: Fix off-by-four in ethtool
Date: Tue, 23 Jun 2015 17:14:12 +0300
Message-ID: <1435068862-26488-2-git-send-email-ogerlitz@mellanox.com>
References: <1435068862-26488-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41170 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933905AbbFWOO6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jun 2015 10:14:58 -0400
In-Reply-To: <1435068862-26488-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

NUM_ALL_STATS was not updated with the new four entries, instead
NUM_FLOW_STATS was updated, fix it. that caused off-by-four for all
counters below pf_*_*.

Fixes: b42de4d01264 ('net/mlx4_en: Show PF own statistics via ethtool')
Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
index c5c1de9..7fd466c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
@@ -79,8 +79,7 @@ struct mlx4_en_flow_stats_tx {
 
 #define NUM_FLOW_STATS (NUM_FLOW_STATS_RX + NUM_FLOW_STATS_TX + \
 			NUM_FLOW_PRIORITY_STATS_TX + \
-			NUM_FLOW_PRIORITY_STATS_RX + \
-			NUM_PF_STATS)
+			NUM_FLOW_PRIORITY_STATS_RX)
 
 struct mlx4_en_stat_out_flow_control_mbox {
 	/* Total number of PAUSE frames received from the far-end port */
@@ -108,7 +107,7 @@ enum {
 };
 
 #define NUM_ALL_STATS	(NUM_MAIN_STATS + NUM_PORT_STATS + NUM_PKT_STATS + \
-			 NUM_FLOW_STATS + NUM_PERF_STATS)
+			 NUM_FLOW_STATS + NUM_PERF_STATS + NUM_PF_STATS)
 
 #define MLX4_FIND_NETDEV_STAT(n) (offsetof(struct net_device_stats, n) / \
 				  sizeof(((struct net_device_stats *)0)->n))
-- 
2.3.7
