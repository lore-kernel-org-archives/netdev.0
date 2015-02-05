From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 01/29] net: Introduce net_ctx and macro for context comparison
Date: Wed,  4 Feb 2015 18:34:02 -0700
Message-ID: <1423100070-31848-2-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:55718 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756055AbbBEBfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:35:54 -0500
Received: by mail-ig0-f178.google.com with SMTP id hl2so8414694igb.5
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:35:53 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For now the network context is just the namespace. A later patch adds
a vrf context.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/net_namespace.h | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 36faf4990c4b..b932f2a83865 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -134,11 +134,19 @@ struct net {
 	atomic_t		fnhe_genid;
 };
 
+struct net_ctx {
+#ifdef CONFIG_NET_NS
+	struct net *net;
+#endif
+};
+
 #include <linux/seq_file_net.h>
 
 /* Init's network namespace */
 extern struct net init_net;
 
+#define INIT_NET_CTX  { .net = &init_net }
+
 #ifdef CONFIG_NET_NS
 struct net *copy_net_ns(unsigned long flags, struct user_namespace *user_ns,
 			struct net *old_net);
@@ -202,6 +210,13 @@ int net_eq(const struct net *net1, const struct net *net2)
 	return net1 == net2;
 }
 
+static inline
+int net_ctx_eq(struct net_ctx *ctx1, struct net_ctx *ctx2)
+{
+	return net_eq(ctx1->net, ctx2->net);
+}
+
+
 void net_drop_ns(void *);
 
 #else
@@ -226,6 +241,12 @@ int net_eq(const struct net *net1, const struct net *net2)
 	return 1;
 }
 
+static inline
+int net_ctx_eq(struct net_ctx *ctx1, struct net_ctx *ctx2)
+{
+	return 1;
+}
+
 #define net_drop_ns NULL
 #endif
 
-- 
1.9.3 (Apple Git-50)
