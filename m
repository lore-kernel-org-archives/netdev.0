From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: [PATCH] rtlwifi: btcoex: 23b 1ant: fix duplicated code for different
 branches
Date: Thu, 17 Aug 2017 19:22:19 -0500
Message-ID: <20170818002219.GA9475@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <gustavo@embeddedor.com>
To: Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway32.websitewelcome.com ([192.185.145.1]:44186 "EHLO
        gateway32.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753449AbdHRAW0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 20:22:26 -0400
Received: from cm16.websitewelcome.com (cm16.websitewelcome.com [100.42.49.19])
        by gateway32.websitewelcome.com (Postfix) with ESMTP id E48822AC130
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 19:22:25 -0500 (CDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor code in order to avoid identical code for different branches.

This issue was detected with the help of Coccinelle.

Addresses-Coverity-ID: 1415177
Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
---
This issue was reported by Coverity and it was tested by compilation only.

 .../net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b1ant.c   | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b1ant.c b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b1ant.c
index 03998d2..c044252 100644
--- a/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b1ant.c
+++ b/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b1ant.c
@@ -600,14 +600,8 @@ static void halbtc8723b1ant_coex_table_with_type(struct btc_coexist *btcoexist,
 						   0xffffff, 0x3);
 		break;
 	case 5:
-		if ((coex_sta->cck_ever_lock) && (coex_sta->scan_ap_num <= 5))
-			halbtc8723b1ant_coex_table(btcoexist, force_exec,
-						   0x5a5a5a5a, 0x5aaa5a5a,
-						   0xffffff, 0x3);
-		else
-			halbtc8723b1ant_coex_table(btcoexist, force_exec,
-						   0x5a5a5a5a, 0x5aaa5a5a,
-						   0xffffff, 0x3);
+		halbtc8723b1ant_coex_table(btcoexist, force_exec, 0x5a5a5a5a,
+					   0x5aaa5a5a, 0xffffff, 0x3);
 		break;
 	case 6:
 		halbtc8723b1ant_coex_table(btcoexist, force_exec, 0x55555555,
-- 
2.5.0
