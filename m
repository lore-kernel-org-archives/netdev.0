From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 02/21] tipc: Update comments in message header include file
Date: Tue, 10 May 2011 16:44:18 -0400
Message-ID: <1305060277-15600-3-git-send-email-paul.gortmaker@windriver.com>
References: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52287 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954Ab1EJUo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:44:56 -0400
In-Reply-To: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Removes comments in TIPC's message header include file that are
outdated and/or unnecessary. Also introduces short comments (or
supplements existing ones) to better describe several set of existing
symbolic constants.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/msg.h |   89 ++++++++++++++-----------------------------------------
 1 files changed, 23 insertions(+), 66 deletions(-)

diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index de02339..d098317 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -39,41 +39,24 @@
 
 #include "bearer.h"
 
+/*
+ * Constants and routines used to read and write TIPC payload message headers
+ *
+ * Note: Some items are also used with TIPC internal message headers
+ */
+
 #define TIPC_VERSION              2
 
 /*
- *		TIPC user data message header format, version 2:
- *
- *
- *     1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0
- *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
- * w0:|vers | user  |hdr sz |n|d|s|-|          message size           |
- *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
- * w1:|mstyp| error |rer cnt|lsc|opt p|      broadcast ack no         |
- *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
- * w2:|        link level ack no      |   broadcast/link level seq no |
- *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
- * w3:|                       previous node                           |
- *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
- * w4:|                      originating port                         |
- *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
- * w5:|                      destination port                         |
- *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
- * w6:|                      originating node                         |
- *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
- * w7:|                      destination node                         |
- *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
- * w8:|            name type / transport sequence number              |
- *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
- * w9:|              name instance/multicast lower bound              |
- *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
- * wA:|                    multicast upper bound                      |
- *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
- *    /                                                               /
- *    \                           options                             \
- *    /                                                               /
- *    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
- *
+ * Payload message users are defined in TIPC's public API:
+ * - TIPC_LOW_IMPORTANCE
+ * - TIPC_MEDIUM_IMPORTANCE
+ * - TIPC_HIGH_IMPORTANCE
+ * - TIPC_CRITICAL_IMPORTANCE
+ */
+
+/*
+ * Payload message types
  */
 
 #define TIPC_CONN_MSG		0
@@ -81,6 +64,9 @@
 #define TIPC_NAMED_MSG		2
 #define TIPC_DIRECT_MSG		3
 
+/*
+ * Message header sizes
+ */
 
 #define SHORT_H_SIZE              24	/* Connected, in-cluster messages */
 #define DIR_MSG_H_SIZE            32	/* Directly addressed messages */
@@ -473,40 +459,11 @@ static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
 
 
 /*
-		TIPC internal message header format, version 2
-
-       1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-   w0:|vers |msg usr|hdr sz |n|resrv|            packet size          |
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-   w1:|m typ|      sequence gap       |       broadcast ack no        |
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-   w2:| link level ack no/bc_gap_from |     seq no / bcast_gap_to     |
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-   w3:|                       previous node                           |
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-   w4:|  next sent broadcast/fragm no | next sent pkt/ fragm msg no   |
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-   w5:|          session no           |rsv=0|r|berid|link prio|netpl|p|
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-   w6:|                      originating node                         |
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-   w7:|                      destination node                         |
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-   w8:|                   transport sequence number                   |
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-   w9:|   msg count / bcast tag       |       link tolerance          |
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-      \                                                               \
-      /                     User Specific Data                        /
-      \                                                               \
-      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-
-      NB: CONN_MANAGER use data message format. LINK_CONFIG has own format.
-*/
+ * Constants and routines used to read and write TIPC internal message headers
+ */
 
 /*
- * Internal users
+ * Internal message users
  */
 
 #define  BCAST_PROTOCOL       5
@@ -520,7 +477,7 @@ static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
 #define  LINK_CONFIG          13
 
 /*
- *  Connection management protocol messages
+ *  Connection management protocol message types
  */
 
 #define CONN_PROBE        0
@@ -528,7 +485,7 @@ static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
 #define CONN_ACK          2
 
 /*
- * Name distributor messages
+ * Name distributor message types
  */
 
 #define PUBLICATION       0
-- 
1.7.4.4

