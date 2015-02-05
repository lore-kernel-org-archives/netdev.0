From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 02/29] net: Flip net_device to use net_ctx
Date: Wed,  4 Feb 2015 18:34:03 -0700
Message-ID: <1423100070-31848-3-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:59670 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756151AbbBEBfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:35:55 -0500
Received: by mail-ig0-f176.google.com with SMTP id hl2so39133430igb.3
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:35:54 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enhances a net_device from the current namespace only assignment to
a network context.

Define nd_net macro to handle existing code references. Add macros
for generating net_ctx struct given a net_device (needed because of
the way net references are done) and for comparing a given net_ctx
struct to the context of a net_device.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/netdevice.h | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 16251e96e6aa..55a221fec12b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1697,9 +1697,8 @@ struct net_device {
 	struct netpoll_info __rcu	*npinfo;
 #endif
 
-#ifdef CONFIG_NET_NS
-	struct net		*nd_net;
-#endif
+	struct net_ctx		net_ctx;
+#define nd_net net_ctx.net
 
 	/* mid-layer private */
 	union {
@@ -1845,6 +1844,18 @@ void dev_net_set(struct net_device *dev, struct net *net)
 #endif
 }
 
+/* get net_ctx from device */
+#define DEV_NET_CTX(dev)  { .net = dev_net((dev)) }
+
+static inline
+int dev_net_ctx_eq(const struct net_device *dev, struct net_ctx *ctx)
+{
+	if (net_eq(dev_net(dev), ctx->net))
+		return 1;
+
+	return 0;
+}
+
 static inline bool netdev_uses_dsa(struct net_device *dev)
 {
 #if IS_ENABLED(CONFIG_NET_DSA)
-- 
1.9.3 (Apple Git-50)
