From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 06/29] net: Flip fib_rules and fib_rules_ops to use net_ctx
Date: Wed,  4 Feb 2015 18:34:07 -0700
Message-ID: <1423100070-31848-7-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:42128 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756260AbbBEBf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:35:58 -0500
Received: by mail-ig0-f176.google.com with SMTP id hl2so39133710igb.3
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:35:58 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/fib_rules.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index e584de16e4c3..b02bd45e3e97 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -20,7 +20,8 @@ struct fib_rule {
 	/* 3 bytes hole, try to use */
 	u32			target;
 	struct fib_rule __rcu	*ctarget;
-	struct net		*fr_net;
+	struct net_ctx		fr_net_ctx;
+#define fr_net  fr_net_ctx.net
 
 	atomic_t		refcnt;
 	u32			pref;
@@ -75,7 +76,8 @@ struct fib_rules_ops {
 	const struct nla_policy	*policy;
 	struct list_head	rules_list;
 	struct module		*owner;
-	struct net		*fro_net;
+	struct net_ctx		fro_net_ctx;
+#define fro_net  fro_net_ctx.net
 	struct rcu_head		rcu;
 };
 
-- 
1.9.3 (Apple Git-50)
