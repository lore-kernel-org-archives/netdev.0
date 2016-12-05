From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH 02/18] RDS: mark few internal functions static to make sparse build happy
Date: Sun,  4 Dec 2016 22:57:37 -0800
Message-ID: <1480921073-9140-3-git-send-email-santosh.shilimkar@oracle.com>
References: <1480921073-9140-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org,
        Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480921073-9140-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes below warnings:
warning: symbol 'rds_send_probe' was not declared. Should it be static?
warning: symbol 'rds_send_ping' was not declared. Should it be static?
warning: symbol 'rds_tcp_accept_one_path' was not declared. Should it be static?
warning: symbol 'rds_walk_conn_path_info' was not declared. Should it be static?

Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/connection.c | 2 +-
 net/rds/send.c       | 4 ++--
 net/rds/tcp_listen.c | 1 +
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index fe9d31c..26533b2 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -545,7 +545,7 @@ void rds_for_each_conn_info(struct socket *sock, unsigned int len,
 }
 EXPORT_SYMBOL_GPL(rds_for_each_conn_info);
 
-void rds_walk_conn_path_info(struct socket *sock, unsigned int len,
+static void rds_walk_conn_path_info(struct socket *sock, unsigned int len,
 			     struct rds_info_iterator *iter,
 			     struct rds_info_lengths *lens,
 			     int (*visitor)(struct rds_conn_path *, void *),
diff --git a/net/rds/send.c b/net/rds/send.c
index 77c8c6e..bb13c56 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -1169,7 +1169,7 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
  * or
  *   RDS_FLAG_HB_PONG|RDS_FLAG_ACK_REQUIRED
  */
-int
+static int
 rds_send_probe(struct rds_conn_path *cp, __be16 sport,
 	       __be16 dport, u8 h_flags)
 {
@@ -1238,7 +1238,7 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 	return rds_send_probe(cp, 0, dport, 0);
 }
 
-void
+static void
 rds_send_ping(struct rds_connection *conn)
 {
 	unsigned long flags;
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index f74bab3..67d0929 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -79,6 +79,7 @@ int rds_tcp_keepalive(struct socket *sock)
  * smaller ip address, we recycle conns in RDS_CONN_ERROR on the passive side
  * by moving them to CONNECTING in this function.
  */
+static
 struct rds_tcp_connection *rds_tcp_accept_one_path(struct rds_connection *conn)
 {
 	int i;
-- 
1.9.1
