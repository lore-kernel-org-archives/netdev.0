From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/10] netfilter: nf_conntrack: Support expectations in different zones
Date: Thu, 23 Jul 2015 01:00:52 +0200
Message-ID: <1437606052-5179-11-git-send-email-pablo@netfilter.org>
References: <1437606052-5179-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54459 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753414AbbGVWza (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 18:55:30 -0400
In-Reply-To: <1437606052-5179-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joestringer@nicira.com>

When zones were originally introduced, the expectation functions were
all extended to perform lookup using the zone. However, insertion was
not modified to check the zone. This means that two expectations which
are intended to apply for different connections that have the same tuple
but exist in different zones cannot both be tracked.

Fixes: 5d0aa2ccd4 (netfilter: nf_conntrack: add support for "conntrack zones")
Signed-off-by: Joe Stringer <joestringer@nicira.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_expect.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 7a17070..b45a422 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -219,7 +219,8 @@ static inline int expect_clash(const struct nf_conntrack_expect *a,
 			a->mask.src.u3.all[count] & b->mask.src.u3.all[count];
 	}
 
-	return nf_ct_tuple_mask_cmp(&a->tuple, &b->tuple, &intersect_mask);
+	return nf_ct_tuple_mask_cmp(&a->tuple, &b->tuple, &intersect_mask) &&
+	       nf_ct_zone(a->master) == nf_ct_zone(b->master);
 }
 
 static inline int expect_matches(const struct nf_conntrack_expect *a,
-- 
1.7.10.4
