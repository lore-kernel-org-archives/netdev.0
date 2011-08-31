From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH 2/3] bnx2x: do not set NETIF_F_LRO in bnx2x_init_bp
Date: Wed, 31 Aug 2011 17:00:35 +0200
Message-ID: <1314802836-9862-3-git-send-email-mschmidt@redhat.com>
References: <1314802836-9862-1-git-send-email-mschmidt@redhat.com>
Cc: vladz@broadcom.com, dmitry@broadcom.com, eilong@broadcom.com,
	mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10436 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756191Ab1HaPAr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 11:00:47 -0400
In-Reply-To: <1314802836-9862-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x_fix_features() will take care of clearing NETIF_F_LRO if
'disable_tpa' is used.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index fd32c04..c1285db 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9755,12 +9755,6 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 					"must load devices in order!\n");
 
 	bp->multi_mode = multi_mode;
-
-	/* Set TPA flags */
-	if (disable_tpa)
-		bp->dev->features &= ~NETIF_F_LRO;
-	else
-		bp->dev->features |= NETIF_F_LRO;
 	bp->disable_tpa = disable_tpa;
 
 	if (CHIP_IS_E1(bp))
-- 
1.7.6
