From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 9/13] udp: Export code sk lookup routines
Date: Fri, 09 Dec 2011 20:23:34 +0400
Message-ID: <4EE23606.6040308@parallels.com>
References: <4EE23561.5020804@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:28043 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751420Ab1LIQXk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Dec 2011 11:23:40 -0500
In-Reply-To: <4EE23561.5020804@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The UDP diag get_exact handler will require them to find a
socket by provided net, [sd]addr-s, [sd]ports and device.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/net/udp.h |    6 ++++++
 net/ipv4/udp.c    |    3 ++-
 net/ipv6/udp.c    |    3 ++-
 3 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index f54a515..1ffb39c 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -194,9 +194,15 @@ extern int udp_lib_setsockopt(struct sock *sk, int level, int optname,
 extern struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 				    __be32 daddr, __be16 dport,
 				    int dif);
+extern struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
+				    __be32 daddr, __be16 dport,
+				    int dif, struct udp_table *tbl);
 extern struct sock *udp6_lib_lookup(struct net *net, const struct in6_addr *saddr, __be16 sport,
 				    const struct in6_addr *daddr, __be16 dport,
 				    int dif);
+extern struct sock *__udp6_lib_lookup(struct net *net, const struct in6_addr *saddr, __be16 sport,
+				    const struct in6_addr *daddr, __be16 dport,
+				    int dif, struct udp_table *tbl);
 
 /*
  * 	SNMP statistics for UDP and UDP-Lite
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ad481b3..5d075b5 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -445,7 +445,7 @@ exact_match:
 /* UDP is nearly always wildcards out the wazoo, it makes no sense to try
  * harder than this. -DaveM
  */
-static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
+struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 		__be16 sport, __be32 daddr, __be16 dport,
 		int dif, struct udp_table *udptable)
 {
@@ -512,6 +512,7 @@ begin:
 	rcu_read_unlock();
 	return result;
 }
+EXPORT_SYMBOL_GPL(__udp4_lib_lookup);
 
 static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
 						 __be16 sport, __be16 dport,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index adfe26a..4f96b5c 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -238,7 +238,7 @@ exact_match:
 	return result;
 }
 
-static struct sock *__udp6_lib_lookup(struct net *net,
+struct sock *__udp6_lib_lookup(struct net *net,
 				      const struct in6_addr *saddr, __be16 sport,
 				      const struct in6_addr *daddr, __be16 dport,
 				      int dif, struct udp_table *udptable)
@@ -305,6 +305,7 @@ begin:
 	rcu_read_unlock();
 	return result;
 }
+EXPORT_SYMBOL_GPL(__udp6_lib_lookup);
 
 static struct sock *__udp6_lib_lookup_skb(struct sk_buff *skb,
 					  __be16 sport, __be16 dport,
-- 
1.5.5.6
