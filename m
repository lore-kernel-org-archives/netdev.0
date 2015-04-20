From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH v2 10/11] IB/ucma: Take the network namespace from the process
Date: Mon, 20 Apr 2015 12:03:41 +0300
Message-ID: <1429520622-10303-11-git-send-email-haggaie@mellanox.com>
References: <1429520622-10303-1-git-send-email-haggaie@mellanox.com>
Cc: Sean Hefty <sean.hefty@intel.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>
To: Doug Ledford <dledford@redhat.com>,
	Roland Dreier <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:44666 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754418AbbDTJFH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2015 05:05:07 -0400
In-Reply-To: <1429520622-10303-1-git-send-email-haggaie@mellanox.com>
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
index 2f7fad84f933..0ccdf2b05153 100644
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
