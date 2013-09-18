From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 7/8 V3] rtlwifi: rtl8188ee: Fix smatch warning in rtl8188ee/hw.c
Date: Wed, 18 Sep 2013 14:58:58 -0500
Message-ID: <1379534339-14895-8-git-send-email-Larry.Finger@lwfinger.net>
References: <1379534339-14895-5-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f182.google.com ([209.85.220.182]:45488 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015Ab3IRT7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 15:59:37 -0400
In-Reply-To: <1379534339-14895-5-git-send-email-Larry.Finger@lwfinger.net>
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

Index: wireless-testing-save/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
===================================================================
--- wireless-testing-save.orig/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
+++ wireless-testing-save/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
@@ -143,6 +143,7 @@ static void _rtl88ee_set_fw_clock_on(str
 		} else {
 			rtlhal->fw_clk_change_in_progress = false;
 			spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
+			break;
 		}
 	}
 
