From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] RDS: use gfp flags from caller in conn_alloc()
Date: Thu, 22 Mar 2012 09:44:09 +0300
Message-ID: <20120322064409.GE7369@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:30841 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752091Ab2CVGoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 02:44:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should be using the gfp flags the caller specified here, instead of
GFP_KERNEL.  I think this might be a bugfix, depending on the value of
"sock->sk->sk_allocation" when we call rds_conn_create_outgoing() in
rds_sendmsg().  Otherwise, it's just a cleanup.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/rds/loop.c b/net/rds/loop.c
index 87ff2a8..6b12b68 100644
--- a/net/rds/loop.c
+++ b/net/rds/loop.c
@@ -121,7 +121,7 @@ static int rds_loop_conn_alloc(struct rds_connection *conn, gfp_t gfp)
 	struct rds_loop_connection *lc;
 	unsigned long flags;
 
-	lc = kzalloc(sizeof(struct rds_loop_connection), GFP_KERNEL);
+	lc = kzalloc(sizeof(struct rds_loop_connection), gfp);
 	if (!lc)
 		return -ENOMEM;
 
diff --git a/net/rds/iw_cm.c b/net/rds/iw_cm.c
index 9556d28..a91e1db 100644
--- a/net/rds/iw_cm.c
+++ b/net/rds/iw_cm.c
@@ -694,7 +694,7 @@ int rds_iw_conn_alloc(struct rds_connection *conn, gfp_t gfp)
 	unsigned long flags;
 
 	/* XXX too lazy? */
-	ic = kzalloc(sizeof(struct rds_iw_connection), GFP_KERNEL);
+	ic = kzalloc(sizeof(struct rds_iw_connection), gfp);
 	if (!ic)
 		return -ENOMEM;
 
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 51c8689..a1e1162 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -749,7 +749,7 @@ int rds_ib_conn_alloc(struct rds_connection *conn, gfp_t gfp)
 	int ret;
 
 	/* XXX too lazy? */
-	ic = kzalloc(sizeof(struct rds_ib_connection), GFP_KERNEL);
+	ic = kzalloc(sizeof(struct rds_ib_connection), gfp);
 	if (!ic)
 		return -ENOMEM;
 
