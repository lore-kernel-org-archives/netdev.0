From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] RDS: verify the underlying transport exists before creating a connection
Date: Fri,  4 Sep 2015 12:43:39 -0400
Message-ID: <1441385019-27019-1-git-send-email-sasha.levin@oracle.com>
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>
To: chien.yen@oracle.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There was no verification that an underlying transport exists when creating
a connection, this would cause dereferencing a NULL ptr.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 net/rds/connection.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index a50e652..0218d81 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -189,6 +189,12 @@ new_conn:
 		}
 	}
 
+	if (trans == NULL) {
+		kmem_cache_free(rds_conn_slab, conn);
+		conn = ERR_PTR(-ENODEV);
+		goto out;
+	}
+
 	conn->c_trans = trans;
 
 	ret = trans->conn_alloc(conn, gfp);
-- 
1.7.10.4
