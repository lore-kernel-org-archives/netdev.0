From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: md5: add more const attributes
Date: Mon, 24 Oct 2011 08:35:11 +0200
Message-ID: <1319438111.2517.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64897 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848Ab1JXGfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 02:35:15 -0400
Received: by wyg36 with SMTP id 36so5792784wyg.19
        for <netdev@vger.kernel.org>; Sun, 23 Oct 2011 23:35:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now tcp_md5_hash_header() has a const tcphdr argument, we can add more
const attributes to callers.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/tcp.h   |   17 +++++++++--------
 net/ipv4/tcp_ipv4.c |   12 ++++++------
 net/ipv6/tcp_ipv6.c |   13 +++++++------
 3 files changed, 22 insertions(+), 20 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 910cc29..ed0e814 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1185,8 +1185,9 @@ struct tcp_md5sig_pool {
 
 /* - functions */
 extern int tcp_v4_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
-			       struct sock *sk, struct request_sock *req,
-			       struct sk_buff *skb);
+			       const struct sock *sk,
+			       const struct request_sock *req,
+			       const struct sk_buff *skb);
 extern struct tcp_md5sig_key * tcp_v4_md5_lookup(struct sock *sk,
 						 struct sock *addr_sk);
 extern int tcp_v4_md5_do_add(struct sock *sk, __be32 addr, u8 *newkey,
@@ -1448,9 +1449,9 @@ struct tcp_sock_af_ops {
 						struct sock *addr_sk);
 	int			(*calc_md5_hash) (char *location,
 						  struct tcp_md5sig_key *md5,
-						  struct sock *sk,
-						  struct request_sock *req,
-						  struct sk_buff *skb);
+						  const struct sock *sk,
+						  const struct request_sock *req,
+						  const struct sk_buff *skb);
 	int			(*md5_add) (struct sock *sk,
 					    struct sock *addr_sk,
 					    u8 *newkey,
@@ -1467,9 +1468,9 @@ struct tcp_request_sock_ops {
 						struct request_sock *req);
 	int			(*calc_md5_hash) (char *location,
 						  struct tcp_md5sig_key *md5,
-						  struct sock *sk,
-						  struct request_sock *req,
-						  struct sk_buff *skb);
+						  const struct sock *sk,
+						  const struct request_sock *req,
+						  const struct sk_buff *skb);
 #endif
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 955c925..1dad7e9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -92,7 +92,7 @@ EXPORT_SYMBOL(sysctl_tcp_low_latency);
 static struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk,
 						   __be32 addr);
 static int tcp_v4_md5_hash_hdr(char *md5_hash, struct tcp_md5sig_key *key,
-			       __be32 daddr, __be32 saddr, struct tcphdr *th);
+			       __be32 daddr, __be32 saddr, const struct tcphdr *th);
 #else
 static inline
 struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk, __be32 addr)
@@ -1090,7 +1090,7 @@ static int tcp_v4_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
 }
 
 static int tcp_v4_md5_hash_hdr(char *md5_hash, struct tcp_md5sig_key *key,
-			       __be32 daddr, __be32 saddr, struct tcphdr *th)
+			       __be32 daddr, __be32 saddr, const struct tcphdr *th)
 {
 	struct tcp_md5sig_pool *hp;
 	struct hash_desc *desc;
@@ -1122,12 +1122,12 @@ clear_hash_noput:
 }
 
 int tcp_v4_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
-			struct sock *sk, struct request_sock *req,
-			struct sk_buff *skb)
+			const struct sock *sk, const struct request_sock *req,
+			const struct sk_buff *skb)
 {
 	struct tcp_md5sig_pool *hp;
 	struct hash_desc *desc;
-	struct tcphdr *th = tcp_hdr(skb);
+	const struct tcphdr *th = tcp_hdr(skb);
 	__be32 saddr, daddr;
 
 	if (sk) {
@@ -1172,7 +1172,7 @@ clear_hash_noput:
 }
 EXPORT_SYMBOL(tcp_v4_md5_hash_skb);
 
-static int tcp_v4_inbound_md5_hash(struct sock *sk, struct sk_buff *skb)
+static int tcp_v4_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
 {
 	/*
 	 * This gets called for each TCP segment that arrives
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index da2ada8..c8683fc 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -761,7 +761,7 @@ static int tcp_v6_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
 
 static int tcp_v6_md5_hash_hdr(char *md5_hash, struct tcp_md5sig_key *key,
 			       const struct in6_addr *daddr, struct in6_addr *saddr,
-			       struct tcphdr *th)
+			       const struct tcphdr *th)
 {
 	struct tcp_md5sig_pool *hp;
 	struct hash_desc *desc;
@@ -793,13 +793,14 @@ clear_hash_noput:
 }
 
 static int tcp_v6_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
-			       struct sock *sk, struct request_sock *req,
-			       struct sk_buff *skb)
+			       const struct sock *sk,
+			       const struct request_sock *req,
+			       const struct sk_buff *skb)
 {
 	const struct in6_addr *saddr, *daddr;
 	struct tcp_md5sig_pool *hp;
 	struct hash_desc *desc;
-	struct tcphdr *th = tcp_hdr(skb);
+	const struct tcphdr *th = tcp_hdr(skb);
 
 	if (sk) {
 		saddr = &inet6_sk(sk)->saddr;
@@ -842,12 +843,12 @@ clear_hash_noput:
 	return 1;
 }
 
-static int tcp_v6_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
+static int tcp_v6_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
 {
 	const __u8 *hash_location = NULL;
 	struct tcp_md5sig_key *hash_expected;
 	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
-	struct tcphdr *th = tcp_hdr(skb);
+	const struct tcphdr *th = tcp_hdr(skb);
 	int genhash;
 	u8 newhash[16];
 
