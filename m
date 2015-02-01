From: Shachar Raindel <raindel@mellanox.com>
Subject: [PATCH for-next 09/10] IB/ucma: Take the network namespace from the process
Date: Sun,  1 Feb 2015 13:28:52 +0200
Message-ID: <1422790133-28725-10-git-send-email-raindel@mellanox.com>
References: <1422790133-28725-1-git-send-email-raindel@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	liranl@mellanox.com, Guy Shapiro <guysh@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>
To: roland@kernel.org, sean.hefty@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:33919 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753283AbbBALcp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Feb 2015 06:32:45 -0500
In-Reply-To: <1422790133-28725-1-git-send-email-raindel@mellanox.com>
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
 drivers/infiniband/core/ucma.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index de755f2c6166..d25a20968ca2 100644
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
