From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 10/12] ERR_PTR() dereference in net/rds/iw.c
Date: Thu,  9 Apr 2009 17:09:45 -0700
Message-ID: <1239322187-3764-11-git-send-email-andy.grover@oracle.com>
References: <1239322187-3764-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, Dan Carpenter <error27@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:53343 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937484AbZDJAKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 20:10:14 -0400
In-Reply-To: <1239322187-3764-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>

rdma_create_id() returns ERR_PTR() not null.

Found by smatch (http://repo.or.cz/w/smatch.git).  Compile tested.

regards,
dan carpenter

Signed-off-by: Dan Carpenter <error27@gmail.com>
Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/iw.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rds/iw.c b/net/rds/iw.c
index b732efb..d16e1cb 100644
--- a/net/rds/iw.c
+++ b/net/rds/iw.c
@@ -233,8 +233,8 @@ static int rds_iw_laddr_check(__be32 addr)
 	 * IB and iWARP capable NICs.
 	 */
 	cm_id = rdma_create_id(NULL, NULL, RDMA_PS_TCP);
-	if (!cm_id)
-		return -EADDRNOTAVAIL;
+	if (IS_ERR(cm_id))
+		return PTR_ERR(cm_id);
 
 	memset(&sin, 0, sizeof(sin));
 	sin.sin_family = AF_INET;
-- 
1.5.6.3

