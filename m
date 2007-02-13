From: "Michael Chan" <mchan@broadcom.com>
Subject: [TG3 5/8]: Power down 5704 serdes transceiver when shutting
 down.
Date: Tue, 13 Feb 2007 12:14:32 -0800
Message-ID: <1171397672.18944.29.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3532 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751805AbXBMTbV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 14:31:21 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Power down 5704 serdes transceiver when shutting down.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index b6615f1..604f308 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1175,8 +1175,18 @@ static void tg3_nvram_unlock(struct tg3
 
 static void tg3_power_down_phy(struct tg3 *tp)
 {
-	if (tp->tg3_flags2 & TG3_FLG2_PHY_SERDES)
+	if (tp->tg3_flags2 & TG3_FLG2_PHY_SERDES) {
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) {
+			u32 sg_dig_ctrl = tr32(SG_DIG_CTRL);
+			u32 serdes_cfg = tr32(MAC_SERDES_CFG);
+
+			sg_dig_ctrl |=
+				SG_DIG_USING_HW_AUTONEG | SG_DIG_SOFT_RESET;
+			tw32(SG_DIG_CTRL, sg_dig_ctrl);
+			tw32(MAC_SERDES_CFG, serdes_cfg | (1 << 15));
+		}
 		return;
+	}
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
 		u32 val;


