From: Dan Carpenter <error27@gmail.com>
Subject: [patch] rdma: potential ERR_PTR dereference
Date: Thu, 22 Apr 2010 11:55:27 +0200
Message-ID: <20100422095527.GQ29647@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61910 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899Ab0DVJzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 05:55:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the original code, the "goto out" calls "rdma_destroy_id(cm_id);"
That isn't needed here and would cause problems because "cm_id" is an 
ERR_PTR.  The new code just returns directly.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/rds/rdma_transport.c b/net/rds/rdma_transport.c
index 9ece910..7b15508 100644
--- a/net/rds/rdma_transport.c
+++ b/net/rds/rdma_transport.c
@@ -134,7 +134,7 @@ static int __init rds_rdma_listen_init(void)
 		ret = PTR_ERR(cm_id);
 		printk(KERN_ERR "RDS/RDMA: failed to setup listener, "
 		       "rdma_create_id() returned %d\n", ret);
-		goto out;
+		return ret;
 	}
 
 	sin.sin_family = AF_INET,
