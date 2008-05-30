From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 11/13 net-next-2.6] [TIPC]: Message header creation optimizations
Date: Fri, 30 May 2008 14:20:46 -0400
Message-ID: <1212171648-27122-12-git-send-email-allan.stephens@windriver.com>
References: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50564 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753226AbYE3SXN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 14:23:13 -0400
In-Reply-To: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch eliminates several cases where message header fields
were being set to the same value twice.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/port.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index e3e9c12..93014f9 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -244,11 +244,8 @@ u32 tipc_createport_raw(void *usr_handle,
 	p_ptr->publ.max_pkt = MAX_PKT_DEFAULT;
 	p_ptr->publ.ref = ref;
 	msg = &p_ptr->publ.phdr;
-	msg_init(msg, TIPC_LOW_IMPORTANCE, TIPC_NAMED_MSG, LONG_H_SIZE, 0);
-	msg_set_orignode(msg, tipc_own_addr);
-	msg_set_prevnode(msg, tipc_own_addr);
+	msg_init(msg, importance, TIPC_NAMED_MSG, LONG_H_SIZE, 0);
 	msg_set_origport(msg, ref);
-	msg_set_importance(msg,importance);
 	p_ptr->last_in_seqno = 41;
 	p_ptr->sent = 1;
 	INIT_LIST_HEAD(&p_ptr->wait_list);
@@ -407,7 +404,6 @@ static struct sk_buff *port_build_proto_msg(u32 destport, u32 destnode,
 		msg_set_errcode(msg, err);
 		msg_set_destport(msg, destport);
 		msg_set_origport(msg, origport);
-		msg_set_destnode(msg, destnode);
 		msg_set_orignode(msg, orignode);
 		msg_set_transp_seqno(msg, seqno);
 		msg_set_msgcnt(msg, ack);
@@ -451,7 +447,6 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 	msg_init(rmsg, imp, msg_type(msg), hdr_sz, msg_orignode(msg));
 	msg_set_errcode(rmsg, err);
 	msg_set_destport(rmsg, msg_origport(msg));
-	msg_set_prevnode(rmsg, tipc_own_addr);
 	msg_set_origport(rmsg, msg_destport(msg));
 	if (msg_short(msg))
 		msg_set_orignode(rmsg, tipc_own_addr);
-- 
1.5.3.2

