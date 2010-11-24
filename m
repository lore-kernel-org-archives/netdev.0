From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 09/10] tg3: Enable phy APD for 5717 and later
 asic revs
Date: Wed, 24 Nov 2010 10:31:53 -0800
Message-ID: <1290623514-18193-10-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3965 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754359Ab0KXScN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 13:32:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables the gphy autopowerdown feature in the phy for all
new devices that support it.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 3079e1f..afb79db 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12431,8 +12431,9 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 		if (cfg2 & (1 << 18))
 			tp->phy_flags |= TG3_PHYFLG_SERDES_PREEMPHASIS;
 
-		if (((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
-		      GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX)) &&
+		if (((tp->tg3_flags3 & TG3_FLG3_5717_PLUS) ||
+		    ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
+		      GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX))) &&
 		    (cfg2 & NIC_SRAM_DATA_CFG_2_APD_EN))
 			tp->phy_flags |= TG3_PHYFLG_ENABLE_APD;
 
-- 
1.7.2.2


