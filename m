From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 05/10] tipc: Optimize initialization of network topology service
Date: Mon, 30 Apr 2012 18:37:03 -0400
Message-ID: <1335825428-16053-6-git-send-email-paul.gortmaker@windriver.com>
References: <1335825428-16053-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<jon.maloy@ericsson.com>, <erik.hugne@ericsson.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35025 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757128Ab2D3WhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 18:37:19 -0400
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
index c8a4f00..ba08940 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -150,7 +150,7 @@ static int tipc_core_start(void)
 	if (!res)
 		res = tipc_nametbl_init();
 	if (!res)
-		res = tipc_k_signal((Handler)tipc_subscr_start, 0);
+		res = tipc_subscr_start();
 	if (!res)
 		res = tipc_cfg_init();
 	if (!res)
-- 
1.7.9.6
