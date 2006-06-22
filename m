From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 13/32] [TIPC] Validate entire interface name when locating bearer to enable.
Date: Thu, 22 Jun 2006 15:59:26 +0200
Message-ID: <115098478691-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:35478 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1030651AbWFVN7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:52 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

This fix prevents a bearer from being enabled using the wrong interface.
For example, specifying "eth:eth14" might enable "eth:eth1" by mistake.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/eth_media.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 3ecb100..682da4a 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -2,7 +2,7 @@
  * net/tipc/eth_media.c: Ethernet bearer support for TIPC
  * 
  * Copyright (c) 2001-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005-2006, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -127,8 +127,7 @@ static int enable_bearer(struct tipc_bea
 
 	/* Find device with specified name */
 
-	while (dev && dev->name &&
-	       (memcmp(dev->name, driver_name, strlen(dev->name)))) {
+	while (dev && dev->name && strncmp(dev->name, driver_name, IFNAMSIZ)) {	
 		dev = dev->next;
 	}
 	if (!dev)
-- 
1.4.0

