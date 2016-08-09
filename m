From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: Remove fib_local variable
Date: Tue,  9 Aug 2016 06:51:06 -0700
Message-ID: <1470750666-28053-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33466 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932398AbcHINvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 09:51:18 -0400
Received: by mail-pf0-f176.google.com with SMTP id y134so5437040pfg.0
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 06:51:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 0ddcf43d5d4a ("ipv4: FIB Local/MAIN table collapse")
fib_local is set but not used. Remove it.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/netns/ipv4.h | 1 -
 net/ipv4/fib_frontend.c  | 7 -------
 2 files changed, 8 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index d061ffeb1e71..7adf4386ac8f 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -40,7 +40,6 @@ struct netns_ipv4 {
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	struct fib_rules_ops	*rules_ops;
 	bool			fib_has_custom_rules;
-	struct fib_table __rcu	*fib_local;
 	struct fib_table __rcu	*fib_main;
 	struct fib_table __rcu	*fib_default;
 #endif
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index ef2ebeb89d0f..317c31939732 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -93,9 +93,6 @@ struct fib_table *fib_new_table(struct net *net, u32 id)
 		return NULL;
 
 	switch (id) {
-	case RT_TABLE_LOCAL:
-		rcu_assign_pointer(net->ipv4.fib_local, tb);
-		break;
 	case RT_TABLE_MAIN:
 		rcu_assign_pointer(net->ipv4.fib_main, tb);
 		break;
@@ -137,9 +134,6 @@ static void fib_replace_table(struct net *net, struct fib_table *old,
 {
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	switch (new->tb_id) {
-	case RT_TABLE_LOCAL:
-		rcu_assign_pointer(net->ipv4.fib_local, new);
-		break;
 	case RT_TABLE_MAIN:
 		rcu_assign_pointer(net->ipv4.fib_main, new);
 		break;
@@ -1249,7 +1243,6 @@ static void ip_fib_net_exit(struct net *net)
 
 	rtnl_lock();
 #ifdef CONFIG_IP_MULTIPLE_TABLES
-	RCU_INIT_POINTER(net->ipv4.fib_local, NULL);
 	RCU_INIT_POINTER(net->ipv4.fib_main, NULL);
 	RCU_INIT_POINTER(net->ipv4.fib_default, NULL);
 #endif
-- 
2.1.4
