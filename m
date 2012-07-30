From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net 2/5] tg3: Fix Read DMA workaround for 5719 A0.
Date: Sun, 29 Jul 2012 22:15:42 -0700
Message-ID: <1343625345-5155-2-git-send-email-mchan@broadcom.com>
References: <1343625345-5155-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2423 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752598Ab2G3FDo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2012 01:03:44 -0400
In-Reply-To: <1343625345-5155-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The workaround was mis-applied to all 5719 and 5720 chips.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index a528f9a..f0434df 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -9086,8 +9086,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 ||
 	    tg3_flag(tp, 57765_PLUS)) {
 		val = tr32(TG3_RDMA_RSRVCTRL_REG);
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) {
+		if (tp->pci_chip_rev_id == CHIPREV_ID_5719_A0) {
 			val &= ~(TG3_RDMA_RSRVCTRL_TXMRGN_MASK |
 				 TG3_RDMA_RSRVCTRL_FIFO_LWM_MASK |
 				 TG3_RDMA_RSRVCTRL_FIFO_HWM_MASK);
-- 
1.7.1
