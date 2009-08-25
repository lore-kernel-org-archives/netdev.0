From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 03/12] tg3: Fix TSO test against wrong flags var
Date: Tue, 25 Aug 2009 13:07:54 -0700
Message-ID: <1251232429.25403@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3450 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755735AbZHYUeD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2009 16:34:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julia Lawall discovered that the TG3_FLG2_TSO_CAPABLE flag was being
compared against the wrong flags device member.  This patch implements
the fix.

Signed-off-by: Julia Lawall <julia@diku.dk>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 595ddf2..ca3052d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7192,7 +7192,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 &&
 	     tp->pci_chip_rev_id != CHIPREV_ID_5705_A0) ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750) {
-		if ((tp->tg3_flags & TG3_FLG2_TSO_CAPABLE) &&
+		if ((tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) &&
 		    (tp->pci_chip_rev_id == CHIPREV_ID_5705_A1 ||
 		     tp->pci_chip_rev_id == CHIPREV_ID_5705_A2)) {
 			/* nothing */
-- 
1.6.3.3


