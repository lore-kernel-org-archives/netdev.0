From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 8/32] [TIPC] Allow compilation when CONFIG_TIPC_DEBUG is not set.
Date: Thu, 22 Jun 2006 15:59:21 +0200
Message-ID: <11509847852443-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:25494 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1030644AbWFVN7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:51 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/core.h |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index 1f2e8b2..d1edb7a 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -2,7 +2,7 @@
  * net/tipc/core.h: Include file for TIPC global declarations
  * 
  * Copyright (c) 2005-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005-2006, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -111,10 +111,6 @@ #endif
 
 #else
 
-#ifndef DBG_OUTPUT
-#define DBG_OUTPUT NULL
-#endif
-
 /*
  * TIPC debug support not included:
  * - system messages are printed to system console
@@ -129,6 +125,19 @@ #define dbg(fmt, arg...) do {} while (0)
 #define msg_dbg(msg,txt) do {} while (0)
 #define dump(fmt,arg...) do {} while (0)
 
+
+/*	
+ * TIPC_OUTPUT is defined to be the system console, while DBG_OUTPUT is
+ * the null print buffer.  Thes ensures that any system or debug messages 
+ * that are generated without using the above macros are handled correctly.
+ */
+
+#undef  TIPC_OUTPUT
+#define TIPC_OUTPUT TIPC_CONS
+
+#undef  DBG_OUTPUT
+#define DBG_OUTPUT NULL
+
 #endif			  
 
 
-- 
1.4.0

