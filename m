From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 09/21] tipc: Set name lookup scope field properly in all data messages
Date: Tue, 10 May 2011 16:44:25 -0400
Message-ID: <1305060277-15600-10-git-send-email-paul.gortmaker@windriver.com>
References: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52372 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974Ab1EJUpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:45:03 -0400
In-Reply-To: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Ensures that all outgoing data messages have the "name lookup scope"
field of their header set correctly; that is, named multicast messages
now specify cluster-wide name lookup, while messages not using TIPC
naming zero out the lookup field.  (Previously, the lookup scope specified
for these types of messages was inherited from the last message sent
by the sending port.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 6ff78f9..c2229c4 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -91,6 +91,7 @@ int tipc_multicast(u32 ref, struct tipc_name_seq const *seq,
 
 	hdr = &oport->phdr;
 	msg_set_type(hdr, TIPC_MCAST_MSG);
+	msg_set_lookup_scope(hdr, TIPC_CLUSTER_SCOPE);
 	msg_set_nametype(hdr, seq->type);
 	msg_set_namelower(hdr, seq->lower);
 	msg_set_nameupper(hdr, seq->upper);
@@ -1065,6 +1066,7 @@ int tipc_connect2port(u32 ref, struct tipc_portid const *peer)
 	msg_set_orignode(msg, tipc_own_addr);
 	msg_set_origport(msg, p_ptr->ref);
 	msg_set_type(msg, TIPC_CONN_MSG);
+	msg_set_lookup_scope(msg, 0);
 	msg_set_hdr_sz(msg, SHORT_H_SIZE);
 
 	p_ptr->probing_interval = PROBING_INTERVAL;
@@ -1276,6 +1278,7 @@ int tipc_send2port(u32 ref, struct tipc_portid const *dest,
 
 	msg = &p_ptr->phdr;
 	msg_set_type(msg, TIPC_DIRECT_MSG);
+	msg_set_lookup_scope(msg, 0);
 	msg_set_orignode(msg, tipc_own_addr);
 	msg_set_origport(msg, ref);
 	msg_set_destnode(msg, dest->node);
-- 
1.7.4.4

