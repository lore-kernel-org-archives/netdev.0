From: David Miller <davem@davemloft.net>
Subject: [PATCH] batman-adv: Fix merge error.
Date: Fri, 16 Dec 2011 15:09:06 -0500 (EST)
Message-ID: <20111216.150906.1619202587161062277.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58139 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376Ab1LPUJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 15:09:11 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pBGK97qh030789
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 12:09:10 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I didn't resolve the merge properly during the last pull of the net
tree into net-next.

The code in the final resolution should set flags to TT_CLIENT_ROAM
not TT_CLIENT_PENDING.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/batman-adv/translation-table.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 46a2b37..ab8dea8 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -244,7 +244,7 @@ void tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 		tt_global_entry->orig_node->tt_poss_change = true;
 		/* The global entry has to be marked as ROAMING and has to be
 		 * kept for consistency purpose */
-		tt_global_entry->common.flags |= TT_CLIENT_PENDING;
+		tt_global_entry->common.flags |= TT_CLIENT_ROAM;
 		tt_global_entry->roam_at = jiffies;
 		send_roam_adv(bat_priv, tt_global_entry->common.addr,
 			      tt_global_entry->orig_node);
-- 
1.7.7.4
