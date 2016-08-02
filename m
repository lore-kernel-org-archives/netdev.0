From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0073/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 18:38:39 +0800
Message-ID: <20160802103839.18619-1-baolex.ni@intel.com>
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
 drivers/atm/solos-pci.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 6ac2b2b..5eabe52 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -161,12 +161,12 @@ MODULE_PARM_DESC(firmware_upgrade, "Initiate Solos firmware upgrade");
 MODULE_PARM_DESC(fpga_upgrade, "Initiate FPGA upgrade");
 MODULE_PARM_DESC(db_firmware_upgrade, "Initiate daughter board Solos firmware upgrade");
 MODULE_PARM_DESC(db_fpga_upgrade, "Initiate daughter board FPGA upgrade");
-module_param(reset, int, 0444);
-module_param(atmdebug, int, 0644);
-module_param(firmware_upgrade, int, 0444);
-module_param(fpga_upgrade, int, 0444);
-module_param(db_firmware_upgrade, int, 0444);
-module_param(db_fpga_upgrade, int, 0444);
+module_param(reset, int, S_IRUSR | S_IRGRP | S_IROTH);
+module_param(atmdebug, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
+module_param(firmware_upgrade, int, S_IRUSR | S_IRGRP | S_IROTH);
+module_param(fpga_upgrade, int, S_IRUSR | S_IRGRP | S_IROTH);
+module_param(db_firmware_upgrade, int, S_IRUSR | S_IRGRP | S_IROTH);
+module_param(db_fpga_upgrade, int, S_IRUSR | S_IRGRP | S_IROTH);
 
 static void fpga_queue(struct solos_card *card, int port, struct sk_buff *skb,
 		       struct atm_vcc *vcc);
@@ -584,7 +584,7 @@ static ssize_t hardware_show(struct device *dev, struct device_attribute *attr,
 	return sprintf(buf, "%d\n", data32);
 }
 
-static DEVICE_ATTR(console, 0644, console_show, console_store);
+static DEVICE_ATTR(console, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH, console_show, console_store);
 
 
 #define SOLOS_ATTR_RO(x) static DEVICE_ATTR(x, 0444, solos_param_show, NULL);
@@ -592,14 +592,14 @@ static DEVICE_ATTR(console, 0644, console_show, console_store);
 
 #include "solos-attrlist.c"
 
-static SOLOS_GPIO_ATTR(GPIO1, 0644, geos_gpio_show, geos_gpio_store, 9);
-static SOLOS_GPIO_ATTR(GPIO2, 0644, geos_gpio_show, geos_gpio_store, 10);
-static SOLOS_GPIO_ATTR(GPIO3, 0644, geos_gpio_show, geos_gpio_store, 11);
-static SOLOS_GPIO_ATTR(GPIO4, 0644, geos_gpio_show, geos_gpio_store, 12);
-static SOLOS_GPIO_ATTR(GPIO5, 0644, geos_gpio_show, geos_gpio_store, 13);
-static SOLOS_GPIO_ATTR(PushButton, 0444, geos_gpio_show, NULL, 14);
-static SOLOS_GPIO_ATTR(HardwareVersion, 0444, hardware_show, NULL, 0);
-static SOLOS_GPIO_ATTR(HardwareVariant, 0444, hardware_show, NULL, 1);
+static SOLOS_GPIO_ATTR(GPIO1, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH, geos_gpio_show, geos_gpio_store, 9);
+static SOLOS_GPIO_ATTR(GPIO2, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH, geos_gpio_show, geos_gpio_store, 10);
+static SOLOS_GPIO_ATTR(GPIO3, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH, geos_gpio_show, geos_gpio_store, 11);
+static SOLOS_GPIO_ATTR(GPIO4, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH, geos_gpio_show, geos_gpio_store, 12);
+static SOLOS_GPIO_ATTR(GPIO5, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH, geos_gpio_show, geos_gpio_store, 13);
+static SOLOS_GPIO_ATTR(PushButton, S_IRUSR | S_IRGRP | S_IROTH, geos_gpio_show, NULL, 14);
+static SOLOS_GPIO_ATTR(HardwareVersion, S_IRUSR | S_IRGRP | S_IROTH, hardware_show, NULL, 0);
+static SOLOS_GPIO_ATTR(HardwareVariant, S_IRUSR | S_IRGRP | S_IROTH, hardware_show, NULL, 1);
 #undef SOLOS_ATTR_RO
 #undef SOLOS_ATTR_RW
 
-- 
2.9.2
