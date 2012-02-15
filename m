From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 10/11] bnx2x: removed code re-checking memory base
 after device open
Date: Wed, 15 Feb 2012 07:10:31 -0500
Message-ID: <1329307832-32454-11-git-send-email-yuvalmin@broadcom.com>
References: <1329307832-32454-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Mintz Yuval" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3822 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751649Ab2BOFQb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 00:16:31 -0500
In-Reply-To: <1329307832-32454-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mintz Yuval <yuvalmin@broadcom.com>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   11 -----------
 1 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 9f29119..b9afd26 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11352,17 +11352,6 @@ static void bnx2x_eeh_recover(struct bnx2x *bp)
 
 	mutex_init(&bp->port.phy_mutex);
 
-	bp->common.shmem_base = REG_RD(bp, MISC_REG_SHARED_MEM_ADDR);
-	bp->link_params.shmem_base = bp->common.shmem_base;
-	BNX2X_DEV_INFO("shmem offset is 0x%x\n", bp->common.shmem_base);
-
-	if (!bp->common.shmem_base ||
-	    (bp->common.shmem_base < 0xA0000) ||
-	    (bp->common.shmem_base >= 0xC0000)) {
-		BNX2X_DEV_INFO("MCP not active\n");
-		bp->flags |= NO_MCP_FLAG;
-		return;
-	}
 
 	val = SHMEM_RD(bp, validity_map[BP_PORT(bp)]);
 	if ((val & (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
-- 
1.7.9.rc2
