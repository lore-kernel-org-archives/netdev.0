From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] net: rds: Remove repeated function names from debug output
Date: Thu,  5 Feb 2015 23:17:20 +0100
Message-ID: <1423174641-11057-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chien Yen <chien.yen@oracle.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The macro rdsdebug is defined as

  pr_debug("%s(): " fmt, __func__ , ##args)

Hence it doesn't make sense to include the name of the calling
function explicitly in the format string passed to rdsdebug.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 net/rds/ib_send.c | 4 ++--
 net/rds/iw_cm.c   | 4 ++--
 net/rds/iw_send.c | 4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index 1dde91e3dc70..bd3825d38abc 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -409,7 +409,7 @@ try_again:
 	posted = IB_GET_POST_CREDITS(oldval);
 	avail = IB_GET_SEND_CREDITS(oldval);
 
-	rdsdebug("rds_ib_send_grab_credits(%u): credits=%u posted=%u\n",
+	rdsdebug("wanted=%u credits=%u posted=%u\n",
 			wanted, avail, posted);
 
 	/* The last credit must be used to send a credit update. */
@@ -453,7 +453,7 @@ void rds_ib_send_add_credits(struct rds_connection *conn, unsigned int credits)
 	if (credits == 0)
 		return;
 
-	rdsdebug("rds_ib_send_add_credits(%u): current=%u%s\n",
+	rdsdebug("credits=%u current=%u%s\n",
 			credits,
 			IB_GET_SEND_CREDITS(atomic_read(&ic->i_credits)),
 			test_bit(RDS_LL_SEND_FULL, &conn->c_flags) ? ", ll_send_full" : "");
diff --git a/net/rds/iw_cm.c b/net/rds/iw_cm.c
index a91e1db62ee6..a6c2bea9f8f9 100644
--- a/net/rds/iw_cm.c
+++ b/net/rds/iw_cm.c
@@ -590,8 +590,8 @@ void rds_iw_conn_shutdown(struct rds_connection *conn)
 			/* Actually this may happen quite frequently, when
 			 * an outgoing connect raced with an incoming connect.
 			 */
-			rdsdebug("rds_iw_conn_shutdown: failed to disconnect,"
-				   " cm: %p err %d\n", ic->i_cm_id, err);
+			rdsdebug("failed to disconnect, cm: %p err %d\n",
+				 ic->i_cm_id, err);
 		}
 
 		if (ic->i_cm_id->qp) {
diff --git a/net/rds/iw_send.c b/net/rds/iw_send.c
index 9105ea03aec5..13834780a308 100644
--- a/net/rds/iw_send.c
+++ b/net/rds/iw_send.c
@@ -361,7 +361,7 @@ try_again:
 	posted = IB_GET_POST_CREDITS(oldval);
 	avail = IB_GET_SEND_CREDITS(oldval);
 
-	rdsdebug("rds_iw_send_grab_credits(%u): credits=%u posted=%u\n",
+	rdsdebug("wanted=%u credits=%u posted=%u\n",
 			wanted, avail, posted);
 
 	/* The last credit must be used to send a credit update. */
@@ -405,7 +405,7 @@ void rds_iw_send_add_credits(struct rds_connection *conn, unsigned int credits)
 	if (credits == 0)
 		return;
 
-	rdsdebug("rds_iw_send_add_credits(%u): current=%u%s\n",
+	rdsdebug("credits=%u current=%u%s\n",
 			credits,
 			IB_GET_SEND_CREDITS(atomic_read(&ic->i_credits)),
 			test_bit(RDS_LL_SEND_FULL, &conn->c_flags) ? ", ll_send_full" : "");
-- 
2.1.3
