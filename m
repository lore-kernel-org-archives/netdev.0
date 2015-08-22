From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 06/14] RDS: check for congestion updates during rds_send_xmit
Date: Sat, 22 Aug 2015 15:45:27 -0700
Message-ID: <1440283535-4800-7-git-send-email-santosh.shilimkar@oracle.com>
References: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ensure we don't keep sending the data if the link is congested.

Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/send.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index e9430f5..dbdf907 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -411,7 +411,8 @@ over_batch:
 	 */
 	if (ret == 0) {
 		smp_mb();
-		if (!list_empty(&conn->c_send_queue) &&
+		if ((test_bit(0, &conn->c_map_queued) ||
+		     !list_empty(&conn->c_send_queue)) &&
 		    send_gen == conn->c_send_gen) {
 			rds_stats_inc(s_send_lock_queue_raced);
 			goto restart;
-- 
1.9.1
