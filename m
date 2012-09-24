From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 26/26 v3] rdma/cm: Allow enabling reuseaddr in any state
Date: Mon, 24 Sep 2012 23:55:37 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A8237346A8F173@ORSMSX101.amr.corp.intel.com>
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

The rdma_cm only allows setting reuseaddr if the corresponding
rdma_cm_id is in the idle state.  Allow setting this value in
other states.  This brings the behavior more inline with
sockets.

Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
resending with netdev copied

 drivers/infiniband/core/cma.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index dbb6d73..08d7b9c 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -2266,7 +2266,7 @@ int rdma_set_reuseaddr(struct rdma_cm_id *id, int reuse)
 
 	id_priv = container_of(id, struct rdma_id_private, id);
 	spin_lock_irqsave(&id_priv->lock, flags);
-	if (id_priv->state == RDMA_CM_IDLE) {
+	if (reuse || id_priv->state == RDMA_CM_IDLE) {
 		id_priv->reuseaddr = reuse;
 		ret = 0;
 	} else {


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
