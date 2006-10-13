From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 13/14] [TIPC] Unrecognized configuration command now returns error message
Date: Fri, 13 Oct 2006 13:37:54 +0200
Message-ID: <11607394751662-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:51360 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1751404AbWJMLiD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 07:38:03 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

This patch causes TIPC to return an error message when it receives
an unrecognized configuration command.  (Previously, the sender
received no feedback.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/config.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index 285e1bc..ed1351e 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -2,7 +2,7 @@
  * net/tipc/config.c: TIPC configuration management code
  * 
  * Copyright (c) 2002-2006, Ericsson AB
- * Copyright (c) 2004-2005, Wind River Systems
+ * Copyright (c) 2004-2006, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -613,7 +613,8 @@ #endif
 		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_net_id);
 		break;
 	default:
-		rep_tlv_buf = NULL;
+		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
+							  " (unknown command)");
 		break;
 	}
 
-- 
1.4.1

