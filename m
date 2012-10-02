From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] bnx2x: use strlcpy() to copy a string
Date: Tue, 2 Oct 2012 14:47:46 +0300
Message-ID: <20121002114746.GB1413@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:21484 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285Ab2JBLr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 07:47:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DRV_MODULE_VERSION is smaller than the ->version buffer so the memcpy()
copies 1 byte past the end of the string.  It's not super harmful, but
it makes the static checkers complain.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index f7ed122..d5648fc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -3052,9 +3052,8 @@ static void bnx2x_drv_info_ether_stat(struct bnx2x *bp)
 	struct eth_stats_info *ether_stat =
 		&bp->slowpath->drv_info_to_mcp.ether_stat;
 
-	/* leave last char as NULL */
-	memcpy(ether_stat->version, DRV_MODULE_VERSION,
-	       ETH_STAT_INFO_VERSION_LEN - 1);
+	strlcpy(ether_stat->version, DRV_MODULE_VERSION,
+		ETH_STAT_INFO_VERSION_LEN);
 
 	bp->sp_objs[0].mac_obj.get_n_elements(bp, &bp->sp_objs[0].mac_obj,
 					DRV_INFO_ETH_STAT_NUM_MACS_REQUIRED,
