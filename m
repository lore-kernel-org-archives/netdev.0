From: David Miller <davem@davemloft.net>
Subject: [PATCH 08/16] inet: Remove ->get_peer() method.
Date: Tue, 10 Jul 2012 08:07:32 -0700 (PDT)
Message-ID: <20120710.080732.939134761109344272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38419 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754762Ab2GJPHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 11:07:33 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 5745258662D
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 08:07:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No longer used.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inet_connection_sock.h |    1 -
 net/ipv4/tcp_ipv4.c                |   16 ----------------
 net/ipv6/tcp_ipv6.c                |   16 ----------------
 3 files changed, 33 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index af3c743..291e7ce 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -43,7 +43,6 @@ struct inet_connection_sock_af_ops {
 	struct sock *(*syn_recv_sock)(struct sock *sk, struct sk_buff *skb,
 				      struct request_sock *req,
 				      struct dst_entry *dst);
-	struct inet_peer *(*get_peer)(struct sock *sk);
 	u16	    net_header_len;
 	u16	    net_frag_header_len;
 	u16	    sockaddr_len;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d406bf7..ddefd39 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1847,21 +1847,6 @@ do_time_wait:
 	goto discard_it;
 }
 
-struct inet_peer *tcp_v4_get_peer(struct sock *sk)
-{
-	struct rtable *rt = (struct rtable *) __sk_dst_get(sk);
-	struct inet_sock *inet = inet_sk(sk);
-
-	/* If we don't have a valid cached route, or we're doing IP
-	 * options which make the IPv4 header destination address
-	 * different from our peer's, do not bother with this.
-	 */
-	if (!rt || inet->cork.fl.u.ip4.daddr != inet->inet_daddr)
-		return NULL;
-	return rt_get_peer_create(rt, inet->inet_daddr);
-}
-EXPORT_SYMBOL(tcp_v4_get_peer);
-
 static struct timewait_sock_ops tcp_timewait_sock_ops = {
 	.twsk_obj_size	= sizeof(struct tcp_timewait_sock),
 	.twsk_unique	= tcp_twsk_unique,
@@ -1874,7 +1859,6 @@ const struct inet_connection_sock_af_ops ipv4_specific = {
 	.rebuild_header	   = inet_sk_rebuild_header,
 	.conn_request	   = tcp_v4_conn_request,
 	.syn_recv_sock	   = tcp_v4_syn_recv_sock,
-	.get_peer	   = tcp_v4_get_peer,
 	.net_header_len	   = sizeof(struct iphdr),
 	.setsockopt	   = ip_setsockopt,
 	.getsockopt	   = ip_getsockopt,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 9e96b5f..61175cb 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1689,20 +1689,6 @@ do_time_wait:
 	goto discard_it;
 }
 
-static struct inet_peer *tcp_v6_get_peer(struct sock *sk)
-{
-	struct rt6_info *rt = (struct rt6_info *) __sk_dst_get(sk);
-	struct ipv6_pinfo *np = inet6_sk(sk);
-
-	/* If we don't have a valid cached route, or we're doing IP
-	 * options which make the IPv6 header destination address
-	 * different from our peer's, do not bother with this.
-	 */
-	if (!rt || !ipv6_addr_equal(&np->daddr, &rt->rt6i_dst.addr))
-		return NULL;
-	return rt6_get_peer_create(rt);
-}
-
 static struct timewait_sock_ops tcp6_timewait_sock_ops = {
 	.twsk_obj_size	= sizeof(struct tcp6_timewait_sock),
 	.twsk_unique	= tcp_twsk_unique,
@@ -1715,7 +1701,6 @@ static const struct inet_connection_sock_af_ops ipv6_specific = {
 	.rebuild_header	   = inet6_sk_rebuild_header,
 	.conn_request	   = tcp_v6_conn_request,
 	.syn_recv_sock	   = tcp_v6_syn_recv_sock,
-	.get_peer	   = tcp_v6_get_peer,
 	.net_header_len	   = sizeof(struct ipv6hdr),
 	.net_frag_header_len = sizeof(struct frag_hdr),
 	.setsockopt	   = ipv6_setsockopt,
@@ -1747,7 +1732,6 @@ static const struct inet_connection_sock_af_ops ipv6_mapped = {
 	.rebuild_header	   = inet_sk_rebuild_header,
 	.conn_request	   = tcp_v6_conn_request,
 	.syn_recv_sock	   = tcp_v6_syn_recv_sock,
-	.get_peer	   = tcp_v4_get_peer,
 	.net_header_len	   = sizeof(struct iphdr),
 	.setsockopt	   = ipv6_setsockopt,
 	.getsockopt	   = ipv6_getsockopt,
-- 
1.7.10.4
