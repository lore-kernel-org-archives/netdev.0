From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 1/4] tipc: remove unnecessary variables and conditions
Date: Thu, 12 Dec 2013 09:36:39 +0800
Message-ID: <1386812202-11956-2-git-send-email-wangweidong1@huawei.com>
References: <1386812202-11956-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <jon.maloy@ericsson.com>, <allan.stephens@windriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:19895 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130Ab3LLBg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 20:36:56 -0500
In-Reply-To: <1386812202-11956-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We remove a number of unnecessary variables and branches
in TIPC. This patch is cosmetic and does not change the
operation of TIPC in any way.

Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/tipc/name_table.c |  3 +--
 net/tipc/port.c       |  9 +++------
 net/tipc/socket.c     | 13 ++++---------
 3 files changed, 8 insertions(+), 17 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 09dcd54..92a1533 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -148,8 +148,7 @@ static struct publication *publ_create(u32 type, u32 lower, u32 upper,
  */
 static struct sub_seq *tipc_subseq_alloc(u32 cnt)
 {
-	struct sub_seq *sseq = kcalloc(cnt, sizeof(struct sub_seq), GFP_ATOMIC);
-	return sseq;
+	return kcalloc(cnt, sizeof(struct sub_seq), GFP_ATOMIC);
 }
 
 /**
diff --git a/net/tipc/port.c b/net/tipc/port.c
index c081a76..5fd4c8c 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -832,17 +832,14 @@ exit:
  */
 int __tipc_disconnect(struct tipc_port *tp_ptr)
 {
-	int res;
-
 	if (tp_ptr->connected) {
 		tp_ptr->connected = 0;
 		/* let timer expire on it's own to avoid deadlock! */
 		tipc_nodesub_unsubscribe(&tp_ptr->subscription);
-		res = 0;
-	} else {
-		res = -ENOTCONN;
+		return 0;
 	}
-	return res;
+
+	return -ENOTCONN;
 }
 
 /*
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 3b61851..32037c5 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -239,7 +239,6 @@ static int tipc_sk_create(struct net *net, struct socket *sock, int protocol,
 int tipc_sock_create_local(int type, struct socket **res)
 {
 	int rc;
-	struct sock *sk;
 
 	rc = sock_create_lite(AF_TIPC, type, 0, res);
 	if (rc < 0) {
@@ -248,8 +247,6 @@ int tipc_sock_create_local(int type, struct socket **res)
 	}
 	tipc_sk_create(&init_net, *res, 0, 1);
 
-	sk = (*res)->sk;
-
 	return 0;
 }
 
@@ -1311,14 +1308,12 @@ static u32 filter_connect(struct tipc_sock *tsock, struct sk_buff **buf)
 static unsigned int rcvbuf_limit(struct sock *sk, struct sk_buff *buf)
 {
 	struct tipc_msg *msg = buf_msg(buf);
-	unsigned int limit;
 
 	if (msg_connected(msg))
-		limit = sysctl_tipc_rmem[2];
-	else
-		limit = sk->sk_rcvbuf >> TIPC_CRITICAL_IMPORTANCE <<
-			msg_importance(msg);
-	return limit;
+		return sysctl_tipc_rmem[2];
+
+	return sk->sk_rcvbuf >> TIPC_CRITICAL_IMPORTANCE <<
+		msg_importance(msg);
 }
 
 /**
-- 
1.7.12
