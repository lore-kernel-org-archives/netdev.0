From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 02/10] tipc: Optimize initialization of configuration service
Date: Mon, 30 Apr 2012 18:37:00 -0400
Message-ID: <1335825428-16053-3-git-send-email-paul.gortmaker@windriver.com>
References: <1335825428-16053-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<jon.maloy@ericsson.com>, <erik.hugne@ericsson.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:45977 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757281Ab2D3WhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 18:37:15 -0400
In-Reply-To: <1335825428-16053-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Initialization now occurs in the calling thread of control,
rather than being deferred to the TIPC tasklet.  With the
current codebase, the deferral is no longer necessary.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index 68eba03..c8a4f00 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -152,7 +152,7 @@ static int tipc_core_start(void)
 	if (!res)
 		res = tipc_k_signal((Handler)tipc_subscr_start, 0);
 	if (!res)
-		res = tipc_k_signal((Handler)tipc_cfg_init, 0);
+		res = tipc_cfg_init();
 	if (!res)
 		res = tipc_netlink_start();
 	if (!res)
-- 
1.7.9.6
