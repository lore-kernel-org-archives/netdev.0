From: Clemens Noss <cnoss@gmx.de>
Subject: [PATCH] netns: build fix for net_alloc_generic
Date: Mon, 23 Feb 2009 16:33:08 +0100
Message-ID: <200902231757.n1NHv1Ae012899@laptop10.darmstadt.cn-net.local>
References: <20090222.000801.250934892.davem@davemloft.net>
Cc: davem@davemloft.net, daniel.lezcano@free.fr
To: linux-netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:34526 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752131AbZBWR5H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2009 12:57:07 -0500
Received: from laptop10.darmstadt.cn-net.local ([192.168.10.169])
	by server.darmstadt.cn-net.local (8.13.7/8.11.2) with ESMTP id n1NHv1FX027069
	for <netdev@vger.kernel.org>; Mon, 23 Feb 2009 18:57:01 +0100
Received: from laptop10.darmstadt.cn-net.local (localhost [127.0.0.1])
	by laptop10.darmstadt.cn-net.local (8.14.0/8.14.0) with ESMTP id n1NHv1Us012902
	for <netdev@vger.kernel.org>; Mon, 23 Feb 2009 18:57:01 +0100
Received: (from cn@localhost)
	by laptop10.darmstadt.cn-net.local (8.14.0/8.14.0/Submit) id n1NHv1Ae012899
	for netdev@vger.kernel.org; Mon, 23 Feb 2009 18:57:01 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net_alloc_generic was defined in #ifdef CONFIG_NET_NS, but used
unconditionally. Move net_alloc_generic out of #ifdef.

Signed-off-by: Clemens Noss <cnoss@gmx.de>
---
 net/core/net_namespace.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index b0767ab..2adb1a7 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
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
@@ -80,6 +76,10 @@ static struct net_generic *net_alloc_generic(void)
 	return ng;
 }
 
+#ifdef CONFIG_NET_NS
+static struct kmem_cache *net_cachep;
+static struct workqueue_struct *netns_wq;
+
 static struct net *net_alloc(void)
 {
 	struct net *net = NULL;
-- 
1.6.1.3

