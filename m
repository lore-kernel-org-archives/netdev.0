From: Matthias Kaehlcke <mka@chromium.org>
Subject: [PATCH] ath9k: Add cast to u8 to FREQ2FBIN macro
Date: Thu,  6 Apr 2017 14:21:35 -0700
Message-ID: <20170406212135.72157-1-mka@chromium.org>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, Grant Grundler <grundler@chromium.org>,
        Matthias Kaehlcke <mka@chromium.org>
To: Kalle Valo <kvalo@codeaurora.org>,
        ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The macro results are assigned to u8 variables/fields. Adding the cast
fixes plenty of clang warnings about "implicit conversion from 'int' to
'u8'".

Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
---
 drivers/net/wireless/ath/ath9k/eeprom.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath9k/eeprom.h b/drivers/net/wireless/ath/ath9k/eeprom.h
index 30bf722e33ed..31390af6c33e 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom.h
+++ b/drivers/net/wireless/ath/ath9k/eeprom.h
@@ -106,7 +106,7 @@
 #define AR9285_RDEXT_DEFAULT    0x1F
 
 #define ATH9K_POW_SM(_r, _s)	(((_r) & 0x3f) << (_s))
-#define FREQ2FBIN(x, y)		((y) ? ((x) - 2300) : (((x) - 4800) / 5))
+#define FREQ2FBIN(x, y)		(u8)((y) ? ((x) - 2300) : (((x) - 4800) / 5))
 #define FBIN2FREQ(x, y)		((y) ? (2300 + x) : (4800 + 5 * x))
 #define ath9k_hw_use_flash(_ah)	(!(_ah->ah_flags & AH_USE_EEPROM))
 
-- 
2.12.2.715.g7642488e1d-goog
