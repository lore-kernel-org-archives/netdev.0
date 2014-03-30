From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH v2] rds: prevent dereference of a NULL device in rds_iw_laddr_check
Date: Sat, 29 Mar 2014 20:39:35 -0400
Message-ID: <1396139975-5314-1-git-send-email-sasha.levin@oracle.com>
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>
To: chien.yen@oracle.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:46618 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497AbaC3Ajn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 20:39:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Binding might result in a NULL device which is later dereferenced
without checking.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 net/rds/iw.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/rds/iw.c b/net/rds/iw.c
index 7826d46..0298920 100644
--- a/net/rds/iw.c
+++ b/net/rds/iw.c
@@ -239,7 +239,8 @@ static int rds_iw_laddr_check(__be32 addr)
 	ret = rdma_bind_addr(cm_id, (struct sockaddr *)&sin);
 	/* due to this, we will claim to support IB devices unless we
 	   check node_type. */
-	if (ret || cm_id->device->node_type != RDMA_NODE_RNIC)
+	if (ret || !cm_id->device ||
+	    cm_id->device->node_type != RDMA_NODE_RNIC)
 		ret = -EADDRNOTAVAIL;
 
 	rdsdebug("addr %pI4 ret %d node type %d\n",
-- 
1.8.3.2
