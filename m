From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next PATCH 2/5] bnx2x: add EEE support for 4-port devices
Date: Mon, 10 Sep 2012 18:51:05 +0300
Message-ID: <1347292268-30348-3-git-send-email-yuvalmin@broadcom.com>
References: <1347292268-30348-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3451 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754372Ab2IJQPV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 12:15:21 -0400
In-Reply-To: <1347292268-30348-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prevent functions from disabling EEE to other functions using other ports.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 14afa17..bf60c07 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -6540,7 +6540,6 @@ static int bnx2x_update_link_down(struct link_params *params,
 		/* Prevent LPI Generation by chip */
 		REG_WR(bp, MISC_REG_CPMU_LP_FW_ENABLE_P0 + (params->port << 2),
 		       0);
-		REG_WR(bp, MISC_REG_CPMU_LP_DR_ENABLE, 0);
 		REG_WR(bp, MISC_REG_CPMU_LP_MASK_ENT_P0 + (params->port << 2),
 		       0);
 		vars->eee_status &= ~(SHMEM_EEE_LP_ADV_STATUS_MASK |
@@ -9932,7 +9931,6 @@ static int bnx2x_8483x_disable_eee(struct bnx2x_phy *phy,
 
 	/* Make Certain LPI is disabled */
 	REG_WR(bp, MISC_REG_CPMU_LP_FW_ENABLE_P0 + (params->port << 2), 0);
-	REG_WR(bp, MISC_REG_CPMU_LP_DR_ENABLE, 0);
 
 	/* Prevent Phy from working in EEE and advertising it */
 	rc = bnx2x_84833_cmd_hdlr(phy, params,
-- 
1.7.9.rc2
