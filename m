From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0067/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 18:38:14 +0800
Message-ID: <20160802103814.18222-1-baolex.ni@intel.com>
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com
To: 3chas3@gmail.com, tj@kernel.org, lenb@kernel.org, x86@kernel.org,
	hpa@zytor.com
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
 drivers/atm/adummy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/adummy.c b/drivers/atm/adummy.c
index f9b983a..e5768cd 100644
--- a/drivers/atm/adummy.c
+++ b/drivers/atm/adummy.c
@@ -64,7 +64,7 @@ static ssize_t __show_signal(struct device *dev,
 	struct atm_dev *atm_dev = container_of(dev, struct atm_dev, class_dev);
 	return sprintf(buf, "%d\n", atm_dev->signal);
 }
-static DEVICE_ATTR(signal, 0644, __show_signal, __set_signal);
+static DEVICE_ATTR(signal, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH, __show_signal, __set_signal);
 
 static struct attribute *adummy_attrs[] = {
 	&dev_attr_signal.attr,
-- 
2.9.2
