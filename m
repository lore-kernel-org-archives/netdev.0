From: sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Subject: [PATCH v4 9/9] rdma/cm: Verify that source and dest sa_family are the same
Date: Tue, 22 Jan 2013 13:56:37 -0800
Message-ID: <1358891797-14625-10-git-send-email-sean.hefty@intel.com>
References: <1358891797-14625-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1358891797-14625-1-git-send-email-sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/core/cma.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index e7409b4..64799ea 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1849,14 +1849,9 @@ static int cma_resolve_iboe_route(struct rdma_id_private *id_priv)
 	struct rdma_addr *addr = &route->addr;
 	struct cma_work *work;
 	int ret;
-	struct sockaddr_in *src_addr = (struct sockaddr_in *)&route->addr.src_addr;
-	struct sockaddr_in *dst_addr = (struct sockaddr_in *)&route->addr.dst_addr;
 	struct net_device *ndev = NULL;
 	u16 vid;
 
-	if (src_addr->sin_family != dst_addr->sin_family)
-		return -EINVAL;
-
 	work = kzalloc(sizeof *work, GFP_KERNEL);
 	if (!work)
 		return -ENOMEM;
@@ -2132,6 +2127,9 @@ int rdma_resolve_addr(struct rdma_cm_id *id, struct sockaddr *src_addr,
 			return ret;
 	}
 
+	if (cma_family(id_priv) != dst_addr->sa_family)
+		return -EINVAL;
+
 	if (!cma_comp_exch(id_priv, RDMA_CM_ADDR_BOUND, RDMA_CM_ADDR_QUERY))
 		return -EINVAL;
 
-- 
1.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
