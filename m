From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 1/4] tg3: Fix 5714S / 5715S / 5780S link failures
Date: Mon, 9 Jun 2008 11:25:17 -0700
Message-ID: <1213046675.0@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2592 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752613AbYFIVUm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2008 17:20:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The git commit ef167e27039eeaea6d3cdd5c547b082e89840bdd entitled
"Fix supporting flowctrl code" introduced a bug that prevents 5714S,
5715S and 5780S devices from falling back to a forced link mode.  The
problem is that the added flow control check will always fail if flow
control is set to autoneg and either RX or TX (or both) flow control
is enabled.  The driver defaults to setting flow control to autoneg
and advertises both RX and TX flow control.

The fix is to remove the errant check.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

---
 drivers/net/tg3.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 07b3f77..4c248d7 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3168,8 +3168,7 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 	err |= tg3_readphy(tp, MII_BMCR, &bmcr);
 
 	if ((tp->link_config.autoneg == AUTONEG_ENABLE) && !force_reset &&
-	    (tp->tg3_flags2 & TG3_FLG2_PARALLEL_DETECT) &&
-	     tp->link_config.flowctrl == tp->link_config.active_flowctrl) {
+	    (tp->tg3_flags2 & TG3_FLG2_PARALLEL_DETECT)) {
 		/* do nothing, just check for link up at the end */
 	} else if (tp->link_config.autoneg == AUTONEG_ENABLE) {
 		u32 adv, new_adv;
-- 
1.5.2.5



