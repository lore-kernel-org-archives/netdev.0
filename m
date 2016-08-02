From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0711/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:38:55 +0800
Message-ID: <20160802113855.29454-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, hdegoede@redhat.com,
	mugunthanvnm@ti.com, felipe.balbi@linux.intel.com, fw@strlen.de
To: derek.chickles@caviumnetworks.com,
	satananda.burla@caviumnetworks.com,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com, computersforpeace@gmail.com,
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
 drivers/net/ethernet/cavium/liquidio/lio_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 8de79ae..35837ee 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -61,19 +61,19 @@ MODULE_FIRMWARE(LIO_FW_DIR LIO_FW_BASE_NAME LIO_210NV_NAME LIO_FW_NAME_SUFFIX);
 MODULE_FIRMWARE(LIO_FW_DIR LIO_FW_BASE_NAME LIO_410NV_NAME LIO_FW_NAME_SUFFIX);
 
 static int ddr_timeout = 10000;
-module_param(ddr_timeout, int, 0644);
+module_param(ddr_timeout, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ddr_timeout,
 		 "Number of milliseconds to wait for DDR initialization. 0 waits for ddr_timeout to be set to non-zero value before starting to check");
 
 static u32 console_bitmask;
-module_param(console_bitmask, int, 0644);
+module_param(console_bitmask, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(console_bitmask,
 		 "Bitmask indicating which consoles have debug output redirected to syslog.");
 
 #define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK)
 
 static int debug = -1;
-module_param(debug, int, 0644);
+module_param(debug, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(debug, "NETIF_MSG debug bits");
 
 static char fw_type[LIO_MAX_FW_TYPE_LEN];
-- 
2.9.2
