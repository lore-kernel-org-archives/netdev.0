From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 15/23] tipc: Minor correction to TIPC module unloading
Date: Tue, 27 Dec 2011 12:39:34 -0500
Message-ID: <1325007582-31610-16-git-send-email-paul.gortmaker@windriver.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39470 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754815Ab1L0RkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:40:06 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Modifies TIPC's module unloading logic to switch itself into "single
node" mode before starting to terminate networking support. This helps
to ensure that no operations that require TIPC to be in "networking"
mode can initiate once unloading starts.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/net.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/net.c b/net/tipc/net.c
index fafef6c..e13162f 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -207,8 +207,8 @@ void tipc_net_stop(void)
 	if (tipc_mode != TIPC_NET_MODE)
 		return;
 	write_lock_bh(&tipc_net_lock);
-	tipc_bearer_stop();
 	tipc_mode = TIPC_NODE_MODE;
+	tipc_bearer_stop();
 	tipc_bclink_stop();
 	list_for_each_entry_safe(node, t_node, &tipc_node_list, list)
 		tipc_node_delete(node);
-- 
1.7.4.4
