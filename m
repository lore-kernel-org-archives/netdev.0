From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 5/5] wlcore: Use common error handling code in
 wl1271_op_suspend()
Date: Sun, 29 Oct 2017 21:16:02 +0100
Message-ID: <5c4844e8-b519-888d-c772-4f925a4f2a66@users.sourceforge.net>
References: <dc2b8a7c-b4a9-2f92-12b4-a1d0d6911d7c@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Eyal Reizer <eyalr@ti.com>, Iain Hunter <drhunter95@gmail.com>,
        James Minor <james.minor@ni.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Maxim Altshul <maxim.altshul@ti.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <dc2b8a7c-b4a9-2f92-12b4-a1d0d6911d7c@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 29 Oct 2017 20:36:39 +0100

Add a jump target so that a specific error message is stored only once
at the end of this function implementation.
Replace two calls of the macro "wl1271_warning" by goto statements.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/wireless/ti/wlcore/main.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
index 12a9d6509382..a110f61110d5 100644
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -1732,8 +1732,7 @@ static int wl1271_op_suspend(struct ieee80211_hw *hw,
 		ret = wl1271_configure_suspend(wl, wlvif, wow);
 		if (ret < 0) {
 			mutex_unlock(&wl->mutex);
-			wl1271_warning("couldn't prepare device to suspend");
-			return ret;
+			goto report_preparation_failure;
 		}
 	}
 
@@ -1752,10 +1751,8 @@ static int wl1271_op_suspend(struct ieee80211_hw *hw,
 	wl1271_ps_elp_sleep(wl);
 	mutex_unlock(&wl->mutex);
 
-	if (ret < 0) {
-		wl1271_warning("couldn't prepare device to suspend");
-		return ret;
-	}
+	if (ret < 0)
+		goto report_preparation_failure;
 
 	/* flush any remaining work */
 	wl1271_debug(DEBUG_MAC80211, "flushing remaining works");
@@ -1783,6 +1780,10 @@ static int wl1271_op_suspend(struct ieee80211_hw *hw,
 	cancel_delayed_work(&wl->tx_watchdog_work);
 
 	return 0;
+
+report_preparation_failure:
+	wl1271_warning("couldn't prepare device to suspend");
+	return ret;
 }
 
 static int wl1271_op_resume(struct ieee80211_hw *hw)
-- 
2.14.3
