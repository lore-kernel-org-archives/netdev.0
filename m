From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: use ipv6_iface_scope_id in conntrack to return scope id
Date: Tue, 12 Mar 2013 22:21:36 +0100
Message-ID: <20130312212136.GB14801@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	pablo@netfilter.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c | 8 ++------
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
1.8.1.4

