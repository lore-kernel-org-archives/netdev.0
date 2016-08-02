From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0730/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:40:43 +0800
Message-ID: <20160802114043.30726-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	romieu@fr.zoreil.com, Baohua.Song@csr.com
To: Dept-GELinuxNICDev@qlogic.com, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com, mpe@ellerman.id.au,
	computersforpeace@gmail.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16742 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934189AbcHBMSZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:18:25 -0400
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
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 1c29105..7c5c9b5 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -34,25 +34,25 @@ static const char qlcnic_driver_string[] = "QLogic 1/10 GbE "
 	"Converged/Intelligent Ethernet Driver v" QLCNIC_LINUX_VERSIONID;
 
 static int qlcnic_mac_learn;
-module_param(qlcnic_mac_learn, int, 0444);
+module_param(qlcnic_mac_learn, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(qlcnic_mac_learn,
 		 "Mac Filter (0=learning is disabled, 1=Driver learning is enabled, 2=FDB learning is enabled)");
 
 int qlcnic_use_msi = 1;
 MODULE_PARM_DESC(use_msi, "MSI interrupt (0=disabled, 1=enabled)");
-module_param_named(use_msi, qlcnic_use_msi, int, 0444);
+module_param_named(use_msi, qlcnic_use_msi, int, S_IRUSR | S_IRGRP | S_IROTH);
 
 int qlcnic_use_msi_x = 1;
 MODULE_PARM_DESC(use_msi_x, "MSI-X interrupt (0=disabled, 1=enabled)");
-module_param_named(use_msi_x, qlcnic_use_msi_x, int, 0444);
+module_param_named(use_msi_x, qlcnic_use_msi_x, int, S_IRUSR | S_IRGRP | S_IROTH);
 
 int qlcnic_auto_fw_reset = 1;
 MODULE_PARM_DESC(auto_fw_reset, "Auto firmware reset (0=disabled, 1=enabled)");
-module_param_named(auto_fw_reset, qlcnic_auto_fw_reset, int, 0644);
+module_param_named(auto_fw_reset, qlcnic_auto_fw_reset, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 
 int qlcnic_load_fw_file;
 MODULE_PARM_DESC(load_fw_file, "Load firmware from (0=flash, 1=file, 2=POST in fast mode, 3= POST in medium mode, 4=POST in slow mode)");
-module_param_named(load_fw_file, qlcnic_load_fw_file, int, 0444);
+module_param_named(load_fw_file, qlcnic_load_fw_file, int, S_IRUSR | S_IRGRP | S_IROTH);
 
 static int qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent);
 static void qlcnic_remove(struct pci_dev *pdev);
-- 
2.9.2
