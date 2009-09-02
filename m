From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/5] inet: inet_connection_sock_af_ops const
Date: Tue, 01 Sep 2009 22:25:04 -0700
Message-ID: <20090902052538.518661801@vyatta.com>
References: <20090902052500.808557262@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46826 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755810AbZIBFhG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 01:37:06 -0400
Content-Disposition: inline; filename=const-inet-connect-sock-af-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function block inet_connect_sock_af_ops contains no data
make it constant.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 include/net/transp_v6.h |    2 +-
 net/dccp/ipv4.c         |    2 +-
 net/dccp/ipv6.c         |    8 ++++----
 net/ipv4/tcp_ipv4.c     |    2 +-
 net/ipv6/tcp_ipv6.c     |    8 ++++----
 5 files changed, 11 insertions(+), 11 deletions(-)

--- a/net/dccp/ipv4.c	2009-09-01 21:54:11.398740410 -0700
+++ b/net/dccp/ipv4.c	2009-09-01 21:55:22.254758800 -0700
@@ -880,7 +880,7 @@ discard_and_relse:
 	goto discard_it;
 }
 
-static struct inet_connection_sock_af_ops dccp_ipv4_af_ops = {
+static const struct inet_connection_sock_af_ops dccp_ipv4_af_ops = {
 	.queue_xmit	   = ip_queue_xmit,
 	.send_check	   = dccp_v4_send_check,
 	.rebuild_header	   = inet_sk_rebuild_header,
--- a/net/dccp/ipv6.c	2009-09-01 21:54:11.414740438 -0700
+++ b/net/dccp/ipv6.c	2009-09-01 21:55:41.734738880 -0700
@@ -35,8 +35,8 @@
 
 /* The per-net dccp.v6_ctl_sk is used for sending RSTs and ACKs */
 
-static struct inet_connection_sock_af_ops dccp_ipv6_mapped;
-static struct inet_connection_sock_af_ops dccp_ipv6_af_ops;
+static const struct inet_connection_sock_af_ops dccp_ipv6_mapped;
+static const struct inet_connection_sock_af_ops dccp_ipv6_af_ops;
 
 static void dccp_v6_hash(struct sock *sk)
 {
@@ -1055,7 +1055,7 @@ failure:
 	return err;
 }
 
-static struct inet_connection_sock_af_ops dccp_ipv6_af_ops = {
+static const struct inet_connection_sock_af_ops dccp_ipv6_af_ops = {
 	.queue_xmit	   = inet6_csk_xmit,
 	.send_check	   = dccp_v6_send_check,
 	.rebuild_header	   = inet6_sk_rebuild_header,
@@ -1076,7 +1076,7 @@ static struct inet_connection_sock_af_op
 /*
  *	DCCP over IPv4 via INET6 API
  */
-static struct inet_connection_sock_af_ops dccp_ipv6_mapped = {
+static const struct inet_connection_sock_af_ops dccp_ipv6_mapped = {
 	.queue_xmit	   = ip_queue_xmit,
 	.send_check	   = dccp_v4_send_check,
 	.rebuild_header	   = inet_sk_rebuild_header,
--- a/net/ipv4/tcp_ipv4.c	2009-09-01 21:55:56.583740315 -0700
+++ b/net/ipv4/tcp_ipv4.c	2009-09-01 21:56:04.623737423 -0700
@@ -1754,7 +1754,7 @@ int tcp_v4_tw_remember_stamp(struct inet
 	return 0;
 }
 
-struct inet_connection_sock_af_ops ipv4_specific = {
+const struct inet_connection_sock_af_ops ipv4_specific = {
 	.queue_xmit	   = ip_queue_xmit,
 	.send_check	   = tcp_v4_send_check,
 	.rebuild_header	   = inet_sk_rebuild_header,
--- a/net/ipv6/tcp_ipv6.c	2009-09-01 21:55:56.599803712 -0700
+++ b/net/ipv6/tcp_ipv6.c	2009-09-01 21:56:23.615764198 -0700
@@ -75,8 +75,8 @@ static void	tcp_v6_reqsk_send_ack(struct
 
 static int	tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb);
 
-static struct inet_connection_sock_af_ops ipv6_mapped;
-static struct inet_connection_sock_af_ops ipv6_specific;
+static const struct inet_connection_sock_af_ops ipv6_mapped;
+static const struct inet_connection_sock_af_ops ipv6_specific;
 #ifdef CONFIG_TCP_MD5SIG
 static const struct tcp_sock_af_ops tcp_sock_ipv6_specific;
 static const struct tcp_sock_af_ops tcp_sock_ipv6_mapped_specific;
@@ -1760,7 +1760,7 @@ static int tcp_v6_remember_stamp(struct 
 	return 0;
 }
 
-static struct inet_connection_sock_af_ops ipv6_specific = {
+static const struct inet_connection_sock_af_ops ipv6_specific = {
 	.queue_xmit	   = inet6_csk_xmit,
 	.send_check	   = tcp_v6_send_check,
 	.rebuild_header	   = inet6_sk_rebuild_header,
@@ -1792,7 +1792,7 @@ static const struct tcp_sock_af_ops tcp_
  *	TCP over IPv4 via INET6 API
  */
 
-static struct inet_connection_sock_af_ops ipv6_mapped = {
+static const struct inet_connection_sock_af_ops ipv6_mapped = {
 	.queue_xmit	   = ip_queue_xmit,
 	.send_check	   = tcp_v4_send_check,
 	.rebuild_header	   = inet_sk_rebuild_header,
--- a/include/net/transp_v6.h	2009-09-01 21:59:47.126112194 -0700
+++ b/include/net/transp_v6.h	2009-09-01 21:59:55.797799523 -0700
@@ -51,7 +51,7 @@ extern int			datagram_send_ctl(struct ne
 /*
  *	address family specific functions
  */
-extern struct inet_connection_sock_af_ops ipv4_specific;
+extern const struct inet_connection_sock_af_ops ipv4_specific;
 
 extern void inet6_destroy_sock(struct sock *sk);
 

-- 

