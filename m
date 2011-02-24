From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 07/17] tipc: Clean out all remaining instances of #if 0'd unused code
Date: Wed, 23 Feb 2011 20:26:35 -0500
Message-ID: <1298510805-20630-8-git-send-email-paul.gortmaker@windriver.com>
References: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com, netdev@vger.kernel.org,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34500 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932096Ab1BXB1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 20:27:09 -0500
In-Reply-To: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Remove all instances of legacy or proposed-but-not-implemented code
that lives within an #if 0 ... #endif block.  If some of it is needed
in the future it can recovered out of history, but there is no need
for it to clutter up the active code base.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 include/linux/tipc.h        |    8 +-------
 include/linux/tipc_config.h |   28 +---------------------------
 2 files changed, 2 insertions(+), 34 deletions(-)

diff --git a/include/linux/tipc.h b/include/linux/tipc.h
index 1eefa3f..a5b994a 100644
--- a/include/linux/tipc.h
+++ b/include/linux/tipc.h
@@ -2,7 +2,7 @@
  * include/linux/tipc.h: Include file for TIPC socket interface
  *
  * Copyright (c) 2003-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -130,12 +130,6 @@ static inline unsigned int tipc_node(__u32 addr)
 #define TIPC_SUB_PORTS		0x01	/* filter for port availability */
 #define TIPC_SUB_SERVICE	0x02	/* filter for service availability */
 #define TIPC_SUB_CANCEL		0x04	/* cancel a subscription */
-#if 0
-/* The following filter options are not currently implemented */
-#define TIPC_SUB_NO_BIND_EVTS	0x04	/* filter out "publish" events */
-#define TIPC_SUB_NO_UNBIND_EVTS	0x08	/* filter out "withdraw" events */
-#define TIPC_SUB_SINGLE_EVT	0x10	/* expire after first event */
-#endif
 
 #define TIPC_WAIT_FOREVER	(~0)	/* timeout for permanent subscription */
 
diff --git a/include/linux/tipc_config.h b/include/linux/tipc_config.h
index c14102d..011556f 100644
--- a/include/linux/tipc_config.h
+++ b/include/linux/tipc_config.h
@@ -2,7 +2,7 @@
  * include/linux/tipc_config.h: Include file for TIPC configuration interface
  *
  * Copyright (c) 2003-2006, Ericsson AB
- * Copyright (c) 2005-2007, Wind River Systems
+ * Copyright (c) 2005-2007, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -76,13 +76,6 @@
 #define  TIPC_CMD_SHOW_LINK_STATS   0x000B    /* tx link_name, rx ultra_string */
 #define  TIPC_CMD_SHOW_STATS        0x000F    /* tx unsigned, rx ultra_string */
 
-#if 0
-#define  TIPC_CMD_SHOW_PORT_STATS   0x0008    /* tx port_ref, rx ultra_string */
-#define  TIPC_CMD_RESET_PORT_STATS  0x0009    /* tx port_ref, rx none */
-#define  TIPC_CMD_GET_ROUTES        0x000A    /* tx ?, rx ? */
-#define  TIPC_CMD_GET_LINK_PEER     0x000D    /* tx link_name, rx ? */
-#endif
-
 /*
  * Protected commands:
  * May only be issued by "network administration capable" process.
@@ -109,13 +102,6 @@
 #define  TIPC_CMD_DUMP_LOG          0x410B    /* tx none, rx ultra_string */
 #define  TIPC_CMD_RESET_LINK_STATS  0x410C    /* tx link_name, rx none */
 
-#if 0
-#define  TIPC_CMD_CREATE_LINK       0x4103    /* tx link_create, rx none */
-#define  TIPC_CMD_REMOVE_LINK       0x4104    /* tx link_name, rx none */
-#define  TIPC_CMD_BLOCK_LINK        0x4105    /* tx link_name, rx none */
-#define  TIPC_CMD_UNBLOCK_LINK      0x4106    /* tx link_name, rx none */
-#endif
-
 /*
  * Private commands:
  * May only be issued by "network administration capable" process.
@@ -123,9 +109,6 @@
  */
 
 #define  TIPC_CMD_SET_NODE_ADDR     0x8001    /* tx net_addr, rx none */
-#if 0
-#define  TIPC_CMD_SET_ZONE_MASTER   0x8002    /* tx none, rx none */
-#endif
 #define  TIPC_CMD_SET_REMOTE_MNG    0x8003    /* tx unsigned, rx none */
 #define  TIPC_CMD_SET_MAX_PORTS     0x8004    /* tx unsigned, rx none */
 #define  TIPC_CMD_SET_MAX_PUBL      0x8005    /* tx unsigned, rx none */
@@ -251,15 +234,6 @@ struct tipc_name_table_query {
 #define TIPC_CFG_NOT_SUPPORTED  "\x84"	/* request is not supported by TIPC */
 #define TIPC_CFG_INVALID_VALUE  "\x85"  /* request has invalid argument value */
 
-#if 0
-/* prototypes TLV structures for proposed commands */
-struct tipc_link_create {
-	__u32   domain;
-	struct tipc_media_addr peer_addr;
-	char bearer_name[TIPC_MAX_BEARER_NAME];
-};
-#endif
-
 /*
  * A TLV consists of a descriptor, followed by the TLV value.
  * TLV descriptor fields are stored in network byte order;
-- 
1.7.3.3

