From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 4/7] qlcnic: module param for firmware load option
Date: Mon, 17 May 2010 04:22:11 -0700
Message-ID: <1274095334-32362-5-git-send-email-amit.salecha@qlogic.com>
References: <1274095334-32362-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:18680 "EHLO
	dut4145.unminc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751374Ab0EQKVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 06:21:50 -0400
In-Reply-To: <1274095334-32362-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default fw is loaded from flash, user can
change this priority using load_fw_file module param.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 0a52d24..b076474 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -61,6 +61,10 @@ static int auto_fw_reset = AUTO_FW_RESET_ENABLED;
 module_param(auto_fw_reset, int, 0644);
 MODULE_PARM_DESC(auto_fw_reset, "Auto firmware reset (0=disabled, 1=enabled");
 
+static int load_fw_file;
+module_param(load_fw_file, int, 0644);
+MODULE_PARM_DESC(load_fw_file, "Load firmware from (0=flash, 1=file");
+
 static int __devinit qlcnic_probe(struct pci_dev *pdev,
 		const struct pci_device_id *ent);
 static void __devexit qlcnic_remove(struct pci_dev *pdev);
@@ -585,7 +589,10 @@ qlcnic_start_firmware(struct qlcnic_adapter *adapter)
 		/* This is the first boot after power up */
 		QLCWR32(adapter, QLCNIC_CAM_RAM(0x1fc), QLCNIC_BDINFO_MAGIC);
 
-	qlcnic_request_firmware(adapter);
+	if (load_fw_file)
+		qlcnic_request_firmware(adapter);
+	else
+		adapter->fw_type = QLCNIC_FLASH_ROMIMAGE;
 
 	err = qlcnic_need_fw_reset(adapter);
 	if (err < 0)
-- 
1.5.6.1

