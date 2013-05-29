From: sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Subject: [PATCH v5 28/28] rdma/cm: Export AF_IB statistics
Date: Wed, 29 May 2013 10:09:34 -0700
Message-ID: <1369847374-12176-29-git-send-email-sean.hefty@intel.com>
References: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1369847374-12176-1-git-send-email-sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Report AF_IB source and destination addresses through
netlink interface.

Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/core/cma.c |   37 ++++++++++---------------------------
 1 files changed, 10 insertions(+), 27 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 6445650..d1e4d09 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -3586,33 +3586,16 @@ static int cma_get_id_stats(struct sk_buff *skb, struct netlink_callback *cb)
 			id_stats->bound_dev_if =
 				id->route.addr.dev_addr.bound_dev_if;
 
-			if (cma_family(id_priv) == AF_INET) {
-				if (ibnl_put_attr(skb, nlh,
-						  sizeof(struct sockaddr_in),
-						  cma_src_addr(id_priv),
-						  RDMA_NL_RDMA_CM_ATTR_SRC_ADDR)) {
-					goto out;
-				}
-				if (ibnl_put_attr(skb, nlh,
-						  sizeof(struct sockaddr_in),
-						  cma_dst_addr(id_priv),
-						  RDMA_NL_RDMA_CM_ATTR_DST_ADDR)) {
-					goto out;
-				}
-			} else if (cma_family(id_priv) == AF_INET6) {
-				if (ibnl_put_attr(skb, nlh,
-						  sizeof(struct sockaddr_in6),
-						  cma_src_addr(id_priv),
-						  RDMA_NL_RDMA_CM_ATTR_SRC_ADDR)) {
-					goto out;
-				}
-				if (ibnl_put_attr(skb, nlh,
-						  sizeof(struct sockaddr_in6),
-						  cma_dst_addr(id_priv),
-						  RDMA_NL_RDMA_CM_ATTR_DST_ADDR)) {
-					goto out;
-				}
-			}
+			if (ibnl_put_attr(skb, nlh,
+					  rdma_addr_size(cma_src_addr(id_priv)),
+					  cma_src_addr(id_priv),
+					  RDMA_NL_RDMA_CM_ATTR_SRC_ADDR))
+				goto out;
+			if (ibnl_put_attr(skb, nlh,
+					  rdma_addr_size(cma_src_addr(id_priv)),
+					  cma_dst_addr(id_priv),
+					  RDMA_NL_RDMA_CM_ATTR_DST_ADDR))
+				goto out;
 
 			id_stats->pid		= id_priv->owner;
 			id_stats->port_space	= id->ps;
-- 
1.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
