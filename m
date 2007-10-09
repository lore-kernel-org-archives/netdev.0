From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][NETNS] Don't memset() netns to zero manually
Date: Tue, 09 Oct 2007 15:48:19 +0400
Message-ID: <470B6A83.8070600@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:43819 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751788AbXJILuv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 07:50:51 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The newly created net namespace is set to 0 with memset()
in setup_net(). The setup_net() is also called for the
init_net_ns(), which is zeroed naturally as a global var.

So remove this memset and allocate new nets with the
kmem_cache_zalloc().

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 0e0ca6d..6f71db8 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -24,7 +24,7 @@ EXPORT_SYMBOL_GPL(init_net);
 
 static struct net *net_alloc(void)
 {
-	return kmem_cache_alloc(net_cachep, GFP_KERNEL);
+	return kmem_cache_zalloc(net_cachep, GFP_KERNEL);
 }
 
 static void net_free(struct net *net)
@@ -90,7 +90,6 @@ static int setup_net(struct net *net)
 	struct pernet_operations *ops;
 	int error;
 
-	memset(net, 0, sizeof(struct net));
 	atomic_set(&net->count, 1);
 	atomic_set(&net->use_count, 0);
 
