From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 9/9] tg3: Remove 5719 jumbo frames and TSO
 blocks
Date: Wed, 27 Jul 2011 17:20:54 -0700
Message-ID: <1311812454-18197-10-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4047 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753084Ab1G1AR7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jul 2011 20:17:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The A0 revision of this chip is the only device that requires these
features to be disabled.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index c77a39d..dc3fbf6 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8406,7 +8406,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	/* Program the jumbo buffer descriptor ring control
 	 * blocks on those devices that have them.
 	 */
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+	if (tp->pci_chip_rev_id == CHIPREV_ID_5719_A0 ||
 	    (tg3_flag(tp, JUMBO_CAPABLE) && !tg3_flag(tp, 5780_CLASS))) {
 
 		if (tg3_flag(tp, JUMBO_RING_ENABLE)) {
@@ -13873,7 +13873,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tg3_flag_set(tp, 5705_PLUS);
 
 	/* Determine TSO capabilities */
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+	if (tp->pci_chip_rev_id == CHIPREV_ID_5719_A0)
 		; /* Do nothing. HW bug. */
 	else if (tg3_flag(tp, 57765_PLUS))
 		tg3_flag_set(tp, HW_TSO_3);
@@ -13943,7 +13943,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tg3_flag_set(tp, LRG_PROD_RING_CAP);
 
 	if (tg3_flag(tp, 57765_PLUS) &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5719)
+	    tp->pci_chip_rev_id != CHIPREV_ID_5719_A0)
 		tg3_flag_set(tp, USE_JUMBO_BDFLAG);
 
 	if (!tg3_flag(tp, 5705_PLUS) ||
-- 
1.7.3.4


