From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next-2.6 1/3] qlcnic: Fix missing error codes
Date: Thu, 26 Aug 2010 17:02:41 -0700
Message-ID: <alpine.OSX.2.00.1008261640190.9385@macintosh-2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:23113 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316Ab0H0ACn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 20:02:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

In the original code, the error codes returned from some of the functions
are not caught and sent up the caller chain. Fixed it here.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 630a077..1b8f67d 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -967,7 +967,8 @@ qlcnic_start_firmware(struct qlcnic_adapter *adapter)
 	if (load_fw_file)
 		qlcnic_request_firmware(adapter);
 	else {
-		if (qlcnic_check_flash_fw_ver(adapter))
+		err = qlcnic_check_flash_fw_ver(adapter);
+		if (err)
 			goto err_out;
 
 		adapter->fw_type = QLCNIC_FLASH_ROMIMAGE;
@@ -998,9 +999,11 @@ set_dev_ready:
 	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_READY);
 	qlcnic_idc_debug_info(adapter, 1);
 
-	if (qlcnic_set_default_offload_settings(adapter))
+	err = qlcnic_set_default_offload_settings(adapter);
+	if (err)
 		goto err_out;
-	if (qlcnic_reset_npar_config(adapter))
+	err = qlcnic_reset_npar_config(adapter);
+	if (err)
 		goto err_out;
 	qlcnic_dev_set_npar_ready(adapter);
 	qlcnic_check_options(adapter);
@@ -1515,7 +1518,8 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (qlcnic_read_mac_addr(adapter))
 		dev_warn(&pdev->dev, "failed to read mac addr\n");
 
-	if (qlcnic_setup_idc_param(adapter))
+	err = qlcnic_setup_idc_param(adapter);
+	if (err)
 		goto err_out_iounmap;
 
 	err = adapter->nic_ops->start_firmware(adapter);
-- 
1.7.1

