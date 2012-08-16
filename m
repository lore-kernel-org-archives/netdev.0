From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 7/9] tipc: add __read_mostly annotations to several global variables
Date: Thu, 16 Aug 2012 18:09:12 -0400
Message-ID: <1345154954-12526-8-git-send-email-paul.gortmaker@windriver.com>
References: <1345154954-12526-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57503 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752661Ab2HPWOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 18:14:54 -0400
In-Reply-To: <1345154954-12526-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

Added to the following:

 - tipc_random
 - tipc_own_addr
 - tipc_max_ports
 - tipc_net_id
 - tipc_remote_management
 - handler_enabled

The above global variables are read often, but written rarely. Use
__read_mostly to prevent them being on the same cacheline as another
variable which is written to often, which would cause cacheline
bouncing.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/core.c    | 10 +++++-----
 net/tipc/core.h    | 10 +++++-----
 net/tipc/handler.c |  2 +-
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index daae7f7..b858f20 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -48,15 +48,15 @@
 
 
 /* global variables used by multiple sub-systems within TIPC */
-int tipc_random;
+int tipc_random __read_mostly;
 
 /* configurable TIPC parameters */
-u32 tipc_own_addr;
-int tipc_max_ports;
+u32 tipc_own_addr __read_mostly;
+int tipc_max_ports __read_mostly;
 int tipc_max_subscriptions;
 int tipc_max_publications;
-int tipc_net_id;
-int tipc_remote_management;
+int tipc_net_id __read_mostly;
+int tipc_remote_management __read_mostly;
 
 
 /**
diff --git a/net/tipc/core.h b/net/tipc/core.h
index e4e46cd..4c5705a 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -74,17 +74,17 @@ int tipc_snprintf(char *buf, int len, const char *fmt, ...);
 /*
  * Global configuration variables
  */
-extern u32 tipc_own_addr;
-extern int tipc_max_ports;
+extern u32 tipc_own_addr __read_mostly;
+extern int tipc_max_ports __read_mostly;
 extern int tipc_max_subscriptions;
 extern int tipc_max_publications;
-extern int tipc_net_id;
-extern int tipc_remote_management;
+extern int tipc_net_id __read_mostly;
+extern int tipc_remote_management __read_mostly;
 
 /*
  * Other global variables
  */
-extern int tipc_random;
+extern int tipc_random __read_mostly;
 
 /*
  * Routines available to privileged subsystems
diff --git a/net/tipc/handler.c b/net/tipc/handler.c
index 7a52d39..111ff83 100644
--- a/net/tipc/handler.c
+++ b/net/tipc/handler.c
@@ -45,7 +45,7 @@ struct queue_item {
 static struct kmem_cache *tipc_queue_item_cache;
 static struct list_head signal_queue_head;
 static DEFINE_SPINLOCK(qitem_lock);
-static int handler_enabled;
+static int handler_enabled __read_mostly;
 
 static void process_signal_queue(unsigned long dummy);
 
-- 
1.7.11.1
