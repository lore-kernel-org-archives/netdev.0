From: Dan Carpenter <error27@gmail.com>
Subject: [patch -next] rds: double unlock in rds_ib_cm_handle_connect()
Date: Sun, 19 Sep 2010 01:42:59 +0200
Message-ID: <20100918234259.GD6236@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Zach Brown <zach.brown@oracle.com>,
	Julia Lawall <julia@diku.dk>, Tejun Heo <tj@kernel.org>,
	rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:60988 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753579Ab0IRXnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Sep 2010 19:43:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We unlock after we goto out.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index bc3dbc1..ee369d2 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -521,7 +521,6 @@ int rds_ib_cm_handle_connect(struct rdma_cm_id *cm_id,
 	err = rds_ib_setup_qp(conn);
 	if (err) {
 		rds_ib_conn_error(conn, "rds_ib_setup_qp failed (%d)\n", err);
-		mutex_unlock(&conn->c_cm_lock);
 		goto out;
 	}
 
