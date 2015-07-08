From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] rtlwifi: rtl8821ae: Fix an expression that is always false
Date: Wed,  8 Jul 2015 10:18:50 -0500
Message-ID: <1436368730-636-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>,
	David Binderman <dcb314@hotmail.com>
To: kvalo@codeaurora.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In routine _rtl8821ae_set_media_status(), an incorrect mask results in a test
for AP status to always be false. Similar bugs were fixed in rtl8192cu and
rtl8192de, but this instance was missed at that time.

Reported-by: David Binderman <dcb314@hotmail.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org> [3.18+]
Cc: David Binderman <dcb314@hotmail.com>
---
 drivers/net/wireless/rtlwifi/rtl8821ae/hw.c  | 2 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/reg.h | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c b/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
index 3236d44..b7f18e21 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
@@ -2180,7 +2180,7 @@ static int _rtl8821ae_set_media_status(struct ieee80211_hw *hw,
 
 	rtl_write_byte(rtlpriv, MSR, bt_msr);
 	rtlpriv->cfg->ops->led_control(hw, ledaction);
-	if ((bt_msr & 0xfc) == MSR_AP)
+	if ((bt_msr & MSR_MASK) == MSR_AP)
 		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x00);
 	else
 		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x66);
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/reg.h b/drivers/net/wireless/rtlwifi/rtl8821ae/reg.h
index 53668fc..1d6110f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/reg.h
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/reg.h
@@ -429,6 +429,7 @@
 #define	MSR_ADHOC				0x01
 #define	MSR_INFRA				0x02
 #define	MSR_AP					0x03
+#define MSR_MASK				0x03
 
 #define	RRSR_RSC_OFFSET				21
 #define	RRSR_SHORT_OFFSET			23
-- 
2.1.4
