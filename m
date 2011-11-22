From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 3/4] tg3: Restrict large prod ring cap devices
Date: Mon, 21 Nov 2011 17:01:19 -0800
Message-ID: <1321923680-7925-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2493 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757636Ab1KVBCF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Nov 2011 20:02:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Future devices may or may not be capable of supporting larger rx
producer rings.  This patch changes the code so that this flag is set on
an ASIC rev to ASIC rev basis.  Also, this patch changes a place where
the LRG_PROD_RING_CAP flag was not controlling how the rx standard
producer ring size was set.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 096a67e..ea3c5f0 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -8553,10 +8553,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		}
 
 		if (tg3_flag(tp, 57765_PLUS)) {
-			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
-				val = TG3_RX_STD_MAX_SIZE_5700;
-			else
-				val = TG3_RX_STD_MAX_SIZE_5717;
+			val = TG3_RX_STD_RING_SIZE(tp);
 			val <<= BDINFO_FLAGS_MAXLEN_SHIFT;
 			val |= (TG3_RX_STD_DMA_SZ << 2);
 		} else
@@ -14009,7 +14006,9 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
 		tg3_flag_set(tp, 4K_FIFO_LIMIT);
 
-	if (tg3_flag(tp, 5717_PLUS))
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
 		tg3_flag_set(tp, LRG_PROD_RING_CAP);
 
 	if (tg3_flag(tp, 57765_PLUS) &&
-- 
1.7.3.4
