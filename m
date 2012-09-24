From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 9/26 v3] rdma/cm: Verify that source and dest sa_family are
 the same
Date: Mon, 24 Sep 2012 23:55:31 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A8237346A8F0E0@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "linux-rdma (linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org)"
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
resending with netdev copied

 drivers/infiniband/core/cma.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index b305963..fa4ac4f 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1839,14 +1839,9 @@ static int cma_resolve_iboe_route(struct rdma_id_private *id_priv)
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
@@ -2122,6 +2117,9 @@ int rdma_resolve_addr(struct rdma_cm_id *id, struct sockaddr *src_addr,
 			return ret;
 	}
 
+	if (cma_family(id_priv) != dst_addr->sa_family)
+		return -EINVAL;
+
 	if (!cma_comp_exch(id_priv, RDMA_CM_ADDR_BOUND, RDMA_CM_ADDR_QUERY))
 		return -EINVAL;
 


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
