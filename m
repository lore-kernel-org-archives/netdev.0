From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net 3/4] bnx2x: dcb bit indices flags used as bits
Date: Mon, 12 Mar 2012 17:22:06 -0400
Message-ID: <1331587327-26279-4-git-send-email-yuvalmin@broadcom.com>
References: <1331587327-26279-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4772 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754075Ab2CLO2X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 10:28:23 -0400
In-Reply-To: <1331587327-26279-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DCB flags were updated using the flags' bit offsets instead of
the actual bits. This is now fixed.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c |    8 +++++---
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 7aee469..99389c8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1934,7 +1934,7 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	}
 
 	if (bp->port.pmf)
-		bnx2x_update_drv_flags(bp, DRV_FLAGS_DCB_CONFIGURED, 0);
+		bnx2x_update_drv_flags(bp, 1 << DRV_FLAGS_DCB_CONFIGURED, 0);
 	else
 		bnx2x__link_status_update(bp);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index 5051cf3..6d82ade 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -735,7 +735,9 @@ void bnx2x_dcbx_set_params(struct bnx2x *bp, u32 state)
 						 bp->dcbx_error);
 
 			/* mark DCBX result for PMF migration */
-			bnx2x_update_drv_flags(bp, DRV_FLAGS_DCB_CONFIGURED, 1);
+			bnx2x_update_drv_flags(bp,
+					       1 << DRV_FLAGS_DCB_CONFIGURED,
+					       1);
 #ifdef BCM_DCBNL
 			/*
 			 * Add new app tlvs to dcbnl
@@ -1020,7 +1022,7 @@ void bnx2x_dcbx_init(struct bnx2x *bp)
 		DP(NETIF_MSG_LINK, "dcbx_lldp_params_offset 0x%x\n",
 		   dcbx_lldp_params_offset);
 
-		bnx2x_update_drv_flags(bp, DRV_FLAGS_DCB_CONFIGURED, 0);
+		bnx2x_update_drv_flags(bp, 1 << DRV_FLAGS_DCB_CONFIGURED, 0);
 
 		if (SHMEM_LLDP_DCBX_PARAMS_NONE != dcbx_lldp_params_offset) {
 			bnx2x_dcbx_admin_mib_updated_params(bp,
@@ -1857,7 +1859,7 @@ void bnx2x_dcbx_pmf_update(struct bnx2x *bp)
 	 * read it from shmem and update bp and netdev accordingly
 	 */
 	if (SHMEM2_HAS(bp, drv_flags) &&
-	   GET_FLAGS(SHMEM2_RD(bp, drv_flags), DRV_FLAGS_DCB_CONFIGURED)) {
+	   GET_FLAGS(SHMEM2_RD(bp, drv_flags), 1 << DRV_FLAGS_DCB_CONFIGURED)) {
 		/* Read neg results if dcbx is in the FW */
 		if (bnx2x_dcbx_read_shmem_neg_results(bp))
 			return;
-- 
1.7.9.rc2
