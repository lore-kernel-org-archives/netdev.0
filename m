From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 21/26] tipc: Eliminate unnecessary constant for neighbor discovery msg size
Date: Sun, 13 Mar 2011 17:34:09 -0400
Message-ID: <1300052054-7531-22-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49933 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932250Ab1CMVe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:58 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Eliminates an unnecessary constant that defines the size of a LINK_CONFIG
message, and uses one of the existing standard message size symbols in
its place. (The defunct constant was located in the wrong place anyway,
since it was grouped with other constants that define message users instead
of message sizes.)

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/discover.c |    4 ++--
 net/tipc/msg.h      |    1 -
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index caac5c9..2c14d6d 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -75,12 +75,12 @@ static struct sk_buff *tipc_disc_init_msg(u32 type,
 					  u32 dest_domain,
 					  struct tipc_bearer *b_ptr)
 {
-	struct sk_buff *buf = tipc_buf_acquire(DSC_H_SIZE);
+	struct sk_buff *buf = tipc_buf_acquire(INT_H_SIZE);
 	struct tipc_msg *msg;
 
 	if (buf) {
 		msg = buf_msg(buf);
-		tipc_msg_init(msg, LINK_CONFIG, type, DSC_H_SIZE, dest_domain);
+		tipc_msg_init(msg, LINK_CONFIG, type, INT_H_SIZE, dest_domain);
 		msg_set_non_seq(msg, 1);
 		msg_set_dest_domain(msg, dest_domain);
 		msg_set_bc_netid(msg, tipc_net_id);
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index bea0126..5006366 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -525,7 +525,6 @@ static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
 #define  NAME_DISTRIBUTOR     11
 #define  MSG_FRAGMENTER       12
 #define  LINK_CONFIG          13
-#define  DSC_H_SIZE           40
 
 /*
  *  Connection management protocol messages
-- 
1.7.3.3

