From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: rds: use kmem_cache_zalloc instead of kmem_cache_alloc/memset
Date: Thu, 09 Apr 2009 16:02:18 +0800
Message-ID: <49DDAB8A.5000300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: Andy Grover <andy.grover@oracle.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54588 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756086AbZDIIDr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2009 04:03:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use kmem_cache_zalloc instead of kmem_cache_alloc/memset.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
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
1.5.3.8




