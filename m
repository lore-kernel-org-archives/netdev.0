From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH]: rfs: record flow in TCP receiving and sending pathes
Date: Fri,  9 Jul 2010 15:28:18 +0800
Message-ID: <1278660498-26587-1-git-send-email-xiaosuo@gmail.com>
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:53091 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411Ab0GIHcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 03:32:00 -0400
Received: by pzk26 with SMTP id 26so351953pzk.19
        for <netdev@vger.kernel.org>; Fri, 09 Jul 2010 00:31:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rfs: record flow in TCP receiving and sending pathes

call sock_rps_record_flow() in function tcp_splice_read(), tcp_sendpage() and
tcp_sendmsg().

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/ipv4/tcp.c |    3 +++
 1 file changed, 3 insertions(+)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4e6ddfb..47537d8 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -608,6 +608,7 @@ ssize_t tcp_splice_read(struct socket *sock, loff_t *ppos,
 	ssize_t spliced;
 	int ret;
 
+	sock_rps_record_flow(sk);
 	/*
 	 * We can't seek on a socket input
 	 */
@@ -862,6 +863,7 @@ ssize_t tcp_sendpage(struct socket *sock, struct page *page, int offset,
 	ssize_t res;
 	struct sock *sk = sock->sk;
 
+	sock_rps_record_flow(sk);
 	if (!(sk->sk_route_caps & NETIF_F_SG) ||
 	    !(sk->sk_route_caps & NETIF_F_ALL_CSUM))
 		return sock_no_sendpage(sock, page, offset, size, flags);
@@ -909,6 +911,7 @@ int tcp_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	int sg, err, copied;
 	long timeo;
 
+	sock_rps_record_flow(sk);
 	lock_sock(sk);
 	TCP_CHECK_TIMER(sk);
 
