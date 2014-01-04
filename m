From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/2] tipc: remove unused code
Date: Sat, 4 Jan 2014 13:49:14 -0800
Message-ID: <20140104134914.13dd63e9@nehalam.linuxnetplumber.net>
References: <20140104134748.0ddff391@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jon Maloy <jon.maloy@ericsson.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:62925 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754703AbaADVtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 16:49:17 -0500
Received: by mail-pd0-f172.google.com with SMTP id g10so16588499pdj.17
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 13:49:17 -0800 (PST)
In-Reply-To: <20140104134748.0ddff391@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove dead code;
       tipc_bearer_find_interface
       tipc_node_redundant_links

This may break out of tree version of TIPC if there still is one.
But that maybe a good thing :-)

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 net/tipc/bearer.c |   19 -------------------
 net/tipc/bearer.h |    1 -
 net/tipc/node.c   |    5 -----
 net/tipc/node.h   |    1 -
 4 files changed, 26 deletions(-)

--- a/net/tipc/bearer.c	2014-01-04 13:39:54.308221241 -0800
+++ b/net/tipc/bearer.c	2014-01-04 13:42:27.553685918 -0800
@@ -185,25 +185,6 @@ struct tipc_bearer *tipc_bearer_find(con
 }
 
 /**
- * tipc_bearer_find_interface - locates bearer object with matching interface name
- */
-struct tipc_bearer *tipc_bearer_find_interface(const char *if_name)
-{
-	struct tipc_bearer *b_ptr;
-	char *b_if_name;
-	u32 i;
-
-	for (i = 0, b_ptr = tipc_bearers; i < MAX_BEARERS; i++, b_ptr++) {
-		if (!b_ptr->active)
-			continue;
-		b_if_name = strchr(b_ptr->name, ':') + 1;
-		if (!strcmp(b_if_name, if_name))
-			return b_ptr;
-	}
-	return NULL;
-}
-
-/**
  * tipc_bearer_get_names - record names of bearers in buffer
  */
 struct sk_buff *tipc_bearer_get_names(void)
--- a/net/tipc/bearer.h	2014-01-04 13:39:54.308221241 -0800
+++ b/net/tipc/bearer.h	2014-01-04 13:42:27.553685918 -0800
@@ -190,7 +190,6 @@ struct sk_buff *tipc_bearer_get_names(vo
 void tipc_bearer_add_dest(struct tipc_bearer *b_ptr, u32 dest);
 void tipc_bearer_remove_dest(struct tipc_bearer *b_ptr, u32 dest);
 struct tipc_bearer *tipc_bearer_find(const char *name);
-struct tipc_bearer *tipc_bearer_find_interface(const char *if_name);
 struct tipc_media *tipc_media_find(const char *name);
 int tipc_bearer_setup(void);
 void tipc_bearer_cleanup(void);
--- a/net/tipc/node.c	2014-01-04 13:39:54.308221241 -0800
+++ b/net/tipc/node.c	2014-01-04 13:42:27.553685918 -0800
@@ -235,11 +235,6 @@ int tipc_node_active_links(struct tipc_n
 	return n_ptr->active_links[0] != NULL;
 }
 
-int tipc_node_redundant_links(struct tipc_node *n_ptr)
-{
-	return n_ptr->working_links > 1;
-}
-
 int tipc_node_is_up(struct tipc_node *n_ptr)
 {
 	return tipc_node_active_links(n_ptr);
--- a/net/tipc/node.h	2014-01-04 13:39:54.308221241 -0800
+++ b/net/tipc/node.h	2014-01-04 13:42:27.553685918 -0800
@@ -115,7 +115,6 @@ void tipc_node_detach_link(struct tipc_n
 void tipc_node_link_down(struct tipc_node *n_ptr, struct tipc_link *l_ptr);
 void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr);
 int tipc_node_active_links(struct tipc_node *n_ptr);
-int tipc_node_redundant_links(struct tipc_node *n_ptr);
 int tipc_node_is_up(struct tipc_node *n_ptr);
 struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space);
 struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space);
