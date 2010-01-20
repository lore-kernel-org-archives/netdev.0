From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH 2/2] IPv6: reassembly:  replace  magic number with macro definitions
Date: Wed, 20 Jan 2010 14:21:17 +0800
Message-ID: <4B56A0DD.1010404@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org
To: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, yoshfuji@linux-ipv6.org,
	Patrick McHardy <kaber@trash.net>, eric.dumazet@gmail.com,
	adobriyan@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Use macro to define high/low thresh value, refer to IPV6_FRAG_TIMEOUT.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 include/net/ipv6.h                      |    2 ++
 net/ipv6/netfilter/nf_conntrack_reasm.c |    4 ++--
 net/ipv6/reassembly.c                   |    4 ++--
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index ccab594..299bbf5 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -246,6 +246,8 @@ extern int ipv6_opt_accepted(struct sock *sk, struct sk_buff *skb);
 int ip6_frag_nqueues(struct net *net);
 int ip6_frag_mem(struct net *net);
 
+#define IPV6_FRAG_HIGH_THRESH	262144		/* == 256*1024 */
+#define IPV6_FRAG_LOW_THRESH	196608		/* == 192*1024 */
 #define IPV6_FRAG_TIMEOUT	(60*HZ)		/* 60 seconds */
 
 extern int __ipv6_addr_type(const struct in6_addr *addr);
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 1030ce1..744ea49 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -666,8 +666,8 @@ int nf_ct_frag6_init(void)
 	nf_frags.frag_expire = nf_ct_frag6_expire;
 	nf_frags.secret_interval = 10 * 60 * HZ;
 	nf_init_frags.timeout = IPV6_FRAG_TIMEOUT;
-	nf_init_frags.high_thresh = 256 * 1024;
-	nf_init_frags.low_thresh = 192 * 1024;
+	nf_init_frags.high_thresh = IPV6_FRAG_HIGH_THRESH;
+	nf_init_frags.low_thresh = IPV6_FRAG_LOW_THRESH;
 	inet_frags_init_net(&nf_init_frags);
 	inet_frags_init(&nf_frags);
 
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 2cddea3..15bb122 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -747,8 +747,8 @@ static inline void ip6_frags_sysctl_unregister(void)
 
 static int ipv6_frags_init_net(struct net *net)
 {
-	net->ipv6.frags.high_thresh = 256 * 1024;
-	net->ipv6.frags.low_thresh = 192 * 1024;
+	net->ipv6.frags.high_thresh = IPV6_FRAG_HIGH_THRESH;
+	net->ipv6.frags.low_thresh = IPV6_FRAG_LOW_THRESH;
 	net->ipv6.frags.timeout = IPV6_FRAG_TIMEOUT;
 
 	inet_frags_init_net(&net->ipv6.frags);
-- 
1.6.3.3

