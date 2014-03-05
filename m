From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next v2 6/6] tipc: don't log disabled tasklet handler errors
Date: Wed, 5 Mar 2014 08:56:18 +0100
Message-ID: <1394006178-23966-7-git-send-email-erik.hugne@ericsson.com>
References: <1394006178-23966-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ying.xue@windriver.com>, <paul.gortmaker@windriver.com>,
	<richard.alpe@ericsson.com>, Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg20.ericsson.net ([193.180.251.56]:56394 "EHLO
	sesbmg20.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752661AbaCEHzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 02:55:52 -0500
In-Reply-To: <1394006178-23966-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

Failure to schedule a TIPC tasklet with tipc_k_signal because the
tasklet handler is disabled is not an error. It means TIPC is
currently in the process of shutting down. We remove the error
logging in this case.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/handler.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/tipc/handler.c b/net/tipc/handler.c
index e4bc8a2..1fabf16 100644
--- a/net/tipc/handler.c
+++ b/net/tipc/handler.c
@@ -58,7 +58,6 @@ unsigned int tipc_k_signal(Handler routine, unsigned long argument)
 
 	spin_lock_bh(&qitem_lock);
 	if (!handler_enabled) {
-		pr_err("Signal request ignored by handler\n");
 		spin_unlock_bh(&qitem_lock);
 		return -ENOPROTOOPT;
 	}
-- 
1.8.3.2
