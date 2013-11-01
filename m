From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH net-next 1/1] ipv6: remove the destination condition on flow label sharing
Date: Fri,  1 Nov 2013 17:11:26 +0100
Message-ID: <1383322286-21464-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:60489 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753429Ab3KAQSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 12:18:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of label sharing, it should be possible to use
one label to more than one destination. This
old restriction is not mandatory, so we can remove it.

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 net/ipv6/ip6_flowlabel.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 46e8843..f8102d0 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -604,8 +604,7 @@ recheck:
 					goto release;

 				err = -EINVAL;
-				if (!ipv6_addr_equal(&fl1->dst, &fl->dst) ||
-				    ipv6_opt_cmp(fl1->opt, fl->opt))
+				if (ipv6_opt_cmp(fl1->opt, fl->opt))
 					goto release;

 				err = -ENOMEM;
--
1.8.4.rc3
