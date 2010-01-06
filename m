From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/8] net/rds: Remove uses of NIPQUAD, use %pI4
Date: Tue,  5 Jan 2010 17:20:15 -0800
Message-ID: <b2b11634105aee49050589f5d0e4e9fd09a270d6.1262726222.git.joe@perches.com>
References: <cover.1262726222.git.joe@perches.com>
Cc: Andy Grover <andy.grover@oracle.com>,
	"David S. Miller" <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755619Ab0AFBW0@vger.kernel.org>
In-Reply-To: <cover.1262726222.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/rds/tcp_connect.c |    7 +++----
 net/rds/tcp_listen.c  |    6 +++---
 net/rds/tcp_send.c    |    4 ++--
 3 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index 211522f..0562562 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -90,8 +90,8 @@ int rds_tcp_conn_connect(struct rds_connection *conn)
 
 	ret = sock->ops->bind(sock, (struct sockaddr *)&src, sizeof(src));
 	if (ret) {
-		rdsdebug("bind failed with %d at address %u.%u.%u.%u\n",
-		     ret, NIPQUAD(conn->c_laddr));
+		rdsdebug("bind failed with %d at address %pI4\n",
+			 ret, &conn->c_laddr);
 		goto out;
 	}
 
@@ -108,8 +108,7 @@ int rds_tcp_conn_connect(struct rds_connection *conn)
 				 O_NONBLOCK);
 	sock = NULL;
 
-	rdsdebug("connect to address %u.%u.%u.%u returned %d\n",
-		 NIPQUAD(conn->c_faddr), ret);
+	rdsdebug("connect to address %pI4 returned %d\n", &conn->c_faddr, ret);
 	if (ret == -EINPROGRESS)
 		ret = 0;
 
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 45474a4..53cb1b5 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -66,9 +66,9 @@ static int rds_tcp_accept_one(struct socket *sock)
 
 	inet = inet_sk(new_sock->sk);
 
-	rdsdebug("accepted tcp %u.%u.%u.%u:%u -> %u.%u.%u.%u:%u\n",
-		  NIPQUAD(inet->inet_saddr), ntohs(inet->inet_sport),
-		  NIPQUAD(inet->inet_daddr), ntohs(inet->inet_dport));
+	rdsdebug("accepted tcp %pI4:%u -> %pI4:%u\n",
+		 &inet->inet_saddr, ntohs(inet->inet_sport),
+		 &inet->inet_daddr, ntohs(inet->inet_dport));
 
 	conn = rds_conn_create(inet->inet_saddr, inet->inet_daddr,
 			       &rds_tcp_transport, GFP_KERNEL);
diff --git a/net/rds/tcp_send.c b/net/rds/tcp_send.c
index ab545e0..34fdcc0 100644
--- a/net/rds/tcp_send.c
+++ b/net/rds/tcp_send.c
@@ -193,9 +193,9 @@ out:
 			rds_tcp_stats_inc(s_tcp_sndbuf_full);
 			ret = 0;
 		} else {
-			printk(KERN_WARNING "RDS/tcp: send to %u.%u.%u.%u "
+			printk(KERN_WARNING "RDS/tcp: send to %pI4 "
 			       "returned %d, disconnecting and reconnecting\n",
-			       NIPQUAD(conn->c_faddr), ret);
+			       &conn->c_faddr, ret);
 			rds_conn_drop(conn);
 		}
 	}
-- 
1.6.6.rc0.57.gad7a
