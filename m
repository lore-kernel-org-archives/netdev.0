From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 08/11] bnx2x: notify cnic of address of
 info-to-the-mcp
Date: Wed, 15 Feb 2012 07:10:29 -0500
Message-ID: <1329307832-32454-9-git-send-email-yuvalmin@broadcom.com>
References: <1329307832-32454-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Mintz Yuval" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3789 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751870Ab2BOFQS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 00:16:18 -0500
In-Reply-To: <1329307832-32454-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mintz Yuval <yuvalmin@broadcom.com>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index e0d5f15..1527aed 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -7125,6 +7125,11 @@ int bnx2x_alloc_mem(struct bnx2x *bp)
 	BNX2X_PCI_ALLOC(bp->slowpath, &bp->slowpath_mapping,
 			sizeof(struct bnx2x_slowpath));
 
+#ifdef BCM_CNIC
+	/* write address to which L5 should insert its values */
+	bp->cnic_eth_dev.addr_drv_info_to_mcp = &bp->slowpath->drv_info_to_mcp;
+#endif
+
 	/* Allocated memory for FW statistics  */
 	if (bnx2x_alloc_fw_stats_mem(bp))
 		goto alloc_mem_err;
-- 
1.7.9.rc2
