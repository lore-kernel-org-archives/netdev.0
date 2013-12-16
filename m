From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net 8/9] RDMA/cxgb4: Server filters are supported only for IPv4
Date: Mon, 16 Dec 2013 17:42:17 +0530
Message-ID: <1387195938-3531-9-git-send-email-hariprasad@chelsio.com>
References: <1387195938-3531-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, hariprasad@chelsio.com,
	nirranjan@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:28108 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754145Ab3LPMUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 07:20:22 -0500
In-Reply-To: <1387195938-3531-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/cm.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 02c7515..bfd4ed7 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -2938,7 +2938,8 @@ int c4iw_create_listen(struct iw_cm_id *cm_id, int backlog)
 	/*
 	 * Allocate a server TID.
 	 */
-	if (dev->rdev.lldi.enable_fw_ofld_conn)
+	if (dev->rdev.lldi.enable_fw_ofld_conn &&
+	    ep->com.local_addr.ss_family == AF_INET)
 		ep->stid = cxgb4_alloc_sftid(dev->rdev.lldi.tids,
 					     cm_id->local_addr.ss_family, ep);
 	else
-- 
1.8.0
