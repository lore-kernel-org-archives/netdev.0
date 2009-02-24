From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH] net: Fix build without CONFIG_NET_NS
Date: Tue, 24 Feb 2009 13:26:45 +1100
Message-ID: <20090224022734.1766BDDE1D@ozlabs.org>
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:33717 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754336AbZBXC1g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2009 21:27:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 486a87f1e5624096bd1c09e9e716239597d48dca broke build without
CONFIG_NET_NS due to calling net_alloc_generic() always while defining
it inside an #ifdef CONFIG_NET_NS block. This moves the function
definition out of that block.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

 net/core/net_namespace.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

--- linux-work.orig/net/core/net_namespace.c	2009-02-24 13:20:42.000000000 +1100
+++ linux-work/net/core/net_namespace.c	2009-02-24 13:24:19.000000000 +1100
@@ -63,10 +63,6 @@ out_undo:
 	goto out;
 }
 
-#ifdef CONFIG_NET_NS
-static struct kmem_cache *net_cachep;
-static struct workqueue_struct *netns_wq;
-
 static struct net_generic *net_alloc_generic(void)
 {
 	struct net_generic *ng;
@@ -80,6 +76,10 @@ static struct net_generic *net_alloc_gen
 	return ng;
 }
 
+#ifdef CONFIG_NET_NS
+static struct kmem_cache *net_cachep;
+static struct workqueue_struct *netns_wq;
+
 static struct net *net_alloc(void)
 {
 	struct net *net = NULL;
@@ -218,7 +218,7 @@ static int __init net_ns_init(void)
 	netns_wq = create_singlethread_workqueue("netns");
 	if (!netns_wq)
 		panic("Could not create netns workq");
-#endif
+#endif /* CONFIG_NET_NS */
 
 	ng = net_alloc_generic();
 	if (!ng)
