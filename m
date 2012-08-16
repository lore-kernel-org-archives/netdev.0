From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 5/9] tipc: change tipc_net_start routine return value type
Date: Thu, 16 Aug 2012 18:09:10 -0400
Message-ID: <1345154954-12526-6-git-send-email-paul.gortmaker@windriver.com>
References: <1345154954-12526-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57497 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754734Ab2HPWOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 18:14:52 -0400
In-Reply-To: <1345154954-12526-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

Since now tipc_net_start() always returns a success code - 0, its
return value type should be changed from integer to void, which can
avoid unnecessary check for its return value.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/core.c | 5 ++---
 net/tipc/net.c  | 3 +--
 net/tipc/net.h  | 2 +-
 3 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index c261a5d..daae7f7 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -98,9 +98,8 @@ int tipc_core_start_net(unsigned long addr)
 {
 	int res;
 
-	res = tipc_net_start(addr);
-	if (!res)
-		res = tipc_eth_media_start();
+	tipc_net_start(addr);
+	res = tipc_eth_media_start();
 	if (res)
 		tipc_core_stop_net();
 	return res;
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 5b5cea2..7d305ec 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -171,7 +171,7 @@ void tipc_net_route_msg(struct sk_buff *buf)
 	tipc_link_send(buf, dnode, msg_link_selector(msg));
 }
 
-int tipc_net_start(u32 addr)
+void tipc_net_start(u32 addr)
 {
 	char addr_string[16];
 
@@ -187,7 +187,6 @@ int tipc_net_start(u32 addr)
 	pr_info("Started in network mode\n");
 	pr_info("Own node address %s, network identity %u\n",
 		tipc_addr_string_fill(addr_string, tipc_own_addr), tipc_net_id);
-	return 0;
 }
 
 void tipc_net_stop(void)
diff --git a/net/tipc/net.h b/net/tipc/net.h
index 9eb4b9e..079daad 100644
--- a/net/tipc/net.h
+++ b/net/tipc/net.h
@@ -41,7 +41,7 @@ extern rwlock_t tipc_net_lock;
 
 void tipc_net_route_msg(struct sk_buff *buf);
 
-int tipc_net_start(u32 addr);
+void tipc_net_start(u32 addr);
 void tipc_net_stop(void);
 
 #endif
-- 
1.7.11.1
