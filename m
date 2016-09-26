From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH net-next] bnx2x: free the mac filter group list before freeing the cmd
Date: Mon, 26 Sep 2016 11:00:44 -0400
Message-ID: <1474902044-16742-1-git-send-email-jbaron@akamai.com>
Cc: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
        netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:19198 "EHLO
        prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934931AbcIZPCR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 11:02:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The group list must be freed prior to freeing the command otherwise
we have a use-after-free.

Signed-off-by: Jason Baron <jbaron@akamai.com>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
Cc: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 4947a9c..cea6bdc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -2714,8 +2714,8 @@ static int bnx2x_mcast_enqueue_cmd(struct bnx2x *bp,
 			elem_group = (struct bnx2x_mcast_elem_group *)
 				     __get_free_page(GFP_ATOMIC | __GFP_ZERO);
 			if (!elem_group) {
-				kfree(new_cmd);
 				bnx2x_free_groups(&new_cmd->group_head);
+				kfree(new_cmd);
 				return -ENOMEM;
 			}
 			total_elems -= MCAST_MAC_ELEMS_PER_PG;
-- 
1.9.1
