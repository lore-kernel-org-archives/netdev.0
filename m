From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 16/17] tcp/dccp: constify rtx_synack() and friends
Date: Fri, 25 Sep 2015 07:39:23 -0700
Message-ID: <1443191964-923-17-git-send-email-edumazet@google.com>
References: <1443191964-923-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33169 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113AbbIYOkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 10:40:45 -0400
Received: by pacex6 with SMTP id ex6so107628885pac.0
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 07:40:44 -0700 (PDT)
In-Reply-To: <1443191964-923-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is done to make sure we do not change listener socket
while sending SYNACK packets while socket lock is not held.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/request_sock.h | 2 +-
 include/net/tcp.h          | 2 +-
 net/dccp/ipv4.c            | 2 +-
 net/dccp/ipv6.c            | 2 +-
 net/ipv4/tcp_output.c      | 2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 87935cad2f7b..ff7ce1e53ed4 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -32,7 +32,7 @@ struct request_sock_ops {
 	int		obj_size;
 	struct kmem_cache	*slab;
 	char		*slab_name;
-	int		(*rtx_syn_ack)(struct sock *sk,
+	int		(*rtx_syn_ack)(const struct sock *sk,
 				       struct request_sock *req);
 	void		(*send_ack)(struct sock *sk, struct sk_buff *skb,
 				    struct request_sock *req);
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0f847eb9af65..cdbf63d3c5cf 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1676,7 +1676,7 @@ int tcp4_proc_init(void);
 void tcp4_proc_exit(void);
 #endif
 
-int tcp_rtx_synack(struct sock *sk, struct request_sock *req);
+int tcp_rtx_synack(const struct sock *sk, struct request_sock *req);
 int tcp_conn_request(struct request_sock_ops *rsk_ops,
 		     const struct tcp_request_sock_ops *af_ops,
 		     struct sock *sk, struct sk_buff *skb);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index ccf4c5629b3c..a46ae9c69ccf 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -498,7 +498,7 @@ static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 	return &rt->dst;
 }
 
-static int dccp_v4_send_response(struct sock *sk, struct request_sock *req)
+static int dccp_v4_send_response(const struct sock *sk, struct request_sock *req)
 {
 	int err = -1;
 	struct sk_buff *skb;
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 5165571f397a..4fa199dc69a3 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -181,7 +181,7 @@ out:
 }
 
 
-static int dccp_v6_send_response(struct sock *sk, struct request_sock *req)
+static int dccp_v6_send_response(const struct sock *sk, struct request_sock *req)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
 	struct ipv6_pinfo *np = inet6_sk(sk);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 0831dcae6d03..9e53dd9bfcad 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3503,7 +3503,7 @@ void tcp_send_probe0(struct sock *sk)
 				  TCP_RTO_MAX);
 }
 
-int tcp_rtx_synack(struct sock *sk, struct request_sock *req)
+int tcp_rtx_synack(const struct sock *sk, struct request_sock *req)
 {
 	const struct tcp_request_sock_ops *af_ops = tcp_rsk(req)->af_specific;
 	struct flowi fl;
-- 
2.6.0.rc2.230.g3dd15c0
