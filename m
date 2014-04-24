From: Adam Lee <adam.lee@canonical.com>
Subject: [PATCH 1/2] Revert "rtlwifi: rtl8188ee: enable MSI interrupts mode"
Date: Thu, 24 Apr 2014 11:08:43 +0800
Message-ID: <1398308924-15312-1-git-send-email-adam.lee@canonical.com>
Cc: netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:51105 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753AbaDXDIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 23:08:51 -0400
Received: by mail-pd0-f178.google.com with SMTP id x10so1444799pdj.23
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 20:08:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 2a54eb5e1476426ee639bbfbe179b52342a0d82c.

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
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
index 1b4101b..347af1e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
@@ -93,7 +93,6 @@ int rtl88e_init_sw_vars(struct ieee80211_hw *hw)
 	u8 tid;
 
 	rtl8188ee_bt_reg_init(hw);
-	rtlpci->msi_support = true;
 
 	rtlpriv->dm.dm_initialgain_enable = 1;
 	rtlpriv->dm.dm_flag = 0;
-- 
2.0.0.rc0
