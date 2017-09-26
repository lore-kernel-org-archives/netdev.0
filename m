From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] net: ena: Remove redundant unlikely()
Date: Tue, 26 Sep 2017 11:04:23 +0200
Message-ID: <20170926090423.16937-1-tklauser@distanz.ch>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>,
        Saeed Bishara <saeed@annapurnalabs.com>,
        Zorik Machulsky <zorik@annapurnalabs.com>,
        "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:45926 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S968363AbdIZJEa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 05:04:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IS_ERR() already implies unlikely(), so it can be omitted.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/amazon/ena/ena_com.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
index 52beba8c7a39..ded29af648c9 100644
--- a/drivers/net/ethernet/amazon/ena/ena_com.c
+++ b/drivers/net/ethernet/amazon/ena/ena_com.c
@@ -315,7 +315,7 @@ static struct ena_comp_ctx *ena_com_submit_admin_cmd(struct ena_com_admin_queue
 					      cmd_size_in_bytes,
 					      comp,
 					      comp_size_in_bytes);
-	if (unlikely(IS_ERR(comp_ctx)))
+	if (IS_ERR(comp_ctx))
 		admin_queue->running_state = false;
 	spin_unlock_irqrestore(&admin_queue->q_lock, flags);
 
@@ -1130,7 +1130,7 @@ int ena_com_execute_admin_command(struct ena_com_admin_queue *admin_queue,
 
 	comp_ctx = ena_com_submit_admin_cmd(admin_queue, cmd, cmd_size,
 					    comp, comp_size);
-	if (unlikely(IS_ERR(comp_ctx))) {
+	if (IS_ERR(comp_ctx)) {
 		if (comp_ctx == ERR_PTR(-ENODEV))
 			pr_debug("Failed to submit command [%ld]\n",
 				 PTR_ERR(comp_ctx));
-- 
2.13.0
