From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 4/8] tipc: rename struct subscriber to struct tipc_subscriber
Date: Thu, 29 Dec 2011 22:48:53 -0500
Message-ID: <1325216937-5856-5-git-send-email-paul.gortmaker@windriver.com>
References: <1325216937-5856-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63615 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755067Ab1L3DtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 22:49:14 -0500
In-Reply-To: <1325216937-5856-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make this rename so that it is consistent with the majority
of the other tipc structs and to assist in removing any
ambiguity with other similar names in other subsystems.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/subscr.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 5bcd1f6..8c49566 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -40,14 +40,14 @@
 #include "subscr.h"
 
 /**
- * struct subscriber - TIPC network topology subscriber
+ * struct tipc_subscriber - TIPC network topology subscriber
  * @port_ref: object reference to server port connecting to subscriber
  * @lock: pointer to spinlock controlling access to subscriber's server port
  * @subscriber_list: adjacent subscribers in top. server's list of subscribers
  * @subscription_list: list of subscription objects for this subscriber
  */
 
-struct subscriber {
+struct tipc_subscriber {
 	u32 port_ref;
 	spinlock_t *lock;
 	struct list_head subscriber_list;
@@ -224,7 +224,7 @@ static void subscr_del(struct tipc_subscription *sub)
  * simply wait for it to be released, then claim it.)
  */
 
-static void subscr_terminate(struct subscriber *subscriber)
+static void subscr_terminate(struct tipc_subscriber *subscriber)
 {
 	u32 port_ref;
 	struct tipc_subscription *sub;
@@ -278,7 +278,7 @@ static void subscr_terminate(struct subscriber *subscriber)
  */
 
 static void subscr_cancel(struct tipc_subscr *s,
-			  struct subscriber *subscriber)
+			  struct tipc_subscriber *subscriber)
 {
 	struct tipc_subscription *sub;
 	struct tipc_subscription *sub_temp;
@@ -315,7 +315,7 @@ static void subscr_cancel(struct tipc_subscr *s,
  */
 
 static struct tipc_subscription *subscr_subscribe(struct tipc_subscr *s,
-					     struct subscriber *subscriber)
+					     struct tipc_subscriber *subscriber)
 {
 	struct tipc_subscription *sub;
 	int swap;
@@ -393,7 +393,7 @@ static void subscr_conn_shutdown_event(void *usr_handle,
 				       unsigned int size,
 				       int reason)
 {
-	struct subscriber *subscriber = usr_handle;
+	struct tipc_subscriber *subscriber = usr_handle;
 	spinlock_t *subscriber_lock;
 
 	if (tipc_port_lock(port_ref) == NULL)
@@ -416,7 +416,7 @@ static void subscr_conn_msg_event(void *usr_handle,
 				  const unchar *data,
 				  u32 size)
 {
-	struct subscriber *subscriber = usr_handle;
+	struct tipc_subscriber *subscriber = usr_handle;
 	spinlock_t *subscriber_lock;
 	struct tipc_subscription *sub;
 
@@ -471,12 +471,12 @@ static void subscr_named_msg_event(void *usr_handle,
 				   struct tipc_portid const *orig,
 				   struct tipc_name_seq const *dest)
 {
-	struct subscriber *subscriber;
+	struct tipc_subscriber *subscriber;
 	u32 server_port_ref;
 
 	/* Create subscriber object */
 
-	subscriber = kzalloc(sizeof(struct subscriber), GFP_ATOMIC);
+	subscriber = kzalloc(sizeof(struct tipc_subscriber), GFP_ATOMIC);
 	if (subscriber == NULL) {
 		warn("Subscriber rejected, no memory\n");
 		return;
@@ -568,8 +568,8 @@ failed:
 
 void tipc_subscr_stop(void)
 {
-	struct subscriber *subscriber;
-	struct subscriber *subscriber_temp;
+	struct tipc_subscriber *subscriber;
+	struct tipc_subscriber *subscriber_temp;
 	spinlock_t *subscriber_lock;
 
 	if (topsrv.setup_port) {
-- 
1.7.4.4
