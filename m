From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 1/6] tg3: Enable EEE support for capable 10/100
 devs
Date: Wed, 14 Dec 2011 13:09:57 -0800
Message-ID: <1323897002-17295-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2397 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758127Ab1LNVJn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Dec 2011 16:09:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some devices in the 57765 ASIC rev that are EEE capable.
Unfortunately the EEE setup code only gets executed if the device is
gigabit capable.  This patch fixes the problem.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 1979151..8a6ea19 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3595,18 +3595,17 @@ static int tg3_phy_autoneg_cfg(struct tg3 *tp, u32 advertise, u32 flowctrl)
 	if (err)
 		goto done;
 
-	if (tp->phy_flags & TG3_PHYFLG_10_100_ONLY)
-		goto done;
-
-	new_adv = ethtool_adv_to_mii_ctrl1000_t(advertise);
+	if (!(tp->phy_flags & TG3_PHYFLG_10_100_ONLY)) {
+		new_adv = ethtool_adv_to_mii_ctrl1000_t(advertise);
 
-	if (tp->pci_chip_rev_id == CHIPREV_ID_5701_A0 ||
-	    tp->pci_chip_rev_id == CHIPREV_ID_5701_B0)
-		new_adv |= CTL1000_AS_MASTER | CTL1000_ENABLE_MASTER;
+		if (tp->pci_chip_rev_id == CHIPREV_ID_5701_A0 ||
+		    tp->pci_chip_rev_id == CHIPREV_ID_5701_B0)
+			new_adv |= CTL1000_AS_MASTER | CTL1000_ENABLE_MASTER;
 
-	err = tg3_writephy(tp, MII_CTRL1000, new_adv);
-	if (err)
-		goto done;
+		err = tg3_writephy(tp, MII_CTRL1000, new_adv);
+		if (err)
+			goto done;
+	}
 
 	if (!(tp->phy_flags & TG3_PHYFLG_EEE_CAP))
 		goto done;
-- 
1.7.3.4
