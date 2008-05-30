From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 10/13 net-next-2.6] [TIPC]: Expand link sequence gap field to 13 bits
Date: Fri, 30 May 2008 14:20:45 -0400
Message-ID: <1212171648-27122-11-git-send-email-allan.stephens@windriver.com>
References: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50555 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752956AbYE3SXM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 14:23:12 -0400
In-Reply-To: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch increases the "sequence gap" field of the LINK_PROTOCOL
message header from 8 bits to 13 bits (utilizing 5 previously
unused 0 bits).  This ensures that the field is big enough to
indicate the loss of up to 8191 consecutive messages on the link,
thereby accommodating the current worst-case scenario of 4000
lost messages.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/msg.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 3418ffa..b23619f 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -2,7 +2,7 @@
  * net/tipc/msg.h: Include file for TIPC message header routines
  *
  * Copyright (c) 2000-2007, Ericsson AB
- * Copyright (c) 2005-2007, Wind River Systems
+ * Copyright (c) 2005-2008, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -325,7 +325,7 @@ static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    w0:|vers |msg usr|hdr sz |n|resrv|            packet size          |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-   w1:|m typ|rsv=0|   sequence gap    |       broadcast ack no        |
+   w1:|m typ|      sequence gap       |       broadcast ack no        |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    w2:| link level ack no/bc_gap_from |     seq no / bcast_gap_to     |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
@@ -388,12 +388,12 @@ static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
 
 static inline u32 msg_seq_gap(struct tipc_msg *m)
 {
-	return msg_bits(m, 1, 16, 0xff);
+	return msg_bits(m, 1, 16, 0x1fff);
 }
 
 static inline void msg_set_seq_gap(struct tipc_msg *m, u32 n)
 {
-	msg_set_bits(m, 1, 16, 0xff, n);
+	msg_set_bits(m, 1, 16, 0x1fff, n);
 }
 
 static inline u32 msg_req_links(struct tipc_msg *m)
-- 
1.5.3.2

