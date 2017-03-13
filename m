From: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCHv3 1/4] rds: ib: drop unnecessary rdma_reject
Date: Mon, 13 Mar 2017 01:43:45 -0400
Message-ID: <1489383828-7699-2-git-send-email-yanjun.zhu@oracle.com>
References: <1489383828-7699-1-git-send-email-yanjun.zhu@oracle.com>
To: santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
        leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489383828-7699-1-git-send-email-yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

When rdma_accept fails, rdma_reject is called in it. As such, it is
not necessary to execute rdma_reject again.

Cc: Joe Jin <joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Junxiao Bi <junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Acked-by: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 net/rds/ib_cm.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index ce3775a..4b9405c 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -677,9 +677,8 @@ int rds_ib_cm_handle_connect(struct rdma_cm_id *cm_id,
 		event->param.conn.initiator_depth);
 
 	/* rdma_accept() calls rdma_reject() internally if it fails */
-	err = rdma_accept(cm_id, &conn_param);
-	if (err)
-		rds_ib_conn_error(conn, "rdma_accept failed (%d)\n", err);
+	if (rdma_accept(cm_id, &conn_param))
+		rds_ib_conn_error(conn, "rdma_accept failed\n");
 
 out:
 	if (conn)
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
