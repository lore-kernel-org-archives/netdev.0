From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 27/28] tipc: Remove callback field from subscription structure
Date: Sat, 17 Sep 2011 23:32:23 -0400
Message-ID: <1316316744-29514-28-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50011 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756304Ab1IRDdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:33:03 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

Eliminate the "event_cb" member from TIPC's "subscription" structure
since the function pointer it holds always points to subscr_send_event().

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/subscr.c |    3 +--
 net/tipc/subscr.h |    6 ------
 2 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 6cf7268..1983717 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -151,7 +151,7 @@ void tipc_subscr_report_overlap(struct subscription *sub,
 	if (!must && !(sub->filter & TIPC_SUB_PORTS))
 		return;
 
-	sub->event_cb(sub, found_lower, found_upper, event, port_ref, node);
+	subscr_send_event(sub, found_lower, found_upper, event, port_ref, node);
 }
 
 /**
@@ -365,7 +365,6 @@ static struct subscription *subscr_subscribe(struct tipc_subscr *s,
 		subscr_terminate(subscriber);
 		return NULL;
 	}
-	sub->event_cb = subscr_send_event;
 	INIT_LIST_HEAD(&sub->nameseq_list);
 	list_add(&sub->subscription_list, &subscriber->subscription_list);
 	sub->server_ref = subscriber->port_ref;
diff --git a/net/tipc/subscr.h b/net/tipc/subscr.h
index 45d89bf..4b06ef6 100644
--- a/net/tipc/subscr.h
+++ b/net/tipc/subscr.h
@@ -39,16 +39,11 @@
 
 struct subscription;
 
-typedef void (*tipc_subscr_event) (struct subscription *sub,
-				   u32 found_lower, u32 found_upper,
-				   u32 event, u32 port_ref, u32 node);
-
 /**
  * struct subscription - TIPC network topology subscription object
  * @seq: name sequence associated with subscription
  * @timeout: duration of subscription (in ms)
  * @filter: event filtering to be done for subscription
- * @event_cb: routine invoked when a subscription event is detected
  * @timer: timer governing subscription duration (optional)
  * @nameseq_list: adjacent subscriptions in name sequence's subscription list
  * @subscription_list: adjacent subscriptions in subscriber's subscription list
@@ -61,7 +56,6 @@ struct subscription {
 	struct tipc_name_seq seq;
 	u32 timeout;
 	u32 filter;
-	tipc_subscr_event event_cb;
 	struct timer_list timer;
 	struct list_head nameseq_list;
 	struct list_head subscription_list;
-- 
1.7.4.4
