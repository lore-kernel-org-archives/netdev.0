From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/5] wlcore: Use common error handling code in wlcore_nvs_cb()
Date: Sun, 29 Oct 2017 21:11:39 +0100
Message-ID: <7b40d50f-cdac-bd47-5070-894140f7ceb3@users.sourceforge.net>
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
Date: Sun, 29 Oct 2017 18:38:04 +0100

Add a jump target so that a bit of exception handling can be better reused
at the end of this function.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/wireless/ti/wlcore/main.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
index c346c021b999..48380d48ef09 100644
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -6496,16 +6496,14 @@ static void wlcore_nvs_cb(const struct firmware *fw, void *context)
 	ret = wl12xx_get_hw_info(wl);
 	if (ret < 0) {
 		wl1271_error("couldn't get hw info");
-		wl1271_power_off(wl);
-		goto out_free_nvs;
+		goto power_off;
 	}
 
 	ret = request_threaded_irq(wl->irq, hardirq_fn, wlcore_irq,
 				   wl->irq_flags, pdev->name, wl);
 	if (ret < 0) {
 		wl1271_error("interrupt configuration failed");
-		wl1271_power_off(wl);
-		goto out_free_nvs;
+		goto power_off;
 	}
 
 #ifdef CONFIG_PM
@@ -6551,6 +6549,11 @@ static void wlcore_nvs_cb(const struct firmware *fw, void *context)
 out:
 	release_firmware(fw);
 	complete_all(&wl->nvs_loading_complete);
+	return;
+
+power_off:
+	wl1271_power_off(wl);
+	goto out_free_nvs;
 }
 
 int wlcore_probe(struct wl1271 *wl, struct platform_device *pdev)
-- 
2.14.3
