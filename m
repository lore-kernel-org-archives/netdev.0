From: Syam Sidhardhan <syamsidhardh@gmail.com>
Subject: [PATCH] s3c-adc-battery: Fix possible NULL pointer dereference
Date: Mon, 25 Feb 2013 04:33:25 +0530
Message-ID: <1361747005-29306-1-git-send-email-s.syam@samsung.com>
Cc: syamsidhardh@gmail.com, dwmw2@infradead.org, cbou@mail.ru
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check for (bat == NULL) has to be done before accessing bat

Signed-off-by: Syam Sidhardhan <s.syam@samsung.com>
---
 drivers/power/s3c_adc_battery.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/power/s3c_adc_battery.c b/drivers/power/s3c_adc_battery.c
index d2ca989..5948ce0 100644
--- a/drivers/power/s3c_adc_battery.c
+++ b/drivers/power/s3c_adc_battery.c
@@ -145,14 +145,17 @@ static int s3c_adc_bat_get_property(struct power_supply *psy,
 
 	int new_level;
 	int full_volt;
-	const struct s3c_adc_bat_thresh *lut = bat->pdata->lut_noac;
-	unsigned int lut_size = bat->pdata->lut_noac_cnt;
+	const struct s3c_adc_bat_thresh *lut;
+	unsigned int lut_size;
 
 	if (!bat) {
 		dev_err(psy->dev, "no battery infos ?!\n");
 		return -EINVAL;
 	}
 
+	lut = bat->pdata->lut_noac;
+	lut_size = bat->pdata->lut_noac_cnt;
+
 	if (bat->volt_value < 0 || bat->cur_value < 0 ||
 		jiffies_to_msecs(jiffies - bat->timestamp) >
 			BAT_POLL_INTERVAL) {
-- 
1.7.9.5
