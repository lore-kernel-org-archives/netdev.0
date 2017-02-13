From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 4/9] bnxt_en: Allow NETIF_F_NTUPLE to be enabled on VFs.
Date: Sun, 12 Feb 2017 19:18:13 -0500
Message-ID: <1486945098-4086-5-git-send-email-michael.chan@broadcom.com>
References: <1486945098-4086-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:35461 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751305AbdBMASx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 19:18:53 -0500
Received: by mail-it0-f41.google.com with SMTP id 203so170032055ith.0
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 16:18:53 -0800 (PST)
In-Reply-To: <1486945098-4086-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit ae10ae740ad2 ("bnxt_en: Add new hardware RFS mode.") has added
code to allow NTUPLE to be enabled on VFs.  So we now remove the
BNXT_VF() check in rfs_capable() to allow NTUPLE on VFs.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 8ac5987..516c5d7 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -6291,7 +6291,7 @@ static bool bnxt_rfs_capable(struct bnxt *bp)
 #ifdef CONFIG_RFS_ACCEL
 	int vnics, max_vnics, max_rss_ctxs;
 
-	if (BNXT_VF(bp) || !(bp->flags & BNXT_FLAG_MSIX_CAP))
+	if (!(bp->flags & BNXT_FLAG_MSIX_CAP))
 		return false;
 
 	vnics = 1 + bp->rx_nr_rings;
-- 
1.8.3.1
