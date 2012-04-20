From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 10/16] tipc: delete duplicate peerport/peernode helper functions
Date: Fri, 20 Apr 2012 17:05:18 -0400
Message-ID: <1334955924-907-11-git-send-email-paul.gortmaker@windriver.com>
References: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:62199 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754422Ab2DTVFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 17:05:39 -0400
In-Reply-To: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Prior to commit 23dd4cce387124ec3ea06ca30d17854ae4d9b772

    "tipc: Combine port structure with tipc_port structure"

there was a need for the two sets of helper functions.  But
now they are just duplicates.  Remove the globally visible
ones, and mark the remaining ones as inline.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |    8 ++++----
 net/tipc/port.h |   10 ----------
 2 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 3b7162c..f1f6b33 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -59,12 +59,12 @@ static struct sk_buff *port_build_peer_abort_msg(struct tipc_port *, u32 err);
 static void port_timeout(unsigned long ref);
 
 
-static u32 port_peernode(struct tipc_port *p_ptr)
+static inline u32 port_peernode(struct tipc_port *p_ptr)
 {
 	return msg_destnode(&p_ptr->phdr);
 }
 
-static u32 port_peerport(struct tipc_port *p_ptr)
+static inline u32 port_peerport(struct tipc_port *p_ptr)
 {
 	return msg_destport(&p_ptr->phdr);
 }
@@ -1159,9 +1159,9 @@ int tipc_port_recv_msg(struct sk_buff *buf)
 	if (likely(p_ptr)) {
 		if (likely(p_ptr->connected)) {
 			if ((unlikely(msg_origport(msg) !=
-				      tipc_peer_port(p_ptr))) ||
+				      port_peerport(p_ptr))) ||
 			    (unlikely(msg_orignode(msg) !=
-				      tipc_peer_node(p_ptr))) ||
+				      port_peernode(p_ptr))) ||
 			    (unlikely(!msg_connected(msg)))) {
 				err = TIPC_ERR_NO_PORT;
 				tipc_port_unlock(p_ptr);
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 9b88531..0a632a6 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -257,16 +257,6 @@ static inline struct tipc_port *tipc_port_deref(u32 ref)
 	return (struct tipc_port *)tipc_ref_deref(ref);
 }
 
-static inline u32 tipc_peer_port(struct tipc_port *p_ptr)
-{
-	return msg_destport(&p_ptr->phdr);
-}
-
-static inline u32 tipc_peer_node(struct tipc_port *p_ptr)
-{
-	return msg_destnode(&p_ptr->phdr);
-}
-
 static inline int tipc_port_congested(struct tipc_port *p_ptr)
 {
 	return (p_ptr->sent - p_ptr->acked) >= (TIPC_FLOW_CONTROL_WIN * 2);
-- 
1.7.9.3
