From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0724/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:40:08 +0800
Message-ID: <20160802114008.30326-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com, fw@strlen.de, davem@davemloft.net,
	Baohua.Song@csr.com
To: yishaih@mellanox.com, benh@kernel.crashing.org, paulus@samba.org,
	mpe@ellerman.id.au, computersforpeace@gmail.com,
	m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19194 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934349AbcHBMSJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:18:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 12c77a7..633b300 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -61,7 +61,7 @@ struct workqueue_struct *mlx4_wq;
 #ifdef CONFIG_MLX4_DEBUG
 
 int mlx4_debug_level = 0;
-module_param_named(debug_level, mlx4_debug_level, int, 0644);
+module_param_named(debug_level, mlx4_debug_level, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(debug_level, "Enable debug tracing if > 0");
 
 #endif /* CONFIG_MLX4_DEBUG */
@@ -69,7 +69,7 @@ MODULE_PARM_DESC(debug_level, "Enable debug tracing if > 0");
 #ifdef CONFIG_PCI_MSI
 
 static int msi_x = 1;
-module_param(msi_x, int, 0444);
+module_param(msi_x, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(msi_x, "attempt to use MSI-X if nonzero");
 
 #else /* CONFIG_PCI_MSI */
@@ -80,19 +80,19 @@ MODULE_PARM_DESC(msi_x, "attempt to use MSI-X if nonzero");
 
 static uint8_t num_vfs[3] = {0, 0, 0};
 static int num_vfs_argc;
-module_param_array(num_vfs, byte , &num_vfs_argc, 0444);
+module_param_array(num_vfs, byte , &num_vfs_argc, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(num_vfs, "enable #num_vfs functions if num_vfs > 0\n"
 			  "num_vfs=port1,port2,port1+2");
 
 static uint8_t probe_vf[3] = {0, 0, 0};
 static int probe_vfs_argc;
-module_param_array(probe_vf, byte, &probe_vfs_argc, 0444);
+module_param_array(probe_vf, byte, &probe_vfs_argc, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(probe_vf, "number of vfs to probe by pf driver (num_vfs > 0)\n"
 			   "probe_vf=port1,port2,port1+2");
 
 int mlx4_log_num_mgm_entry_size = MLX4_DEFAULT_MGM_LOG_ENTRY_SIZE;
 module_param_named(log_num_mgm_entry_size,
-			mlx4_log_num_mgm_entry_size, int, 0444);
+			mlx4_log_num_mgm_entry_size, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(log_num_mgm_entry_size, "log mgm size, that defines the num"
 					 " of qp per mcg, for example:"
 					 " 10 gives 248.range: 7 <="
@@ -101,12 +101,12 @@ MODULE_PARM_DESC(log_num_mgm_entry_size, "log mgm size, that defines the num"
 					 " flow steering when available, set to -1");
 
 static bool enable_64b_cqe_eqe = true;
-module_param(enable_64b_cqe_eqe, bool, 0444);
+module_param(enable_64b_cqe_eqe, bool, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(enable_64b_cqe_eqe,
 		 "Enable 64 byte CQEs/EQEs when the FW supports this (default: True)");
 
 static bool enable_4k_uar;
-module_param(enable_4k_uar, bool, 0444);
+module_param(enable_4k_uar, bool, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(enable_4k_uar,
 		 "Enable using 4K UAR. Should not be enabled if have VFs which do not support 4K UARs (default: false)");
 
@@ -141,11 +141,11 @@ static struct mlx4_profile low_mem_profile = {
 };
 
 static int log_num_mac = 7;
-module_param_named(log_num_mac, log_num_mac, int, 0444);
+module_param_named(log_num_mac, log_num_mac, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(log_num_mac, "Log2 max number of MACs per ETH port (1-7)");
 
 static int log_num_vlan;
-module_param_named(log_num_vlan, log_num_vlan, int, 0444);
+module_param_named(log_num_vlan, log_num_vlan, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(log_num_vlan, "Log2 max number of VLANs per ETH port (0-7)");
 /* Log2 max number of VLANs per ETH port (0-7) */
 #define MLX4_LOG_NUM_VLANS 7
@@ -153,16 +153,16 @@ MODULE_PARM_DESC(log_num_vlan, "Log2 max number of VLANs per ETH port (0-7)");
 #define MLX4_MIN_LOG_NUM_MAC 1
 
 static bool use_prio;
-module_param_named(use_prio, use_prio, bool, 0444);
+module_param_named(use_prio, use_prio, bool, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(use_prio, "Enable steering by VLAN priority on ETH ports (deprecated)");
 
 int log_mtts_per_seg = ilog2(MLX4_MTT_ENTRY_PER_SEG);
-module_param_named(log_mtts_per_seg, log_mtts_per_seg, int, 0444);
+module_param_named(log_mtts_per_seg, log_mtts_per_seg, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(log_mtts_per_seg, "Log2 number of MTT entries per segment (1-7)");
 
 static int port_type_array[2] = {MLX4_PORT_TYPE_NONE, MLX4_PORT_TYPE_NONE};
 static int arr_argc = 2;
-module_param_array(port_type_array, int, &arr_argc, 0444);
+module_param_array(port_type_array, int, &arr_argc, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(port_type_array, "Array of port types: HW_DEFAULT (0) is default "
 				"1 for IB, 2 for Ethernet");
 
-- 
2.9.2
