From: Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v1 09/10] IB/ucma: Take the network namespace from the process
Date: Wed, 11 Feb 2015 17:06:43 +0200
Message-ID: <1423667204-8807-10-git-send-email-raindel@mellanox.com>
References: <1423667204-8807-1-git-send-email-raindel@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1423667204-8807-1-git-send-email-raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Add support for network namespaces from user space. This is done by passing
the network namespace of the process instead of init_net.

Signed-off-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

---
 drivers/infiniband/core/ucma.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index de755f2..d25a209 100644
--- a/drivers/infiniband/core/ucma.c
+++ b/drivers/infiniband/core/ucma.c
@@ -42,6 +42,7 @@
 #include <linux/slab.h>
 #include <linux/sysctl.h>
 #include <linux/module.h>
+#include <linux/nsproxy.h>
 
 #include <rdma/rdma_user_cm.h>
 #include <rdma/ib_marshall.h>
@@ -392,7 +393,7 @@ static ssize_t ucma_create_id(struct ucma_file *file, const char __user *inbuf,
 
 	ctx->uid = cmd.uid;
 	ctx->cm_id = rdma_create_id(ucma_event_handler, ctx, cmd.ps, qp_type,
-				    &init_net);
+				    current->nsproxy->net_ns);
 	if (IS_ERR(ctx->cm_id)) {
 		ret = PTR_ERR(ctx->cm_id);
 		goto err1;
-- 
1.7.11.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
