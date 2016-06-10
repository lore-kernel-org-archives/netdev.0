From: Bruno Herrera <bruherrera@gmail.com>
Subject: [PATCH] wlcore: sdio: Fix crash on wlcore_probe_of when failing to parse/map irq
Date: Thu,  9 Jun 2016 21:46:46 -0300
Message-ID: <1465519606-68129-1-git-send-email-bruherrera@gmail.com>
Cc: poggi.raph@gmail.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pdev_data pointer is being freed with kfree but the pointer is not dynamic allocated.

Signed-off-by: Bruno Herrera <bruherrera@gmail.com>
---
 drivers/net/wireless/ti/wlcore/sdio.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/ti/wlcore/sdio.c b/drivers/net/wireless/ti/wlcore/sdio.c
index c172da5..5839acb 100644
--- a/drivers/net/wireless/ti/wlcore/sdio.c
+++ b/drivers/net/wireless/ti/wlcore/sdio.c
@@ -241,7 +241,6 @@ static int wlcore_probe_of(struct device *dev, int *irq,
 	*irq = irq_of_parse_and_map(np, 0);
 	if (!*irq) {
 		dev_err(dev, "No irq in platform data\n");
-		kfree(pdev_data);
 		return -EINVAL;
 	}
 
-- 
2.7.4 (Apple Git-66)
