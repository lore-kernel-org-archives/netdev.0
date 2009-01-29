From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/6] netfilter: change elements in x_tables
Date: Thu, 29 Jan 2009 11:12:40 -0800
Message-ID: <20090129191520.012734381@vyatta.com>
References: <20090129191239.483204605@vyatta.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=x_tables.patch
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

