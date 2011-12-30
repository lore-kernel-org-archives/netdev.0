From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 1/8] tipc: rename struct media to struct tipc_media
Date: Thu, 29 Dec 2011 22:48:50 -0500
Message-ID: <1325216937-5856-2-git-send-email-paul.gortmaker@windriver.com>
References: <1325216937-5856-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63603 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754981Ab1L3DtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 22:49:11 -0500
In-Reply-To: <1325216937-5856-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Give it a meaningful prefix, as suggested by DaveM, so that it
is consistent with things like struct tipc_bearer, and so it isn't
confused with anything else.  This has no impact on the actual
runtime code behaviour.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c     |    2 +-
 net/tipc/bearer.c    |   12 ++++++------
 net/tipc/bearer.h    |   10 +++++-----
 net/tipc/eth_media.c |    4 ++--
 net/tipc/link.c      |    2 +-
 5 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 048b7a3..b6afe73 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -76,7 +76,7 @@ struct bcbearer_pair {
 
 struct bcbearer {
 	struct tipc_bearer bearer;
-	struct media media;
+	struct tipc_media media;
 	struct bcbearer_pair bpairs[MAX_BEARERS];
 	struct bcbearer_pair bpairs_temp[TIPC_MAX_LINK_PRI + 1];
 	struct tipc_node_map remains;
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index b40e98a..cddec3d 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -41,7 +41,7 @@
 
 #define MAX_ADDR_STR 32
 
-static struct media *media_list[MAX_MEDIA];
+static struct tipc_media *media_list[MAX_MEDIA];
 static u32 media_count;
 
 struct tipc_bearer tipc_bearers[MAX_BEARERS];
@@ -68,7 +68,7 @@ static int media_name_valid(const char *name)
  * tipc_media_find - locates specified media object by name
  */
 
-struct media *tipc_media_find(const char *name)
+struct tipc_media *tipc_media_find(const char *name)
 {
 	u32 i;
 
@@ -83,7 +83,7 @@ struct media *tipc_media_find(const char *name)
  * media_find_id - locates specified media object by type identifier
  */
 
-static struct media *media_find_id(u8 type)
+static struct tipc_media *media_find_id(u8 type)
 {
 	u32 i;
 
@@ -100,7 +100,7 @@ static struct media *media_find_id(u8 type)
  * Bearers for this media type must be activated separately at a later stage.
  */
 
-int  tipc_register_media(struct media *m_ptr)
+int tipc_register_media(struct tipc_media *m_ptr)
 {
 	int res = -EINVAL;
 
@@ -138,7 +138,7 @@ exit:
 void tipc_media_addr_printf(struct print_buf *pb, struct tipc_media_addr *a)
 {
 	char addr_str[MAX_ADDR_STR];
-	struct media *m_ptr;
+	struct tipc_media *m_ptr;
 
 	m_ptr = media_find_id(a->media_id);
 
@@ -425,7 +425,7 @@ int tipc_bearer_congested(struct tipc_bearer *b_ptr, struct link *l_ptr)
 int tipc_enable_bearer(const char *name, u32 disc_domain, u32 priority)
 {
 	struct tipc_bearer *b_ptr;
-	struct media *m_ptr;
+	struct tipc_media *m_ptr;
 	struct bearer_name b_name;
 	char addr_string[16];
 	u32 bearer_id;
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index cfe77c4..af01ca2 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -74,7 +74,7 @@ struct tipc_media_addr {
 struct tipc_bearer;
 
 /**
- * struct media - TIPC media information available to internal users
+ * struct tipc_media - TIPC media information available to internal users
  * @send_msg: routine which handles buffer transmission
  * @enable_bearer: routine which enables a bearer
  * @disable_bearer: routine which disables a bearer
@@ -90,7 +90,7 @@ struct tipc_bearer;
  * @name: media name
  */
 
-struct media {
+struct tipc_media {
 	int (*send_msg)(struct sk_buff *buf,
 			struct tipc_bearer *b_ptr,
 			struct tipc_media_addr *dest);
@@ -139,7 +139,7 @@ struct tipc_bearer {
 	struct tipc_media_addr addr;		/* initalized by media */
 	char name[TIPC_MAX_BEARER_NAME];
 	spinlock_t lock;
-	struct media *media;
+	struct tipc_media *media;
 	u32 priority;
 	u32 window;
 	u32 tolerance;
@@ -164,7 +164,7 @@ extern struct tipc_bearer tipc_bearers[];
 /*
  * TIPC routines available to supported media types
  */
-int tipc_register_media(struct media *m_ptr);
+int tipc_register_media(struct tipc_media *m_ptr);
 
 void tipc_recv_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr);
 
@@ -191,7 +191,7 @@ void tipc_bearer_remove_dest(struct tipc_bearer *b_ptr, u32 dest);
 void tipc_bearer_schedule(struct tipc_bearer *b_ptr, struct link *l_ptr);
 struct tipc_bearer *tipc_bearer_find(const char *name);
 struct tipc_bearer *tipc_bearer_find_interface(const char *if_name);
-struct media *tipc_media_find(const char *name);
+struct tipc_media *tipc_media_find(const char *name);
 int tipc_bearer_resolve_congestion(struct tipc_bearer *b_ptr, struct link *l_ptr);
 int tipc_bearer_congested(struct tipc_bearer *b_ptr, struct link *l_ptr);
 void tipc_bearer_stop(void);
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index cd0a4b8..527e3f0 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -56,7 +56,7 @@ struct eth_bearer {
 	struct work_struct cleanup;
 };
 
-static struct media eth_media_info;
+static struct tipc_media eth_media_info;
 static struct eth_bearer eth_bearers[MAX_ETH_BEARERS];
 static int eth_started;
 static struct notifier_block notifier;
@@ -340,7 +340,7 @@ static int eth_msg2addr(struct tipc_media_addr *a, char *msg_area)
  * Ethernet media registration info
  */
 
-static struct media eth_media_info = {
+static struct tipc_media eth_media_info = {
 	.send_msg	= send_msg,
 	.enable_bearer	= enable_bearer,
 	.disable_bearer	= disable_bearer,
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 853b286..515dfe4 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2793,7 +2793,7 @@ static int link_cmd_set_value(const char *name, u32 new_value, u16 cmd)
 	struct tipc_node *node;
 	struct link *l_ptr;
 	struct tipc_bearer *b_ptr;
-	struct media *m_ptr;
+	struct tipc_media *m_ptr;
 
 	l_ptr = link_find_link(name, &node);
 	if (l_ptr) {
-- 
1.7.4.4
