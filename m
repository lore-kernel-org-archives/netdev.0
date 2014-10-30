From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 6/6 V3.18] rtlwifi: rtl8192se: Fix firmware loading
Date: Wed, 29 Oct 2014 23:17:13 -0500
Message-ID: <1414642633-3700-7-git-send-email-Larry.Finger@lwfinger.net>
References: <1414642633-3700-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org,
	Murilo Opsfelder Araujo <mopsfelder@gmail.com>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:62250 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752421AbaJ3ERb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 00:17:31 -0400
In-Reply-To: <1414642633-3700-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An error in the code makes the allocated space for firmware to be too
small.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Murilo Opsfelder Araujo <mopsfelder@gmail.com>
---
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
index 1fd2208..aadba29 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
@@ -209,8 +209,8 @@ static int rtl92s_init_sw_vars(struct ieee80211_hw *hw)
 	if (!rtlpriv->rtlhal.pfirmware)
 		return 1;
 
-	rtlpriv->max_fw_size = RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE;
-
+	rtlpriv->max_fw_size = RTL8190_MAX_FIRMWARE_CODE_SIZE*2 +
+			       sizeof(struct fw_hdr);
 	pr_info("Driver for Realtek RTL8192SE/RTL8191SE\n"
 		"Loading firmware %s\n", rtlpriv->cfg->fw_name);
 	/* request fw */
-- 
2.1.1
