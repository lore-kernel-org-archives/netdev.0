From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 4/7 net-2.6.26] [TIPC]: Minor cleanup of message header code
Date: Thu,  6 Mar 2008 16:34:26 -0500
Message-ID: <1204839269-30593-5-git-send-email-allan.stephens@windriver.com>
References: <1204839269-30593-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:55392 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762614AbYCFVu3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2008 16:50:29 -0500
In-Reply-To: <1204839269-30593-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch eliminates some unused or duplicate message header
symbols, and fixes up the comments and/or location of a few
other symbols.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/link.c |   16 ++++++++--------
 net/tipc/msg.c  |   16 ++++++++--------
 net/tipc/msg.h  |   19 ++++++++-----------
 net/tipc/port.c |    5 +++--
 4 files changed, 27 insertions(+), 29 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index cefa998..a42f434 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2832,15 +2832,15 @@ static void link_set_supervision_props(struct link *l_ptr, u32 tolerance)
 void tipc_link_set_queue_limits(struct link *l_ptr, u32 window)
 {
 	/* Data messages from this node, inclusive FIRST_FRAGM */
-	l_ptr->queue_limit[DATA_LOW] = window;
-	l_ptr->queue_limit[DATA_MEDIUM] = (window / 3) * 4;
-	l_ptr->queue_limit[DATA_HIGH] = (window / 3) * 5;
-	l_ptr->queue_limit[DATA_CRITICAL] = (window / 3) * 6;
+	l_ptr->queue_limit[TIPC_LOW_IMPORTANCE] = window;
+	l_ptr->queue_limit[TIPC_MEDIUM_IMPORTANCE] = (window / 3) * 4;
+	l_ptr->queue_limit[TIPC_HIGH_IMPORTANCE] = (window / 3) * 5;
+	l_ptr->queue_limit[TIPC_CRITICAL_IMPORTANCE] = (window / 3) * 6;
 	/* Transiting data messages,inclusive FIRST_FRAGM */
-	l_ptr->queue_limit[DATA_LOW + 4] = 300;
-	l_ptr->queue_limit[DATA_MEDIUM + 4] = 600;
-	l_ptr->queue_limit[DATA_HIGH + 4] = 900;
-	l_ptr->queue_limit[DATA_CRITICAL + 4] = 1200;
+	l_ptr->queue_limit[TIPC_LOW_IMPORTANCE + 4] = 300;
+	l_ptr->queue_limit[TIPC_MEDIUM_IMPORTANCE + 4] = 600;
+	l_ptr->queue_limit[TIPC_HIGH_IMPORTANCE + 4] = 900;
+	l_ptr->queue_limit[TIPC_CRITICAL_IMPORTANCE + 4] = 1200;
 	l_ptr->queue_limit[CONN_MANAGER] = 1200;
 	l_ptr->queue_limit[ROUTE_DISTRIBUTOR] = 1200;
 	l_ptr->queue_limit[CHANGEOVER_PROTOCOL] = 2500;
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 7824854..696a863 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -73,10 +73,10 @@ void tipc_msg_print(struct print_buf *buf, struct tipc_msg *msg, const char *str
 		tipc_printf(buf, "NO(%u/%u):",msg_long_msgno(msg),
 			    msg_fragm_no(msg));
 		break;
-	case DATA_LOW:
-	case DATA_MEDIUM:
-	case DATA_HIGH:
-	case DATA_CRITICAL:
+	case TIPC_LOW_IMPORTANCE:
+	case TIPC_MEDIUM_IMPORTANCE:
+	case TIPC_HIGH_IMPORTANCE:
+	case TIPC_CRITICAL_IMPORTANCE:
 		tipc_printf(buf, "DAT%u:", msg_user(msg));
 		if (msg_short(msg)) {
 			tipc_printf(buf, "CON:");
@@ -229,10 +229,10 @@ void tipc_msg_print(struct print_buf *buf, struct tipc_msg *msg, const char *str
 	switch (usr) {
 	case CONN_MANAGER:
 	case NAME_DISTRIBUTOR:
-	case DATA_LOW:
-	case DATA_MEDIUM:
-	case DATA_HIGH:
-	case DATA_CRITICAL:
+	case TIPC_LOW_IMPORTANCE:
+	case TIPC_MEDIUM_IMPORTANCE:
+	case TIPC_HIGH_IMPORTANCE:
+	case TIPC_CRITICAL_IMPORTANCE:
 		if (msg_short(msg))
 			break;	/* No error */
 		switch (msg_errcode(msg)) {
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 12f8945..5cf76a4 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -40,18 +40,16 @@
 #include "core.h"
 
 #define TIPC_VERSION              2
-#define DATA_LOW                  TIPC_LOW_IMPORTANCE
-#define DATA_MEDIUM               TIPC_MEDIUM_IMPORTANCE
-#define DATA_HIGH                 TIPC_HIGH_IMPORTANCE
-#define DATA_CRITICAL             TIPC_CRITICAL_IMPORTANCE
-#define SHORT_H_SIZE              24	/* Connected,in cluster */
+
+#define SHORT_H_SIZE              24	/* Connected, in-cluster messages */
 #define DIR_MSG_H_SIZE            32	/* Directly addressed messages */
-#define CONN_MSG_H_SIZE           36	/* Routed connected msgs*/
-#define LONG_H_SIZE               40	/* Named Messages */
+#define LONG_H_SIZE               40	/* Named messages */
 #define MCAST_H_SIZE              44	/* Multicast messages */
-#define MAX_H_SIZE                60	/* Inclusive full options */
+#define INT_H_SIZE                40	/* Internal messages */
+#define MIN_H_SIZE                24	/* Smallest legal TIPC header size */
+#define MAX_H_SIZE                60	/* Largest possible TIPC header size */
+
 #define MAX_MSG_SIZE (MAX_H_SIZE + TIPC_MAX_USER_MSG_SIZE)
-#define LINK_CONFIG               13
 
 
 /*
@@ -97,7 +95,7 @@ static inline u32 msg_user(struct tipc_msg *m)
 
 static inline u32 msg_isdata(struct tipc_msg *m)
 {
-	return (msg_user(m) <= DATA_CRITICAL);
+	return (msg_user(m) <= TIPC_CRITICAL_IMPORTANCE);
 }
 
 static inline void msg_set_user(struct tipc_msg *m, u32 n)
@@ -365,7 +363,6 @@ static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
 #define  NAME_DISTRIBUTOR     11
 #define  MSG_FRAGMENTER       12
 #define  LINK_CONFIG          13
-#define  INT_H_SIZE           40
 #define  DSC_H_SIZE           40
 
 /*
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 2a16ca4..e2646a9 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -242,7 +242,8 @@ u32 tipc_createport_raw(void *usr_handle,
 	p_ptr->publ.max_pkt = MAX_PKT_DEFAULT;
 	p_ptr->publ.ref = ref;
 	msg = &p_ptr->publ.phdr;
-	msg_init(msg, DATA_LOW, TIPC_NAMED_MSG, TIPC_OK, LONG_H_SIZE, 0);
+	msg_init(msg, TIPC_LOW_IMPORTANCE, TIPC_NAMED_MSG, TIPC_OK, LONG_H_SIZE,
+		 0);
 	msg_set_orignode(msg, tipc_own_addr);
 	msg_set_prevnode(msg, tipc_own_addr);
 	msg_set_origport(msg, ref);
@@ -625,7 +626,7 @@ void tipc_port_recv_proto_msg(struct sk_buff *buf)
 					     msg_orignode(msg),
 					     msg_destport(msg),
 					     tipc_own_addr,
-					     DATA_HIGH,
+					     TIPC_HIGH_IMPORTANCE,
 					     TIPC_CONN_MSG,
 					     err,
 					     0,
-- 
1.5.3.2

