From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 1/7] tg3: Add missed 5719 workaround change
Date: Wed, 9 Mar 2011 18:58:19 -0800
Message-ID: <1299725905-8498-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, stable@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4248 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752444Ab1CJC6q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 21:58:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 2866d956fe0ad8fc8d8a7c54104ccc879b49406d, entitled
"tg3: Expand 5719 workaround" extended a 5719 A0 workaround to all
revisions of the chip.  There was a change that should have been a
part of that patch that was missed.  This patch adds the missing
piece.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6be4185..6fd5cf0 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8103,7 +8103,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	/* Program the jumbo buffer descriptor ring control
 	 * blocks on those devices that have them.
 	 */
-	if (tp->pci_chip_rev_id == CHIPREV_ID_5719_A0 ||
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
 	    ((tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) &&
 	    !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS))) {
 		/* Setup replenish threshold. */
-- 
1.7.3.4


