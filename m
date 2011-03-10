From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 7/7] tg3: Remove 5750 PCI code
Date: Wed, 9 Mar 2011 18:58:25 -0800
Message-ID: <1299725905-8498-8-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, stable@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2007 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752096Ab1CJC6q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 21:58:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 5750 ASIC rev was never released as a PCI device.  It only exists as
a PCIe device.  This patch removes the code that supports the former
configuration.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   15 +++++----------
 1 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 2c67cc9..ebec888 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8193,10 +8193,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 			      RDMAC_MODE_MBUF_RBD_CRPT_ENAB |
 			      RDMAC_MODE_MBUF_SBD_CRPT_ENAB;
 
-	/* If statement applies to 5705 and 5750 PCI devices only */
-	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 &&
-	     tp->pci_chip_rev_id != CHIPREV_ID_5705_A0) ||
-	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750)) {
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 &&
+	    tp->pci_chip_rev_id != CHIPREV_ID_5705_A0) {
 		if (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE &&
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {
 			rdmac_mode |= RDMAC_MODE_FIFO_SIZE_128;
@@ -8369,17 +8367,14 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	       WDMAC_MODE_FIFOURUN_ENAB | WDMAC_MODE_FIFOOREAD_ENAB |
 	       WDMAC_MODE_LNGREAD_ENAB);
 
-	/* If statement applies to 5705 and 5750 PCI devices only */
-	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 &&
-	     tp->pci_chip_rev_id != CHIPREV_ID_5705_A0) ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750) {
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 &&
+	    tp->pci_chip_rev_id != CHIPREV_ID_5705_A0) {
 		if ((tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) &&
 		    (tp->pci_chip_rev_id == CHIPREV_ID_5705_A1 ||
 		     tp->pci_chip_rev_id == CHIPREV_ID_5705_A2)) {
 			/* nothing */
 		} else if (!(tr32(TG3PCI_PCISTATE) & PCISTATE_BUS_SPEED_HIGH) &&
-			   !(tp->tg3_flags2 & TG3_FLG2_IS_5788) &&
-			   !(tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS)) {
+			   !(tp->tg3_flags2 & TG3_FLG2_IS_5788)) {
 			val |= WDMAC_MODE_RX_ACCEL;
 		}
 	}
-- 
1.7.3.4


