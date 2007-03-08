From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 8/8] udp: deinline
Date: Thu, 08 Mar 2007 12:52:22 -0800
Message-ID: <20070308205306.296232086@linux-foundation.org>
References: <20070308205214.580772044@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:35780 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933318AbXCHUyk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 15:54:40 -0500
Content-Disposition: inline; filename=udp-deinline.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A couple of functions are exported or used indirectly
so it is pointless to mark them as inline.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/ipv4/udp.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

--- net-2.6.22.orig/net/ipv4/udp.c	2007-03-07 14:51:07.000000000 -0800
+++ net-2.6.22/net/ipv4/udp.c	2007-03-07 14:51:35.000000000 -0800
@@ -213,13 +213,13 @@
 	return error;
 }
 
-__inline__ int udp_get_port(struct sock *sk, unsigned short snum,
+int udp_get_port(struct sock *sk, unsigned short snum,
 			int (*scmp)(const struct sock *, const struct sock *))
 {
 	return  __udp_lib_get_port(sk, snum, udp_hash, &udp_port_rover, scmp);
 }
 
-inline int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
+int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
 {
 	struct inet_sock *inet1 = inet_sk(sk1), *inet2 = inet_sk(sk2);
 
@@ -391,7 +391,7 @@
 	sock_put(sk);
 }
 
-__inline__ void udp_err(struct sk_buff *skb, u32 info)
+void udp_err(struct sk_buff *skb, u32 info)
 {
 	return __udp4_lib_err(skb, info, udp_hash);
 }
@@ -1296,7 +1296,7 @@
 	return 0;
 }
 
-__inline__ int udp_rcv(struct sk_buff *skb)
+int udp_rcv(struct sk_buff *skb)
 {
 	return __udp4_lib_rcv(skb, udp_hash, IPPROTO_UDP);
 }

--
Stephen Hemminger <shemminger@linux-foundation.org>

