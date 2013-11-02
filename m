From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH net-next v2] ipv6: remove old conditions on flow label sharing
Date: Sat,  2 Nov 2013 14:55:07 +0100
Message-ID: <1383400507-12604-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:47574 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753568Ab3KBNzL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Nov 2013 09:55:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code of flow label in Linux Kernel follows
the rules of RFC 1809 (an informational one) for
conditions on flow label sharing. There rules are
not in the last proposed standard for flow label
(RFC 6437), or in the previous one (RFC 3697).

Since this code does not follow any current or
old standard, we can remove it.

With this removal, the ipv6_opt_cmp function is
now a dead code and it can be removed too.

Changelog to v1:
 * add justification for the change
 * remove the condition on IPv6 options

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 net/ipv6/ip6_flowlabel.c | 22 ----------------------
 1 file changed, 22 deletions(-)

diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 46e8843..ff20f5a 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -476,23 +476,6 @@ static bool ipv6_hdr_cmp(struct ipv6_opt_hdr *h1, struct ipv6_opt_hdr *h2)
 	return memcmp(h1+1, h2+1, ((h1->hdrlen+1)<<3) - sizeof(*h1));
 }

-static bool ipv6_opt_cmp(struct ipv6_txoptions *o1, struct ipv6_txoptions *o2)
-{
-	if (o1 == o2)
-		return false;
-	if (o1 == NULL || o2 == NULL)
-		return true;
-	if (o1->opt_nflen != o2->opt_nflen)
-		return true;
-	if (ipv6_hdr_cmp(o1->hopopt, o2->hopopt))
-		return true;
-	if (ipv6_hdr_cmp(o1->dst0opt, o2->dst0opt))
-		return true;
-	if (ipv6_hdr_cmp((struct ipv6_opt_hdr *)o1->srcrt, (struct ipv6_opt_hdr *)o2->srcrt))
-		return true;
-	return false;
-}
-
 static inline void fl_link(struct ipv6_pinfo *np, struct ipv6_fl_socklist *sfl,
 		struct ip6_flowlabel *fl)
 {
@@ -603,11 +586,6 @@ recheck:
 				     uid_eq(fl1->owner.uid, fl->owner.uid)))
 					goto release;

-				err = -EINVAL;
-				if (!ipv6_addr_equal(&fl1->dst, &fl->dst) ||
-				    ipv6_opt_cmp(fl1->opt, fl->opt))
-					goto release;
-
 				err = -ENOMEM;
 				if (sfl1 == NULL)
 					goto release;
--
1.8.4.rc3
