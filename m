From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 11/21] tipc: Update destination node field on incoming multicast messages
Date: Tue, 10 May 2011 16:44:27 -0400
Message-ID: <1305060277-15600-12-git-send-email-paul.gortmaker@windriver.com>
References: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52389 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752659Ab1EJUpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:45:04 -0400
In-Reply-To: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Sets the destination node field of an incoming multicast message
to the receiving node's network address before handing off the message
to each receiving port. This ensures that, in the event the destination
port returns the message to the sender, the sender can identify which
node the destination port belonged to.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index ac64037..9f2ff12 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -164,6 +164,7 @@ void tipc_port_recv_mcast(struct sk_buff *buf, struct port_list *dp)
 	/* Deliver a copy of message to each destination port */
 
 	if (dp->count != 0) {
+		msg_set_destnode(msg, tipc_own_addr);
 		if (dp->count == 1) {
 			msg_set_destport(msg, dp->ports[0]);
 			tipc_port_recv_msg(buf);
-- 
1.7.4.4

