From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: wireless: rtlwifi: rtl8192cu: hw.c:  Cleaning up if statement that always evaluates to false
Date: Sun,  8 Jun 2014 03:39:33 +0200
Message-ID: <1402191573-25878-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	"John W. Linville" <linville@tuxdriver.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Peter Wu <lekensteyn@gmail.com>,
	Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:58720 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297AbaFHBij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jun 2014 21:38:39 -0400
Received: by mail-wi0-f175.google.com with SMTP id f8so2673636wiw.8
        for <netdev@vger.kernel.org>; Sat, 07 Jun 2014 18:38:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I find a logical error in an if statement '(X & 0xfc) == 0x3' is always false

After pointing this out, Larry Finger informed what would be the correct one.
'(X & 0x3) == 0x3'

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
index 07cb06d..40b9ad6 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
@@ -1360,7 +1360,7 @@ static int _rtl92cu_set_media_status(struct ieee80211_hw *hw,
 	}
 	rtl_write_byte(rtlpriv, (MSR), bt_msr);
 	rtlpriv->cfg->ops->led_control(hw, ledaction);
-	if ((bt_msr & 0xfc) == MSR_AP)
+	if ((bt_msr & MSR_AP) == MSR_AP)
 		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x00);
 	else
 		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x66);
-- 
1.7.10.4
