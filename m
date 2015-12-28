From: Ivan Safonov <insafonov@gmail.com>
Subject: [PATCH] /drivers/net/wireless/ath/ath9k remove unnecessary ?:
 operator
Date: Mon, 28 Dec 2015 20:48:52 +0700
Message-ID: <20151228134852.GA10572@alpha.sfu-kras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	ath9k-devel@lists.ath9k.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

((thermometer < 0) ? 0 : (thermometer == X)) and (thermometer == X) are equal for X >= 0.

Signed-off-by: Ivan Safonov <insafonov@gmail.com>
---
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
index 8b4561e..35e57f7 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
@@ -4097,16 +4097,16 @@ static void ar9003_hw_thermometer_apply(struct ath_hw *ah)
 		REG_RMW_FIELD(ah, AR_PHY_65NM_CH2_RXTX4,
 			      AR_PHY_65NM_CH0_RXTX4_THERM_ON_OVR, therm_on);
 
-	therm_on = (thermometer < 0) ? 0 : (thermometer == 0);
+	therm_on = thermometer == 0;
 	REG_RMW_FIELD(ah, AR_PHY_65NM_CH0_RXTX4,
 		      AR_PHY_65NM_CH0_RXTX4_THERM_ON, therm_on);
 	if (pCap->chip_chainmask & BIT(1)) {
-		therm_on = (thermometer < 0) ? 0 : (thermometer == 1);
+		therm_on = thermometer == 1;
 		REG_RMW_FIELD(ah, AR_PHY_65NM_CH1_RXTX4,
 			      AR_PHY_65NM_CH0_RXTX4_THERM_ON, therm_on);
 	}
 	if (pCap->chip_chainmask & BIT(2)) {
-		therm_on = (thermometer < 0) ? 0 : (thermometer == 2);
+		therm_on = thermometer == 2;
 		REG_RMW_FIELD(ah, AR_PHY_65NM_CH2_RXTX4,
 			      AR_PHY_65NM_CH0_RXTX4_THERM_ON, therm_on);
 	}
-- 
2.4.10
