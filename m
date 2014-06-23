From: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Subject: [PATCHv3 4/6] rtlwifi/rtl8723ae: Replace magic number by macro
Date: Tue, 24 Jun 2014 00:05:24 +0200
Message-ID: <1403561124-7889-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	Peter Wu <peter-VTkQYDcBqhK7DlmcbJSQ7g@public.gmane.org>,
	Mark Cave-Ayland <mark.cave-ayland-r2/yp8inhXLQXOPxS62xeg@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

For consistency with other drivers, replace a magic number by a macro.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Reviewed-by: Peter Wu <peter-VTkQYDcBqhK7DlmcbJSQ7g@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c  |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/reg.h |    1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
index 65c9e80..8f50ace 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
@@ -1109,7 +1109,7 @@ static int _rtl8723ae_set_media_status(struct ieee80211_hw *hw,
 
 	rtl_write_byte(rtlpriv, (MSR), bt_msr);
 	rtlpriv->cfg->ops->led_control(hw, ledaction);
-	if ((bt_msr & 0x03) == MSR_AP)
+	if ((bt_msr & MSR_MASK) == MSR_AP)
 		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x00);
 	else
 		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x66);
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/reg.h b/drivers/net/wireless/rtlwifi/rtl8723ae/reg.h
index 64376b3..ce2c66f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/reg.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/reg.h
@@ -361,6 +361,7 @@
 #define	MSR_ADHOC				0x01
 #define	MSR_INFRA				0x02
 #define	MSR_AP					0x03
+#define	MSR_MASK				0x03
 
 #define	RRSR_RSC_OFFSET				21
 #define	RRSR_SHORT_OFFSET			23
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
