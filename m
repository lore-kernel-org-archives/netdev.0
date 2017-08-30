From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: [PATCH] rtlwifi: rtl8723be: fix duplicated code for different
 branches
Date: Wed, 30 Aug 2017 12:04:24 -0500
Message-ID: <20170830170424.GA19424@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <gustavo@embeddedor.com>
To: Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Refactor code in order to avoid identical code for different branches.

Addresses-Coverity-ID: 1248728
Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
---
This issue was reported by Coverity and it was tested by compilation only.
Please, verify if this is not a copy/paste error.
Also, notice this code has been there since 2014.

 drivers/net/wireless/realtek/rtlwifi/rtl8723be/dm.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/dm.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/dm.c
index 131c0d1..15c117e 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/dm.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/dm.c
@@ -883,12 +883,8 @@ static void rtl8723be_dm_txpower_tracking_callback_thermalmeter(
 	if ((rtldm->power_index_offset[RF90_PATH_A] != 0) &&
 	    (rtldm->txpower_track_control)) {
 		rtldm->done_txpower = true;
-		if (thermalvalue > rtlefuse->eeprom_thermalmeter)
-			rtl8723be_dm_tx_power_track_set_power(hw, BBSWING, 0,
-							     index_for_channel);
-		else
-			rtl8723be_dm_tx_power_track_set_power(hw, BBSWING, 0,
-							     index_for_channel);
+		rtl8723be_dm_tx_power_track_set_power(hw, BBSWING, 0,
+						      index_for_channel);
 
 		rtldm->swing_idx_cck_base = rtldm->swing_idx_cck;
 		rtldm->swing_idx_ofdm_base[RF90_PATH_A] =
-- 
2.5.0
