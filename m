From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 08/29] net: Flip fib_info to net_ctx
Date: Wed,  4 Feb 2015 18:34:09 -0700
Message-ID: <1423100070-31848-9-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:35625 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756278AbbBEBgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:36:00 -0500
Received: by mail-ie0-f174.google.com with SMTP id vy18so6752957iec.5
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:35:59 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/ip_fib.h | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 5bd120e4bc0a..dca7f30be57f 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -98,7 +98,8 @@ struct fib_nh {
 struct fib_info {
 	struct hlist_node	fib_hash;
 	struct hlist_node	fib_lhash;
-	struct net		*fib_net;
+	struct net_ctx		fib_net_ctx;
+#define fib_net  fib_net_ctx.net
 	int			fib_treeref;
 	atomic_t		fib_clntref;
 	unsigned int		fib_flags;
@@ -122,6 +123,14 @@ struct fib_info {
 #define fib_dev		fib_nh[0].nh_dev
 };
 
+static inline
+int fib_net_ctx_eq(const struct fib_info *fi, const struct net_ctx *ctx)
+{
+	if (net_eq(fi->fib_net_ctx.net, ctx->net))
+		return 1;
+
+	return 0;
+}
 
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 struct fib_rule;
-- 
1.9.3 (Apple Git-50)
