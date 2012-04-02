From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH] tg3: Fix 5717 serdes powerdown problem
Date: Mon, 2 Apr 2012 12:01:40 -0700
Message-ID: <1333393300-5102-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1288 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751666Ab2DBTD3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2012 15:03:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If port 0 of a 5717 serdes device powers down, it hides the phy from
port 1.  This patch works around the problem by keeping port 0's phy
powered up.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 7b71387..d2ff8ee 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -2779,7 +2779,9 @@ static void tg3_power_down_phy(struct tg3 *tp, bool do_low_power)
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704 ||
 	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5780 &&
-	     (tp->phy_flags & TG3_PHYFLG_MII_SERDES)))
+	     (tp->phy_flags & TG3_PHYFLG_MII_SERDES)) ||
+	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 &&
+	     !tp->pci_fn))
 		return;
 
 	if (GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5784_AX ||
-- 
1.7.3.4
