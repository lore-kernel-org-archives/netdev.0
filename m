From: Colin King <colin.king@canonical.com>
Subject: [PATCH] rsi: add in missing RSI_FSM_STATES into array fsm_state
Date: Thu, 22 Jun 2017 17:58:04 +0100
Message-ID: <20170622165804.24379-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>,
        Colin Ian King <colin.king@canonical.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Two recent commits added new RSI_FSM_STATES (namely FSM_FW_NOT_LOADED
and FSM_COMMON_DEV_PARAMS_SENT) and the corresponding table fsm_state
was not updated to match. This can lead to an array overrun when
accessing the latter two states in fsm_state. Fix this by adding in
the missing states.

Detected by CoverityScan, CID#1398379 ("Illegal address computation")

Fixes: 9920322ccd8e04 ("rsi: add tx frame for common device configuration")
Fixes: 015e367494c1d5 ("rsi: Register interrupt handler before firmware load")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/rsi/rsi_91x_debugfs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/wireless/rsi/rsi_91x_debugfs.c b/drivers/net/wireless/rsi/rsi_91x_debugfs.c
index 828a042f903f..4c0a493bd44e 100644
--- a/drivers/net/wireless/rsi/rsi_91x_debugfs.c
+++ b/drivers/net/wireless/rsi/rsi_91x_debugfs.c
@@ -125,7 +125,9 @@ static int rsi_stats_read(struct seq_file *seq, void *data)
 	struct rsi_common *common = seq->private;
 
 	unsigned char fsm_state[][32] = {
+		"FSM_FW_NOT_LOADED",
 		"FSM_CARD_NOT_READY",
+		"FSM_COMMON_DEV_PARAMS_SENT",
 		"FSM_BOOT_PARAMS_SENT",
 		"FSM_EEPROM_READ_MAC_ADDR",
 		"FSM_RESET_MAC_SENT",
-- 
2.11.0
