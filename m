From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v4 for-next 12/12] IB/ucma: Take the network namespace from the process
Date: Sun, 17 May 2015 08:51:08 +0300
Message-ID: <1431841868-28063-13-git-send-email-haggaie@mellanox.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1431841868-28063-1-git-send-email-haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
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
 drivers/infiniband/core/ucma.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index 44670ad5ba10..46b50c64933d 100644
--- a/drivers/infiniband/core/ucma.c
+++ b/drivers/infiniband/core/ucma.c
@@ -42,6 +42,7 @@
 #include <linux/slab.h>
 #include <linux/sysctl.h>
 #include <linux/module.h>
+#include <linux/nsproxy.h>
 
 #include <rdma/rdma_user_cm.h>
 #include <rdma/ib_marshall.h>
@@ -391,8 +392,8 @@ static ssize_t ucma_create_id(struct ucma_file *file, const char __user *inbuf,
 		return -ENOMEM;
 
 	ctx->uid = cmd.uid;
-	ctx->cm_id = rdma_create_id(&init_net, ucma_event_handler, ctx, cmd.ps,
-				    qp_type);
+	ctx->cm_id = rdma_create_id(current->nsproxy->net_ns,
+				    ucma_event_handler, ctx, cmd.ps, qp_type);
 	if (IS_ERR(ctx->cm_id)) {
 		ret = PTR_ERR(ctx->cm_id);
 		goto err1;
-- 
1.7.11.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
