From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 06/14] tg3: Restrict ASPM workaround devlist
Date: Mon, 2 Aug 2010 14:26:00 -0700
Message-ID: <1280784368-4226-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1403 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751747Ab0HBV0Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 17:26:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ASPM workaround setting obtained from NVRAM only works with devices
older than 5717.  This patch enforces the restriction.

Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 38979f2..7c2c81a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12188,7 +12188,9 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 		    (cfg2 & NIC_SRAM_DATA_CFG_2_APD_EN))
 			tp->tg3_flags3 |= TG3_FLG3_PHY_ENABLE_APD;
 
-		if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) {
+		if ((tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) &&
+		    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785 &&
+		    !(tp->tg3_flags3 & TG3_FLG3_5717_PLUS)) {
 			u32 cfg3;
 
 			tg3_read_mem(tp, NIC_SRAM_DATA_CFG_3, &cfg3);
-- 
1.7.1


