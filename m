From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH nf] netfilter: Support expectations in different zones
Date: Tue, 21 Jul 2015 21:37:31 -0700
Message-ID: <1437539851-65437-1-git-send-email-joestringer@nicira.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When zones were originally introduced, the expectation functions were
all extended to perform lookup using the zone. However, insertion was
not modified to check the zone. This means that two expectations which
are intended to apply for different connections that have the same tuple
but exist in different zones cannot both be tracked.

Fixes: 5d0aa2ccd4 (netfilter: nf_conntrack: add support for "conntrack zones")

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 net/netfilter/nf_conntrack_expect.c | 3 ++-
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
2.1.4

