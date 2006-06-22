From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 24/32] [TIPC] Withdrawing all names from nameless port now returns success, not error
Date: Thu, 22 Jun 2006 15:59:37 +0200
Message-ID: <11509847871959-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:38294 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1030658AbWFVN7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:52 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/port.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 360920b..899e08e 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -1171,8 +1171,6 @@ int tipc_withdraw(u32 ref, unsigned int 
 	p_ptr = tipc_port_lock(ref);
 	if (!p_ptr)
 		return -EINVAL;
-	if (!p_ptr->publ.published)
-		goto exit;
 	if (!seq) {
 		list_for_each_entry_safe(publ, tpubl, 
 					 &p_ptr->publications, pport_list) {
@@ -1199,7 +1197,6 @@ int tipc_withdraw(u32 ref, unsigned int 
 	}
 	if (list_empty(&p_ptr->publications))
 		p_ptr->publ.published = 0;
-exit:
 	tipc_port_unlock(p_ptr);
 	return res;
 }
-- 
1.4.0

