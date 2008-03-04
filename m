From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 3/7 net-2.6.26] [TIPC]: Eliminate "sparse" symbol warnings
Date: Tue,  4 Mar 2008 16:20:15 -0500
Message-ID: <1204665619-6345-4-git-send-email-allan.stephens@windriver.com>
References: <1204665619-6345-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:48067 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759758AbYCDVgI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2008 16:36:08 -0500
In-Reply-To: <1204665619-6345-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch eliminates warnings about undeclared symbols.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 include/net/tipc/tipc_bearer.h |   10 ++++++++++
 net/tipc/core.c                |    9 ---------
 net/tipc/core.h                |    7 +++++++
 3 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/include/net/tipc/tipc_bearer.h b/include/net/tipc/tipc_bearer.h
index 2151a80..3eb02fd 100644
--- a/include/net/tipc/tipc_bearer.h
+++ b/include/net/tipc/tipc_bearer.h
@@ -100,6 +100,10 @@ struct tipc_bearer {
 };
 
 
+/*
+ * TIPC routines available to supported media types
+ */
+
 int  tipc_register_media(u32 media_type,
 			 char *media_name, 
 			 int (*enable)(struct tipc_bearer *), 
@@ -123,6 +127,12 @@ void tipc_continue(struct tipc_bearer *tb_ptr);
 int tipc_enable_bearer(const char *bearer_name, u32 bcast_scope, u32 priority);
 int tipc_disable_bearer(const char *name);
 
+/*
+ * Routines made available to TIPC by supported media types
+ */
+
+int  tipc_eth_media_start(void);
+void tipc_eth_media_stop(void);
 
 #endif
 
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 9b9429e..10209ec 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -48,15 +48,6 @@
 #include "subscr.h"
 #include "config.h"
 
-int  tipc_eth_media_start(void);
-void tipc_eth_media_stop(void);
-int  tipc_handler_start(void);
-void tipc_handler_stop(void);
-int  tipc_socket_init(void);
-void tipc_socket_stop(void);
-int  tipc_netlink_start(void);
-void tipc_netlink_stop(void);
-
 #define TIPC_MOD_VER "1.6.3"
 
 #ifndef CONFIG_TIPC_ZONES
diff --git a/net/tipc/core.h b/net/tipc/core.h
index feabca5..bc3f384 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -180,6 +180,13 @@ extern int  tipc_core_start(void);
 extern void tipc_core_stop(void);
 extern int  tipc_core_start_net(void);
 extern void tipc_core_stop_net(void);
+extern int  tipc_handler_start(void);
+extern void tipc_handler_stop(void);
+extern int  tipc_netlink_start(void);
+extern void tipc_netlink_stop(void);
+extern int  tipc_socket_init(void);
+extern void tipc_socket_stop(void);
+
 
 static inline int delimit(int val, int min, int max)
 {
-- 
1.5.3.2

