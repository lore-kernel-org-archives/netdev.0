From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 03/16] tipc: Prune unused data structures from configuration service
Date: Tue, 11 May 2010 20:30:05 -0400
Message-ID: <5ed4748c202d222531ecdfd3f1fd8ea1649ccb66.1273621271.git.paul.gortmaker@windriver.com>
References: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35219 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136Ab0ELAa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 20:30:26 -0400
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.windriver.com (8.14.3/8.14.3) with ESMTP id o4C0UQnD000093
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 17:30:26 -0700 (PDT)
In-Reply-To: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
References: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Eliminate some unused data structures in the TIPC
configuration service that relate to the handling of link
subscriptions, which were not supported when TIPC 1.5 was
introduced.  If and when support for link subscriptions is
offered in TIPC, these elements may need to be re-introduced.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/config.c |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index ca3544d..7370241 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -56,9 +56,6 @@ struct subscr_data {
 struct manager {
 	u32 user_ref;
 	u32 port_ref;
-	u32 subscr_ref;
-	u32 link_subscriptions;
-	struct list_head link_subscribers;
 };
 
 static struct manager mng = { 0};
@@ -70,12 +67,6 @@ static int req_tlv_space;		/* request message TLV area size */
 static int rep_headroom;		/* reply message headroom to use */
 
 
-void tipc_cfg_link_event(u32 addr, char *name, int up)
-{
-	/* TIPC DOESN'T HANDLE LINK EVENT SUBSCRIPTIONS AT THE MOMENT */
-}
-
-
 struct sk_buff *tipc_cfg_reply_alloc(int payload_size)
 {
 	struct sk_buff *buf;
@@ -130,12 +121,24 @@ struct sk_buff *tipc_cfg_reply_string_type(u16 tlv_type, char *string)
 }
 
 
-
-
 #if 0
 
 /* Now obsolete code for handling commands not yet implemented the new way */
 
+/*
+ * Some of this code assumed that the manager structure contains two added
+ * fields:
+ *	u32 link_subscriptions;
+ *	struct list_head link_subscribers;
+ * which are currently not present.  These fields may need to be re-introduced
+ * if and when support for link subscriptions is added.
+ */
+
+void tipc_cfg_link_event(u32 addr, char *name, int up)
+{
+	/* TIPC DOESN'T HANDLE LINK EVENT SUBSCRIPTIONS AT THE MOMENT */
+}
+
 int tipc_cfg_cmd(const struct tipc_cmd_msg * msg,
 		 char *data,
 		 u32 sz,
@@ -667,9 +670,6 @@ int tipc_cfg_init(void)
 	struct tipc_name_seq seq;
 	int res;
 
-	memset(&mng, 0, sizeof(mng));
-	INIT_LIST_HEAD(&mng.link_subscribers);
-
 	res = tipc_attach(&mng.user_ref, NULL, NULL);
 	if (res)
 		goto failed;
-- 
1.7.1.rc2

