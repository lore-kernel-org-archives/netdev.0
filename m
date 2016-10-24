From: Jakub Sitnicki <jkbs@redhat.com>
Subject: [PATCH net-next 1/5] ipv6: Fold rt6_info_hash_nhsfn() into its only caller
Date: Mon, 24 Oct 2016 11:28:48 +0200
Message-ID: <1477301332-23954-2-git-send-email-jkbs@redhat.com>
References: <1477301332-23954-1-git-send-email-jkbs@redhat.com>
Cc: linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477301332-23954-1-git-send-email-jkbs@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 644d0e656958 ("ipv6 Use get_hash_from_flowi6 for rt6 hash") has
turned rt6_info_hash_nhsfn() into a one-liner, so it no longer makes
sense to keep it around.

Also the accompanying documentation comment has become outdated, so just
remove it altogether.

Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/route.c | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index bdbc38e..0514b35 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -425,16 +425,6 @@ static bool rt6_check_expired(const struct rt6_info *rt)
 	return false;
 }
 
-/* Multipath route selection:
- *   Hash based function using packet header and flowlabel.
- * Adapted from fib_info_hashfn()
- */
-static int rt6_info_hash_nhsfn(unsigned int candidate_count,
-			       const struct flowi6 *fl6)
-{
-	return get_hash_from_flowi6(fl6) % candidate_count;
-}
-
 static struct rt6_info *rt6_multipath_select(struct rt6_info *match,
 					     struct flowi6 *fl6, int oif,
 					     int strict)
@@ -442,7 +432,7 @@ static struct rt6_info *rt6_multipath_select(struct rt6_info *match,
 	struct rt6_info *sibling, *next_sibling;
 	int route_choosen;
 
-	route_choosen = rt6_info_hash_nhsfn(match->rt6i_nsiblings + 1, fl6);
+	route_choosen = get_hash_from_flowi6(fl6) % (match->rt6i_nsiblings + 1);
 	/* Don't change the route, if route_choosen == 0
 	 * (siblings does not include ourself)
 	 */
-- 
2.7.4
