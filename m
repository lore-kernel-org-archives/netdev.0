From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 16/16] tipc: Ensure network address change doesn't impact configuration service
Date: Fri, 20 Apr 2012 17:05:24 -0400
Message-ID: <1334955924-907-17-git-send-email-paul.gortmaker@windriver.com>
References: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:62208 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754454Ab2DTVFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 17:05:45 -0400
In-Reply-To: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Enhances command validation done by TIPC's configuration service so
that it works properly even if the node's network address is changed in
mid-operation. The default node address of <0.0.0> is now recognized as an
alias for "this node" even after a new network address has been assigned.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/config.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index f76d3b1..f5458ed 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -290,7 +290,7 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 
 	/* Check command authorization */
 
-	if (likely(orig_node == tipc_own_addr)) {
+	if (likely(in_own_node(orig_node))) {
 		/* command is permitted */
 	} else if (cmd >= 0x8000) {
 		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-- 
1.7.9.3
