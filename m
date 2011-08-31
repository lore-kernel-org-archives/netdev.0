From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 1/8] tg3: Check all adv bits when checking
 config
Date: Wed, 31 Aug 2011 14:44:47 -0700
Message-ID: <1314827094-29714-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2319 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932160Ab1HaRzb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 13:55:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes sure the driver checks all advertisement bits when
checking the current hw advertisements.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 0f81111..de98c10 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3334,8 +3334,9 @@ static int tg3_copper_is_advertising_all(struct tg3 *tp, u32 mask)
 	if (tg3_readphy(tp, MII_ADVERTISE, &adv_reg))
 		return 0;
 
-	if ((adv_reg & all_mask) != all_mask)
+	if ((adv_reg & ADVERTISE_ALL) != all_mask)
 		return 0;
+
 	if (!(tp->phy_flags & TG3_PHYFLG_10_100_ONLY)) {
 		u32 tg3_ctrl;
 
@@ -3348,7 +3349,8 @@ static int tg3_copper_is_advertising_all(struct tg3 *tp, u32 mask)
 		if (tg3_readphy(tp, MII_CTRL1000, &tg3_ctrl))
 			return 0;
 
-		if ((tg3_ctrl & all_mask) != all_mask)
+		tg3_ctrl &= (ADVERTISE_1000HALF | ADVERTISE_1000FULL);
+		if (tg3_ctrl != all_mask)
 			return 0;
 	}
 	return 1;
-- 
1.7.3.4
