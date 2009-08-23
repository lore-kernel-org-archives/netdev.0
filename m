From: Balazs Scheidler <bazsi@balabit.hu>
Subject: [PATCH 06/13] TProxy: added udp6_lib_lookup function
Date: Sun, 23 Aug 2009 11:19:43 +0200
Message-ID: <1253548005.12519.6.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:58469 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752468AbZIUQZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2009 12:25:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just like with IPv4, we need access to the UDP hash table to look up local
sockets, but instead of exporting the global udp_table, export a lookup
function.

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
---
 include/net/udp.h |    3 +++
 net/ipv6/udp.c    |    8 ++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 90e6ce5..5b45f5b 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -150,6 +150,9 @@ extern int 	udp_lib_setsockopt(struct sock *sk, int level, int optname,
 extern struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 				    __be32 daddr, __be16 dport,
 				    int dif);
+extern struct sock *udp6_lib_lookup(struct net *net, const struct in6_addr *saddr, __be16 sport,
+				    const struct in6_addr *daddr, __be16 dport,
+				    int dif);
 
 /*
  * 	SNMP statistics for UDP and UDP-Lite
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 9c9b24b..eee936c 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -182,6 +182,14 @@ static struct sock *__udp6_lib_lookup_skb(struct sk_buff *skb,
 				 udptable);
 }
 
+struct sock *udp6_lib_lookup(struct net *net, const struct in6_addr *saddr, __be16 sport,
+                             const struct in6_addr *daddr, __be16 dport, int dif)
+{
+        return __udp6_lib_lookup(net, saddr, sport, daddr, dport, dif, &udp_table);
+}
+EXPORT_SYMBOL_GPL(udp6_lib_lookup);
+
+
 /*
  * 	This should be easy, if there is something there we
  * 	return it, otherwise we block.
-- 
1.6.0.4

