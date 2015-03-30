From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/7] net/mlx4_en: Create new header file for all statistics info
Date: Mon, 30 Mar 2015 17:45:21 +0300
Message-ID: <1427726726-27516-3-git-send-email-ogerlitz@mellanox.com>
References: <1427726726-27516-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Hadar Har-Zion <hadarh@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:50782 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753454AbbC3Opx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 10:45:53 -0400
In-Reply-To: <1427726726-27516-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Add mlx4_stats.h file and move there all statistics structs and marcos.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    2 -
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |   34 +----------------
 drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h |   47 +++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/port.c       |    1 +
 4 files changed, 49 insertions(+), 35 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index a7b58ba..310d798 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -123,8 +123,6 @@ static const char main_strings[][ETH_GSTRING_LEN] = {
 	"tx_prio_1", "tx_prio_2", "tx_prio_3", "tx_prio_4", "tx_prio_5",
 	"tx_prio_6", "tx_prio_7",
 };
-#define NUM_MAIN_STATS	21
-#define NUM_ALL_STATS	(NUM_MAIN_STATS + NUM_PORT_STATS + NUM_PKT_STATS + NUM_PERF_STATS)
 
 static const char mlx4_en_test_names[][ETH_GSTRING_LEN]= {
 	"Interrupt Test",
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 8ad241b..6b379a2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -55,6 +55,7 @@
 #include <linux/mlx4/cmd.h>
 
 #include "en_port.h"
+#include "mlx4_stats.h"
 
 #define DRV_NAME	"mlx4_en"
 #define DRV_VERSION	"2.2-1"
@@ -171,7 +172,6 @@ enum {
 /* Number of samples to 'average' */
 #define AVG_SIZE			128
 #define AVG_FACTOR			1024
-#define NUM_PERF_STATS			NUM_PERF_COUNTERS
 
 #define INC_PERF_COUNTER(cnt)		(++(cnt))
 #define ADD_PERF_COUNTER(cnt, add)	((cnt) += (add))
@@ -182,7 +182,6 @@ enum {
 
 #else
 
-#define NUM_PERF_STATS			0
 #define INC_PERF_COUNTER(cnt)		do {} while (0)
 #define ADD_PERF_COUNTER(cnt, add)	do {} while (0)
 #define AVG_PERF_COUNTER(cnt, sample)	do {} while (0)
@@ -435,37 +434,6 @@ struct mlx4_en_port_state {
 	u32 flags;
 };
 
-struct mlx4_en_pkt_stats {
-	unsigned long broadcast;
-	unsigned long rx_prio[8];
-	unsigned long tx_prio[8];
-#define NUM_PKT_STATS		17
-};
-
-struct mlx4_en_port_stats {
-	unsigned long tso_packets;
-	unsigned long xmit_more;
-	unsigned long queue_stopped;
-	unsigned long wake_queue;
-	unsigned long tx_timeout;
-	unsigned long rx_alloc_failed;
-	unsigned long rx_chksum_good;
-	unsigned long rx_chksum_none;
-	unsigned long rx_chksum_complete;
-	unsigned long tx_chksum_offload;
-#define NUM_PORT_STATS		10
-};
-
-struct mlx4_en_perf_stats {
-	u32 tx_poll;
-	u64 tx_pktsz_avg;
-	u32 inflight_avg;
-	u16 tx_coal_avg;
-	u16 rx_coal_avg;
-	u32 napi_quota;
-#define NUM_PERF_COUNTERS		6
-};
-
 enum mlx4_en_mclist_act {
 	MCLIST_NONE,
 	MCLIST_REM,
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
new file mode 100644
index 0000000..abea7a5
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
@@ -0,0 +1,47 @@
+#ifndef _MLX4_STATS_
+#define _MLX4_STATS_
+
+#ifdef MLX4_EN_PERF_STAT
+#define NUM_PERF_STATS			NUM_PERF_COUNTERS
+#else
+#define NUM_PERF_STATS			0
+#endif
+
+#define NUM_PRIORITIES	9
+#define NUM_PRIORITY_STATS 2
+
+struct mlx4_en_pkt_stats {
+	unsigned long broadcast;
+	unsigned long rx_prio[8];
+	unsigned long tx_prio[8];
+#define NUM_PKT_STATS                17
+};
+
+struct mlx4_en_port_stats {
+	unsigned long tso_packets;
+	unsigned long xmit_more;
+	unsigned long queue_stopped;
+	unsigned long wake_queue;
+	unsigned long tx_timeout;
+	unsigned long rx_alloc_failed;
+	unsigned long rx_chksum_good;
+	unsigned long rx_chksum_none;
+	unsigned long rx_chksum_complete;
+	unsigned long tx_chksum_offload;
+#define NUM_PORT_STATS		10
+};
+
+struct mlx4_en_perf_stats {
+	u32 tx_poll;
+	u64 tx_pktsz_avg;
+	u32 inflight_avg;
+	u16 tx_coal_avg;
+	u16 rx_coal_avg;
+	u32 napi_quota;
+#define NUM_PERF_COUNTERS		6
+};
+
+#define NUM_MAIN_STATS	21
+#define NUM_ALL_STATS	(NUM_MAIN_STATS + NUM_PORT_STATS + NUM_PKT_STATS + \
+			 NUM_PERF_STATS)
+#endif
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 553c98c..3f6f771 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -38,6 +38,7 @@
 #include <linux/mlx4/cmd.h>
 
 #include "mlx4.h"
+#include "mlx4_stats.h"
 
 #define MLX4_MAC_VALID		(1ull << 63)
 
-- 
1.7.1
