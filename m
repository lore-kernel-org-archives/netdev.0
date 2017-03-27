From: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/5] rds: tcp: release the created connection
Date: Mon, 27 Mar 2017 03:06:26 -0400
Message-ID: <1490598390-13812-2-git-send-email-yanjun.zhu@oracle.com>
References: <1490598390-13812-1-git-send-email-yanjun.zhu@oracle.com>
To: yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1490598390-13812-1-git-send-email-yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

When some error occurs, the created connection should be destroyed.

Signed-off-by: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 net/rds/tcp_listen.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 5076788..58aa5bc 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -196,6 +196,7 @@ int rds_tcp_accept_one(struct socket *sock)
 rst_nsk:
 	/* reset the newly returned accept sock and bail */
 	kernel_sock_shutdown(new_sock, SHUT_RDWR);
+	rds_conn_destroy(conn);
 	ret = 0;
 out:
 	if (rs_tcp)
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
