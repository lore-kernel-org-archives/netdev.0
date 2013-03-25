From: pablo@netfilter.org
Subject: [PATCH 04/12] netfilter: nf_ct_ipv6: use ipv6_iface_scope_id in conntrack to return scope id
Date: Mon, 25 Mar 2013 13:15:44 +0100
Message-ID: <1364213752-3934-5-git-send-email-pablo@netfilter.org>
References: <1364213752-3934-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46515 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757196Ab3CYMQN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 08:16:13 -0400
In-Reply-To: <1364213752-3934-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>

As in (842df07 ipv6: use newly introduced __ipv6_addr_needs_scope_id and
ipv6_iface_scope_id).

Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 2b6c226..97bcf2b 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -330,12 +330,8 @@ ipv6_getorigdst(struct sock *sk, int optval, void __user *user, int *len)
 					sizeof(sin6.sin6_addr));
 
 	nf_ct_put(ct);
-
-	if (ipv6_addr_type(&sin6.sin6_addr) & IPV6_ADDR_LINKLOCAL)
-		sin6.sin6_scope_id = sk->sk_bound_dev_if;
-	else
-		sin6.sin6_scope_id = 0;
-
+	sin6.sin6_scope_id = ipv6_iface_scope_id(&sin6.sin6_addr,
+						 sk->sk_bound_dev_if);
 	return copy_to_user(user, &sin6, sizeof(sin6)) ? -EFAULT : 0;
 }
 
-- 
1.7.10.4
