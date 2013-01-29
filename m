From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 4/5] netfilter ip6table_mangle: Use ipv6_addr_equal()
 where appropriate.
Date: Wed, 30 Jan 2013 07:48:58 +0900
Message-ID: <510851DA.5060408@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:54635 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752171Ab3A2Ws7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 17:48:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/netfilter/ip6table_mangle.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index 7431121..6134a1e 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -11,6 +11,7 @@
 #include <linux/module.h>
 #include <linux/netfilter_ipv6/ip6_tables.h>
 #include <linux/slab.h>
+#include <net/ipv6.h>
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
@@ -60,8 +61,8 @@ ip6t_mangle_out(struct sk_buff *skb, const struct net_device *out)
 			    dev_net(out)->ipv6.ip6table_mangle);
 
 	if (ret != NF_DROP && ret != NF_STOLEN &&
-	    (memcmp(&ipv6_hdr(skb)->saddr, &saddr, sizeof(saddr)) ||
-	     memcmp(&ipv6_hdr(skb)->daddr, &daddr, sizeof(daddr)) ||
+	    (!ipv6_addr_equal(&ipv6_hdr(skb)->saddr, &saddr) ||
+	     !ipv6_addr_equal(&ipv6_hdr(skb)->daddr, &daddr) ||
 	     skb->mark != mark ||
 	     ipv6_hdr(skb)->hop_limit != hop_limit ||
 	     flowlabel != *((u_int32_t *)ipv6_hdr(skb))))
-- 
1.7.9.5
