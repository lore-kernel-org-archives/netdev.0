From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/4] ath: Fix ath_dbg access beyond array bound
Date: Thu,  2 Dec 2010 19:12:38 -0800
Message-ID: <f27b95daeb152de787dea20e4eefd21e65a7108e.1291333544.git.joe@perches.com>
References: <20101202190239.GE7399@tux>
Cc: Peter Stuge <peter@stuge.se>, Felix Fietkau <nbd@openwrt.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Jouni Malinen <jmalinen@atheros.com>,
	Vasanthakumar Thiagarajan <vasanth@atheros.com>,
	Senthil Balasubramanian <senthilkumar@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2182 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932426Ab0LCDNg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Dec 2010 22:13:36 -0500
In-Reply-To: <20101202190239.GE7399@tux>
In-Reply-To: <cover.1291333543.git.joe@perches.com>
References: <cover.1291333543.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ar9300RateSize is not necessarily a power of 4.

Change ar9003_hw_set_target_power_eeprom
to print the targetPowerValT2 array one per line.

ath9k_hw_ar9300_set_txpower repeated the output 4 times per line,
change it to print the targetPowerValT2 value one per line.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c |   27 +----------------------
 1 files changed, 2 insertions(+), 25 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
index 7b13a2e..34d1d7a 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
@@ -4086,22 +4086,9 @@ static void ar9003_hw_set_target_power_eeprom(struct ath_hw *ah, u16 freq,
 	    ar9003_hw_eeprom_get_ht40_tgt_pwr(ah, HT_TARGET_RATE_23, freq,
 					      is2GHz) + ht40PowerIncForPdadc;
 
-	while (i < ar9300RateSize) {
-		ath_dbg(common, ATH_DBG_EEPROM,
-			"TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
-		i++;
-
-		ath_dbg(common, ATH_DBG_EEPROM,
-			"TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
-		i++;
-
-		ath_dbg(common, ATH_DBG_EEPROM,
-			"TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
-		i++;
-
+	for (i = 0; i < ar9300RateSize; i++) {
 		ath_dbg(common, ATH_DBG_EEPROM,
 			"TPC[%02d] 0x%08x\n", i, targetPowerValT2[i]);
-		i++;
 	}
 }
 
@@ -4689,17 +4676,7 @@ static void ath9k_hw_ar9300_set_txpower(struct ath_hw *ah,
 
 	for (i = 0; i < ar9300RateSize; i++) {
 		ath_dbg(common, ATH_DBG_EEPROM,
-			"TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
-		i++;
-		ath_dbg(common, ATH_DBG_EEPROM,
-			"TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
-		i++;
-		ath_dbg(common, ATH_DBG_EEPROM,
-			"TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
-		i++;
-		ath_dbg(common, ATH_DBG_EEPROM,
-			"TPC[%02d] 0x%08x\n\n", i, targetPowerValT2[i]);
-		i++;
+			"TPC[%02d] 0x%08x\n", i, targetPowerValT2[i]);
 	}
 
 	/*
-- 
1.7.3.2.245.g03276.dirty

