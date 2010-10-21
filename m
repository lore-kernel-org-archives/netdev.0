From: kaber@trash.net
Subject: [PATCH 60/72] tproxy: added const specifiers to udp lookup functions
Date: Thu, 21 Oct 2010 17:19:47 +0200
Message-ID: <1287674399-31455-61-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Balazs Scheidler <bazsi@balabit.hu>

The parameters for various UDP lookup functions were non-const, even though
they could be const. TProxy has some const references and instead of
downcasting it, I added const specifiers along the path.

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/udp.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 5acb356..33e3683 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -122,8 +122,8 @@ static void udp_v6_rehash(struct sock *sk)
 
 static inline int compute_score(struct sock *sk, struct net *net,
 				unsigned short hnum,
-				struct in6_addr *saddr, __be16 sport,
-				struct in6_addr *daddr, __be16 dport,
+				const struct in6_addr *saddr, __be16 sport,
+				const struct in6_addr *daddr, __be16 dport,
 				int dif)
 {
 	int score = -1;
@@ -239,8 +239,8 @@ exact_match:
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
1.7.1

