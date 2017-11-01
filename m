From: Colin King <colin.king@canonical.com>
Subject: [PATCH] iwlegacy: remove redundant pointer sta_priv
Date: Wed,  1 Nov 2017 09:26:22 +0000
Message-ID: <20171101092622.16625-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Pointer sta_priv is assigned but never read, hence it is redundant
and can be removed. Cleans up clang warning:

drivers/net/wireless/intel/iwlegacy/4965-rs.c:2163:2: warning: Value
stored to 'sta_priv' is never read

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/intel/iwlegacy/4965-rs.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/wireless/intel/iwlegacy/4965-rs.c b/drivers/net/wireless/intel/iwlegacy/4965-rs.c
index c055f6da11c6..365a4187fc37 100644
--- a/drivers/net/wireless/intel/iwlegacy/4965-rs.c
+++ b/drivers/net/wireless/intel/iwlegacy/4965-rs.c
@@ -2154,13 +2154,11 @@ il4965_rs_initialize_lq(struct il_priv *il, struct ieee80211_conf *conf,
 	u8 use_green;
 	u8 active_tbl = 0;
 	u8 valid_tx_ant;
-	struct il_station_priv *sta_priv;
 
 	if (!sta || !lq_sta)
 		return;
 
 	use_green = il4965_rs_use_green(il, sta);
-	sta_priv = (void *)sta->drv_priv;
 
 	i = lq_sta->last_txrate_idx;
 
-- 
2.14.1
