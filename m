From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 3/5] RDS: Clean up error handling in rds_cmsg_rdma_args
Date: Thu, 28 Oct 2010 18:40:57 -0700
Message-ID: <1288316459-4679-4-git-send-email-andy.grover@oracle.com>
References: <1288316459-4679-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:43461 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755651Ab0J2Bl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 21:41:27 -0400
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by rcsinet10.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id o9T1fPnm030242
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 01:41:26 GMT
In-Reply-To: <1288316459-4679-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't need to set ret = 0 at the end -- it's initialized to 0.

Also, don't increment s_send_rdma stat if we're exiting with an
error.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/rdma.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index d0ba2ca..334acdd 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -664,13 +664,12 @@ int rds_cmsg_rdma_args(struct rds_sock *rs, struct rds_message *rm,
 	}
 	op->op_bytes = nr_bytes;
 
-	ret = 0;
 out:
 	kfree(pages);
 	if (ret)
 		rds_rdma_free_op(op);
-
-	rds_stats_inc(s_send_rdma);
+	else
+		rds_stats_inc(s_send_rdma);
 
 	return ret;
 }
-- 
1.7.1

