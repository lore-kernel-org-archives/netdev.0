From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 05/12] bnxt_en: Allocate rx_cpu_rmap only if Accelerated RFS is enabled.
Date: Sun, 27 Dec 2015 18:19:22 -0500
Message-ID: <1451258369-21543-6-git-send-email-mchan@broadcom.com>
References: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:44954 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754431AbbL0XTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2015 18:19:30 -0500
In-Reply-To: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also, no need to check for bp->rx_nr_rings as it is always >= 1.  If the
allocation fails, it is not a fatal error and we can still proceed.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 3ce3bd3..06ce100 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4009,10 +4009,8 @@ static int bnxt_set_real_num_queues(struct bnxt *bp)
 		return rc;
 
 #ifdef CONFIG_RFS_ACCEL
-	if (bp->rx_nr_rings)
+	if (bp->flags & BNXT_FLAG_RFS)
 		dev->rx_cpu_rmap = alloc_irq_cpu_rmap(bp->rx_nr_rings);
-	if (!dev->rx_cpu_rmap)
-		rc = -ENOMEM;
 #endif
 
 	return rc;
-- 
1.8.3.1
