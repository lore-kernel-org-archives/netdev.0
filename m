From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 2/6] bnxt_en: Clear TPA flags when BNXT_FLAG_NO_AGG_RINGS is set.
Date: Tue, 10 Jan 2017 20:12:35 -0500
Message-ID: <1484097159-21575-3-git-send-email-michael.chan@broadcom.com>
References: <1484097159-21575-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36761 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760648AbdAKBM6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 20:12:58 -0500
Received: by mail-pf0-f172.google.com with SMTP id 189so43493298pfu.3
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 17:12:58 -0800 (PST)
In-Reply-To: <1484097159-21575-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit bdbd1eb59c56 ("bnxt_en: Handle no aggregation ring gracefully.")
introduced the BNXT_FLAG_NO_AGG_RINGS flag.  For consistency,
bnxt_set_tpa_flags() should also clear TPA flags when there are no
aggregation rings.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index c091850..df2358b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2467,6 +2467,8 @@ static int bnxt_calc_nr_ring_pages(u32 ring_size, int desc_per_pg)
 static void bnxt_set_tpa_flags(struct bnxt *bp)
 {
 	bp->flags &= ~BNXT_FLAG_TPA;
+	if (bp->flags & BNXT_FLAG_NO_AGG_RINGS)
+		return;
 	if (bp->dev->features & NETIF_F_LRO)
 		bp->flags |= BNXT_FLAG_LRO;
 	if (bp->dev->features & NETIF_F_GRO)
-- 
1.8.3.1
