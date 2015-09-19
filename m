From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 10/15] RDS: handle rds_ibdev release case instead of crashing the kernel
Date: Sat, 19 Sep 2015 19:04:47 -0400
Message-ID: <1442703892-26692-11-git-send-email-santosh.shilimkar@oracle.com>
References: <1442703892-26692-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442703892-26692-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <ssantosh@kernel.org>

Just in case we are still handling the QP receive completion while the
rds_ibdev is released, drop the connection instead of crashing the kernel.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
---
 net/rds/ib_cm.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 8f51d0d..2b2370e 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -285,7 +285,8 @@ static void rds_ib_tasklet_fn_recv(unsigned long data)
 	struct rds_ib_device *rds_ibdev = ic->rds_ibdev;
 	struct rds_ib_ack_state state;
 
-	BUG_ON(!rds_ibdev);
+	if (!rds_ibdev)
+		rds_conn_drop(conn);
 
 	rds_ib_stats_inc(s_ib_tasklet_call);
 
-- 
1.9.1
