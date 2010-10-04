From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 6/8] qlcnic: sparse warning fixes
Date: Mon,  4 Oct 2010 07:20:14 -0700
Message-ID: <1286202016-18026-7-git-send-email-amit.salecha@qlogic.com>
References: <1286202016-18026-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:43756 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755803Ab0JDOUS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Oct 2010 10:20:18 -0400
In-Reply-To: <1286202016-18026-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ctx.c  |   12 ++++++------
 drivers/net/qlcnic/qlcnic_main.c |   10 +++++-----
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index a4c4d09..75e3b19 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -742,15 +742,15 @@ int qlcnic_get_pci_info(struct qlcnic_adapter *adapter,
 
 	if (err == QLCNIC_RCODE_SUCCESS) {
 		for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++, npar++, pci_info++) {
-			pci_info->id = le32_to_cpu(npar->id);
-			pci_info->active = le32_to_cpu(npar->active);
-			pci_info->type = le32_to_cpu(npar->type);
+			pci_info->id = le16_to_cpu(npar->id);
+			pci_info->active = le16_to_cpu(npar->active);
+			pci_info->type = le16_to_cpu(npar->type);
 			pci_info->default_port =
-				le32_to_cpu(npar->default_port);
+				le16_to_cpu(npar->default_port);
 			pci_info->tx_min_bw =
-				le32_to_cpu(npar->tx_min_bw);
+				le16_to_cpu(npar->tx_min_bw);
 			pci_info->tx_max_bw =
-				le32_to_cpu(npar->tx_max_bw);
+				le16_to_cpu(npar->tx_max_bw);
 			memcpy(pci_info->mac, npar->mac, ETH_ALEN);
 		}
 	} else {
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 6001f41..59a2138 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -521,9 +521,9 @@ qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 		pfn = pci_info[i].id;
 		if (pfn > QLCNIC_MAX_PCI_FUNC)
 			return QL_STATUS_INVALID_PARAM;
-		adapter->npars[pfn].active = pci_info[i].active;
-		adapter->npars[pfn].type = pci_info[i].type;
-		adapter->npars[pfn].phy_port = pci_info[i].default_port;
+		adapter->npars[pfn].active = (u8)pci_info[i].active;
+		adapter->npars[pfn].type = (u8)pci_info[i].type;
+		adapter->npars[pfn].phy_port = (u8)pci_info[i].default_port;
 		adapter->npars[pfn].min_bw = pci_info[i].tx_min_bw;
 		adapter->npars[pfn].max_bw = pci_info[i].tx_max_bw;
 	}
@@ -723,7 +723,7 @@ qlcnic_initialize_nic(struct qlcnic_adapter *adapter)
 	if (err)
 		return err;
 
-	adapter->physical_port = nic_info.phys_port;
+	adapter->physical_port = (u8)nic_info.phys_port;
 	adapter->switch_mode = nic_info.switch_mode;
 	adapter->max_tx_ques = nic_info.max_tx_ques;
 	adapter->max_rx_ques = nic_info.max_rx_ques;
@@ -3762,7 +3762,7 @@ qlcnic_sysfs_read_npar_config(struct file *file, struct kobject *kobj,
 			return ret;
 
 		np_cfg[i].pci_func = i;
-		np_cfg[i].op_mode = nic_info.op_mode;
+		np_cfg[i].op_mode = (u8)nic_info.op_mode;
 		np_cfg[i].port_num = nic_info.phys_port;
 		np_cfg[i].fw_capab = nic_info.capabilities;
 		np_cfg[i].min_bw = nic_info.min_tx_bw ;
-- 
1.6.3.3

