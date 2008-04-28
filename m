From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 7/9 net-next-2.6] [TIPC]: Cosmetic cleanup of system & debug output declarations
Date: Mon, 28 Apr 2008 15:48:44 -0400
Message-ID: <1209412126-2109-8-git-send-email-allan.stephens@windriver.com>
References: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33691 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934079AbYD1TwG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 15:52:06 -0400
In-Reply-To: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch contains changes to make TIPC's system & debug
message declarations more readable.  Declarations have been
regrouped and recommented to make it easier to understand
what output is generated in both standard and debugging modes.
In addition, oversize lines have been fixed to respect the
80 character upper bound used in the kernel.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/core.h |  117 +++++++++++++++++++++++++++++++-----------------------
 1 files changed, 67 insertions(+), 50 deletions(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index bc63355..d7f3b3c 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -59,87 +59,104 @@
 #include <linux/vmalloc.h>
 
 /*
- * TIPC debugging code
+ * TIPC sanity test macros
  */
 
 #define assert(i)  BUG_ON(!(i))
 
-struct tipc_msg;
-extern struct print_buf *const TIPC_NULL;
-extern struct print_buf *const TIPC_CONS;
-extern struct print_buf *const TIPC_LOG;
-void tipc_msg_print(struct print_buf*,struct tipc_msg *,const char*);
-void tipc_printf(struct print_buf *, const char *fmt, ...);
-void tipc_dump(struct print_buf*,const char *fmt, ...);
-
-#ifdef CONFIG_TIPC_DEBUG
-
 /*
- * TIPC debug support included:
- * - system messages are printed to TIPC_OUTPUT print buffer
- * - debug messages are printed to DBG_OUTPUT print buffer
+ * TIPC system monitoring code
  */
 
-#define err(fmt, arg...)  tipc_printf(TIPC_OUTPUT, KERN_ERR "TIPC: " fmt, ## arg)
-#define warn(fmt, arg...) tipc_printf(TIPC_OUTPUT, KERN_WARNING "TIPC: " fmt, ## arg)
-#define info(fmt, arg...) tipc_printf(TIPC_OUTPUT, KERN_NOTICE "TIPC: " fmt, ## arg)
-
-#define dbg(fmt, arg...)  do {if (DBG_OUTPUT != TIPC_NULL) tipc_printf(DBG_OUTPUT, fmt, ## arg);} while(0)
-#define msg_dbg(msg, txt) do {if (DBG_OUTPUT != TIPC_NULL) tipc_msg_print(DBG_OUTPUT, msg, txt);} while(0)
-#define dump(fmt, arg...) do {if (DBG_OUTPUT != TIPC_NULL) tipc_dump(DBG_OUTPUT, fmt, ##arg);} while(0)
-
-
 /*
- * By default, TIPC_OUTPUT is defined to be system console and TIPC log buffer,
- * while DBG_OUTPUT is the null print buffer.  These defaults can be changed
- * here, or on a per .c file basis, by redefining these symbols.  The following
- * print buffer options are available:
+ * TIPC's print buffer subsystem supports the following print buffers:
  *
- * TIPC_NULL		   : null buffer (i.e. print nowhere)
- * TIPC_CONS		   : system console
- * TIPC_LOG		   : TIPC log buffer
- * &buf			   : user-defined buffer (struct print_buf *)
+ * TIPC_NULL : null buffer (i.e. print nowhere)
+ * TIPC_CONS : system console
+ * TIPC_LOG  : TIPC log buffer
+ * &buf	     : user-defined buffer (struct print_buf *)
  *
  * Note: TIPC_LOG is configured to echo its output to the system console;
  *       user-defined buffers can be configured to do the same thing.
  */
 
+extern struct print_buf *const TIPC_NULL;
+extern struct print_buf *const TIPC_CONS;
+extern struct print_buf *const TIPC_LOG;
+
+void tipc_printf(struct print_buf *, const char *fmt, ...);
+void tipc_msg_print(struct print_buf *, struct tipc_msg *, const char *);
+void tipc_dump(struct print_buf *, const char *fmt, ...);
+
+/*
+ * TIPC_OUTPUT is the destination print buffer for system messages.
+ */
+
 #ifndef TIPC_OUTPUT
 #define TIPC_OUTPUT TIPC_LOG
 #endif
 
-#ifndef DBG_OUTPUT
-#define DBG_OUTPUT TIPC_NULL
-#endif
-
-#else
-
 /*
- * TIPC debug support not included:
- * - system messages are printed to system console
- * - debug messages are not printed
+ * TIPC can be configured to send system messages to TIPC_OUTPUT
+ * or to the system console only.
  */
 
+#ifdef CONFIG_TIPC_DEBUG
+
+#define err(fmt, arg...)  tipc_printf(TIPC_OUTPUT, \
+					KERN_ERR "TIPC: " fmt, ## arg)
+#define warn(fmt, arg...) tipc_printf(TIPC_OUTPUT, \
+					KERN_WARNING "TIPC: " fmt, ## arg)
+#define info(fmt, arg...) tipc_printf(TIPC_OUTPUT, \
+					KERN_NOTICE "TIPC: " fmt, ## arg)
+
+#else
+
 #define err(fmt, arg...)  printk(KERN_ERR "TIPC: " fmt , ## arg)
 #define info(fmt, arg...) printk(KERN_INFO "TIPC: " fmt , ## arg)
 #define warn(fmt, arg...) printk(KERN_WARNING "TIPC: " fmt , ## arg)
 
-#define dbg(fmt, arg...) do {} while (0)
-#define msg_dbg(msg,txt) do {} while (0)
-#define dump(fmt,arg...) do {} while (0)
+#endif
 
+/*
+ * DBG_OUTPUT is the destination print buffer for debug messages.
+ * It defaults to the the null print buffer, but can be redefined
+ * (typically in the individual .c files being debugged) to allow
+ * selected debug messages to be generated where needed.
+ */
+
+#ifndef DBG_OUTPUT
+#define DBG_OUTPUT TIPC_NULL
+#endif
 
 /*
- * TIPC_OUTPUT is defined to be the system console, while DBG_OUTPUT is
- * the null print buffer.  Thes ensures that any system or debug messages
- * that are generated without using the above macros are handled correctly.
+ * TIPC can be configured to send debug messages to the specified print buffer
+ * (typically DBG_OUTPUT) or to suppress them entirely.
  */
 
-#undef  TIPC_OUTPUT
-#define TIPC_OUTPUT TIPC_CONS
+#ifdef CONFIG_TIPC_DEBUG
 
-#undef  DBG_OUTPUT
-#define DBG_OUTPUT TIPC_NULL
+#define dbg(fmt, arg...)  \
+	do { \
+		if (DBG_OUTPUT != TIPC_NULL) \
+			tipc_printf(DBG_OUTPUT, fmt, ## arg); \
+	} while (0)
+#define msg_dbg(msg, txt) \
+	do { \
+		if (DBG_OUTPUT != TIPC_NULL) \
+			tipc_msg_print(DBG_OUTPUT, msg, txt); \
+	} while (0)
+#define dump(fmt, arg...) \
+	do { \
+		if (DBG_OUTPUT != TIPC_NULL) \
+			tipc_dump(DBG_OUTPUT, fmt, ##arg); \
+	} while (0)
+
+#else
+
+#define dbg(fmt, arg...)	do {} while (0)
+#define msg_dbg(msg, txt)	do {} while (0)
+#define dump(fmt, arg...)	do {} while (0)
 
 #endif
 
-- 
1.5.3.2

