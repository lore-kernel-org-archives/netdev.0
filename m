From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 16/17] tipc: Eliminate obsolete code for re-sending a message
Date: Wed, 29 Feb 2012 18:18:42 -0500
Message-ID: <1330557523-2024-17-git-send-email-paul.gortmaker@windriver.com>
References: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54003 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965160Ab2B2XTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 18:19:09 -0500
In-Reply-To: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Removes code that updated the "previous node" field of an out-going
message over TIPC's links. Such updating is unnecessary since the
removal of the prototype multi-cluster capability means that all
outgoing messages are generated locally and already have this field
populated correctly.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index f16e65d..b4b9b30 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -871,8 +871,6 @@ int tipc_link_send_buf(struct tipc_link *l_ptr, struct sk_buff *buf)
 	u32 queue_limit = l_ptr->queue_limit[imp];
 	u32 max_packet = l_ptr->max_pkt;
 
-	msg_set_prevnode(msg, tipc_own_addr);	/* If routed message */
-
 	/* Match msg importance against queue limits: */
 
 	if (unlikely(queue_size >= queue_limit)) {
-- 
1.7.9.1
