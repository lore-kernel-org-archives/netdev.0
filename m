From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/4] xfrm: Use a static gc threshold value for ipv6
Date: Thu, 22 Nov 2012 09:02:41 +0100
Message-ID: <1353571362-6774-4-git-send-email-steffen.klassert@secunet.com>
References: <1353571362-6774-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36100 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932380Ab2KVTBS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2012 14:01:18 -0500
In-Reply-To: <1353571362-6774-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unlike ipv4 did, ipv6 does not handle the maximum number of cached
routes dynamically. So no need to try to handle the IPsec gc threshold
value dynamically. This patch sets the IPsec gc threshold value back to
1024 routes, as it is for non-IPsec routes.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/xfrm6_policy.c |   16 +---------------
 1 file changed, 1 insertion(+), 15 deletions(-)

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index f3ed8ca..6ce4a4f 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -327,21 +327,7 @@ static struct ctl_table_header *sysctl_hdr;
 int __init xfrm6_init(void)
 {
 	int ret;
-	unsigned int gc_thresh;
-
-	/*
-	 * We need a good default value for the xfrm6 gc threshold.
-	 * In ipv4 we set it to the route hash table size * 8, which
-	 * is half the size of the maximaum route cache for ipv4.  It
-	 * would be good to do the same thing for v6, except the table is
-	 * constructed differently here.  Here each table for a net namespace
-	 * can have FIB_TABLE_HASHSZ entries, so lets go with the same
-	 * computation that we used for ipv4 here.  Also, lets keep the initial
-	 * gc_thresh to a minimum of 1024, since, the ipv6 route cache defaults
-	 * to that as a minimum as well
-	 */
-	gc_thresh = FIB6_TABLE_HASHSZ * 8;
-	xfrm6_dst_ops.gc_thresh = (gc_thresh < 1024) ? 1024 : gc_thresh;
+
 	dst_entries_init(&xfrm6_dst_ops);
 
 	ret = xfrm6_policy_init();
-- 
1.7.9.5
