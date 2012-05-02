From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next] bnx2x: fix handling single MSIX mode for
 57710/57711
Date: Wed, 2 May 2012 14:16:33 +0300
Message-ID: <1335957393-21804-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2377 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751160Ab2EBLQs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2012 07:16:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 30a5de7723a8a4211be02e94236e9167a424fd07 added
ability to use single MSI-X vector, but lack proper
handling for 57710/57711 HW

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 35b82e0..27d9e4b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -1281,14 +1281,17 @@ static void bnx2x_hc_int_enable(struct bnx2x *bp)
 	int port = BP_PORT(bp);
 	u32 addr = port ? HC_REG_CONFIG_1 : HC_REG_CONFIG_0;
 	u32 val = REG_RD(bp, addr);
-	int msix = (bp->flags & USING_MSIX_FLAG) ? 1 : 0;
-	int msi = (bp->flags & USING_MSI_FLAG) ? 1 : 0;
+	bool msix = (bp->flags & USING_MSIX_FLAG) ? true : false;
+	bool single_msix = (bp->flags & USING_SINGLE_MSIX_FLAG) ? true : false;
+	bool msi = (bp->flags & USING_MSI_FLAG) ? true : false;
 
 	if (msix) {
 		val &= ~(HC_CONFIG_0_REG_SINGLE_ISR_EN_0 |
 			 HC_CONFIG_0_REG_INT_LINE_EN_0);
 		val |= (HC_CONFIG_0_REG_MSI_MSIX_INT_EN_0 |
 			HC_CONFIG_0_REG_ATTN_BIT_EN_0);
+		if (single_msix)
+			val |= HC_CONFIG_0_REG_SINGLE_ISR_EN_0;
 	} else if (msi) {
 		val &= ~HC_CONFIG_0_REG_INT_LINE_EN_0;
 		val |= (HC_CONFIG_0_REG_SINGLE_ISR_EN_0 |
-- 
1.7.7.2
