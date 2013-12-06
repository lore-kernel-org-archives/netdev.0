From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH NEXT] rtlwifi: rtl8192c-common: Fix sparse warning
Date: Thu,  5 Dec 2013 22:07:12 -0600
Message-ID: <1386302832-22453-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:49927 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268Ab3LFEHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 23:07:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparse reports the following:

  CHECK   drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:570:34: warning: dubious: !x & y

There should be a parens around the expression.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
index fd7e4a7..eb78fd8 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
@@ -567,7 +567,7 @@ static void rtl92c_dm_dig(struct ieee80211_hw *hw)
 
 	if (rtlpriv->dm.dm_initialgain_enable == false)
 		return;
-	if (!rtlpriv->dm.dm_flag & DYNAMIC_FUNC_DIG)
+	if (!(rtlpriv->dm.dm_flag & DYNAMIC_FUNC_DIG))
 		return;
 
 	rtl92c_dm_ctrl_initgain_by_twoport(hw);
-- 
1.8.4
