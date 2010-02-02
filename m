From: akpm@linux-foundation.org
Subject: [patch 1/1] net/rds: remove uses of NIPQUAD, use %pI4
Date: Tue, 02 Feb 2010 14:43:59 -0800
Message-ID: <201002022244.o12Mhx7D019239@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, joe@perches.com,
	andy.grover@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54408 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754630Ab0BBWof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 17:44:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Signed-off-by: Joe Perches <joe@perches.com>
Cc: Andy Grover <andy.grover@oracle.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/rds/tcp_connect.c |    7 +++----
 net/rds/tcp_listen.c  |    6 +++---
 net/rds/tcp_send.c    |    4 ++--
 3 files changed, 8 insertions(+), 9 deletions(-)

diff -puN net/rds/tcp_connect.c~net-rds-remove-uses-of-nipquad-use-%pi4 net/rds/tcp_connect.c
--- a/net/rds/tcp_connect.c~net-rds-remove-uses-of-nipquad-use-%pi4
+++ a/net/rds/tcp_connect.c
@@ -90,8 +90,8 @@ int rds_tcp_conn_connect(struct rds_conn
 
 	ret = sock->ops->bind(sock, (struct sockaddr *)&src, sizeof(src));
 	if (ret) {
-		rdsdebug("bind failed with %d at address %u.%u.%u.%u\n",
-		     ret, NIPQUAD(conn->c_laddr));
+		rdsdebug("bind failed with %d at address %pI4\n",
+			 ret, &conn->c_laddr);
 		goto out;
 	}
 
@@ -108,8 +108,7 @@ int rds_tcp_conn_connect(struct rds_conn
 				 O_NONBLOCK);
 	sock = NULL;
 
-	rdsdebug("connect to address %u.%u.%u.%u returned %d\n",
-		 NIPQUAD(conn->c_faddr), ret);
+	rdsdebug("connect to address %pI4 returned %d\n", &conn->c_faddr, ret);
 	if (ret == -EINPROGRESS)
 		ret = 0;
 
diff -puN net/rds/tcp_listen.c~net-rds-remove-uses-of-nipquad-use-%pi4 net/rds/tcp_listen.c
--- a/net/rds/tcp_listen.c~net-rds-remove-uses-of-nipquad-use-%pi4
+++ a/net/rds/tcp_listen.c
@@ -66,9 +66,9 @@ static int rds_tcp_accept_one(struct soc
 
 	inet = inet_sk(new_sock->sk);
 
-	rdsdebug("accepted tcp %u.%u.%u.%u:%u -> %u.%u.%u.%u:%u\n",
-		  NIPQUAD(inet->inet_saddr), ntohs(inet->inet_sport),
-		  NIPQUAD(inet->inet_daddr), ntohs(inet->inet_dport));
+	rdsdebug("accepted tcp %pI4:%u -> %pI4:%u\n",
+		 &inet->inet_saddr, ntohs(inet->inet_sport),
+		 &inet->inet_daddr, ntohs(inet->inet_dport));
 
 	conn = rds_conn_create(inet->inet_saddr, inet->inet_daddr,
 			       &rds_tcp_transport, GFP_KERNEL);
diff -puN net/rds/tcp_send.c~net-rds-remove-uses-of-nipquad-use-%pi4 net/rds/tcp_send.c
--- a/net/rds/tcp_send.c~net-rds-remove-uses-of-nipquad-use-%pi4
+++ a/net/rds/tcp_send.c
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
_
