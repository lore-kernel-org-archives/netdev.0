From: Jakub Sitnicki <jkbs@redhat.com>
Subject: [PATCH net-next v2 1/5] ipv6: Fold rt6_info_hash_nhsfn() into its only caller
Date: Fri, 28 Oct 2016 14:32:31 +0200
Message-ID: <1477657955-5157-2-git-send-email-jkbs@redhat.com>
References: <1477657955-5157-1-git-send-email-jkbs@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37122 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757449AbcJ1Mcm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 08:32:42 -0400
Received: by mail-wm0-f46.google.com with SMTP id 140so73769376wmv.0
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 05:32:41 -0700 (PDT)
In-Reply-To: <1477657955-5157-1-git-send-email-jkbs@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
