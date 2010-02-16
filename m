From: Patrick McHardy <kaber@trash.net>
Subject: IPv6 20/62: reassembly: replace magic number with macro definitions
Date: Tue, 16 Feb 2010 15:55:47 +0100 (MET)
Message-ID: <20100216145545.2796.47717.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51997 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932368Ab0BPOzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:55:48 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 7c070aa947d1a4105742378579c267f6e7fd08a1
Author: Shan Wei <shanwei@cn.fujitsu.com>
Date:   Wed Jan 20 10:42:41 2010 +0100

    IPv6: reassembly: replace magic number with macro definitions
    
    Use macro to define high/low thresh value, refer to IPV6_FRAG_TIMEOUT.
    
    Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
    Acked-by: David S. Miller <davem@davemloft.net>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

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
