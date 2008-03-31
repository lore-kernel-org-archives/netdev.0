From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/3 net-2.6.26] [NETNS]: Merge ifdef CONFIG_NET in include/net/net_namespace.h.
Date: Mon, 31 Mar 2008 19:47:00 +0400
Message-ID: <1206978422-13088-1-git-send-email-den@openvz.org>
References: <1206978361.10660.31.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	yoshfuji@linux-ipv6.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:37975 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751567AbYCaPrL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 11:47:11 -0400
In-Reply-To: <1206978361.10660.31.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/net_namespace.h |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index f8f3d1a..035ebff 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -61,25 +61,27 @@ struct net {
 #endif
 };
 
+
 #ifdef CONFIG_NET
 /* Init's network namespace */
 extern struct net init_net;
 #define INIT_NET_NS(net_ns) .net_ns = &init_net,
-#else
-#define INIT_NET_NS(net_ns)
-#endif
 
-extern struct list_head net_namespace_list;
-
-#ifdef CONFIG_NET
 extern struct net *copy_net_ns(unsigned long flags, struct net *net_ns);
-#else
+
+#else /* CONFIG_NET */
+
+#define INIT_NET_NS(net_ns)
+
 static inline struct net *copy_net_ns(unsigned long flags, struct net *net_ns)
 {
 	/* There is nothing to copy so this is a noop */
 	return net_ns;
 }
-#endif
+#endif /* CONFIG_NET */
+
+
+extern struct list_head net_namespace_list;
 
 #ifdef CONFIG_NET_NS
 extern void __put_net(struct net *net);
-- 
1.5.3.rc5

