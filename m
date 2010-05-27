From: Dan Carpenter <error27@gmail.com>
Subject: [patch 2/3] rds/iw_rdma: spin_lock_irq() is not nestable
Date: Thu, 27 May 2010 11:10:46 +0200
Message-ID: <20100527091046.GS22515@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:44795 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757082Ab0E0JLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 05:11:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IRQs are already disabled here so we don't need to disable them
again.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/rds/iw_rdma.c b/net/rds/iw_rdma.c
index 7365fa2..48d5073 100644
--- a/net/rds/iw_rdma.c
+++ b/net/rds/iw_rdma.c
@@ -213,9 +213,9 @@ void rds_iw_add_conn(struct rds_iw_device *rds_iwdev, struct rds_connection *con
 	BUG_ON(list_empty(&ic->iw_node));
 	list_del(&ic->iw_node);
 
-	spin_lock_irq(&rds_iwdev->spinlock);
+	spin_lock(&rds_iwdev->spinlock);
 	list_add_tail(&ic->iw_node, &rds_iwdev->conn_list);
-	spin_unlock_irq(&rds_iwdev->spinlock);
+	spin_unlock(&rds_iwdev->spinlock);
 	spin_unlock_irq(&iw_nodev_conns_lock);
 
 	ic->rds_iwdev = rds_iwdev;
