From: Thomas Graf <tgraf@suug.ch>
Subject: [IPv6] fib: initialize tb6_lock in common place to give lockdep a key
Date: Fri, 20 Oct 2006 14:42:04 +0200
Message-ID: <20061020124204.GW12964@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:37039 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751652AbWJTMln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 08:41:43 -0400
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/ipv6/ip6_fib.c
===================================================================
--- net-2.6.orig/net/ipv6/ip6_fib.c	2006-10-20 12:33:57.000000000 +0200
+++ net-2.6/net/ipv6/ip6_fib.c	2006-10-20 12:39:13.000000000 +0200
@@ -169,7 +169,6 @@
 
 static struct fib6_table fib6_main_tbl = {
 	.tb6_id		= RT6_TABLE_MAIN,
-	.tb6_lock	= RW_LOCK_UNLOCKED,
 	.tb6_root	= {
 		.leaf		= &ip6_null_entry,
 		.fn_flags	= RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO,
@@ -187,6 +186,12 @@
 {
 	unsigned int h;
 
+	/*
+	 * Initialize table lock at a single place to give lockdep a key,
+	 * tables aren't visible prior to being linked to the list.
+	 */
+	rwlock_init(&tb->tb6_lock);
+
 	h = tb->tb6_id & (FIB_TABLE_HASHSZ - 1);
 
 	/*
@@ -199,7 +204,6 @@
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 static struct fib6_table fib6_local_tbl = {
 	.tb6_id		= RT6_TABLE_LOCAL,
-	.tb6_lock	= RW_LOCK_UNLOCKED,
 	.tb6_root 	= {
 		.leaf		= &ip6_null_entry,
 		.fn_flags	= RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO,
@@ -213,7 +217,6 @@
 	table = kzalloc(sizeof(*table), GFP_ATOMIC);
 	if (table != NULL) {
 		table->tb6_id = id;
-		table->tb6_lock = RW_LOCK_UNLOCKED;
 		table->tb6_root.leaf = &ip6_null_entry;
 		table->tb6_root.fn_flags = RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO;
 	}
