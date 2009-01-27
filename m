From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFT 1/4] netfilter: change elements in x_tables
Date: Tue, 27 Jan 2009 15:53:11 -0800
Message-ID: <20090127235508.704420370@vyatta.com>
References: <20090127235310.159946902@vyatta.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:40009 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751212AbZA0X5t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2009 18:57:49 -0500
Content-Disposition: inline; filename=x_tables.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change to proper type on private pointer rather than anonymous void.
Keep active elements on same cache line.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 include/linux/netfilter/x_tables.h |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

--- a/include/linux/netfilter/x_tables.h	2009-01-26 17:24:43.251543415 -0800
+++ b/include/linux/netfilter/x_tables.h	2009-01-26 17:29:12.510649107 -0800
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

-- 

