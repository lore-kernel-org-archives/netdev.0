From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH V2 6/7] tipc: use limited socket backlog
Date: Wed,  3 Mar 2010 16:36:28 +0800
Message-ID: <1267605389-7369-6-git-send-email-yi.zhu@intel.com>
References: <1267605389-7369-1-git-send-email-yi.zhu@intel.com>
 <1267605389-7369-2-git-send-email-yi.zhu@intel.com>
 <1267605389-7369-3-git-send-email-yi.zhu@intel.com>
 <1267605389-7369-4-git-send-email-yi.zhu@intel.com>
 <1267605389-7369-5-git-send-email-yi.zhu@intel.com>
Cc: Zhu Yi <yi.zhu@intel.com>, Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60230 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752238Ab0CCIeu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 03:34:50 -0500
In-Reply-To: <1267605389-7369-5-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make tipc adapt to the limited socket backlog change.

Cc: Jon Maloy <jon.maloy@ericsson.com>
Cc: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>
---
 net/tipc/socket.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 1ea64f0..22bfbc3 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1322,8 +1322,10 @@ static u32 dispatch(struct tipc_port *tport, struct sk_buff *buf)
 	if (!sock_owned_by_user(sk)) {
 		res = filter_rcv(sk, buf);
 	} else {
-		sk_add_backlog(sk, buf);
-		res = TIPC_OK;
+		if (sk_add_backlog_limited(sk, buf))
+			res = TIPC_ERR_OVERLOAD;
+		else
+			res = TIPC_OK;
 	}
 	bh_unlock_sock(sk);
 
-- 
1.6.3.3

