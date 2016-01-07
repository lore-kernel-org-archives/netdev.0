From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH] wlcore: fix error handling in wlcore_event_fw_logger
Date: Thu, 07 Jan 2016 14:28:50 +0100
Message-ID: <1452173330-19963-1-git-send-email-a.hajda@samsung.com>
Cc: Andrzej Hajda <a.hajda@samsung.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	linux-kernel@vger.kernel.org (open list)
To: Kalle Valo <kvalo@codeaurora.org>, Shahar Patury <shaharp@ti.com>,
	linux-wireless@vger.kernel.org (open list:TI WILINK WIRELESS DRIVERS)
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

wlcore_read/wlcore_write can return negative values so it should
be assigned to signed variable.

The problem has been detected using proposed semantic patch
scripts/coccinelle/tests/unsigned_lesser_than_zero.cocci [1].

[1]: http://permalink.gmane.org/gmane.linux.kernel/2120705

Fixes: 3719c17e1816 ("wlcore/wl18xx: fw logger over sdio")
Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
 drivers/net/wireless/ti/wlcore/event.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ti/wlcore/event.c b/drivers/net/wireless/ti/wlcore/event.c
index c964054..4b59f67 100644
--- a/drivers/net/wireless/ti/wlcore/event.c
+++ b/drivers/net/wireless/ti/wlcore/event.c
@@ -38,7 +38,7 @@
 
 int wlcore_event_fw_logger(struct wl1271 *wl)
 {
-	u32 ret;
+	int ret;
 	struct fw_logger_information fw_log;
 	u8  *buffer;
 	u32 internal_fw_addrbase = WL18XX_DATA_RAM_BASE_ADDRESS;
-- 
1.9.1
