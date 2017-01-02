From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v3 06/17] RDS: RDMA: start rdma listening after init
Date: Mon,  2 Jan 2017 14:45:41 -0800
Message-ID: <1483397152-8307-7-git-send-email-santosh.shilimkar@oracle.com>
References: <1483397152-8307-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50541 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756908AbdABWqM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 17:46:12 -0500
In-Reply-To: <1483397152-8307-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Qing Huang <qing.huang@oracle.com>

This prevents RDS from handling incoming rdma packets before RDS
completes initializing its recv/send components.

Signed-off-by: Qing Huang <qing.huang@oracle.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/rdma_transport.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/rds/rdma_transport.c b/net/rds/rdma_transport.c
index d5f3117..fc59821 100644
--- a/net/rds/rdma_transport.c
+++ b/net/rds/rdma_transport.c
@@ -206,18 +206,13 @@ static int rds_rdma_init(void)
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
