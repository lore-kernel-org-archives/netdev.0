From: kaber@trash.net
Subject: [PATCH 61/72] tproxy: added udp6_lib_lookup function
Date: Thu, 21 Oct 2010 17:19:48 +0200
Message-ID: <1287674399-31455-62-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Balazs Scheidler <bazsi@balabit.hu>

Just like with IPv4, we need access to the UDP hash table to look up local
sockets, but instead of exporting the global udp_table, export a lookup
function.

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/udp.h |    3 +++
 net/ipv6/udp.c    |    8 ++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index a184d34..200b828 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -183,6 +183,9 @@ extern int udp_lib_setsockopt(struct sock *sk, int level, int optname,
 extern struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 				    __be32 daddr, __be16 dport,
 				    int dif);
+extern struct sock *udp6_lib_lookup(struct net *net, const struct in6_addr *saddr, __be16 sport,
+				    const struct in6_addr *daddr, __be16 dport,
+				    int dif);
 
 /*
  * 	SNMP statistics for UDP and UDP-Lite
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 33e3683..c84dad4 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -320,6 +320,14 @@ static struct sock *__udp6_lib_lookup_skb(struct sk_buff *skb,
 				 udptable);
 }
 
+struct sock *udp6_lib_lookup(struct net *net, const struct in6_addr *saddr, __be16 sport,
+			     const struct in6_addr *daddr, __be16 dport, int dif)
+{
+	return __udp6_lib_lookup(net, saddr, sport, daddr, dport, dif, &udp_table);
+}
+EXPORT_SYMBOL_GPL(udp6_lib_lookup);
+
+
 /*
  * 	This should be easy, if there is something there we
  * 	return it, otherwise we block.
-- 
1.7.1

