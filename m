From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 2/2] tg3: Add braces around 5906 workaround.
Date: Thu, 19 May 2011 18:11:04 -0700
Message-ID: <1305853864-2135-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3791 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755465Ab1ETAvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 20:51:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit dabc5c670d3f86d15ee4f42ab38ec5bd2682487d, entitled
"tg3: Move TSO_CAPABLE assignment", moved some TSO flagging code around.
In the process it failed to add braces around an exceptional 5906
condition.  This patch fixes the problem.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 0b78c5d..1d91b35 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -13707,9 +13707,11 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 				     tp->pcie_cap + PCI_EXP_LNKCTL,
 				     &lnkctl);
 		if (lnkctl & PCI_EXP_LNKCTL_CLKREQ_EN) {
-			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
+			if (GET_ASIC_REV(tp->pci_chip_rev_id) ==
+			    ASIC_REV_5906) {
 				tg3_flag_clear(tp, HW_TSO_2);
 				tg3_flag_clear(tp, TSO_CAPABLE);
+			}
 			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
 			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 			    tp->pci_chip_rev_id == CHIPREV_ID_57780_A0 ||
-- 
1.7.3.4


