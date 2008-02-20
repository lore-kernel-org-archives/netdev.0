From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 11/28] selinux: tag avc cache alloc as non-critical
Date: Wed, 20 Feb 2008 15:46:21 +0100
Message-ID: <20080220150306.682229000@chello.nl>
References: <20080220144610.548202000@chello.nl>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	James Morris <jmorris@namei.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:29524 "EHLO
	viefep21-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755677AbYBTPSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 10:18:43 -0500
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

