From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 8/8] tipc: rename struct bearer_name to struct tipc_bearer_names
Date: Thu, 29 Dec 2011 22:48:57 -0500
Message-ID: <1325216937-5856-9-git-send-email-paul.gortmaker@windriver.com>
References: <1325216937-5856-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63632 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755094Ab1L3DtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 22:49:17 -0500
In-Reply-To: <1325216937-5856-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The addition of the "s" to indicate pluralization is intentional,
since the struct actually contains two name variants.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c |   10 +++++-----
 net/tipc/bearer.h |    2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index eab4201..329fb65 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -185,7 +185,7 @@ struct sk_buff *tipc_media_get_names(void)
  */
 
 static int bearer_name_validate(const char *name,
-				struct bearer_name *name_parts)
+				struct tipc_bearer_names *name_parts)
 {
 	char name_copy[TIPC_MAX_BEARER_NAME];
 	char *media_name;
@@ -428,7 +428,7 @@ int tipc_enable_bearer(const char *name, u32 disc_domain, u32 priority)
 {
 	struct tipc_bearer *b_ptr;
 	struct tipc_media *m_ptr;
-	struct bearer_name b_name;
+	struct tipc_bearer_names b_names;
 	char addr_string[16];
 	u32 bearer_id;
 	u32 with_this_prio;
@@ -440,7 +440,7 @@ int tipc_enable_bearer(const char *name, u32 disc_domain, u32 priority)
 		     name);
 		return -ENOPROTOOPT;
 	}
-	if (!bearer_name_validate(name, &b_name)) {
+	if (!bearer_name_validate(name, &b_names)) {
 		warn("Bearer <%s> rejected, illegal name\n", name);
 		return -EINVAL;
 	}
@@ -465,10 +465,10 @@ int tipc_enable_bearer(const char *name, u32 disc_domain, u32 priority)
 
 	write_lock_bh(&tipc_net_lock);
 
-	m_ptr = tipc_media_find(b_name.media_name);
+	m_ptr = tipc_media_find(b_names.media_name);
 	if (!m_ptr) {
 		warn("Bearer <%s> rejected, media <%s> not registered\n", name,
-		     b_name.media_name);
+		     b_names.media_name);
 		goto exit;
 	}
 
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 3480654..d3eac56 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -152,7 +152,7 @@ struct tipc_bearer {
 	struct tipc_node_map nodes;
 };
 
-struct bearer_name {
+struct tipc_bearer_names {
 	char media_name[TIPC_MAX_MEDIA_NAME];
 	char if_name[TIPC_MAX_IF_NAME];
 };
-- 
1.7.4.4
