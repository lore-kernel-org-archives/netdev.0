From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] fix:gpio: mark symbols static where possible
Date: Sun, 28 Aug 2016 00:27:08 +0800
Message-ID: <1472315228-14802-1-git-send-email-baoyou.xie@linaro.org>
Cc: linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@linaro.org, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: ath9k-devel@qca.qualcomm.com, kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get 1 warning about global functions without a declaration
in the ath9k gpio driver when building with W=1:
drivers/net/wireless/ath/ath9k/gpio.c:25:6: warning: no previous prototype for 'ath_fill_led_pin' [-Wmissing-prototypes]

In fact, this function is only used in the file in which it is declared
and don't need a declaration, but can be made static.
so this patch marks it 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/wireless/ath/ath9k/gpio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath9k/gpio.c b/drivers/net/wireless/ath/ath9k/gpio.c
index 490f74d..ddb2886 100644
--- a/drivers/net/wireless/ath/ath9k/gpio.c
+++ b/drivers/net/wireless/ath/ath9k/gpio.c
@@ -22,7 +22,7 @@
 
 #ifdef CONFIG_MAC80211_LEDS
 
-void ath_fill_led_pin(struct ath_softc *sc)
+static void ath_fill_led_pin(struct ath_softc *sc)
 {
 	struct ath_hw *ah = sc->sc_ah;
 
-- 
2.7.4
