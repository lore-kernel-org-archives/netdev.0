From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] staging: rtl8821ae: Fix potential infinite loop
Date: Wed, 12 Feb 2014 17:10:28 -0600
Message-ID: <1392246628-30049-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:35771 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754039AbaBLXKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 18:10:35 -0500
Received: by mail-oa0-f51.google.com with SMTP id h16so11694720oag.24
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 15:10:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch reports the following:
drivers/staging/rtl8821ae/rtl8821ae/hw.c:153 _rtl8821ae_set_fw_clock_on() info: ignoring unreachable code.

Upon investigation, the code in this region has the capability of creating
an infinite loop.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8821ae/rtl8821ae/hw.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/rtl8821ae/rtl8821ae/hw.c b/drivers/staging/rtl8821ae/rtl8821ae/hw.c
index 5ed7a11..e8344be 100644
--- a/drivers/staging/rtl8821ae/rtl8821ae/hw.c
+++ b/drivers/staging/rtl8821ae/rtl8821ae/hw.c
@@ -147,6 +147,7 @@ static void _rtl8821ae_set_fw_clock_on(struct ieee80211_hw *hw,
 		} else {
 			rtlhal->bfw_clk_change_in_progress = false;
 			spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
+			break;
 		}
 	}
 
-- 
1.8.4.5
