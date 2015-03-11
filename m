From: Priit Laes <plaes@plaes.org>
Subject: [PATCH 2/6] rtlwifi: Clean rtl_evm_db_to_percentage a bit
Date: Wed, 11 Mar 2015 22:03:25 +0200
Message-ID: <1426104209-6913-3-git-send-email-plaes@plaes.org>
References: <1426104209-6913-1-git-send-email-plaes@plaes.org>
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Priit Laes <plaes@plaes.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from plaes.org ([188.166.43.21]:51905 "EHLO plaes.org"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752324AbbCKUDs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 16:03:48 -0400
In-Reply-To: <1426104209-6913-1-git-send-email-plaes@plaes.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Priit Laes <plaes@plaes.org>
---
 drivers/net/wireless/rtlwifi/stats.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/stats.c b/drivers/net/wireless/rtlwifi/stats.c
index 874e7d1..2021223 100644
--- a/drivers/net/wireless/rtlwifi/stats.c
+++ b/drivers/net/wireless/rtlwifi/stats.c
@@ -39,15 +39,8 @@ EXPORT_SYMBOL(rtl_query_rxpwrpercentage);
 
 u8 rtl_evm_db_to_percentage(char value)
 {
-	char ret_val;
-	ret_val = value;
-
-	if (ret_val >= 0)
-		ret_val = 0;
-	if (ret_val <= -33)
-		ret_val = -33;
-	ret_val = 0 - ret_val;
-	ret_val *= 3;
+	char ret_val = clamp(-value, 0, 33) * 3;
+
 	if (ret_val == 99)
 		ret_val = 100;
 
-- 
2.3.1
