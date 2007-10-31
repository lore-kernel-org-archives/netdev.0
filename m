From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 5/5] Hide the net_ns kmem cache
Date: Wed, 31 Oct 2007 22:32:55 +0300
Message-ID: <4728D867.8050207@openvz.org>
References: <4728D54F.2080208@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:46427 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752446AbXJaSai (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 14:30:38 -0400
In-Reply-To: <4728D54F.2080208@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This cache is only required to create new namespaces,
but we won't have them in CONFIG_NET_NS=n case.

Hide it under the appropriate ifdef.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index a044e2d..e9f0964 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -17,8 +17,6 @@ static DEFINE_MUTEX(net_mutex);
 
 LIST_HEAD(net_namespace_list);
 
-static struct kmem_cache *net_cachep;
-
 struct net init_net;
 EXPORT_SYMBOL_GPL(init_net);
 
@@ -59,6 +57,8 @@ out_undo:
 }
 
 #ifdef CONFIG_NET_NS
+static struct kmem_cache *net_cachep;
+
 static struct net *net_alloc(void)
 {
 	return kmem_cache_zalloc(net_cachep, GFP_KERNEL);
@@ -167,9 +167,11 @@ static int __init net_ns_init(void)
 	int err;
 
 	printk(KERN_INFO "net_namespace: %zd bytes\n", sizeof(struct net));
+#ifdef CONFIG_NET_NS
 	net_cachep = kmem_cache_create("net_namespace", sizeof(struct net),
 					SMP_CACHE_BYTES,
 					SLAB_PANIC, NULL);
+#endif
 	mutex_lock(&net_mutex);
 	err = setup_net(&init_net);
 
-- 
1.5.3.4

