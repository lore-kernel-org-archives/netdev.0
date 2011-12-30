From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 3/8] tipc: rename struct subscription to struct tipc_subscription
Date: Thu, 29 Dec 2011 22:48:52 -0500
Message-ID: <1325216937-5856-4-git-send-email-paul.gortmaker@windriver.com>
References: <1325216937-5856-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63616 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755066Ab1L3DtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 22:49:14 -0500
In-Reply-To: <1325216937-5856-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make this rename so that it is consistent with the majority
of the other tipc structs and to assist in removing any
ambiguity with other similar names in other subsystems.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_table.c |   13 +++++++------
 net/tipc/name_table.h |    6 +++---
 net/tipc/subscr.c     |   24 ++++++++++++------------
 net/tipc/subscr.h     |   10 +++++-----
 4 files changed, 27 insertions(+), 26 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index f0abae9..89eb562 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -251,8 +251,8 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 						    u32 type, u32 lower, u32 upper,
 						    u32 scope, u32 node, u32 port, u32 key)
 {
-	struct subscription *s;
-	struct subscription *st;
+	struct tipc_subscription *s;
+	struct tipc_subscription *st;
 	struct publication *publ;
 	struct sub_seq *sseq;
 	struct name_info *info;
@@ -381,7 +381,7 @@ static struct publication *tipc_nameseq_remove_publ(struct name_seq *nseq, u32 i
 	struct sub_seq *sseq = nameseq_find_subseq(nseq, inst);
 	struct name_info *info;
 	struct sub_seq *free;
-	struct subscription *s, *st;
+	struct tipc_subscription *s, *st;
 	int removed_subseq = 0;
 
 	if (!sseq)
@@ -448,7 +448,8 @@ found:
  * sequence overlapping with the requested sequence
  */
 
-static void tipc_nameseq_subscribe(struct name_seq *nseq, struct subscription *s)
+static void tipc_nameseq_subscribe(struct name_seq *nseq,
+					struct tipc_subscription *s)
 {
 	struct sub_seq *sseq = nseq->sseqs;
 
@@ -739,7 +740,7 @@ int tipc_nametbl_withdraw(u32 type, u32 lower, u32 ref, u32 key)
  * tipc_nametbl_subscribe - add a subscription object to the name table
  */
 
-void tipc_nametbl_subscribe(struct subscription *s)
+void tipc_nametbl_subscribe(struct tipc_subscription *s)
 {
 	u32 type = s->seq.type;
 	struct name_seq *seq;
@@ -763,7 +764,7 @@ void tipc_nametbl_subscribe(struct subscription *s)
  * tipc_nametbl_unsubscribe - remove a subscription object from name table
  */
 
-void tipc_nametbl_unsubscribe(struct subscription *s)
+void tipc_nametbl_unsubscribe(struct tipc_subscription *s)
 {
 	struct name_seq *seq;
 
diff --git a/net/tipc/name_table.h b/net/tipc/name_table.h
index c3b0f2c..8086b42 100644
--- a/net/tipc/name_table.h
+++ b/net/tipc/name_table.h
@@ -39,7 +39,7 @@
 
 #include "node_subscr.h"
 
-struct subscription;
+struct tipc_subscription;
 struct tipc_port_list;
 
 /*
@@ -100,8 +100,8 @@ struct publication *tipc_nametbl_insert_publ(u32 type, u32 lower, u32 upper,
 					u32 scope, u32 node, u32 ref, u32 key);
 struct publication *tipc_nametbl_remove_publ(u32 type, u32 lower,
 					u32 node, u32 ref, u32 key);
-void tipc_nametbl_subscribe(struct subscription *s);
-void tipc_nametbl_unsubscribe(struct subscription *s);
+void tipc_nametbl_subscribe(struct tipc_subscription *s);
+void tipc_nametbl_unsubscribe(struct tipc_subscription *s);
 int tipc_nametbl_init(void);
 void tipc_nametbl_stop(void);
 
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 1983717..5bcd1f6 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -92,7 +92,7 @@ static u32 htohl(u32 in, int swap)
  *       try to take the lock if the message is rejected and returned!
  */
 
-static void subscr_send_event(struct subscription *sub,
+static void subscr_send_event(struct tipc_subscription *sub,
 			      u32 found_lower,
 			      u32 found_upper,
 			      u32 event,
@@ -118,7 +118,7 @@ static void subscr_send_event(struct subscription *sub,
  * Returns 1 if there is overlap, otherwise 0.
  */
 
-int tipc_subscr_overlap(struct subscription *sub,
+int tipc_subscr_overlap(struct tipc_subscription *sub,
 			u32 found_lower,
 			u32 found_upper)
 
@@ -138,7 +138,7 @@ int tipc_subscr_overlap(struct subscription *sub,
  * Protected by nameseq.lock in name_table.c
  */
 
-void tipc_subscr_report_overlap(struct subscription *sub,
+void tipc_subscr_report_overlap(struct tipc_subscription *sub,
 				u32 found_lower,
 				u32 found_upper,
 				u32 event,
@@ -158,7 +158,7 @@ void tipc_subscr_report_overlap(struct subscription *sub,
  * subscr_timeout - subscription timeout has occurred
  */
 
-static void subscr_timeout(struct subscription *sub)
+static void subscr_timeout(struct tipc_subscription *sub)
 {
 	struct tipc_port *server_port;
 
@@ -205,7 +205,7 @@ static void subscr_timeout(struct subscription *sub)
  * Called with subscriber port locked.
  */
 
-static void subscr_del(struct subscription *sub)
+static void subscr_del(struct tipc_subscription *sub)
 {
 	tipc_nametbl_unsubscribe(sub);
 	list_del(&sub->subscription_list);
@@ -227,8 +227,8 @@ static void subscr_del(struct subscription *sub)
 static void subscr_terminate(struct subscriber *subscriber)
 {
 	u32 port_ref;
-	struct subscription *sub;
-	struct subscription *sub_temp;
+	struct tipc_subscription *sub;
+	struct tipc_subscription *sub_temp;
 
 	/* Invalidate subscriber reference */
 
@@ -280,8 +280,8 @@ static void subscr_terminate(struct subscriber *subscriber)
 static void subscr_cancel(struct tipc_subscr *s,
 			  struct subscriber *subscriber)
 {
-	struct subscription *sub;
-	struct subscription *sub_temp;
+	struct tipc_subscription *sub;
+	struct tipc_subscription *sub_temp;
 	int found = 0;
 
 	/* Find first matching subscription, exit if not found */
@@ -314,10 +314,10 @@ static void subscr_cancel(struct tipc_subscr *s,
  * Called with subscriber port locked.
  */
 
-static struct subscription *subscr_subscribe(struct tipc_subscr *s,
+static struct tipc_subscription *subscr_subscribe(struct tipc_subscr *s,
 					     struct subscriber *subscriber)
 {
-	struct subscription *sub;
+	struct tipc_subscription *sub;
 	int swap;
 
 	/* Determine subscriber's endianness */
@@ -418,7 +418,7 @@ static void subscr_conn_msg_event(void *usr_handle,
 {
 	struct subscriber *subscriber = usr_handle;
 	spinlock_t *subscriber_lock;
-	struct subscription *sub;
+	struct tipc_subscription *sub;
 
 	/*
 	 * Lock subscriber's server port (& make a local copy of lock pointer,
diff --git a/net/tipc/subscr.h b/net/tipc/subscr.h
index 4b06ef6..ef6529c 100644
--- a/net/tipc/subscr.h
+++ b/net/tipc/subscr.h
@@ -37,10 +37,10 @@
 #ifndef _TIPC_SUBSCR_H
 #define _TIPC_SUBSCR_H
 
-struct subscription;
+struct tipc_subscription;
 
 /**
- * struct subscription - TIPC network topology subscription object
+ * struct tipc_subscription - TIPC network topology subscription object
  * @seq: name sequence associated with subscription
  * @timeout: duration of subscription (in ms)
  * @filter: event filtering to be done for subscription
@@ -52,7 +52,7 @@ struct subscription;
  * @evt: template for events generated by subscription
  */
 
-struct subscription {
+struct tipc_subscription {
 	struct tipc_name_seq seq;
 	u32 timeout;
 	u32 filter;
@@ -64,11 +64,11 @@ struct subscription {
 	struct tipc_event evt;
 };
 
-int tipc_subscr_overlap(struct subscription *sub,
+int tipc_subscr_overlap(struct tipc_subscription *sub,
 			u32 found_lower,
 			u32 found_upper);
 
-void tipc_subscr_report_overlap(struct subscription *sub,
+void tipc_subscr_report_overlap(struct tipc_subscription *sub,
 				u32 found_lower,
 				u32 found_upper,
 				u32 event,
-- 
1.7.4.4
