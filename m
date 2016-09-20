From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 3/5] r8152: move PHY settings to hw_phy_cfg
Date: Tue, 20 Sep 2016 16:22:07 +0800
Message-ID: <1394712342-15778-222-Taiwan-albertk@realtek.com>
References: <1394712342-15778-219-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-219-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the PHY relative settings together to hw_phy_cfg().

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index dbf11ba..9ce5bd5 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2632,6 +2632,10 @@ static void rtl8152_disable(struct r8152 *tp)
 
 static void r8152b_hw_phy_cfg(struct r8152 *tp)
 {
+	r8152b_enable_eee(tp);
+	r8152_aldps_en(tp, true);
+	r8152b_enable_fc(tp);
+
 	set_bit(PHY_RESET, &tp->flags);
 }
 
@@ -2839,6 +2843,10 @@ static void r8153_hw_phy_cfg(struct r8152 *tp)
 	sram_write(tp, SRAM_10M_AMP1, 0x00af);
 	sram_write(tp, SRAM_10M_AMP2, 0x0208);
 
+	r8153_enable_eee(tp);
+	r8153_aldps_en(tp, true);
+	r8152b_enable_fc(tp);
+
 	set_bit(PHY_RESET, &tp->flags);
 }
 
@@ -3369,9 +3377,6 @@ static void r8152b_init(struct r8152 *tp)
 		   SPDWN_RXDV_MSK | SPDWN_LINKCHG_MSK;
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_GPHY_INTR_IMR, ocp_data);
 
-	r8152b_enable_eee(tp);
-	r8152_aldps_en(tp, true);
-	r8152b_enable_fc(tp);
 	rtl_tally_reset(tp);
 
 	/* enable rx aggregation */
@@ -3490,9 +3495,6 @@ static void r8153_init(struct r8152 *tp)
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MAC_PWR_CTRL3, 0);
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MAC_PWR_CTRL4, 0);
 
-	r8153_enable_eee(tp);
-	r8153_aldps_en(tp, true);
-	r8152b_enable_fc(tp);
 	rtl_tally_reset(tp);
 	r8153_u2p3en(tp, true);
 }
-- 
2.7.4
