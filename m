From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 06/14] sctp: remove the typedef sctp_socket_type_t
Date: Fri, 11 Aug 2017 10:23:50 +0800
Message-ID: <bec27150caf5435011467a5488247f853f782409.1502417340.git.lucien.xin@gmail.com>
References: <cover.1502417340.git.lucien.xin@gmail.com>
 <e15322cc52e110730f2bcb77973222b687717369.1502417340.git.lucien.xin@gmail.com>
 <67dec3f4936413e5bf596dc0ce9be0b9aa15a444.1502417340.git.lucien.xin@gmail.com>
 <5031dc5f40135c4ede57452bc61a1b29dfc76d89.1502417340.git.lucien.xin@gmail.com>
 <58f1f86286c91cf55e9d6eb9395e59e9f1fd4519.1502417340.git.lucien.xin@gmail.com>
 <77692e0783b8134d97fd4c15e37cf0b6e4fa643e.1502417340.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:38695 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752335AbdHKCYx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 22:24:53 -0400
In-Reply-To: <77692e0783b8134d97fd4c15e37cf0b6e4fa643e.1502417340.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1502417340.git.lucien.xin@gmail.com>
References: <cover.1502417340.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_socket_type_t, and
replace with enum sctp_socket_type in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sctp.h    | 3 ++-
 include/net/sctp/structs.h | 6 +++---
 net/sctp/socket.c          | 7 ++++---
 3 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 24ff793..06b4f51 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -550,7 +550,8 @@ static inline int sctp_ep_hashfn(struct net *net, __u16 lport)
 
 /* Is a socket of this style? */
 #define sctp_style(sk, style) __sctp_style((sk), (SCTP_SOCKET_##style))
-static inline int __sctp_style(const struct sock *sk, sctp_socket_type_t style)
+static inline int __sctp_style(const struct sock *sk,
+			       enum sctp_socket_type style)
 {
 	return sctp_sk(sk)->type == style;
 }
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index b6d75b3..0477945 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -150,18 +150,18 @@ extern struct sctp_globals {
 #define sctp_checksum_disable		(sctp_globals.checksum_disable)
 
 /* SCTP Socket type: UDP or TCP style. */
-typedef enum {
+enum sctp_socket_type {
 	SCTP_SOCKET_UDP = 0,
 	SCTP_SOCKET_UDP_HIGH_BANDWIDTH,
 	SCTP_SOCKET_TCP
-} sctp_socket_type_t;
+};
 
 /* Per socket SCTP information. */
 struct sctp_sock {
 	/* inet_sock has to be the first member of sctp_sock */
 	struct inet_sock inet;
 	/* What kind of a socket is this? */
-	sctp_socket_type_t type;
+	enum sctp_socket_type type;
 
 	/* PF_ family specific functions.  */
 	struct sctp_pf *pf;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 0181906..c01af72 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -100,8 +100,9 @@ static int sctp_send_asconf(struct sctp_association *asoc,
 			    struct sctp_chunk *chunk);
 static int sctp_do_bind(struct sock *, union sctp_addr *, int);
 static int sctp_autobind(struct sock *sk);
-static void sctp_sock_migrate(struct sock *, struct sock *,
-			      struct sctp_association *, sctp_socket_type_t);
+static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
+			      struct sctp_association *assoc,
+			      enum sctp_socket_type type);
 
 static unsigned long sctp_memory_pressure;
 static atomic_long_t sctp_memory_allocated;
@@ -8086,7 +8087,7 @@ static inline void sctp_copy_descendant(struct sock *sk_to,
  */
 static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 			      struct sctp_association *assoc,
-			      sctp_socket_type_t type)
+			      enum sctp_socket_type type)
 {
 	struct sctp_sock *oldsp = sctp_sk(oldsk);
 	struct sctp_sock *newsp = sctp_sk(newsk);
-- 
2.1.0
