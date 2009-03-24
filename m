From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/41: x_tables: change elements in x_tables
Date: Tue, 24 Mar 2009 15:03:10 +0100 (MET)
Message-ID: <20090324140306.31401.91924.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34743 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756831AbZCXODN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:03:13 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 4a2f965ca5a4e2593744bf75425d85e0e8ff814a
Author: Stephen Hemminger <shemminger@vyatta.com>
Date:   Wed Feb 18 16:29:44 2009 +0100

    netfilter: x_tables: change elements in x_tables
    
    Change to proper type on private pointer rather than anonymous void.
    Keep active elements on same cache line.
    
    Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index c7ee874..9fac88f 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -349,9 +349,6 @@ struct xt_table
 {
 	struct list_head list;
 
-	/* A unique name... */
-	const char name[XT_TABLE_MAXNAMELEN];
-
 	/* What hooks you will enter on */
 	unsigned int valid_hooks;
 
@@ -359,13 +356,15 @@ struct xt_table
 	rwlock_t lock;
 
 	/* Man behind the curtain... */
-	//struct ip6t_table_info *private;
-	void *private;
+	struct xt_table_info *private;
 
 	/* Set this to THIS_MODULE if you are a module, otherwise NULL */
 	struct module *me;
 
 	u_int8_t af;		/* address/protocol family */
+
+	/* A unique name... */
+	const char name[XT_TABLE_MAXNAMELEN];
 };
 
 #include <linux/netfilter_ipv4.h>
