From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 5/8] tg3: Allow 5761 WOL and LED fixes to 5761S too
Date: Mon, 20 Apr 2009 09:58:01 -0700
Message-ID: <1240247958.7021@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3625 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753253AbZDTRTQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 13:19:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 5761 WOL and LED fixes used the PCI device ID to as the activation
key.  The 5761S requires the same process.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index ed7a86d..c5c3d28 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1950,7 +1950,8 @@ static void tg3_frob_aux_power(struct tg3 *tp)
 				     GRC_LCLCTRL_GPIO_OUTPUT0 |
 				     GRC_LCLCTRL_GPIO_OUTPUT1),
 				    100);
-		} else if (tp->pdev->device == PCI_DEVICE_ID_TIGON3_5761) {
+		} else if (tp->pdev->device == PCI_DEVICE_ID_TIGON3_5761 ||
+			   tp->pdev->device == TG3PCI_DEVICE_TIGON3_5761S) {
 			/* The 5761 non-e device swaps GPIO 0 and GPIO 2. */
 			u32 grc_local_ctrl = GRC_LCLCTRL_GPIO_OE0 |
 					     GRC_LCLCTRL_GPIO_OE1 |
@@ -12183,7 +12184,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
 		tp->grc_local_ctrl |= GRC_LCLCTRL_GPIO_UART_SEL;
 
-	if (tp->pdev->device == PCI_DEVICE_ID_TIGON3_5761) {
+	if (tp->pdev->device == PCI_DEVICE_ID_TIGON3_5761 ||
+	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5761S) {
 		/* Turn off the debug UART. */
 		tp->grc_local_ctrl |= GRC_LCLCTRL_GPIO_UART_SEL;
 		if (tp->tg3_flags2 & TG3_FLG2_IS_NIC)
-- 
1.6.0.6


