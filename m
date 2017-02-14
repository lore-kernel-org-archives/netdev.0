From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: [PATCH 1/4] ptp: do not explicitly set drvdata in ptp_clock_register()
Date: Mon, 13 Feb 2017 19:51:05 -0800
Message-ID: <20170214035108.19622-1-dmitry.torokhov@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We do not need explicitly call dev_set_drvdata(), as it is done for us by
device_create().

Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
---
 drivers/ptp/ptp_clock.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index 9c13381b6966..b4e5e8022c29 100644
--- a/drivers/ptp/ptp_clock.c
+++ b/drivers/ptp/ptp_clock.c
@@ -227,8 +227,6 @@ struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
 	if (IS_ERR(ptp->dev))
 		goto no_device;
 
-	dev_set_drvdata(ptp->dev, ptp);
-
 	err = ptp_populate_sysfs(ptp);
 	if (err)
 		goto no_sysfs;
-- 
2.11.0.483.g087da7b7c-goog
