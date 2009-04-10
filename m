From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 09/12] rds: use kmem_cache_zalloc instead of kmem_cache_alloc/memset
Date: Thu,  9 Apr 2009 17:09:44 -0700
Message-ID: <1239322187-3764-10-git-send-email-andy.grover@oracle.com>
References: <1239322187-3764-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, Wei Yongjun <yjwei@cn.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:39376 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937533AbZDJAKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 20:10:14 -0400
In-Reply-To: <1239322187-3764-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

Use kmem_cache_zalloc instead of kmem_cache_alloc/memset.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/connection.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index 273f064..d14445c 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -148,14 +148,12 @@ static struct rds_connection *__rds_conn_create(__be32 laddr, __be32 faddr,
 	if (conn)
 		goto out;
 
-	conn = kmem_cache_alloc(rds_conn_slab, gfp);
+	conn = kmem_cache_zalloc(rds_conn_slab, gfp);
 	if (conn == NULL) {
 		conn = ERR_PTR(-ENOMEM);
 		goto out;
 	}
 
-	memset(conn, 0, sizeof(*conn));
-
 	INIT_HLIST_NODE(&conn->c_hash_node);
 	conn->c_version = RDS_PROTOCOL_3_0;
 	conn->c_laddr = laddr;
-- 
1.5.6.3

