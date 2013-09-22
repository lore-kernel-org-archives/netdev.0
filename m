From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH V3] wireless: rtlwifi: Replace variable with a break
Date: Sun, 22 Sep 2013 22:22:46 +0200
Message-ID: <1379881366-25487-1-git-send-email-peter.senna@gmail.com>
Cc: joe@perches.com, sergei.shtylyov@cogentembedded.com,
	chaoming_li@realsil.com.cn, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Peter Senna Tschudin <peter.senna@gmail.com>
To: Larry.Finger@lwfinger.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:51251 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093Ab3IVUXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Sep 2013 16:23:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the variable continual, and change the while loop
to break when efuse_data == 0xFF.

Tested by compilation only.

CC: Joe Perches <joe@perches.com>
Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
---
Changes from V2:
 - Fix typo in the subject
 - Fix indentation

Changes from V1:
 - Fix the indetation
 - Remove remaining } from removed else

Please ignore the patch:
[PATCH 12/19] wireless: Change variable type to bool

And apply this one instead.

The variable continual was declared as int, but was used as bool. I
sent previous patch changing the variable type to bool, but Joe Perches
proposed that removing the variable and adding a break would be better.

 drivers/net/wireless/rtlwifi/efuse.c | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/efuse.c b/drivers/net/wireless/rtlwifi/efuse.c
index 838a1ed..ae13fb9 100644
--- a/drivers/net/wireless/rtlwifi/efuse.c
+++ b/drivers/net/wireless/rtlwifi/efuse.c
@@ -1203,20 +1203,18 @@ static void efuse_power_switch(struct ieee80211_hw *hw, u8 write, u8 pwrstate)
 
 static u16 efuse_get_current_size(struct ieee80211_hw *hw)
 {
-	int continual = true;
 	u16 efuse_addr = 0;
 	u8 hworden;
 	u8 efuse_data, word_cnts;
 
-	while (continual && efuse_one_byte_read(hw, efuse_addr, &efuse_data)
-	       && (efuse_addr < EFUSE_MAX_SIZE)) {
-		if (efuse_data != 0xFF) {
-			hworden = efuse_data & 0x0F;
-			word_cnts = efuse_calculate_word_cnts(hworden);
-			efuse_addr = efuse_addr + (word_cnts * 2) + 1;
-		} else {
-			continual = false;
-		}
+	while (efuse_one_byte_read(hw, efuse_addr, &efuse_data) &&
+	       efuse_addr < EFUSE_MAX_SIZE) {
+		if (efuse_data == 0xFF)
+			break;
+
+		hworden = efuse_data & 0x0F;
+		word_cnts = efuse_calculate_word_cnts(hworden);
+		efuse_addr = efuse_addr + (word_cnts * 2) + 1;
 	}
 
 	return efuse_addr;
-- 
1.8.3.1
