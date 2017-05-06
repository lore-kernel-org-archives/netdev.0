From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH net] bnxt_en: allocate enough space for ->ntp_fltr_bmap
Date: Sat, 6 May 2017 03:49:01 +0300
Message-ID: <20170506004901.ruf3g47szijai4yk@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:47370 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751751AbdEFAtL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 20:49:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have the number of longs, but we need to calculate the number of
bytes required.

Fixes: c0c050c58d84 ("bnxt_en: New Broadcom ethernet driver.")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index b3ba66032980..b56c54d68d5e 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3000,7 +3000,8 @@ static int bnxt_alloc_ntp_fltrs(struct bnxt *bp)
 		INIT_HLIST_HEAD(&bp->ntp_fltr_hash_tbl[i]);
 
 	bp->ntp_fltr_count = 0;
-	bp->ntp_fltr_bmap = kzalloc(BITS_TO_LONGS(BNXT_NTP_FLTR_MAX_FLTR),
+	bp->ntp_fltr_bmap = kcalloc(BITS_TO_LONGS(BNXT_NTP_FLTR_MAX_FLTR),
+				    sizeof(long),
 				    GFP_KERNEL);
 
 	if (!bp->ntp_fltr_bmap)
