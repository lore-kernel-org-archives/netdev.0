From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0869/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:53:44 +0800
Message-ID: <20160802115344.7912-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com
To: richardcochran@gmail.com, benh@kernel.crashing.org,
	paulus@samba.org, mpe@ellerman.id.au, dwmw2@infradead.org,
	m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/ptp/ptp_sysfs.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/ptp/ptp_sysfs.c b/drivers/ptp/ptp_sysfs.c
index 302e626..e957e42 100644
--- a/drivers/ptp/ptp_sysfs.c
+++ b/drivers/ptp/ptp_sysfs.c
@@ -28,7 +28,7 @@ static ssize_t clock_name_show(struct device *dev,
 	struct ptp_clock *ptp = dev_get_drvdata(dev);
 	return snprintf(page, PAGE_SIZE-1, "%s\n", ptp->info->name);
 }
-static DEVICE_ATTR(clock_name, 0444, clock_name_show, NULL);
+static DEVICE_ATTR(clock_name, S_IRUSR | S_IRGRP | S_IROTH, clock_name_show, NULL);
 
 #define PTP_SHOW_INT(name, var)						\
 static ssize_t var##_show(struct device *dev,				\
@@ -235,10 +235,10 @@ static ssize_t ptp_pin_store(struct device *dev, struct device_attribute *attr,
 	return count;
 }
 
-static DEVICE_ATTR(extts_enable, 0220, NULL, extts_enable_store);
-static DEVICE_ATTR(fifo,         0444, extts_fifo_show, NULL);
-static DEVICE_ATTR(period,       0220, NULL, period_store);
-static DEVICE_ATTR(pps_enable,   0220, NULL, pps_enable_store);
+static DEVICE_ATTR(extts_enable, S_IWUSR | S_IWGRP, NULL, extts_enable_store);
+static DEVICE_ATTR(fifo,         S_IRUSR | S_IRGRP | S_IROTH, extts_fifo_show, NULL);
+static DEVICE_ATTR(period,       S_IWUSR | S_IWGRP, NULL, period_store);
+static DEVICE_ATTR(pps_enable,   S_IWUSR | S_IWGRP, NULL, pps_enable_store);
 
 int ptp_cleanup_sysfs(struct ptp_clock *ptp)
 {
-- 
2.9.2
