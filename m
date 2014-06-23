From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCHv3 1/6] rtlwifi/rtl8192de: Fix media status register mask
Date: Mon, 23 Jun 2014 23:48:17 +0200
Message-ID: <1403560098-7520-2-git-send-email-rickard_strandqvist@spectrumdigital.se>
References: <1403560098-7520-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	"John W. Linville" <linville@tuxdriver.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Peter Wu <peter@lekensteyn.nl>,
	Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:62840 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753349AbaFWVrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 17:47:20 -0400
Received: by mail-wi0-f174.google.com with SMTP id bs8so4977149wib.7
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2014 14:47:19 -0700 (PDT)
In-Reply-To: <1403560098-7520-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bt_msr & 0xfc will never match 0x3. Fix this by using a mask that actually matches the available types.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Reviewed-by: Peter Wu <peter@lekensteyn.nl>
---
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c  |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/reg.h |    1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
index 2b08671..280c3da 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
@@ -1128,7 +1128,7 @@ static int _rtl92de_set_media_status(struct ieee80211_hw *hw,
 	}
 	rtl_write_byte(rtlpriv, REG_CR + 2, bt_msr);
 	rtlpriv->cfg->ops->led_control(hw, ledaction);
-	if ((bt_msr & 0xfc) == MSR_AP)
+	if ((bt_msr & MSR_MASK) == MSR_AP)
 		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x00);
 	else
 		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x66);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/reg.h b/drivers/net/wireless/rtlwifi/rtl8192de/reg.h
index 7f29b8d..315a298 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/reg.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/reg.h
@@ -369,6 +369,7 @@
 #define	MSR_ADHOC			0x01
 #define	MSR_INFRA			0x02
 #define	MSR_AP				0x03
+#define	MSR_MASK			0x03
 
 /* 6. Adaptive Control Registers  (Offset: 0x0160 - 0x01CF) */
 /* ----------------------------------------------------- */
-- 
1.7.10.4
