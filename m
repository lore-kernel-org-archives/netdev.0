From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 10/17] tipc: Remove obsolete comments about routing table updates
Date: Wed, 29 Feb 2012 18:18:36 -0500
Message-ID: <1330557523-2024-11-git-send-email-paul.gortmaker@windriver.com>
References: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53971 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965327Ab2B2XTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 18:19:04 -0500
In-Reply-To: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Eliminates a block of comments that describe how routing table updates
are to be handled. These comments no longer apply following the removal
of TIPC's prototype multi-cluster support.

Note that these changes are essentially cosmetic in nature, and have
no impact on the actual operation of TIPC.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/node.c |   46 ----------------------------------------------
 1 files changed, 0 insertions(+), 46 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 24c42f7..d7f8b7b 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -266,52 +266,6 @@ void tipc_node_detach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 	n_ptr->link_cnt--;
 }
 
-/*
- * Routing table management - five cases to handle:
- *
- * 1: A link towards a zone/cluster external node comes up.
- *    => Send a multicast message updating routing tables of all
- *    system nodes within own cluster that the new destination
- *    can be reached via this node.
- *    (node.establishedContact()=>cluster.multicastNewRoute())
- *
- * 2: A link towards a slave node comes up.
- *    => Send a multicast message updating routing tables of all
- *    system nodes within own cluster that the new destination
- *    can be reached via this node.
- *    (node.establishedContact()=>cluster.multicastNewRoute())
- *    => Send a  message to the slave node about existence
- *    of all system nodes within cluster:
- *    (node.establishedContact()=>cluster.sendLocalRoutes())
- *
- * 3: A new cluster local system node becomes available.
- *    => Send message(s) to this particular node containing
- *    information about all cluster external and slave
- *     nodes which can be reached via this node.
- *    (node.establishedContact()==>network.sendExternalRoutes())
- *    (node.establishedContact()==>network.sendSlaveRoutes())
- *    => Send messages to all directly connected slave nodes
- *    containing information about the existence of the new node
- *    (node.establishedContact()=>cluster.multicastNewRoute())
- *
- * 4: The link towards a zone/cluster external node or slave
- *    node goes down.
- *    => Send a multcast message updating routing tables of all
- *    nodes within cluster that the new destination can not any
- *    longer be reached via this node.
- *    (node.lostAllLinks()=>cluster.bcastLostRoute())
- *
- * 5: A cluster local system node becomes unavailable.
- *    => Remove all references to this node from the local
- *    routing tables. Note: This is a completely node
- *    local operation.
- *    (node.lostAllLinks()=>network.removeAsRouter())
- *    => Send messages to all directly connected slave nodes
- *    containing information about loss of the node
- *    (node.establishedContact()=>cluster.multicastLostRoute())
- *
- */
-
 static void node_established_contact(struct tipc_node *n_ptr)
 {
 	tipc_k_signal((Handler)tipc_named_node_up, n_ptr->addr);
-- 
1.7.9.1
