From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 08/15] tipc: Fix bug in broadcast link duplicate message statistics
Date: Mon,  6 Feb 2012 19:52:41 -0500
Message-ID: <1328575968-20643-9-git-send-email-paul.gortmaker@windriver.com>
References: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50187 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756300Ab2BGAxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 19:53:14 -0500
In-Reply-To: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Modifies broadcast link so that it increments the "received duplicate
message" count if an incoming message cannot be added to the deferred
message queue because it is already present in the queue. (The aligns
broadcast link behavior with that of TIPC's unicast links.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index e7df313..035b350 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -603,6 +603,8 @@ receive:
 
 	if (deferred)
 		bcl->stats.deferred_recv++;
+	else
+		bcl->stats.duplicates++;
 
 unlock:
 	tipc_node_unlock(node);
-- 
1.7.9
