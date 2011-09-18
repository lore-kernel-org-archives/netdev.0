From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 28/28] tipc: Remove unused link event tracking code
Date: Sat, 17 Sep 2011 23:32:24 -0400
Message-ID: <1316316744-29514-29-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50013 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756311Ab1IRDdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:33:04 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

Elimintes prototype link event tracking functionality that has never
been fleshed out and doesn't do anything useful at the current time.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/config.h |    1 -
 net/tipc/link.c   |   10 ----------
 2 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/net/tipc/config.h b/net/tipc/config.h
index 443159a..80da6eb 100644
--- a/net/tipc/config.h
+++ b/net/tipc/config.h
@@ -65,7 +65,6 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd,
 				const void *req_tlv_area, int req_tlv_space,
 				int headroom);
 
-void tipc_cfg_link_event(u32 addr, char *name, int up);
 int  tipc_cfg_init(void);
 void tipc_cfg_stop(void);
 
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 2ea3f22..ae98a72 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -537,9 +537,6 @@ void tipc_link_stop(struct link *l_ptr)
 	l_ptr->proto_msg_queue = NULL;
 }
 
-/* LINK EVENT CODE IS NOT SUPPORTED AT PRESENT */
-#define link_send_event(fcn, l_ptr, up) do { } while (0)
-
 void tipc_link_reset(struct link *l_ptr)
 {
 	struct sk_buff *buf;
@@ -597,10 +594,6 @@ void tipc_link_reset(struct link *l_ptr)
 	l_ptr->fsm_msg_cnt = 0;
 	l_ptr->stale_count = 0;
 	link_reset_statistics(l_ptr);
-
-	link_send_event(tipc_cfg_link_event, l_ptr, 0);
-	if (!in_own_cluster(l_ptr->addr))
-		link_send_event(tipc_disc_link_event, l_ptr, 0);
 }
 
 
@@ -609,9 +602,6 @@ static void link_activate(struct link *l_ptr)
 	l_ptr->next_in_no = l_ptr->stats.recv_info = 1;
 	tipc_node_link_up(l_ptr->owner, l_ptr);
 	tipc_bearer_add_dest(l_ptr->b_ptr, l_ptr->addr);
-	link_send_event(tipc_cfg_link_event, l_ptr, 1);
-	if (!in_own_cluster(l_ptr->addr))
-		link_send_event(tipc_disc_link_event, l_ptr, 1);
 }
 
 /**
-- 
1.7.4.4
