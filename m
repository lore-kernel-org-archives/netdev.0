From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] b43: Fix memory leaks in b43_bus_dev_ssb_init and b43_bus_dev_bcma_init
Date: Tue, 12 Jan 2016 09:01:04 +0800
Message-ID: <1452560464-7146-1-git-send-email-baijiaju1990@163.com>
Cc: linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jia-Ju Bai <baijiaju1990@163.com>
To: kvalo@codeaurora.org, zajec5@gmail.com, joe@perches.com,
	davem@davemloft.net, m@bues.ch, johannes.berg@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The memory allocated by kzalloc in b43_bus_dev_ssb_init and
b43_bus_dev_bcma_initis not freed.
This patch fixes the bug by adding kfree in b43_ssb_remove,
b43_bcma_remove and error handling code of b43_bcma_probe.

Thanks Michael for his suggestion.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/wireless/b43/main.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index ec013fb..2c9d9c1 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -5683,6 +5683,7 @@ static int b43_bcma_probe(struct bcma_device *core)
 	schedule_work(&wl->firmware_load);
 
 bcma_out:
+	kfree(dev);
 	return err;
 
 bcma_err_wireless_exit:
@@ -5716,6 +5717,7 @@ static void b43_bcma_remove(struct bcma_device *core)
 	b43_leds_unregister(wl);
 
 	ieee80211_free_hw(wl->hw);
+	kfree(wldev->dev);
 }
 
 static struct bcma_driver b43_bcma_driver = {
@@ -5798,6 +5800,7 @@ static void b43_ssb_remove(struct ssb_device *sdev)
 
 	b43_leds_unregister(wl);
 	b43_wireless_exit(dev, wl);
+	kfree(dev);
 }
 
 static struct ssb_driver b43_ssb_driver = {
-- 
1.7.9.5
