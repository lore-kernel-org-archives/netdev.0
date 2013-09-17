From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/7] netfilter: ipset: Validate the set family and not the set type family at swapping
Date: Wed, 18 Sep 2013 00:07:32 +0200
Message-ID: <1379455654-3905-6-git-send-email-pablo@netfilter.org>
References: <1379455654-3905-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34681 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752003Ab3IQWIF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Sep 2013 18:08:05 -0400
In-Reply-To: <1379455654-3905-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

This closes netfilter bugzilla #843, reported by Quentin Armitage.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index c8c303c..f2e30fb 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1052,7 +1052,7 @@ ip_set_swap(struct sock *ctnl, struct sk_buff *skb,
 	 * Not an artificial restriction anymore, as we must prevent
 	 * possible loops created by swapping in setlist type of sets. */
 	if (!(from->type->features == to->type->features &&
-	      from->type->family == to->type->family))
+	      from->family == to->family))
 		return -IPSET_ERR_TYPE_MISMATCH;
 
 	strncpy(from_name, from->name, IPSET_MAXNAMELEN);
-- 
1.7.10.4
