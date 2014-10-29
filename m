From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] ipv6: remove inline on static in c file
Date: Wed, 29 Oct 2014 11:38:17 +0100
Message-ID: <1414579097-11659-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

remove __inline__ / inline and let compiler decide what to do
with static functions

Inspired-by: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipv6/reassembly.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 1a157ca..51ab096 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -69,7 +69,7 @@ struct ip6frag_skb_cb {
 
 #define FRAG6_CB(skb)	((struct ip6frag_skb_cb *)((skb)->cb))
 
-static inline u8 ip6_frag_ecn(const struct ipv6hdr *ipv6h)
+static u8 ip6_frag_ecn(const struct ipv6hdr *ipv6h)
 {
 	return 1 << (ipv6_get_dsfield(ipv6h) & INET_ECN_MASK);
 }
@@ -178,7 +178,7 @@ static void ip6_frag_expire(unsigned long data)
 	ip6_expire_frag_queue(net, fq, &ip6_frags);
 }
 
-static __inline__ struct frag_queue *
+static struct frag_queue *
 fq_find(struct net *net, __be32 id, const struct in6_addr *src,
 	const struct in6_addr *dst, u8 ecn)
 {
@@ -684,21 +684,21 @@ static void ip6_frags_sysctl_unregister(void)
 	unregister_net_sysctl_table(ip6_ctl_header);
 }
 #else
-static inline int ip6_frags_ns_sysctl_register(struct net *net)
+static int ip6_frags_ns_sysctl_register(struct net *net)
 {
 	return 0;
 }
 
-static inline void ip6_frags_ns_sysctl_unregister(struct net *net)
+static void ip6_frags_ns_sysctl_unregister(struct net *net)
 {
 }
 
-static inline int ip6_frags_sysctl_register(void)
+static int ip6_frags_sysctl_register(void)
 {
 	return 0;
 }
 
-static inline void ip6_frags_sysctl_unregister(void)
+static void ip6_frags_sysctl_unregister(void)
 {
 }
 #endif
-- 
1.9.3
