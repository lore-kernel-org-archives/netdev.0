From: Thomas Meyer <thomas@m3y3r.de>
Subject: [PATCH 8/10] ath9k: Use ARRAY_SIZE macro
Date: Sun, 03 Sep 2017 14:19:31 +0200
Message-ID: <1504439110050-1887263060-8-diffsplit-thomas@m3y3r.de>
References: <1504439110050-939061377-0-diffsplit-thomas@m3y3r.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www17.your-server.de ([213.133.104.17]:34267 "EHLO
        www17.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751611AbdICMab (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 08:30:31 -0400
In-Reply-To: <1504439110050-939061377-0-diffsplit-thomas@m3y3r.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use ARRAY_SIZE macro, rather than explicitly coding some variant of it
yourself.
Found with: find -type f -name "*.c" -o -name "*.h" | xargs perl -p -i -e
's/\bsizeof\s*\(\s*(\w+)\s*\)\s*\ /\s*sizeof\s*\(\s*\1\s*\[\s*0\s*\]\s*\)
/ARRAY_SIZE(\1)/g' and manual check/verification.

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
index 3dbfd86ebe36..c2e210c0a770 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
@@ -15,6 +15,7 @@
  */
 
 #include <asm/unaligned.h>
+#include <linux/kernel.h>
 #include "hw.h"
 #include "ar9003_phy.h"
 #include "ar9003_eeprom.h"
@@ -2946,14 +2947,12 @@ static const struct ar9300_eeprom *ar9300_eep_templates[] = {
 
 static const struct ar9300_eeprom *ar9003_eeprom_struct_find_by_id(int id)
 {
-#define N_LOOP (sizeof(ar9300_eep_templates) / sizeof(ar9300_eep_templates[0]))
 	int it;
 
-	for (it = 0; it < N_LOOP; it++)
+	for (it = 0; it < ARRAY_SIZE(ar9300_eep_templates); it++)
 		if (ar9300_eep_templates[it]->templateVersion == id)
 			return ar9300_eep_templates[it];
 	return NULL;
-#undef N_LOOP
 }
 
 static int ath9k_hw_ar9300_check_eeprom(struct ath_hw *ah)
