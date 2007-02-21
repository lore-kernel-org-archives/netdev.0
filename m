From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 09/29] selinux: tag avc cache alloc as non-critical
Date: Wed, 21 Feb 2007 15:43:13 +0100
Message-ID: <20070221144842.396545000@taijtu.programming.kicks-ass.net>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34537 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751285AbXBUPFf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 10:05:35 -0500
Content-Disposition: inline; filename=mm-selinux-emergency.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Failing to allocate a cache entry will only harm performance.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 security/selinux/avc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6-git/security/selinux/avc.c
===================================================================
--- linux-2.6-git.orig/security/selinux/avc.c	2007-02-14 08:31:13.000000000 +0100
+++ linux-2.6-git/security/selinux/avc.c	2007-02-14 10:10:47.000000000 +0100
@@ -332,7 +332,7 @@ static struct avc_node *avc_alloc_node(v
 {
 	struct avc_node *node;
 
-	node = kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC);
+	node = kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC|__GFP_NOMEMALLOC);
 	if (!node)
 		goto out;
 

-- 

