From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 6/8] tipc: rename struct bcbearer* to tipc_bcbearer*
Date: Thu, 29 Dec 2011 22:48:55 -0500
Message-ID: <1325216937-5856-7-git-send-email-paul.gortmaker@windriver.com>
References: <1325216937-5856-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63630 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755091Ab1L3DtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 22:49:16 -0500
In-Reply-To: <1325216937-5856-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This changes both the struct bcbearer and struct bcbearer_pair to
have the "tipc_" prefix.  Runtime behaviour is unchanged.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index e88da1c..c24690f 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -46,7 +46,7 @@
 #define BCLINK_WIN_DEFAULT 20		/* bcast link window size (default) */
 
 /**
- * struct bcbearer_pair - a pair of bearers used by broadcast link
+ * struct tipc_bcbearer_pair - a pair of bearers used by broadcast link
  * @primary: pointer to primary bearer
  * @secondary: pointer to secondary bearer
  *
@@ -54,13 +54,13 @@
  * to be paired.
  */
 
-struct bcbearer_pair {
+struct tipc_bcbearer_pair {
 	struct tipc_bearer *primary;
 	struct tipc_bearer *secondary;
 };
 
 /**
- * struct bcbearer - bearer used by broadcast link
+ * struct tipc_bcbearer - bearer used by broadcast link
  * @bearer: (non-standard) broadcast bearer structure
  * @media: (non-standard) broadcast media structure
  * @bpairs: array of bearer pairs
@@ -74,11 +74,11 @@ struct bcbearer_pair {
  * prevented through use of the spinlock "bc_lock".
  */
 
-struct bcbearer {
+struct tipc_bcbearer {
 	struct tipc_bearer bearer;
 	struct tipc_media media;
-	struct bcbearer_pair bpairs[MAX_BEARERS];
-	struct bcbearer_pair bpairs_temp[TIPC_MAX_LINK_PRI + 1];
+	struct tipc_bcbearer_pair bpairs[MAX_BEARERS];
+	struct tipc_bcbearer_pair bpairs_temp[TIPC_MAX_LINK_PRI + 1];
 	struct tipc_node_map remains;
 	struct tipc_node_map remains_new;
 };
@@ -100,10 +100,10 @@ struct tipc_bclink {
 	struct tipc_node *retransmit_to;
 };
 
-static struct bcbearer bcast_bearer;
+static struct tipc_bcbearer bcast_bearer;
 static struct tipc_bclink bcast_link;
 
-static struct bcbearer *bcbearer = &bcast_bearer;
+static struct tipc_bcbearer *bcbearer = &bcast_bearer;
 static struct tipc_bclink *bclink = &bcast_link;
 static struct link *bcl = &bcast_link.link;
 
@@ -677,8 +677,8 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 
 void tipc_bcbearer_sort(void)
 {
-	struct bcbearer_pair *bp_temp = bcbearer->bpairs_temp;
-	struct bcbearer_pair *bp_curr;
+	struct tipc_bcbearer_pair *bp_temp = bcbearer->bpairs_temp;
+	struct tipc_bcbearer_pair *bp_curr;
 	int b_index;
 	int pri;
 
-- 
1.7.4.4
