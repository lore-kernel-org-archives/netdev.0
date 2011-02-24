From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 14/17] tipc: Add in missing lock during link initialization
Date: Wed, 23 Feb 2011 20:26:42 -0500
Message-ID: <1298510805-20630-15-git-send-email-paul.gortmaker@windriver.com>
References: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com, netdev@vger.kernel.org,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34533 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932119Ab1BXB1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 20:27:16 -0500
In-Reply-To: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Ensure that the routine that starts up processing on a newly created
link endpoint takes the spinlock of the node object that owns the link,
to prevent possible conflicts with processing involving other links
owned by that node object.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 754e310..89fbb6d 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -388,7 +388,9 @@ void tipc_link_delete(struct link *l_ptr)
 
 static void link_start(struct link *l_ptr)
 {
+	tipc_node_lock(l_ptr->owner);
 	link_state_event(l_ptr, STARTING_EVT);
+	tipc_node_unlock(l_ptr->owner);
 }
 
 /**
-- 
1.7.3.3

