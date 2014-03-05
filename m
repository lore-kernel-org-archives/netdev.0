From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 3/3] rtlwifi: rtl8723be: Fix smatch warnings
Date: Wed,  5 Mar 2014 17:26:01 -0600
Message-ID: <1394061961-11682-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1394061961-11682-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:42778 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757235AbaCEX0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 18:26:23 -0500
In-Reply-To: <1394061961-11682-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch reports the following:

drivers/net/wireless/rtlwifi/rtl8723be/fw.c:208 _rtl8723be_fill_h2c_command() warn: variable dereferenced before check 'rtlhal' (see line 69)
drivers/net/wireless/rtlwifi/rtl8723be/hw.c:1732 _rtl8723be_read_adapter_info() error: __builtin_memcpy() '&rtlefuse->efuse_map[0][0]' too small (256 vs 512)

The first one is fixed by removing two pointless tests for NULL pointers.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8723be/fw.c | 8 --------
 drivers/net/wireless/rtlwifi/wifi.h         | 2 +-
 2 files changed, 1 insertion(+), 9 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/fw.c b/drivers/net/wireless/rtlwifi/rtl8723be/fw.c
index 0f3522d..f856be6 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/fw.c
@@ -201,14 +201,6 @@ static void _rtl8723be_fill_h2c_command(struct ieee80211_hw *hw, u8 element_id,
 			 "pHalData->last_hmeboxnum  = %d\n",
 			 rtlhal->last_hmeboxnum);
 	}
-	if (!rtlpriv) {
-		pr_err("rtlpriv bad\n");
-		return;
-	}
-	if (!rtlhal) {
-		pr_err("rtlhal bad\n");
-		return;
-	}
 	spin_lock_irqsave(&rtlpriv->locks.h2c_lock, flag);
 	rtlhal->h2c_setinprogress = false;
 	spin_unlock_irqrestore(&rtlpriv->locks.h2c_lock, flag);
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index 0b4d641..6965afd 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -1587,7 +1587,7 @@ struct rtl_dm {
 	u64 last_rx_ok_cnt;
 };
 
-#define	EFUSE_MAX_LOGICAL_SIZE			256
+#define	EFUSE_MAX_LOGICAL_SIZE			512
 
 struct rtl_efuse {
 	bool autoLoad_ok;
-- 
1.8.4.5
