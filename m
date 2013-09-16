From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 7/8 V2] rtlwifi: rtl8188ee: Fix smatch warning in rtl8188ee/hw.c
Date: Mon, 16 Sep 2013 13:55:21 -0500
Message-ID: <1379357722-17687-8-git-send-email-Larry.Finger@lwfinger.net>
References: <1379357722-17687-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:44264 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043Ab3IPSz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 14:55:56 -0400
In-Reply-To: <1379357722-17687-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch lists the following:
  CHECK   drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
drivers/net/wireless/rtlwifi/rtl8188ee/hw.c:149 _rtl88ee_set_fw_clock_on() info: ignoring unreachable code.
drivers/net/wireless/rtlwifi/rtl8188ee/hw.c:149 _rtl88ee_set_fw_clock_on() info: ignoring unreachable code.

This info message is the result of a real error due to a missing break statement
in a "while (1)" loop.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org> [3.10+]
---
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
index b68cae3..e06971b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
@@ -143,6 +143,7 @@ static void _rtl88ee_set_fw_clock_on(struct ieee80211_hw *hw,
 		} else {
 			rtlhal->fw_clk_change_in_progress = false;
 			spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
+			break;
 		}
 	}
 
-- 
1.8.1.4
