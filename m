From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH v3 for-next 13/13] IB/ucma: Take the network namespace from the process
Date: Sun, 10 May 2015 13:26:44 +0300
Message-ID: <1431253604-9214-14-git-send-email-haggaie@mellanox.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:49372 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752534AbbEJK1i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 May 2015 06:27:38 -0400
In-Reply-To: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guy Shapiro <guysh@mellanox.com>

Add support for network namespaces from user space. This is done by passing
the network namespace of the process instead of init_net.

Signed-off-by: Haggai Eran <haggaie@mellanox.com>
Signed-off-by: Yotam Kenneth <yotamke@mellanox.com>
Signed-off-by: Shachar Raindel <raindel@mellanox.com>
Signed-off-by: Guy Shapiro <guysh@mellanox.com>
---
 drivers/infiniband/core/ucma.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index b595d78b8ab0..0289d64d717c 100644
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
