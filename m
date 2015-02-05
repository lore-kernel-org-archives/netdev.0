From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 09/29] net: Flip ip6_flowlabel to net_ctx
Date: Wed,  4 Feb 2015 18:34:10 -0700
Message-ID: <1423100070-31848-10-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:44921 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756318AbbBEBgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:36:01 -0500
Received: by mail-ie0-f172.google.com with SMTP id at20so6738179iec.3
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:36:00 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/ipv6.h | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 8027ca53e31f..2d025ed7a183 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -238,9 +238,20 @@ struct ip6_flowlabel {
 	} owner;
 	unsigned long		lastuse;
 	unsigned long		expires;
-	struct net		*fl_net;
+	struct net_ctx		fl_net_ctx;
+#define fl_net  fl_net_ctx.net
 };
 
+static inline
+int fl_net_ctx_eq(struct ip6_flowlabel *fl, struct net_ctx *ctx)
+{
+#ifdef CONFIG_NET_NS
+	return net_eq(fl->fl_net, ctx->net);
+#else
+	return 1;
+#endif
+}
+
 #define IPV6_FLOWINFO_MASK	cpu_to_be32(0x0FFFFFFF)
 #define IPV6_FLOWLABEL_MASK	cpu_to_be32(0x000FFFFF)
 #define IPV6_TCLASS_MASK (IPV6_FLOWINFO_MASK & ~IPV6_FLOWLABEL_MASK)
-- 
1.9.3 (Apple Git-50)
