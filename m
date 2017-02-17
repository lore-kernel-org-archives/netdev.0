From: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCHv2 1/1] rds:Remove unnecessary ib_ring unalloc
Date: Fri, 17 Feb 2017 04:16:22 -0500
Message-ID: <1487322982-29215-1-git-send-email-yanjun.zhu@oracle.com>
To: santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In the function rds_ib_xmit_atomic, ib_ring is not allocated
successfully. As such, it is not necessary to unalloc it.

Cc: Joe Jin <joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Junxiao Bi <junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
Change from v1 to v2:
  fix the word errors in the short log.

 net/rds/ib_send.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index 84d90c9..84b34cc 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -765,7 +765,6 @@ int rds_ib_xmit_atomic(struct rds_connection *conn, struct rm_atomic_op *op)
 
 	work_alloc = rds_ib_ring_alloc(&ic->i_send_ring, 1, &pos);
 	if (work_alloc != 1) {
-		rds_ib_ring_unalloc(&ic->i_send_ring, work_alloc);
 		rds_ib_stats_inc(s_ib_tx_ring_full);
 		ret = -ENOMEM;
 		goto out;
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
