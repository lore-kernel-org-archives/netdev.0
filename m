From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 08/16] tipc: Optimize re-initialization of port message header templates
Date: Fri, 20 Apr 2012 17:05:16 -0400
Message-ID: <1334955924-907-9-git-send-email-paul.gortmaker@windriver.com>
References: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:62196 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754218Ab2DTVFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 17:05:36 -0400
In-Reply-To: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Removes an unnecessary check in the logic that updates the message
header template for existing ports when a node's network address is
first assigned. There is no longer any need to check to see if the
node's network address has actually changed since the calling routine
has already verified that this is so.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 94d2904..6156c67 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -646,8 +646,6 @@ void tipc_port_reinit(void)
 	spin_lock_bh(&tipc_port_list_lock);
 	list_for_each_entry(p_ptr, &ports, port_list) {
 		msg = &p_ptr->phdr;
-		if (msg_orignode(msg) == tipc_own_addr)
-			break;
 		msg_set_prevnode(msg, tipc_own_addr);
 		msg_set_orignode(msg, tipc_own_addr);
 	}
-- 
1.7.9.3
