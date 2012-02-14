From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 01/10] tg3: Disable new DMA engine for 57766
Date: Mon, 13 Feb 2012 17:20:08 -0800
Message-ID: <1329182417-28223-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3514 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758336Ab2BNBVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 20:21:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A bug was found in the new DMA engine for the 57766.  This patch
disables it, which causes the device to fallback to the old DMA engine.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index d418f95..0a765f1 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -8896,9 +8896,6 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	if (tg3_flag(tp, PCI_EXPRESS))
 		rdmac_mode |= RDMAC_MODE_FIFO_LONG_BURST;
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57766)
-		rdmac_mode |= RDMAC_MODE_JMB_2K_MMRR;
-
 	if (tg3_flag(tp, HW_TSO_1) ||
 	    tg3_flag(tp, HW_TSO_2) ||
 	    tg3_flag(tp, HW_TSO_3))
@@ -14190,8 +14187,6 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
 		tp->dma_limit = TG3_TX_BD_DMA_MAX_4K;
-	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57766)
-		tp->dma_limit = TG3_TX_BD_DMA_MAX_2K;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-- 
1.7.3.4
