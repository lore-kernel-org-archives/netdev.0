From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 04/21] tipc: Cosmetic consolidation of internal message type definitions
Date: Tue, 10 May 2011 16:44:20 -0400
Message-ID: <1305060277-15600-5-git-send-email-paul.gortmaker@windriver.com>
References: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52295 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752496Ab1EJUo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:44:58 -0400
In-Reply-To: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Half of the #define entries in msg.h were down at the bottom
of the header, instead of up at the top before any of the static
inlines etc.   Relocate them up to the top, to be consistent with
the other normal linux header file layout conventions.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/msg.h |   58 ++++++++++++++++++++++++++++----------------------------
 1 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index c5593ac..005b318 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -491,6 +491,35 @@ static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
 #define PUBLICATION       0
 #define WITHDRAWAL        1
 
+/*
+ * Segmentation message types
+ */
+
+#define FIRST_FRAGMENT		0
+#define FRAGMENT		1
+#define LAST_FRAGMENT		2
+
+/*
+ * Link management protocol message types
+ */
+
+#define STATE_MSG		0
+#define RESET_MSG		1
+#define ACTIVATE_MSG		2
+
+/*
+ * Changeover tunnel message types
+ */
+#define DUPLICATE_MSG		0
+#define ORIGINAL_MSG		1
+
+/*
+ * Config protocol message types
+ */
+
+#define DSC_REQ_MSG		0
+#define DSC_RESP_MSG		1
+
 
 /*
  * Word 1
@@ -718,35 +747,6 @@ static inline void msg_set_link_tolerance(struct tipc_msg *m, u32 n)
 	msg_set_bits(m, 9, 0, 0xffff, n);
 }
 
-/*
- * Segmentation message types
- */
-
-#define FIRST_FRAGMENT     0
-#define FRAGMENT           1
-#define LAST_FRAGMENT      2
-
-/*
- * Link management protocol message types
- */
-
-#define STATE_MSG       0
-#define RESET_MSG       1
-#define ACTIVATE_MSG    2
-
-/*
- * Changeover tunnel message types
- */
-#define DUPLICATE_MSG    0
-#define ORIGINAL_MSG     1
-
-/*
- * Config protocol message types
- */
-
-#define DSC_REQ_MSG          0
-#define DSC_RESP_MSG         1
-
 u32 tipc_msg_tot_importance(struct tipc_msg *m);
 void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type,
 			    u32 hsize, u32 destnode);
-- 
1.7.4.4

