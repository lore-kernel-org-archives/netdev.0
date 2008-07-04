From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 3/4] MIB: add struct net to UDP6_INC_STATS_USER
Date: Fri, 04 Jul 2008 16:03:44 +0400
Message-ID: <486E11A0.2090409@openvz.org>
References: <486E1074.7040702@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Denis Lunev <den@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:50235 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753832AbYGDMGQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 08:06:16 -0400
In-Reply-To: <486E1074.7040702@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As simple as the patch #1 in this set.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Acked-by: Denis V. Lunev <den@openvz.org>

---
 include/net/udp.h |    2 +-
 net/ipv6/udp.c    |   11 +++++++----
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 7b18cfb..bb5b9ec 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -168,7 +168,7 @@ DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
 #define UDP6_INC_STATS_BH(field, is_udplite) 			      do  {  \
 	if (is_udplite) SNMP_INC_STATS_BH(udplite_stats_in6, field);         \
 	else		SNMP_INC_STATS_BH(udp_stats_in6, field);    } while(0)
-#define UDP6_INC_STATS_USER(field, is_udplite)			       do {    \
+#define UDP6_INC_STATS_USER(net, field, is_udplite)	    do { (void)net;    \
 	if (is_udplite) SNMP_INC_STATS_USER(udplite_stats_in6, field);         \
 	else		SNMP_INC_STATS_USER(udp_stats_in6, field);    } while(0)
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f91e1df..833f715 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -166,7 +166,8 @@ try_again:
 		goto out_free;
 
 	if (!peeked)
-		UDP6_INC_STATS_USER(UDP_MIB_INDATAGRAMS, is_udplite);
+		UDP6_INC_STATS_USER(sock_net(sk),
+				UDP_MIB_INDATAGRAMS, is_udplite);
 
 	sock_recv_timestamp(msg, sk, skb);
 
@@ -213,7 +214,7 @@ out:
 csum_copy_err:
 	lock_sock(sk);
 	if (!skb_kill_datagram(sk, skb, flags))
-		UDP6_INC_STATS_USER(UDP_MIB_INERRORS, is_udplite);
+		UDP6_INC_STATS_USER(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
 	release_sock(sk);
 
 	if (flags & MSG_DONTWAIT)
@@ -591,7 +592,8 @@ out:
 	up->len = 0;
 	up->pending = 0;
 	if (!err)
-		UDP6_INC_STATS_USER(UDP_MIB_OUTDATAGRAMS, is_udplite);
+		UDP6_INC_STATS_USER(sock_net(sk),
+				UDP_MIB_OUTDATAGRAMS, is_udplite);
 	return err;
 }
 
@@ -873,7 +875,8 @@ out:
 	 * seems like overkill.
 	 */
 	if (err == -ENOBUFS || test_bit(SOCK_NOSPACE, &sk->sk_socket->flags)) {
-		UDP6_INC_STATS_USER(UDP_MIB_SNDBUFERRORS, is_udplite);
+		UDP6_INC_STATS_USER(sock_net(sk),
+				UDP_MIB_SNDBUFERRORS, is_udplite);
 	}
 	return err;
 
-- 
1.5.3.4

