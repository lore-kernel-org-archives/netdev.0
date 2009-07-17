From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 14/15] RDS/IW: Remove dead code
Date: Fri, 17 Jul 2009 16:13:35 -0700
Message-ID: <1247872416-17834-15-git-send-email-andy.grover@oracle.com>
References: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:26045 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757957AbZGQXov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 19:44:51 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by acsinet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n6HNiunl007930
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 23:44:58 GMT
In-Reply-To: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In iWARP code, node_type will always be RNIC

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/iw.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/net/rds/iw.c b/net/rds/iw.c
index 2e6b495..f5e9a29 100644
--- a/net/rds/iw.c
+++ b/net/rds/iw.c
@@ -89,15 +89,10 @@ void rds_iw_add_one(struct ib_device *device)
 		goto free_dev;
 
 	if (!rds_iwdev->dma_local_lkey) {
-		if (device->node_type != RDMA_NODE_RNIC) {
-			rds_iwdev->mr = ib_get_dma_mr(rds_iwdev->pd,
-						IB_ACCESS_LOCAL_WRITE);
-		} else {
-			rds_iwdev->mr = ib_get_dma_mr(rds_iwdev->pd,
-						IB_ACCESS_REMOTE_READ |
-						IB_ACCESS_REMOTE_WRITE |
-						IB_ACCESS_LOCAL_WRITE);
-		}
+		rds_iwdev->mr = ib_get_dma_mr(rds_iwdev->pd,
+					IB_ACCESS_REMOTE_READ |
+					IB_ACCESS_REMOTE_WRITE |
+					IB_ACCESS_LOCAL_WRITE);
 		if (IS_ERR(rds_iwdev->mr))
 			goto err_pd;
 	} else
-- 
1.6.0.4

