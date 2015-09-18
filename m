From: Guodong Xu <guodong.xu@linaro.org>
Subject: [PATCH] wlcore: align reg_ch_conf_last[] to 64bit
Date: Fri, 18 Sep 2015 20:37:27 +0800
Message-ID: <1442579847-8138-1-git-send-email-guodong.xu@linaro.org>
To: linux-wireless@vger.kernel.org, kvalo@codeaurora.org,
	eliad@wizery.com, guym@ti.com, arik@wizery.com, nsekhar@ti.com,
	luca@coelho.fi, ramrani@ti.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, guodong.xu@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Align fields reg_ch_conf_last and reg_ch_conf_pending of
struct wl1271{} to 64bit.

Without this, on 64bit ARM, wlcore_set_pending_regdomain_ch() fails at
the point it calls set_bit(ch_bit_idx, (long*)wl->reg_ch_conf_pending);
Here is the error message while doing iw wlan0 scan or connect:

[   10.666857] wlcore: IRQ work
[   10.670046] wlcore: intr: 0x40 (fw_rx_counter = 1, drv_rx_counter = 0, tx_results_counter = 0)
[   10.678697] wlcore: WL1271_ACX_INTR_DATA
[   10.682810] Unhandled fault: alignment fault (0x96000021) at 0xffffffc037a817f4
[   10.690139] Internal error: : 96000021 [#1] PREEMPT SMP
[   10.695366] Modules linked in:
[   10.698437] CPU: 3 PID: 894 Comm: irq/60-wl18xx Tainted: G        W       4.2.0-rc6-linaro-hikey #2
[   10.707501] Hardware name: HiKey Development Board (DT)
[   10.712733] task: ffffffc03a9d1680 ti: ffffffc039e18000 task.ti: ffffffc039e18000
[   10.720239] PC is at set_bit+0x14/0x30
[   10.724002] LR is at wlcore_set_pending_regdomain_ch+0x40/0x4c

Signed-off-by: Guodong Xu <guodong.xu@linaro.org>
---
 drivers/net/wireless/ti/wlcore/wlcore.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ti/wlcore/wlcore.h b/drivers/net/wireless/ti/wlcore/wlcore.h
index a1b6040..906be6a 100644
--- a/drivers/net/wireless/ti/wlcore/wlcore.h
+++ b/drivers/net/wireless/ti/wlcore/wlcore.h
@@ -318,7 +318,7 @@ struct wl1271 {
 	bool watchdog_recovery;
 
 	/* Reg domain last configuration */
-	u32 reg_ch_conf_last[2];
+	u32 reg_ch_conf_last[2]  __aligned(8);
 	/* Reg domain pending configuration */
 	u32 reg_ch_conf_pending[2];
 
-- 
1.9.1
