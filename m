From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH 06/18] RDS: RDMA: start rdma listening after init
Date: Sun,  4 Dec 2016 22:57:41 -0800
Message-ID: <1480921073-9140-7-git-send-email-santosh.shilimkar@oracle.com>
References: <1480921073-9140-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org,
        Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480921073-9140-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Qing Huang <qing.huang@oracle.com>

This prevents RDS from handling incoming rdma packets before RDS
completes initializing its recv/send components.

Signed-off-by: Qing Huang <qing.huang@oracle.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/rdma_transport.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/rds/rdma_transport.c b/net/rds/rdma_transport.c
index 345f090..250c6b8 100644
--- a/net/rds/rdma_transport.c
+++ b/net/rds/rdma_transport.c
@@ -203,18 +203,13 @@ static int rds_rdma_init(void)
 {
 	int ret;
 
-	ret = rds_rdma_listen_init();
+	ret = rds_ib_init();
 	if (ret)
 		goto out;
 
-	ret = rds_ib_init();
+	ret = rds_rdma_listen_init();
 	if (ret)
-		goto err_ib_init;
-
-	goto out;
-
-err_ib_init:
-	rds_rdma_listen_stop();
+		rds_ib_exit();
 out:
 	return ret;
 }
-- 
1.9.1
