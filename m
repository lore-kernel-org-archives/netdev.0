From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH v2 3/9] tproxy: added udp6_lib_lookup function
Date: Thu, 21 Oct 2010 12:47:09 +0200
Message-ID: <20101021104709.5192.57640.stgit@este.odu>
References: <20101021104709.5192.31249.stgit@este.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Balazs Scheidler <bazsi@balabit.hu>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-reply-to: <20101021104709.5192.31249.stgit@este.odu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Balazs Scheidler <bazsi@balabit.hu>

Just like with IPv4, we need access to the UDP hash table to look up local
sockets, but instead of exporting the global udp_table, export a lookup
function.

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
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


