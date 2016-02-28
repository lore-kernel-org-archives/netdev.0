From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 04/10] net/mlx5e: Move common case counters within sq_stats struct
Date: Sun, 28 Feb 2016 17:09:05 +0200
Message-ID: <1456672151-11749-5-git-send-email-saeedm@mellanox.com>
References: <1456672151-11749-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:59839 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757979AbcB1PKw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 10:10:52 -0500
In-Reply-To: <1456672151-11749-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

For data cache locality considerations, we moved the nop and
csum_offload_inner within sq_stats struct as they are more
commonly accessed in xmit path.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 4511984..b289660 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -260,26 +260,28 @@ static const char sq_stats_strings[][ETH_GSTRING_LEN] = {
 	"tso_bytes",
 	"tso_inner_packets",
 	"tso_inner_bytes",
-	"csum_offload_none",
 	"csum_offload_inner",
+	"nop",
+	"csum_offload_none",
 	"stopped",
 	"wake",
 	"dropped",
-	"nop"
 };
 
 struct mlx5e_sq_stats {
+	/* commonly accessed in data path */
 	u64 packets;
 	u64 tso_packets;
 	u64 tso_bytes;
 	u64 tso_inner_packets;
 	u64 tso_inner_bytes;
-	u64 csum_offload_none;
 	u64 csum_offload_inner;
+	u64 nop;
+	/* less likely accessed in data path */
+	u64 csum_offload_none;
 	u64 stopped;
 	u64 wake;
 	u64 dropped;
-	u64 nop;
 #define NUM_SQ_STATS 11
 };
 
-- 
1.7.1
