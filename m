From: Jakub Sitnicki <jkbs@redhat.com>
Subject: [PATCH net-next v3 3/4] ipv6: Fold rt6_info_hash_nhsfn() into its only caller
Date: Wed, 23 Aug 2017 09:58:30 +0200
Message-ID: <20170823075831.27031-4-jkbs@redhat.com>
References: <20170823075831.27031-1-jkbs@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:38115 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753420AbdHWH6k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 03:58:40 -0400
Received: by mail-wm0-f47.google.com with SMTP id l19so9702945wmi.1
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 00:58:39 -0700 (PDT)
In-Reply-To: <20170823075831.27031-1-jkbs@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 644d0e656958 ("ipv6 Use get_hash_from_flowi6 for rt6 hash") has
turned rt6_info_hash_nhsfn() into a one-liner, so it no longer makes
sense to keep it around. Also remove the accompanying comment that has
become outdated.

Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>
---
 net/ipv6/route.c | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 6c4dd57..246e7d7 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -445,16 +445,6 @@ static bool rt6_check_expired(const struct rt6_info *rt)
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
@@ -462,7 +452,7 @@ static struct rt6_info *rt6_multipath_select(struct rt6_info *match,
 	struct rt6_info *sibling, *next_sibling;
 	int route_choosen;
 
-	route_choosen = rt6_info_hash_nhsfn(match->rt6i_nsiblings + 1, fl6);
+	route_choosen = get_hash_from_flowi6(fl6) % (match->rt6i_nsiblings + 1);
 	/* Don't change the route, if route_choosen == 0
 	 * (siblings does not include ourself)
 	 */
-- 
2.9.4
