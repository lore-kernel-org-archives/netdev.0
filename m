From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [patch v3 11/11] infiniband: pass rdma_cm module to netlink_dump_start
Date: Thu, 4 Oct 2012 12:41:29 +0800
Message-ID: <1349325689-16104-11-git-send-email-gaofeng@cn.fujitsu.com>
References: <1349325689-16104-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org, jengelh-9+2X+4sQBs8@public.gmane.org,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1349325689-16104-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

set netlink_dump_control.module to avoid panic.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/core/cma.c     |    3 ++-
 drivers/infiniband/core/netlink.c |    1 +
 include/rdma/rdma_netlink.h       |    1 +
 3 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 26b3760..4fff27a 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -3498,7 +3498,8 @@ out:
 }
 
 static const struct ibnl_client_cbs cma_cb_table[] = {
-	[RDMA_NL_RDMA_CM_ID_STATS] = { .dump = cma_get_id_stats },
+	[RDMA_NL_RDMA_CM_ID_STATS] = { .dump = cma_get_id_stats,
+				       .module = THIS_MODULE },
 };
 
 static int __init cma_init(void)
diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index fe10a94..da06abd 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -154,6 +154,7 @@ static int ibnl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 			{
 				struct netlink_dump_control c = {
 					.dump = client->cb_table[op].dump,
+					.module = client->cb_table[op].module,
 				};
 				return netlink_dump_start(nls, skb, nlh, &c);
 			}
diff --git a/include/rdma/rdma_netlink.h b/include/rdma/rdma_netlink.h
index 3c5363a..bd3d8b2 100644
--- a/include/rdma/rdma_netlink.h
+++ b/include/rdma/rdma_netlink.h
@@ -39,6 +39,7 @@ struct rdma_cm_id_stats {
 
 struct ibnl_client_cbs {
 	int (*dump)(struct sk_buff *skb, struct netlink_callback *nlcb);
+	struct module *module;
 };
 
 int ibnl_init(void);
-- 
1.7.7.6

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
