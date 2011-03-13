From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 14/26] tipc: make msg_set_redundant_link() consistent with other set ops
Date: Sun, 13 Mar 2011 17:34:02 -0400
Message-ID: <1300052054-7531-15-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49905 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932222Ab1CMVes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:48 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

All the other boolean like msg_set_X(m) operations don't
export both a msg_set_X(a) and a msg_clear_X(m), but instead
just have the single msg_set_X(m, val) variant.

Make the redundant_link one consistent by having the set take
a value, and delete the msg_clear_redundant_link() anomoly.
This is a cosmetic change and should not change behaviour.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |    5 +----
 net/tipc/msg.h  |    9 ++-------
 2 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index d8a4b90..6ffae0e 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1954,10 +1954,7 @@ void tipc_link_send_proto_msg(struct link *l_ptr, u32 msg_typ, int probe_msg,
 		msg_set_max_pkt(msg, l_ptr->max_pkt_target);
 	}
 
-	if (tipc_node_redundant_links(l_ptr->owner))
-		msg_set_redundant_link(msg);
-	else
-		msg_clear_redundant_link(msg);
+	msg_set_redundant_link(msg, tipc_node_redundant_links(l_ptr->owner));
 	msg_set_linkprio(msg, l_ptr->priority);
 
 	/* Ensure sequence number will not fit : */
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 6948d3d..bea0126 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -719,14 +719,9 @@ static inline u32 msg_redundant_link(struct tipc_msg *m)
 	return msg_bits(m, 5, 12, 0x1);
 }
 
-static inline void msg_set_redundant_link(struct tipc_msg *m)
+static inline void msg_set_redundant_link(struct tipc_msg *m, u32 r)
 {
-	msg_set_bits(m, 5, 12, 0x1, 1);
-}
-
-static inline void msg_clear_redundant_link(struct tipc_msg *m)
-{
-	msg_set_bits(m, 5, 12, 0x1, 0);
+	msg_set_bits(m, 5, 12, 0x1, r);
 }
 
 
-- 
1.7.3.3

