From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 08/28] mm: system wide ALLOC_NO_WATERMARK
Date: Wed, 20 Feb 2008 15:46:18 +0100
Message-ID: <20080220150306.297640000@chello.nl>
References: <20080220144610.548202000@chello.nl>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:6667 "EHLO
	viefep18-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753543AbYBTPSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 10:18:39 -0500
Content-Disposition: inline; filename=global-ALLOC_NO_WATERMARKS.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change ALLOC_NO_WATERMARK page allocation such that the reserves are system
wide - which they are per setup_per_zone_pages_min(), when we scrape the
barrel, do it properly.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/page_alloc.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -1552,6 +1552,12 @@ restart:
 rebalance:
 	if (alloc_flags & ALLOC_NO_WATERMARKS) {
 nofail_alloc:
+		/*
+		 * break out of mempolicy boundaries
+		 */
+		zonelist = NODE_DATA(numa_node_id())->node_zonelists +
+			gfp_zone(gfp_mask);
+
 		/* go through the zonelist yet again, ignoring mins */
 		page = get_page_from_freelist(gfp_mask, order, zonelist,
 				ALLOC_NO_WATERMARKS);

--

