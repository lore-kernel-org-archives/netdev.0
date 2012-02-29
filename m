From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 17/17] tipc: Optimize setting of immutable payload message header fields
Date: Wed, 29 Feb 2012 18:18:43 -0500
Message-ID: <1330557523-2024-18-git-send-email-paul.gortmaker@windriver.com>
References: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54010 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965325Ab2B2XTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 18:19:10 -0500
In-Reply-To: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Optimizes routines that send payload messages so that they no longer
update the "originating node" and "originating port" fields of the
outgoing message header template, since these fields are initialized
when the sending port is created and never change thereafter. Also
optimizes the routine which updates the message header template when
a connection to a port is established, for the same reason.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 6adcdf9..94d2904 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -1054,8 +1054,6 @@ int tipc_connect2port(u32 ref, struct tipc_portid const *peer)
 	msg = &p_ptr->phdr;
 	msg_set_destnode(msg, peer->node);
 	msg_set_destport(msg, peer->ref);
-	msg_set_orignode(msg, tipc_own_addr);
-	msg_set_origport(msg, p_ptr->ref);
 	msg_set_type(msg, TIPC_CONN_MSG);
 	msg_set_lookup_scope(msg, 0);
 	msg_set_hdr_sz(msg, SHORT_H_SIZE);
@@ -1254,8 +1252,6 @@ int tipc_send2name(u32 ref, struct tipc_name const *name, unsigned int domain,
 
 	msg = &p_ptr->phdr;
 	msg_set_type(msg, TIPC_NAMED_MSG);
-	msg_set_orignode(msg, tipc_own_addr);
-	msg_set_origport(msg, ref);
 	msg_set_hdr_sz(msg, NAMED_H_SIZE);
 	msg_set_nametype(msg, name->type);
 	msg_set_nameinst(msg, name->instance);
@@ -1305,8 +1301,6 @@ int tipc_send2port(u32 ref, struct tipc_portid const *dest,
 	msg = &p_ptr->phdr;
 	msg_set_type(msg, TIPC_DIRECT_MSG);
 	msg_set_lookup_scope(msg, 0);
-	msg_set_orignode(msg, tipc_own_addr);
-	msg_set_origport(msg, ref);
 	msg_set_destnode(msg, dest->node);
 	msg_set_destport(msg, dest->ref);
 	msg_set_hdr_sz(msg, BASIC_H_SIZE);
@@ -1345,8 +1339,6 @@ int tipc_send_buf2port(u32 ref, struct tipc_portid const *dest,
 
 	msg = &p_ptr->phdr;
 	msg_set_type(msg, TIPC_DIRECT_MSG);
-	msg_set_orignode(msg, tipc_own_addr);
-	msg_set_origport(msg, ref);
 	msg_set_destnode(msg, dest->node);
 	msg_set_destport(msg, dest->ref);
 	msg_set_hdr_sz(msg, BASIC_H_SIZE);
-- 
1.7.9.1
