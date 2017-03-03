From: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] rds: remove unnecessary returned value check
Date: Fri,  3 Mar 2017 00:44:26 -0500
Message-ID: <1488519866-24148-1-git-send-email-yanjun.zhu@oracle.com>
To: santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
        yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The function rds_trans_register always returns 0. As such, it is not
necessary to check the returned value.

Cc: Joe Jin <joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Junxiao Bi <junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 net/rds/ib.c        | 6 +-----
 net/rds/rds.h       | 2 +-
 net/rds/tcp.c       | 6 +-----
 net/rds/transport.c | 4 +---
 4 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/net/rds/ib.c b/net/rds/ib.c
index 0f557b2..7a64c8d 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -438,16 +438,12 @@ int rds_ib_init(void)
 	if (ret)
 		goto out_sysctl;
 
-	ret = rds_trans_register(&rds_ib_transport);
-	if (ret)
-		goto out_recv;
+	rds_trans_register(&rds_ib_transport);
 
 	rds_info_register_func(RDS_INFO_IB_CONNECTIONS, rds_ib_ic_info);
 
 	goto out;
 
-out_recv:
-	rds_ib_recv_exit();
 out_sysctl:
 	rds_ib_sysctl_exit();
 out_ibreg:
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 966d2ee..39518ef 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -903,7 +903,7 @@ void rds_connect_path_complete(struct rds_conn_path *conn, int curr);
 void rds_connect_complete(struct rds_connection *conn);
 
 /* transport.c */
-int rds_trans_register(struct rds_transport *trans);
+void rds_trans_register(struct rds_transport *trans);
 void rds_trans_unregister(struct rds_transport *trans);
 struct rds_transport *rds_trans_get_preferred(struct net *net, __be32 addr);
 void rds_trans_put(struct rds_transport *trans);
diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 5438f67..a973d3b 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -652,16 +652,12 @@ static int rds_tcp_init(void)
 	if (ret)
 		goto out_pernet;
 
-	ret = rds_trans_register(&rds_tcp_transport);
-	if (ret)
-		goto out_recv;
+	rds_trans_register(&rds_tcp_transport);
 
 	rds_info_register_func(RDS_INFO_TCP_SOCKETS, rds_tcp_tc_info);
 
 	goto out;
 
-out_recv:
-	rds_tcp_recv_exit();
 out_pernet:
 	unregister_pernet_subsys(&rds_tcp_net_ops);
 out_notifier:
diff --git a/net/rds/transport.c b/net/rds/transport.c
index 2ffd3e3..0b188dd 100644
--- a/net/rds/transport.c
+++ b/net/rds/transport.c
@@ -40,7 +40,7 @@
 static struct rds_transport *transports[RDS_TRANS_COUNT];
 static DECLARE_RWSEM(rds_trans_sem);
 
-int rds_trans_register(struct rds_transport *trans)
+void rds_trans_register(struct rds_transport *trans)
 {
 	BUG_ON(strlen(trans->t_name) + 1 > TRANSNAMSIZ);
 
@@ -55,8 +55,6 @@ int rds_trans_register(struct rds_transport *trans)
 	}
 
 	up_write(&rds_trans_sem);
-
-	return 0;
 }
 EXPORT_SYMBOL_GPL(rds_trans_register);
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
