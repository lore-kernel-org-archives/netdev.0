From: Shachar Raindel <raindel@mellanox.com>
Subject: [PATCH for-next 10/10] IB/ucm: Add partial support for network namespaces
Date: Sun,  1 Feb 2015 13:28:53 +0200
Message-ID: <1422790133-28725-11-git-send-email-raindel@mellanox.com>
References: <1422790133-28725-1-git-send-email-raindel@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	liranl@mellanox.com, Shachar Raindel <raindel@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>
To: roland@kernel.org, sean.hefty@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:33867 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752852AbbBALcL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Feb 2015 06:32:11 -0500
In-Reply-To: <1422790133-28725-1-git-send-email-raindel@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is impossible to completely support network namespaces for UCM, as
we cannot identify the target IPoIB device. However, we add support
which will work if the user is following the IB-Spec Annex 11 (RDMA IP
CM Services) with the service ID and private data formatting.

Signed-off-by: Haggai Eran <haggaie@mellanox.com>
Signed-off-by: Yotam Kenneth <yotamke@mellanox.com>
Signed-off-by: Shachar Raindel <raindel@mellanox.com>
Signed-off-by: Guy Shapiro <guysh@mellanox.com>

---
 drivers/infiniband/core/ucm.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/core/ucm.c b/drivers/infiniband/core/ucm.c
index 9604ab068984..424421091dae 100644
--- a/drivers/infiniband/core/ucm.c
+++ b/drivers/infiniband/core/ucm.c
@@ -45,6 +45,7 @@
 #include <linux/idr.h>
 #include <linux/mutex.h>
 #include <linux/slab.h>
+#include <linux/nsproxy.h>
 
 #include <asm/uaccess.h>
 
@@ -490,7 +491,7 @@ static ssize_t ib_ucm_create_id(struct ib_ucm_file *file,
 	ctx->uid = cmd.uid;
 	ctx->cm_id = ib_create_cm_id(file->device->ib_dev,
 				     ib_ucm_event_handler, ctx,
-				     &init_net);
+				     current->nsproxy->net_ns);
 	if (IS_ERR(ctx->cm_id)) {
 		result = PTR_ERR(ctx->cm_id);
 		goto err1;
-- 
1.7.11.2
