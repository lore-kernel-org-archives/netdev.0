From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 4/5] r8152: remove r8153_enable_eee
Date: Tue, 20 Sep 2016 16:22:08 +0800
Message-ID: <1394712342-15778-223-Taiwan-albertk@realtek.com>
References: <1394712342-15778-219-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([211.75.126.72]:51149 "EHLO
        rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752636AbcITIXl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 04:23:41 -0400
In-Reply-To: <1394712342-15778-219-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove r8153_enable_eee().

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 9ce5bd5..e7a05dd 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2803,12 +2803,6 @@ static void r8153_eee_en(struct r8152 *tp, bool enable)
 	ocp_reg_write(tp, OCP_EEE_CFG, config);
 }
 
-static void r8153_enable_eee(struct r8152 *tp)
-{
-	r8153_eee_en(tp, true);
-	ocp_reg_write(tp, OCP_EEE_ADV, MDIO_EEE_1000T | MDIO_EEE_100TX);
-}
-
 static void r8153_hw_phy_cfg(struct r8152 *tp)
 {
 	u32 ocp_data;
@@ -2843,7 +2837,9 @@ static void r8153_hw_phy_cfg(struct r8152 *tp)
 	sram_write(tp, SRAM_10M_AMP1, 0x00af);
 	sram_write(tp, SRAM_10M_AMP2, 0x0208);
 
-	r8153_enable_eee(tp);
+	r8153_eee_en(tp, true);
+	ocp_reg_write(tp, OCP_EEE_ADV, MDIO_EEE_1000T | MDIO_EEE_100TX);
+
 	r8153_aldps_en(tp, true);
 	r8152b_enable_fc(tp);
 
-- 
2.7.4
