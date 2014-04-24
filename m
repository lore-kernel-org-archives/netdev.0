From: Adam Lee <adam.lee@canonical.com>
Subject: [PATCH 2/2] rtlwifi: rtl8723be: disable MSI interrupts mode
Date: Thu, 24 Apr 2014 11:08:44 +0800
Message-ID: <1398308924-15312-2-git-send-email-adam.lee@canonical.com>
References: <1398308924-15312-1-git-send-email-adam.lee@canonical.com>
Cc: netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:51166 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752357AbaDXDI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 23:08:57 -0400
Received: by mail-pb0-f54.google.com with SMTP id ma3so1471818pbc.13
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 20:08:56 -0700 (PDT)
In-Reply-To: <1398308924-15312-1-git-send-email-adam.lee@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

94010fa0dd07e8b904e7c6b6589f15573008ab15 introduced MSI interrupts mode
support, which seemed safe enough with RTL8188EE and RTL8723BE as
RealTek's testing results, but some users reported their RTL8188EE
modules could not connect to any wireless network after the MSI mode was
enabled by Ubuntu 14.04.

So, let's fallback to pin-based mode until rtlwifi's MSI support get
good compatibility.

BugLink: https://bugs.launchpad.net/bugs/1310512
Signed-off-by: Adam Lee <adam.lee@canonical.com>
---
 drivers/net/wireless/rtlwifi/rtl8723be/sw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/sw.c b/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
index b4577eb..a072136 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
@@ -92,7 +92,7 @@ int rtl8723be_init_sw_vars(struct ieee80211_hw *hw)
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 
 	rtl8723be_bt_reg_init(hw);
-	rtlpci->msi_support = true;
+	rtlpci->msi_support = false;
 	rtlpriv->btcoexist.btc_ops = rtl_btc_get_ops_pointer();
 
 	rtlpriv->dm.dm_initialgain_enable = 1;
-- 
2.0.0.rc0
