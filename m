From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 4/5 net-next-2.6] [TIPC]: Update "previous node" indicators when node address changes
Date: Tue, 20 May 2008 17:08:31 -0400
Message-ID: <1211317712-13596-5-git-send-email-allan.stephens@windriver.com>
References: <1211317712-13596-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:41796 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762366AbYETVJy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 17:09:54 -0400
In-Reply-To: <1211317712-13596-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch ensures that the "previous node" field in any existing
TIPC port message header templates is updated properly when a TIPC
network address is assigned to the node.  (Previously, only the
"originating node" field was updated.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/port.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 757de38..2c64ad8 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -780,6 +780,7 @@ void tipc_port_reinit(void)
 		msg = &p_ptr->publ.phdr;
 		if (msg_orignode(msg) == tipc_own_addr)
 			break;
+		msg_set_prevnode(msg, tipc_own_addr);
 		msg_set_orignode(msg, tipc_own_addr);
 	}
 	spin_unlock_bh(&tipc_port_list_lock);
-- 
1.5.3.2

