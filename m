From: Balazs Scheidler <bazsi@balabit.hu>
Subject: [PATCH 05/13] TProxy: added const specifiers to udp lookup
 functions
Date: Sun, 23 Aug 2009 11:16:17 +0200
Message-ID: <1253548005.12519.5.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The parameters for various UDP lookup functions were non-const, even though
they could be const. TProxy has some const references and instead of
downcasting it, I added const specifiers along the path.

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
---
 net/ipv6/udp.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 33b59bd..9c9b24b 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -88,8 +88,8 @@ int udp_v6_get_port(struct sock *sk, unsigned short snum)
 
 static inline int compute_score(struct sock *sk, struct net *net,
 				unsigned short hnum,
-				struct in6_addr *saddr, __be16 sport,
-				struct in6_addr *daddr, __be16 dport,
+				const struct in6_addr *saddr, __be16 sport,
+				const struct in6_addr *daddr, __be16 dport,
 				int dif)
 {
 	int score = -1;
@@ -125,8 +125,8 @@ static inline int compute_score(struct sock *sk, struct net *net,
 }
 
 static struct sock *__udp6_lib_lookup(struct net *net,
-				      struct in6_addr *saddr, __be16 sport,
-				      struct in6_addr *daddr, __be16 dport,
+				      const struct in6_addr *saddr, __be16 sport,
+				      const struct in6_addr *daddr, __be16 dport,
 				      int dif, struct udp_table *udptable)
 {
 	struct sock *sk, *result;
-- 
1.6.0.4

