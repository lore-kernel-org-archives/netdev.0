From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] fib: fib_rules_cleanup can be static
Date: Tue, 5 Oct 2010 15:14:17 +0900
Message-ID: <20101005151417.57eae0b0@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47697 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754548Ab0JEGOW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Oct 2010 02:14:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib_rules_cleanup_ups is only defined and used in one place.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/net/fib_rules.h	2010-10-02 14:31:52.528341728 +0900
+++ b/include/net/fib_rules.h	2010-10-02 14:31:59.890839969 +0900
@@ -106,7 +106,6 @@ static inline u32 frh_get_table(struct f
 
 extern struct fib_rules_ops *fib_rules_register(const struct fib_rules_ops *, struct net *);
 extern void fib_rules_unregister(struct fib_rules_ops *);
-extern void                     fib_rules_cleanup_ops(struct fib_rules_ops *);
 
 extern int			fib_rules_lookup(struct fib_rules_ops *,
 						 struct flowi *, int flags,
--- a/net/core/fib_rules.c	2010-10-02 14:31:52.578341727 +0900
+++ b/net/core/fib_rules.c	2010-10-02 14:32:09.850842358 +0900
@@ -144,7 +144,7 @@ fib_rules_register(const struct fib_rule
 }
 EXPORT_SYMBOL_GPL(fib_rules_register);
 
-void fib_rules_cleanup_ops(struct fib_rules_ops *ops)
+static void fib_rules_cleanup_ops(struct fib_rules_ops *ops)
 {
 	struct fib_rule *rule, *tmp;
 
@@ -153,7 +153,6 @@ void fib_rules_cleanup_ops(struct fib_ru
 		fib_rule_put(rule);
 	}
 }
-EXPORT_SYMBOL_GPL(fib_rules_cleanup_ops);
 
 static void fib_rules_put_rcu(struct rcu_head *head)
 {
