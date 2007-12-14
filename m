From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 11/29] selinux: tag avc cache alloc as non-critical
Date: Fri, 14 Dec 2007 16:39:18 +0100
Message-ID: <20071214154440.693615000@chello.nl>
References: <20071214153907.770251000@chello.nl>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	James Morris <jmorris@namei.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:47249 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754608AbXLNTXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 14:23:35 -0500
Content-Disposition: inline; filename=mm-selinux-emergency.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Failing to allocate a cache entry will only harm performance not correctness.
Do not consume valuable reserve pages for something like that.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Acked-by: James Morris <jmorris@namei.org>
---
 security/selinux/avc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6-2/security/selinux/avc.c
===================================================================
--- linux-2.6-2.orig/security/selinux/avc.c
+++ linux-2.6-2/security/selinux/avc.c
@@ -334,7 +334,7 @@ static struct avc_node *avc_alloc_node(v
 {
 	struct avc_node *node;
 
-	node = kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC);
+	node = kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC|__GFP_NOMEMALLOC);
 	if (!node)
 		goto out;
 

--

