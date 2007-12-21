From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [TCP]: Convert several length variable to unsigned.
Date: Fri, 21 Dec 2007 16:48:11 +0900 (JST)
Message-ID: <20071221.164811.126977620.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44225 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbXLUHrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 02:47:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several length variables cannot be negative, so convert int to
unsigned int.  This also allows us to do sane shift operations
on those variables.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--
diff --git a/include/net/tcp.h b/include/net/tcp.h
index cb5b033..f663a85 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1153,7 +1153,8 @@ extern int			tcp_v4_calc_md5_hash(char *md5_hash,
 						     struct dst_entry *dst,
 						     struct request_sock *req,
 						     struct tcphdr *th,
-						     int protocol, int tcplen);
+						     int protocol,
+						     unsigned int tcplen);
 extern struct tcp_md5sig_key	*tcp_v4_md5_lookup(struct sock *sk,
 						   struct sock *addr_sk);
 
@@ -1359,7 +1360,8 @@ struct tcp_sock_af_ops {
 						  struct dst_entry *dst,
 						  struct request_sock *req,
 						  struct tcphdr *th,
-						  int protocol, int len);
+						  int protocol,
+						  unsigned int len);
 	int			(*md5_add) (struct sock *sk,
 					    struct sock *addr_sk,
 					    u8 *newkey,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 652c323..601b4ca 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -99,7 +99,7 @@ static struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk,
 static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				   __be32 saddr, __be32 daddr,
 				   struct tcphdr *th, int protocol,
-				   int tcplen);
+				   unsigned int tcplen);
 #endif
 
 struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
@@ -1020,7 +1020,7 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
 static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				   __be32 saddr, __be32 daddr,
 				   struct tcphdr *th, int protocol,
-				   int tcplen)
+				   unsinged int tcplen)
 {
 	struct scatterlist sg[4];
 	__u16 data_len;
@@ -1113,7 +1113,7 @@ int tcp_v4_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 			 struct dst_entry *dst,
 			 struct request_sock *req,
 			 struct tcphdr *th, int protocol,
-			 int tcplen)
+			 unsigned int tcplen)
 {
 	__be32 saddr, daddr;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 93980c3..3b4169c 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -733,7 +733,7 @@ static int tcp_v6_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				   struct in6_addr *saddr,
 				   struct in6_addr *daddr,
 				   struct tcphdr *th, int protocol,
-				   int tcplen)
+				   unsigned int tcplen)
 {
 	struct scatterlist sg[4];
 	__u16 data_len;
@@ -818,7 +818,7 @@ static int tcp_v6_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				struct dst_entry *dst,
 				struct request_sock *req,
 				struct tcphdr *th, int protocol,
-				int tcplen)
+				unsigned int tcplen)
 {
 	struct in6_addr *saddr, *daddr;
 
@@ -985,7 +985,7 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 	struct tcphdr *th = tcp_hdr(skb), *t1;
 	struct sk_buff *buff;
 	struct flowi fl;
-	int tot_len = sizeof(*th);
+	unsigned int tot_len = sizeof(*th);
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key *key;
 #endif
@@ -1085,7 +1085,7 @@ static void tcp_v6_send_ack(struct tcp_timewait_sock *tw,
 	struct tcphdr *th = tcp_hdr(skb), *t1;
 	struct sk_buff *buff;
 	struct flowi fl;
-	int tot_len = sizeof(struct tcphdr);
+	unsigned int tot_len = sizeof(struct tcphdr);
 	__be32 *topt;
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key *key;
