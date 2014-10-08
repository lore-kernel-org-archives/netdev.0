From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH V3.18] rtlwifi: Fix possible unaligned array in ether_addr_copy()
Date: Wed,  8 Oct 2014 12:44:55 -0500
Message-ID: <1412790295-27858-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, troy_tan@realsil.com.cn,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:49672 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbaJHRpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 13:45:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two macros used to copy BSSID information use ether_addr_copy(), thus
the arrays must be 2-byte aligned. In one case, the array could become
unaligned if the struct containing it were changed. Use the __unaligned(2)
attribute to retain the necessary alignment. In addition, the magic number
used to specify the size of the array is replaced by ETH_ALEN.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/wifi.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index 976667a..6866dcf 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -1370,7 +1370,7 @@ struct rtl_mac {
 	bool rdg_en;
 
 	/*AP*/
-	u8 bssid[6];
+	u8 bssid[ETH_ALEN] __aligned(2);
 	u32 vendor;
 	u8 mcs[16];	/* 16 bytes mcs for HT rates. */
 	u32 basic_rates; /* b/g rates */
-- 
1.8.4.5
