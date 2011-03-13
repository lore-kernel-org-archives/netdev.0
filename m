From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 12/26] tipc: Eliminate timestamp from link protocol messages
Date: Sun, 13 Mar 2011 17:34:00 -0400
Message-ID: <1300052054-7531-13-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49897 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932215Ab1CMVeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:46 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Removes support for the timestamp field of TIPC's link protocol messages.

This field was previously used to hold an OS-dependent timestamp value
that was used to assist in debugging early versions of TIPC. The field
has now been deemed unnecessary and has been removed from the latest TIPC
specification. This change has no impact on the operation of TIPC since
the field was set by TIPC, but never referenced.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |    1 -
 net/tipc/msg.c  |    1 -
 net/tipc/msg.h  |   10 ----------
 3 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 89fbb6d..d4f2780 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1977,7 +1977,6 @@ void tipc_link_send_proto_msg(struct link *l_ptr, u32 msg_typ, int probe_msg,
 		skb_copy_to_linear_data(buf, msg, sizeof(l_ptr->proto_msg));
 		return;
 	}
-	msg_set_timestamp(msg, jiffies_to_msecs(jiffies));
 
 	/* Message can be sent */
 
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 0787e12..b694c9a 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -238,7 +238,6 @@ void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 			tipc_printf(buf, "REROUTED(%u):", msg_reroute_cnt(msg));
 		break;
 	case LINK_PROTOCOL:
-		tipc_printf(buf, "PROT:TIM(%u):", msg_timestamp(msg));
 		switch (msg_type(msg)) {
 		case STATE_MSG:
 			tipc_printf(buf, "STATE:");
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 9d643a1..6948d3d 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -438,16 +438,6 @@ static inline void msg_set_nametype(struct tipc_msg *m, u32 n)
 	msg_set_word(m, 8, n);
 }
 
-static inline void msg_set_timestamp(struct tipc_msg *m, u32 n)
-{
-	msg_set_word(m, 8, n);
-}
-
-static inline u32 msg_timestamp(struct tipc_msg *m)
-{
-	return msg_word(m, 8);
-}
-
 static inline u32 msg_nameinst(struct tipc_msg *m)
 {
 	return msg_word(m, 9);
-- 
1.7.3.3

