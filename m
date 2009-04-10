From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 11/12] ERR_PTR() dereference in net/rds/ib.c
Date: Thu,  9 Apr 2009 17:09:46 -0700
Message-ID: <1239322187-3764-12-git-send-email-andy.grover@oracle.com>
References: <1239322187-3764-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, Dan Carpenter <error27@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:22866 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937561AbZDJAKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 20:10:15 -0400
In-Reply-To: <1239322187-3764-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>

rdma_create_id() doesn't return NULL, only ERR_PTR().

Found by smatch (http://repo.or.cz/w/smatch.git).  Compile tested.

regards,
dan carpenter

Signed-off-by: Dan Carpenter <error27@gmail.com>
Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rds/ib.c b/net/rds/ib.c
index 4933b38..b9bcd32 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -224,8 +224,8 @@ static int rds_ib_laddr_check(__be32 addr)
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

