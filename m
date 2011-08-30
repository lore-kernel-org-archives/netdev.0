From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH 5/7] bnx2x: do not set TPA flags and features in bnx2x_init_bp
Date: Tue, 30 Aug 2011 16:30:44 +0200
Message-ID: <1314714646-3642-6-git-send-email-mschmidt@redhat.com>
References: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
Cc: vladz@broadcom.com, dmitry@broadcom.com, eilong@broadcom.com,
	Michal Schmidt <mschmidt@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49008 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754535Ab1H3ObR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 10:31:17 -0400
In-Reply-To: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The .ndo_{set,fix}_features callbacks are sufficient.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 64314f7..617a072 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9752,15 +9752,6 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 					"must load devices in order!\n");
 
 	bp->multi_mode = multi_mode;
-
-	/* Set TPA flags */
-	if (disable_tpa) {
-		bp->flags &= ~TPA_ENABLE_FLAG;
-		bp->dev->features &= ~NETIF_F_LRO;
-	} else {
-		bp->flags |= TPA_ENABLE_FLAG;
-		bp->dev->features |= NETIF_F_LRO;
-	}
 	bp->disable_tpa = disable_tpa;
 
 	if (CHIP_IS_E1(bp))
-- 
1.7.6
