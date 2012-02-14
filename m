From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 07/10] tg3: Remove unused link config code
Date: Mon, 13 Feb 2012 17:20:14 -0800
Message-ID: <1329182417-28223-8-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1664 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758336Ab2BNBVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 20:21:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When tg3 devices are shutdown, the driver uses the
TG3_PHYFLG_IS_LOW_POWER flag to enable a static phy configuration.
Any attempt to use the link configuration variables is dead code.  This
patch removes such code.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 27cf74c..610997c 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3607,12 +3607,8 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 			tp->link_config.orig_autoneg = tp->link_config.autoneg;
 		}
 
-		if (!(tp->phy_flags & TG3_PHYFLG_ANY_SERDES)) {
-			tp->link_config.speed = SPEED_10;
-			tp->link_config.duplex = DUPLEX_HALF;
-			tp->link_config.autoneg = AUTONEG_ENABLE;
+		if (!(tp->phy_flags & TG3_PHYFLG_ANY_SERDES))
 			tg3_setup_phy(tp, 0);
-		}
 	}
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
-- 
1.7.3.4
