From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/3] inet: Remove unused send_check length argument
Date: Sun, 11 Apr 2010 20:15:55 +0800
Message-ID: <E1O0w4x-0005VA-LH@gondolin.me.apana.org.au>
References: <20100411100902.GA20141@gondor.apana.org.au>
To: davem@davemloft.net, yinghai@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:55361 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751338Ab0DKMQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 08:16:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet: Remove unused send_check length argument

This patch removes the unused length argument from the send_check
function in struct inet_connection_sock_af_ops.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/inet_connection_sock.h |    3 +--
 include/net/tcp.h                  |    2 +-
 net/dccp/dccp.h                    |    2 +-
 net/dccp/ipv4.c                    |    2 +-
 net/dccp/ipv6.c                    |    3 +--
 net/dccp/output.c                  |    2 +-
 net/ipv4/tcp_ipv4.c                |    2 +-
 net/ipv4/tcp_output.c              |    2 +-
 net/ipv6/tcp_ipv6.c                |    2 +-
 9 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 696d6e4..52c8b8b 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -37,8 +37,7 @@ struct tcp_congestion_ops;
  */
 struct inet_connection_sock_af_ops {
 	int	    (*queue_xmit)(struct sk_buff *skb, int ipfragok);
-	void	    (*send_check)(struct sock *sk, int len,
-				  struct sk_buff *skb);
+	void	    (*send_check)(struct sock *sk, struct sk_buff *skb);
 	int	    (*rebuild_header)(struct sock *sk);
 	int	    (*conn_request)(struct sock *sk, struct sk_buff *skb);
 	struct sock *(*syn_recv_sock)(struct sock *sk, struct sk_buff *skb,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 75be5a2..70c5159 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -423,7 +423,7 @@ extern u8			*tcp_parse_md5sig_option(struct tcphdr *th);
  *	TCP v4 functions exported for the inet6 API
  */
 
-extern void		       	tcp_v4_send_check(struct sock *sk, int len,
+extern void		       	tcp_v4_send_check(struct sock *sk,
 						  struct sk_buff *skb);
 
 extern int			tcp_v4_conn_request(struct sock *sk,
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 5ef32c2..33035ab 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -223,7 +223,7 @@ static inline void dccp_csum_outgoing(struct sk_buff *skb)
 	skb->csum = skb_checksum(skb, 0, (cov > skb->len)? skb->len : cov, 0);
 }
 
-extern void dccp_v4_send_check(struct sock *sk, int len, struct sk_buff *skb);
+extern void dccp_v4_send_check(struct sock *sk, struct sk_buff *skb);
 
 extern int  dccp_retransmit_skb(struct sock *sk);
 
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 52ffa1c..d9b11ef 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -349,7 +349,7 @@ static inline __sum16 dccp_v4_csum_finish(struct sk_buff *skb,
 	return csum_tcpudp_magic(src, dst, skb->len, IPPROTO_DCCP, skb->csum);
 }
 
-void dccp_v4_send_check(struct sock *sk, int unused, struct sk_buff *skb)
+void dccp_v4_send_check(struct sock *sk, struct sk_buff *skb)
 {
 	const struct inet_sock *inet = inet_sk(sk);
 	struct dccp_hdr *dh = dccp_hdr(skb);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 3b11e41..ab1ab95 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -60,8 +60,7 @@ static inline __sum16 dccp_v6_csum_finish(struct sk_buff *skb,
 	return csum_ipv6_magic(saddr, daddr, skb->len, IPPROTO_DCCP, skb->csum);
 }
 
-static inline void dccp_v6_send_check(struct sock *sk, int unused_value,
-				      struct sk_buff *skb)
+static inline void dccp_v6_send_check(struct sock *sk, struct sk_buff *skb)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct dccp_hdr *dh = dccp_hdr(skb);
diff --git a/net/dccp/output.c b/net/dccp/output.c
index fc3f436..b8d98e3 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -129,7 +129,7 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 			break;
 		}
 
-		icsk->icsk_af_ops->send_check(sk, 0, skb);
+		icsk->icsk_af_ops->send_check(sk, skb);
 
 		if (set_ack)
 			dccp_event_ack_sent(sk);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index aebfd28..a24995c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -537,7 +537,7 @@ static void __tcp_v4_send_check(struct sk_buff *skb,
 }
 
 /* This routine computes an IPv4 TCP checksum. */
-void tcp_v4_send_check(struct sock *sk, int len, struct sk_buff *skb)
+void tcp_v4_send_check(struct sock *sk, struct sk_buff *skb)
 {
 	struct inet_sock *inet = inet_sk(sk);
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 0dda86e..0ae7ce7 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -878,7 +878,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	}
 #endif
 
-	icsk->icsk_af_ops->send_check(sk, skb->len, skb);
+	icsk->icsk_af_ops->send_check(sk, skb);
 
 	if (likely(tcb->flags & TCPCB_FLAG_ACK))
 		tcp_event_ack_sent(sk, tcp_skb_pcount(skb));
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f84c506..b429dfd 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -933,7 +933,7 @@ static void __tcp_v6_send_check(struct sk_buff *skb,
 	}
 }
 
-static void tcp_v6_send_check(struct sock *sk, int len, struct sk_buff *skb)
+static void tcp_v6_send_check(struct sock *sk, struct sk_buff *skb)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 
