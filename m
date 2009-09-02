From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/5] tcp: MD5 operations should be const
Date: Tue, 01 Sep 2009 22:25:03 -0700
Message-ID: <20090902052538.428954402@vyatta.com>
References: <20090902052500.808557262@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46824 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755806AbZIBFhG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 01:37:06 -0400
Content-Disposition: inline; filename=const-md5-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 include/linux/tcp.h |    6 +++---
 net/ipv4/tcp_ipv4.c |    4 ++--
 net/ipv6/tcp_ipv6.c |   10 +++++-----
 3 files changed, 10 insertions(+), 10 deletions(-)

--- a/include/linux/tcp.h	2009-09-01 21:45:24.022174846 -0700
+++ b/include/linux/tcp.h	2009-09-01 21:52:18.131739158 -0700
@@ -233,7 +233,7 @@ struct tcp_request_sock {
 	struct inet_request_sock 	req;
 #ifdef CONFIG_TCP_MD5SIG
 	/* Only used by TCP MD5 Signature so far. */
-	struct tcp_request_sock_ops	*af_specific;
+	const struct tcp_request_sock_ops *af_specific;
 #endif
 	u32			 	rcv_isn;
 	u32			 	snt_isn;
@@ -401,9 +401,9 @@ struct tcp_sock {
 
 #ifdef CONFIG_TCP_MD5SIG
 /* TCP AF-Specific parts; only used by MD5 Signature support so far */
-	struct tcp_sock_af_ops	*af_specific;
+	const struct tcp_sock_af_ops	*af_specific;
 
-/* TCP MD5 Signagure Option information */
+/* TCP MD5 Signature Option information */
 	struct tcp_md5sig_info	*md5sig_info;
 #endif
 };
--- a/net/ipv4/tcp_ipv4.c	2009-09-01 21:45:24.039229254 -0700
+++ b/net/ipv4/tcp_ipv4.c	2009-09-01 22:22:23.997230300 -0700
@@ -1195,7 +1195,7 @@ struct request_sock_ops tcp_request_sock
 };
 
 #ifdef CONFIG_TCP_MD5SIG
-static struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
+static const struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
 	.md5_lookup	=	tcp_v4_reqsk_md5_lookup,
 	.calc_md5_hash	=	tcp_v4_md5_hash_skb,
 };
@@ -1774,7 +1774,7 @@ struct inet_connection_sock_af_ops ipv4_
 };
 
 #ifdef CONFIG_TCP_MD5SIG
-static struct tcp_sock_af_ops tcp_sock_ipv4_specific = {
+static const struct tcp_sock_af_ops tcp_sock_ipv4_specific = {
 	.md5_lookup		= tcp_v4_md5_lookup,
 	.calc_md5_hash		= tcp_v4_md5_hash_skb,
 	.md5_add		= tcp_v4_md5_add_func,
--- a/net/ipv6/tcp_ipv6.c	2009-09-01 21:45:24.055740485 -0700
+++ b/net/ipv6/tcp_ipv6.c	2009-09-01 22:22:23.988774018 -0700
@@ -78,8 +78,8 @@ static int	tcp_v6_do_rcv(struct sock *sk
 static struct inet_connection_sock_af_ops ipv6_mapped;
 static struct inet_connection_sock_af_ops ipv6_specific;
 #ifdef CONFIG_TCP_MD5SIG
-static struct tcp_sock_af_ops tcp_sock_ipv6_specific;
-static struct tcp_sock_af_ops tcp_sock_ipv6_mapped_specific;
+static const struct tcp_sock_af_ops tcp_sock_ipv6_specific;
+static const struct tcp_sock_af_ops tcp_sock_ipv6_mapped_specific;
 #else
 static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(struct sock *sk,
 						   struct in6_addr *addr)
@@ -894,7 +894,7 @@ struct request_sock_ops tcp6_request_soc
 };
 
 #ifdef CONFIG_TCP_MD5SIG
-static struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
+static const struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
 	.md5_lookup	=	tcp_v6_reqsk_md5_lookup,
 	.calc_md5_hash	=	tcp_v6_md5_hash_skb,
 };
@@ -1780,7 +1780,7 @@ static struct inet_connection_sock_af_op
 };
 
 #ifdef CONFIG_TCP_MD5SIG
-static struct tcp_sock_af_ops tcp_sock_ipv6_specific = {
+static const struct tcp_sock_af_ops tcp_sock_ipv6_specific = {
 	.md5_lookup	=	tcp_v6_md5_lookup,
 	.calc_md5_hash	=	tcp_v6_md5_hash_skb,
 	.md5_add	=	tcp_v6_md5_add_func,
@@ -1812,7 +1812,7 @@ static struct inet_connection_sock_af_op
 };
 
 #ifdef CONFIG_TCP_MD5SIG
-static struct tcp_sock_af_ops tcp_sock_ipv6_mapped_specific = {
+static const struct tcp_sock_af_ops tcp_sock_ipv6_mapped_specific = {
 	.md5_lookup	=	tcp_v4_md5_lookup,
 	.calc_md5_hash	=	tcp_v4_md5_hash_skb,
 	.md5_add	=	tcp_v6_md5_add_func,

-- 

