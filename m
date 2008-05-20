From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 3/5 net-next-2.6] [TIPC]: Optimize null pointer check during neighbor discovery
Date: Tue, 20 May 2008 17:08:30 -0400
Message-ID: <1211317712-13596-4-git-send-email-allan.stephens@windriver.com>
References: <1211317712-13596-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:41776 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760057AbYETVJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 17:09:52 -0400
In-Reply-To: <1211317712-13596-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch optimizes TIPC neighbor discovery code to avoid testing for
a null node pointer when the pointer is already known to be non-null.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/discover.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 5d643e5..faeaf06 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -200,9 +200,8 @@ void tipc_disc_recv_msg(struct sk_buff *buf)
 		dbg(" in own cluster\n");
 		if (n_ptr == NULL) {
 			n_ptr = tipc_node_create(orig);
-		}
-		if (n_ptr == NULL) {
-			return;
+			if (!n_ptr)
+				return;
 		}
 		spin_lock_bh(&n_ptr->lock);
 		link = n_ptr->links[b_ptr->identity];
-- 
1.5.3.2

