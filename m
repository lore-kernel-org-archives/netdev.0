From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH] tg3: Expand 5719 workaround
Date: Thu, 10 Feb 2011 17:57:27 -0800
Message-ID: <1297389447-5324-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2230 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754457Ab1BKB5g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Feb 2011 20:57:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As a precautionary measure, expand the fix submitted in commit
4d163b75e979833979cc401ae433cb1d7743d57e entitled "tg3: Fix 5719 A0 tx
completion bug" to apply to all 5719 revisions.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index cc06952..ecb3eb0 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -13318,7 +13318,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	}
 
 	/* Determine TSO capabilities */
-	if (tp->pci_chip_rev_id == CHIPREV_ID_5719_A0)
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
 		; /* Do nothing. HW bug. */
 	else if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)
 		tp->tg3_flags2 |= TG3_FLG2_HW_TSO_3;
@@ -13372,7 +13372,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	}
 
 	if ((tp->tg3_flags3 & TG3_FLG3_5717_PLUS) &&
-	    tp->pci_chip_rev_id != CHIPREV_ID_5719_A0)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5719)
 		tp->tg3_flags3 |= TG3_FLG3_USE_JUMBO_BDFLAG;
 
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ||
-- 
1.7.3.4


