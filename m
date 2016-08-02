From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0742/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:41:49 +0800
Message-ID: <20160802114149.31523-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	robert.jarzmik@free.fr, mugunthanvnm@ti.com,
	felipe.balbi@linux.intel.com, fw@strlen.de, arnd@arndb.de
To: cmetcalf@mellanox.com, ecree@solarflare.com,
	bkenward@solarflare.com, linux-driver@qlogic.com,
	computersforpeace@gmail.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
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
 drivers/net/ethernet/tile/tilegx.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 0a15acc..fe1bfcc 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -319,7 +319,7 @@ static bool network_cpus_init(void)
 	return true;
 }
 
-module_param_named(cpus, network_cpus_string, charp, 0444);
+module_param_named(cpus, network_cpus_string, charp, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(cpus, "cpulist of cores that handle network interrupts");
 
 /* The "tile_net.loopify=LINK" argument causes the named device to
@@ -328,19 +328,19 @@ MODULE_PARM_DESC(cpus, "cpulist of cores that handle network interrupts");
  * (some) packets along to linux, and forwarding (some) packets sent
  * out by linux.
  */
-module_param_named(loopify, loopify_link_name, charp, 0444);
+module_param_named(loopify, loopify_link_name, charp, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(loopify, "name the device to use loop0/1 for ingress/egress");
 
 /* The "tile_net.custom" argument causes us to ignore the "conventional"
  * classifier metadata, in particular, the "l2_offset".
  */
-module_param_named(custom, custom_flag, bool, 0444);
+module_param_named(custom, custom_flag, bool, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(custom, "indicates a (heavily) customized classifier");
 
 /* The "tile_net.jumbo" argument causes us to support "jumbo" packets,
  * and to allocate the given number of "jumbo" buffers.
  */
-module_param_named(jumbo, jumbo_num, uint, 0444);
+module_param_named(jumbo, jumbo_num, uint, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(jumbo, "the number of buffers to support jumbo packets");
 
 /* Atomically update a statistics field.
-- 
2.9.2
