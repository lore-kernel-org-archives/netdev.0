From: pablo@netfilter.org
Subject: [PATCH 03/16] netfilter: nf_nat: remove obsolete rcu_read_unlock call
Date: Mon, 24 Sep 2012 21:19:15 +0200
Message-ID: <1348514369-3272-4-git-send-email-pablo@netfilter.org>
References: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58088 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757872Ab2IXTU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 15:20:57 -0400
In-Reply-To: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrich Weber <ulrich.weber@sophos.com>

hlist walk in find_appropriate_src() is not protected anymore by rcu_read_lock(),
so rcu_read_unlock() is unnecessary if in_range() matches.

This bug was added in (c7232c9 netfilter: add protocol independent NAT core).

Signed-off-by: Ulrich Weber <ulrich.weber@sophos.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_nat_core.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 65cf694..5f2f910 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -201,10 +201,8 @@ find_appropriate_src(struct net *net, u16 zone,
 				       &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
 			result->dst = tuple->dst;
 
-			if (in_range(l3proto, l4proto, result, range)) {
-				rcu_read_unlock();
+			if (in_range(l3proto, l4proto, result, range))
 				return 1;
-			}
 		}
 	}
 	return 0;
-- 
1.7.10.4
