From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 04/11] tg3: Disable multivec mode for 1 MSIX
 vector
Date: Tue, 25 Jan 2011 17:58:50 -0800
Message-ID: <1296007137-23146-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3912 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752216Ab1AZB7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jan 2011 20:59:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For single vector MSI-X allocations, we do not want to enable
multivector modes.  This patch makes the necessary corrections.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 07da2b5..b1274bc 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8322,7 +8322,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32_f(GRC_LOCAL_CTRL, tp->grc_local_ctrl);
 	udelay(100);
 
-	if (tp->tg3_flags2 & TG3_FLG2_USING_MSIX) {
+	if ((tp->tg3_flags2 & TG3_FLG2_USING_MSIX) &&
+		tp->irq_cnt > 1) {
 		val = tr32(MSGINT_MODE);
 		val |= MSGINT_MODE_MULTIVEC_EN | MSGINT_MODE_ENABLE;
 		tw32(MSGINT_MODE, val);
@@ -9062,7 +9063,8 @@ static void tg3_ints_init(struct tg3 *tp)
 
 	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI_OR_MSIX) {
 		u32 msi_mode = tr32(MSGINT_MODE);
-		if (tp->tg3_flags2 & TG3_FLG2_USING_MSIX)
+		if ((tp->tg3_flags2 & TG3_FLG2_USING_MSIX) &&
+		    tp->irq_cnt > 1)
 			msi_mode |= MSGINT_MODE_MULTIVEC_EN;
 		tw32(MSGINT_MODE, msi_mode | MSGINT_MODE_ENABLE);
 	}
-- 
1.7.2.2


