From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 7/8] tipc: use limited socket backlog
Date: Wed,  3 Mar 2010 14:35:10 +0800
Message-ID: <1267598111-12503-7-git-send-email-yi.zhu@intel.com>
References: <1267598111-12503-1-git-send-email-yi.zhu@intel.com>
 <1267598111-12503-2-git-send-email-yi.zhu@intel.com>
 <1267598111-12503-3-git-send-email-yi.zhu@intel.com>
 <1267598111-12503-4-git-send-email-yi.zhu@intel.com>
 <1267598111-12503-5-git-send-email-yi.zhu@intel.com>
 <1267598111-12503-6-git-send-email-yi.zhu@intel.com>
Cc: Zhu Yi <yi.zhu@intel.com>, Per Liden <per.liden@ericsson.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:65441 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754468Ab0CCGdl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 01:33:41 -0500
In-Reply-To: <1267598111-12503-6-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make tipc adapt to the limited socket backlog change.

Cc: Per Liden <per.liden@ericsson.com>
Cc: Jon Maloy <jon.maloy@ericsson.com>
Cc: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>
---
 net/tipc/socket.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 1ea64f0..4b235fc 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1322,8 +1322,10 @@ static u32 dispatch(struct tipc_port *tport, struct sk_buff *buf)
 	if (!sock_owned_by_user(sk)) {
 		res = filter_rcv(sk, buf);
 	} else {
-		sk_add_backlog(sk, buf);
-		res = TIPC_OK;
+		if (sk_add_backlog(sk, buf))
+			res = TIPC_ERR_OVERLOAD;
+		else
+			res = TIPC_OK;
 	}
 	bh_unlock_sock(sk);
 
-- 
1.6.3.3

