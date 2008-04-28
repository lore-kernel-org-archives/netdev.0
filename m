From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 6/9 net-next-2.6] [TIPC]: Cosmetic cleanup of print buffer code
Date: Mon, 28 Apr 2008 15:48:43 -0400
Message-ID: <1209412126-2109-7-git-send-email-allan.stephens@windriver.com>
References: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33683 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934197AbYD1TwF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 15:52:05 -0400
In-Reply-To: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch contains changes to make TIPC's print buffer code
conform more closely to Linux kernel coding guidelines.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/core.h |    6 ++++--
 net/tipc/dbg.c  |   14 +++++++-------
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index 7042ef3..bc63355 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -2,7 +2,7 @@
  * net/tipc/core.h: Include file for TIPC global declarations
  *
  * Copyright (c) 2005-2006, Ericsson AB
- * Copyright (c) 2005-2006, Wind River Systems
+ * Copyright (c) 2005-2007, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -65,7 +65,9 @@
 #define assert(i)  BUG_ON(!(i))
 
 struct tipc_msg;
-extern struct print_buf *TIPC_NULL, *TIPC_CONS, *TIPC_LOG;
+extern struct print_buf *const TIPC_NULL;
+extern struct print_buf *const TIPC_CONS;
+extern struct print_buf *const TIPC_LOG;
 void tipc_msg_print(struct print_buf*,struct tipc_msg *,const char*);
 void tipc_printf(struct print_buf *, const char *fmt, ...);
 void tipc_dump(struct print_buf*,const char *fmt, ...);
diff --git a/net/tipc/dbg.c b/net/tipc/dbg.c
index 8ca9457..cda4968 100644
--- a/net/tipc/dbg.c
+++ b/net/tipc/dbg.c
@@ -49,13 +49,13 @@
  */
 
 static struct print_buf null_buf = { NULL, 0, NULL, 0 };
-struct print_buf *TIPC_NULL = &null_buf;
+struct print_buf *const TIPC_NULL = &null_buf;
 
 static struct print_buf cons_buf = { NULL, 0, NULL, 1 };
-struct print_buf *TIPC_CONS = &cons_buf;
+struct print_buf *const TIPC_CONS = &cons_buf;
 
 static struct print_buf log_buf = { NULL, 0, NULL, 1 };
-struct print_buf *TIPC_LOG = &log_buf;
+struct print_buf *const TIPC_LOG = &log_buf;
 
 /*
  * Locking policy when using print buffers.
@@ -107,7 +107,7 @@ void tipc_printbuf_init(struct print_buf *pb, char *raw, u32 size)
 		pb->buf = NULL;
 	} else if (raw) {
 		pb->buf[0] = 0;
-		pb->buf[size-1] = ~0;
+		pb->buf[size - 1] = ~0;
 	}
 }
 
@@ -118,7 +118,7 @@ void tipc_printbuf_init(struct print_buf *pb, char *raw, u32 size)
 
 void tipc_printbuf_reset(struct print_buf *pb)
 {
-	if (pb->buf != NULL) {
+	if (pb->buf) {
 		pb->crs = pb->buf;
 		pb->buf[0] = 0;
 		pb->buf[pb->size - 1] = ~0;
@@ -158,7 +158,7 @@ int tipc_printbuf_validate(struct print_buf *pb)
 
 	if (pb->buf[pb->size - 1] == 0) {
 		cp_buf = kmalloc(pb->size, GFP_ATOMIC);
-		if (cp_buf != NULL){
+		if (cp_buf) {
 			tipc_printbuf_init(&cb, cp_buf, pb->size);
 			tipc_printbuf_move(&cb, pb);
 			tipc_printbuf_move(pb, &cb);
@@ -205,7 +205,7 @@ void tipc_printbuf_move(struct print_buf *pb_to, struct print_buf *pb_from)
 	/* Copy data from char after cursor to end (if used) */
 
 	len = pb_from->buf + pb_from->size - pb_from->crs - 2;
-	if ((pb_from->buf[pb_from->size-1] == 0) && (len > 0)) {
+	if ((pb_from->buf[pb_from->size - 1] == 0) && (len > 0)) {
 		strcpy(pb_to->buf, pb_from->crs + 1);
 		pb_to->crs = pb_to->buf + len;
 	} else
-- 
1.5.3.2

