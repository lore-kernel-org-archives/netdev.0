From: Shawn Lu <shawn.lu@ericsson.com>
Subject: [PATCH] tcp: md5: using remote adress for md5 lookup in rst packet
Date: Fri, 20 Jan 2012 14:22:04 -0800
Message-ID: <1327098124-19922-1-git-send-email-shawn.lu@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, xiaoclu@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr3.ericy.com ([198.24.6.13]:36272 "EHLO imr3.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755373Ab2ATWWP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jan 2012 17:22:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: shawnlu <shawn.lu@ericsson.com>

md5 key is added in socket through remote address.
remote address should be used in finding md5 key when
sending out reset packet.

Signed-off-by: shawnlu <shawn.lu@ericsson.com>
---
 net/ipv4/tcp_ipv4.c |    2 +-
 net/ipv6/tcp_ipv6.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1eb4ad5..337ba4c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -631,7 +631,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 	arg.iov[0].iov_len  = sizeof(rep.th);
 
 #ifdef CONFIG_TCP_MD5SIG
-	key = sk ? tcp_v4_md5_do_lookup(sk, ip_hdr(skb)->daddr) : NULL;
+	key = sk ? tcp_v4_md5_do_lookup(sk, ip_hdr(skb)->saddr) : NULL;
 	if (key) {
 		rep.opt[0] = htonl((TCPOPT_NOP << 24) |
 				   (TCPOPT_NOP << 16) |
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 906c7ca..3edd05a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1083,7 +1083,7 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 
 #ifdef CONFIG_TCP_MD5SIG
 	if (sk)
-		key = tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr);
+		key = tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->saddr);
 #endif
 
 	if (th->ack)
-- 
1.7.0.4
