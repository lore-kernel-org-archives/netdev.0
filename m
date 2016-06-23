From: Tom Goff <thomas.goff@ll.mit.edu>
Subject: [PATCH] ipmr/ip6mr: Initialize the last assert time of mfc entries.
Date: Thu, 23 Jun 2016 16:11:57 -0400
Message-ID: <20160623201157.GA4178@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from LLMX2.LL.MIT.EDU ([129.55.12.48]:57426 "EHLO llmx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750799AbcFWU2R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2016 16:28:17 -0400
Received: from LLE2K10-HUB01.mitll.ad.local (LLE2K10-HUB01.mitll.ad.local) by llmx2.ll.mit.edu (unknown) with ESMTP id u5NK9WYR019160 for <netdev@vger.kernel.org>; Thu, 23 Jun 2016 16:09:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes wrong-interface signaling on 32-bit platforms for entries
created when jiffies > 2^31 + MFC_ASSERT_THRESH.

Signed-off-by: Tom Goff <thomas.goff@ll.mit.edu>
---
 net/ipv4/ipmr.c  | 4 +++-
 net/ipv6/ip6mr.c | 1 +
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 21a38e2..5ad48ec 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -891,8 +891,10 @@ static struct mfc_cache *ipmr_cache_alloc(void)
 {
 	struct mfc_cache *c = kmem_cache_zalloc(mrt_cachep, GFP_KERNEL);
 
-	if (c)
+	if (c) {
+		c->mfc_un.res.last_assert = jiffies - MFC_ASSERT_THRESH - 1;
 		c->mfc_un.res.minvif = MAXVIFS;
+	}
 	return c;
 }
 
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index f2e2013f8..487ef3b 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1074,6 +1074,7 @@ static struct mfc6_cache *ip6mr_cache_alloc(void)
 	struct mfc6_cache *c = kmem_cache_zalloc(mrt_cachep, GFP_KERNEL);
 	if (!c)
 		return NULL;
+	c->mfc_un.res.last_assert = jiffies - MFC_ASSERT_THRESH - 1;
 	c->mfc_un.res.minvif = MAXMIFS;
 	return c;
 }
-- 
1.9.1
