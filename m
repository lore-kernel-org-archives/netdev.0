From: "Herton R. Krzesinski" <herton@redhat.com>
Subject: [PATCH 1/3] net/rds: call rds_conn_drop instead of open code it at rds_connect_complete
Date: Wed,  1 Oct 2014 18:49:52 -0300
Message-ID: <1412200194-28902-2-git-send-email-herton@redhat.com>
References: <1412200194-28902-1-git-send-email-herton@redhat.com>
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, rmanes@redhat.com,
	dledford@redhat.com
To: Chien Yen <chien.yen@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412200194-28902-1-git-send-email-herton@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Herton R. Krzesinski <herton@redhat.com>
---
 net/rds/threads.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/rds/threads.c b/net/rds/threads.c
index 65eaefc..dc2402e 100644
--- a/net/rds/threads.c
+++ b/net/rds/threads.c
@@ -78,8 +78,7 @@ void rds_connect_complete(struct rds_connection *conn)
 				"current state is %d\n",
 				__func__,
 				atomic_read(&conn->c_state));
-		atomic_set(&conn->c_state, RDS_CONN_ERROR);
-		queue_work(rds_wq, &conn->c_down_w);
+		rds_conn_drop(conn);
 		return;
 	}
 
-- 
1.9.3
