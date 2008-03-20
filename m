From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 13/30] selinux: tag avc cache alloc as non-critical
Date: Thu, 20 Mar 2008 21:10:55 +0100
Message-ID: <20080320202123.205173000@chello.nl>
References: <20080320201042.675090000@chello.nl>
Cc: James Morris <jmorris@namei.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fy
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep32-int.chello.at ([62.179.121.50]:36297 "EHLO
	viefep32-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755348AbYCTUVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 16:21:13 -0400
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

Index: linux-2.6/security/selinux/avc.c
===================================================================
--- linux-2.6.orig/security/selinux/avc.c
+++ linux-2.6/security/selinux/avc.c
@@ -334,7 +334,7 @@ static struct avc_node *avc_alloc_node(v
 {
 	struct avc_node *node;
 
-	node = kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC);
+	node = kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC|__GFP_NOMEMALLOC);
 	if (!node)
 		goto out;
 

--

