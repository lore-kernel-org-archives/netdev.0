From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: ipv6_select_ident() returns a __be32
Date: Mon, 25 May 2015 16:02:21 -0700
Message-ID: <1432594941.4060.198.camel@edumazet-glaptop2.roam.corp.google.com>
References: <201505260544.3guHqjoi%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
To: kbuild test robot <fengguang.wu@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:34038 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903AbbEYXCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 19:02:23 -0400
Received: by igbhj9 with SMTP id hj9so46307566igb.1
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 16:02:23 -0700 (PDT)
In-Reply-To: <201505260544.3guHqjoi%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ipv6_select_ident() returns a 32bit value in network order.

Fixes: 286c2349f666 ("ipv6: Clean up ipv6_select_ident() and ip6_fragment()")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: kbuild test robot <fengguang.wu@intel.com>
---
 include/net/ipv6.h     |    6 +++---
 net/ipv6/output_core.c |    6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index b950a2000b7f4608647b77dd029c94277a1afd97..35d485c780802cc28dedb4f889f3478be712b9df 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -671,9 +671,9 @@ static inline int ipv6_addr_diff(const struct in6_addr *a1, const struct in6_add
 	return __ipv6_addr_diff(a1, a2, sizeof(struct in6_addr));
 }
 
-u32 ipv6_select_ident(struct net *net,
-		      const struct in6_addr *daddr,
-		      const struct in6_addr *saddr);
+__be32 ipv6_select_ident(struct net *net,
+			 const struct in6_addr *daddr,
+			 const struct in6_addr *saddr);
 void ipv6_proxy_select_ident(struct net *net, struct sk_buff *skb);
 
 int ip6_dst_hoplimit(struct dst_entry *dst);
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 055e85cb7b6518f20796859e46fa043b186278e7..21678acd452165fae8a2c0b7c007ed1daa407344 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -61,9 +61,9 @@ void ipv6_proxy_select_ident(struct net *net, struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(ipv6_proxy_select_ident);
 
-u32 ipv6_select_ident(struct net *net,
-		      const struct in6_addr *daddr,
-		      const struct in6_addr *saddr)
+__be32 ipv6_select_ident(struct net *net,
+			 const struct in6_addr *daddr,
+			 const struct in6_addr *saddr)
 {
 	static u32 ip6_idents_hashrnd __read_mostly;
 	u32 id;
