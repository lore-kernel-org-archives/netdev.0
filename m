From: Dan Carpenter <error27@gmail.com>
Subject: [patch -next] rds: spin_lock_irq() is not nestable
Date: Sun, 19 Sep 2010 01:44:14 +0200
Message-ID: <20100918234414.GE6236@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Zach Brown <zach.brown@oracle.com>,
	Chris Mason <chris.mason@oracle.com>, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:56359 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752995Ab0IRXoa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Sep 2010 19:44:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is basically just a cleanup.  IRQs were disabled on the previous
line so we don't need to do it again here.  In the current code IRQs
would get turned on one line earlier than intended.

Signed-off-by: Dan Carpenter <error27@gmail.com>
---
Andy Grover acked part of this patch before but it didn't get pushed.

diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index 8f6e221..b5a8841 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -171,9 +171,9 @@ void rds_ib_add_conn(struct rds_ib_device *rds_ibdev, struct rds_connection *con
 	BUG_ON(list_empty(&ic->ib_node));
 	list_del(&ic->ib_node);
 
-	spin_lock_irq(&rds_ibdev->spinlock);
+	spin_lock(&rds_ibdev->spinlock);
 	list_add_tail(&ic->ib_node, &rds_ibdev->conn_list);
-	spin_unlock_irq(&rds_ibdev->spinlock);
+	spin_unlock(&rds_ibdev->spinlock);
 	spin_unlock_irq(&ib_nodev_conns_lock);
 
 	ic->rds_ibdev = rds_ibdev;
diff --git a/net/rds/iw_rdma.c b/net/rds/iw_rdma.c
index 4e152e2..0e7accc 100644
--- a/net/rds/iw_rdma.c
+++ b/net/rds/iw_rdma.c
@@ -206,9 +206,9 @@ void rds_iw_add_conn(struct rds_iw_device *rds_iwdev, struct rds_connection *con
 	BUG_ON(list_empty(&ic->iw_node));
 	list_del(&ic->iw_node);
 
-	spin_lock_irq(&rds_iwdev->spinlock);
+	spin_lock(&rds_iwdev->spinlock);
 	list_add_tail(&ic->iw_node, &rds_iwdev->conn_list);
-	spin_unlock_irq(&rds_iwdev->spinlock);
+	spin_unlock(&rds_iwdev->spinlock);
 	spin_unlock_irq(&iw_nodev_conns_lock);
 
 	ic->rds_iwdev = rds_iwdev;
