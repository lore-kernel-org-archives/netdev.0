From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 2/6] qlcnic: Add support for 0x8830 device ID
Date: Wed, 27 Aug 2014 12:43:18 -0400
Message-ID: <1409157802-7895-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1409157802-7895-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:19562 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932511AbaH0RQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 13:16:25 -0400
In-Reply-To: <1409157802-7895-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h           | 2 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c | 1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c      | 8 ++++++++
 3 files changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index b84f5ea..80a5509 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -2283,6 +2283,7 @@ extern const struct ethtool_ops qlcnic_ethtool_failed_ops;
 
 #define PCI_DEVICE_ID_QLOGIC_QLE824X		0x8020
 #define PCI_DEVICE_ID_QLOGIC_QLE834X		0x8030
+#define PCI_DEVICE_ID_QLOGIC_QLE8830		0x8830
 #define PCI_DEVICE_ID_QLOGIC_VF_QLE834X	0x8430
 #define PCI_DEVICE_ID_QLOGIC_QLE844X		0x8040
 #define PCI_DEVICE_ID_QLOGIC_VF_QLE844X	0x8440
@@ -2307,6 +2308,7 @@ static inline bool qlcnic_83xx_check(struct qlcnic_adapter *adapter)
 	bool status;
 
 	status = ((device == PCI_DEVICE_ID_QLOGIC_QLE834X) ||
+		  (device == PCI_DEVICE_ID_QLOGIC_QLE8830) ||
 		  (device == PCI_DEVICE_ID_QLOGIC_QLE844X) ||
 		  (device == PCI_DEVICE_ID_QLOGIC_VF_QLE844X) ||
 		  (device == PCI_DEVICE_ID_QLOGIC_VF_QLE834X)) ? true : false;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index 86783e1..d1bded7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -2284,6 +2284,7 @@ static int qlcnic_83xx_get_fw_info(struct qlcnic_adapter *adapter)
 		fw_info = ahw->fw_info;
 		switch (pdev->device) {
 		case PCI_DEVICE_ID_QLOGIC_QLE834X:
+		case PCI_DEVICE_ID_QLOGIC_QLE8830:
 			strncpy(fw_info->fw_file_name, QLC_83XX_FW_FILE_NAME,
 				QLC_FW_FILE_NAME_LEN);
 			break;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index cf08b2d..8db11e2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -111,6 +111,7 @@ static u32 qlcnic_vlan_tx_check(struct qlcnic_adapter *adapter)
 static const struct pci_device_id qlcnic_pci_tbl[] = {
 	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE824X),
 	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE834X),
+	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE8830),
 	ENTRY(PCI_DEVICE_ID_QLOGIC_VF_QLE834X),
 	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE844X),
 	ENTRY(PCI_DEVICE_ID_QLOGIC_VF_QLE844X),
@@ -228,6 +229,11 @@ static const struct qlcnic_board_info qlcnic_boards[] = {
 	  PCI_DEVICE_ID_QLOGIC_QLE834X,
 	  0x0, 0x0, "8300 Series 1/10GbE Controller" },
 	{ PCI_VENDOR_ID_QLOGIC,
+	  PCI_DEVICE_ID_QLOGIC_QLE8830,
+	  0x0,
+	  0x0,
+	  "8830 Series 1/10GbE Controller" },
+	{ PCI_VENDOR_ID_QLOGIC,
 	  PCI_DEVICE_ID_QLOGIC_QLE824X,
 	  PCI_VENDOR_ID_QLOGIC,
 	  0x203,
@@ -1131,6 +1137,7 @@ static void qlcnic_get_bar_length(u32 dev_id, ulong *bar)
 		*bar = QLCNIC_82XX_BAR0_LENGTH;
 		break;
 	case PCI_DEVICE_ID_QLOGIC_QLE834X:
+	case PCI_DEVICE_ID_QLOGIC_QLE8830:
 	case PCI_DEVICE_ID_QLOGIC_QLE844X:
 	case PCI_DEVICE_ID_QLOGIC_VF_QLE834X:
 	case PCI_DEVICE_ID_QLOGIC_VF_QLE844X:
@@ -2474,6 +2481,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		ahw->reg_tbl = (u32 *) qlcnic_reg_tbl;
 		break;
 	case PCI_DEVICE_ID_QLOGIC_QLE834X:
+	case PCI_DEVICE_ID_QLOGIC_QLE8830:
 	case PCI_DEVICE_ID_QLOGIC_QLE844X:
 		qlcnic_83xx_register_map(ahw);
 		break;
-- 
1.8.1.4
