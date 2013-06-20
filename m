From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 04/04] bnx2x: Fix 20G KR2 support claims
Date: Thu, 20 Jun 2013 17:39:11 +0300
Message-ID: <1371739151-15744-5-git-send-email-yuvalmin@broadcom.com>
References: <1371739151-15744-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4483 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757757Ab3FTOja (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 10:39:30 -0400
In-Reply-To: <1371739151-15744-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yanivr@broadcom.com>

Don't claim 20G is supported if the speed is unsupported by the phys
(reflected by various ethtools and ndos).

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 12cc701..ba3e7e8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10559,6 +10559,10 @@ static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch_cfg)
 		if (!(bp->link_params.speed_cap_mask[idx] &
 					PORT_HW_CFG_SPEED_CAPABILITY_D0_10G))
 			bp->port.supported[idx] &= ~SUPPORTED_10000baseT_Full;
+
+		if (!(bp->link_params.speed_cap_mask[idx] &
+					PORT_HW_CFG_SPEED_CAPABILITY_D0_20G))
+			bp->port.supported[idx] &= ~SUPPORTED_20000baseKR2_Full;
 	}
 
 	BNX2X_DEV_INFO("supported 0x%x 0x%x\n", bp->port.supported[0],
-- 
1.8.1.227.g44fe835
