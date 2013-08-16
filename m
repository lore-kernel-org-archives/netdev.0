From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next 1/5] qlcnic: Enable support for 844X adapter
Date: Fri, 16 Aug 2013 19:07:13 -0400
Message-ID: <2d10a21452c272645498b29d1b0aa9659f933c25.1376720973.git.himanshu.madhani@qlogic.com>
References: <cover.1376720973.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:56430 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754069Ab3HQAAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 20:00:14 -0400
In-Reply-To: <cover.1376720973.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      | 14 +++++++++++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c   |  5 +----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 11 +++++++++++
 3 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 7387354..9ae5d2e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1972,9 +1972,11 @@ extern const struct ethtool_ops qlcnic_ethtool_failed_ops;
 			__func__, ##_args);		\
 	} while (0)
 
-#define PCI_DEVICE_ID_QLOGIC_QLE834X    0x8030
+#define PCI_DEVICE_ID_QLOGIC_QLE824X		0x8020
+#define PCI_DEVICE_ID_QLOGIC_QLE834X		0x8030
 #define PCI_DEVICE_ID_QLOGIC_VF_QLE834X	0x8430
-#define PCI_DEVICE_ID_QLOGIC_QLE824X	0x8020
+#define PCI_DEVICE_ID_QLOGIC_QLE844X		0x8040
+#define PCI_DEVICE_ID_QLOGIC_VF_QLE844X	0x8440
 
 static inline bool qlcnic_82xx_check(struct qlcnic_adapter *adapter)
 {
@@ -1988,6 +1990,8 @@ static inline bool qlcnic_83xx_check(struct qlcnic_adapter *adapter)
 	bool status;
 
 	status = ((device == PCI_DEVICE_ID_QLOGIC_QLE834X) ||
+		  (device == PCI_DEVICE_ID_QLOGIC_QLE844X) ||
+		  (device == PCI_DEVICE_ID_QLOGIC_VF_QLE844X) ||
 		  (device == PCI_DEVICE_ID_QLOGIC_VF_QLE834X)) ? true : false;
 
 	return status;
@@ -2001,7 +2005,11 @@ static inline bool qlcnic_sriov_pf_check(struct qlcnic_adapter *adapter)
 static inline bool qlcnic_sriov_vf_check(struct qlcnic_adapter *adapter)
 {
 	unsigned short device = adapter->pdev->device;
+	bool status;
+
+	status = ((device == PCI_DEVICE_ID_QLOGIC_VF_QLE834X) ||
+		  (device == PCI_DEVICE_ID_QLOGIC_VF_QLE844X)) ? true : false;
 
-	return (device == PCI_DEVICE_ID_QLOGIC_VF_QLE834X) ? true : false;
+	return status;
 }
 #endif				/* __QLCNIC_H_ */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index f807f3b..cec0908 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -147,10 +147,7 @@ static inline u8 qlcnic_mac_hash(u64 mac)
 static inline u32 qlcnic_get_ref_handle(struct qlcnic_adapter *adapter,
 					u16 handle, u8 ring_id)
 {
-	unsigned short device = adapter->pdev->device;
-
-	if ((device == PCI_DEVICE_ID_QLOGIC_QLE834X) ||
-	    (device == PCI_DEVICE_ID_QLOGIC_VF_QLE834X))
+	if (qlcnic_83xx_check(adapter))
 		return handle | (ring_id << 15);
 	else
 		return handle;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index b8242bc..499c777 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -100,6 +100,8 @@ static DEFINE_PCI_DEVICE_TABLE(qlcnic_pci_tbl) = {
 	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE824X),
 	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE834X),
 	ENTRY(PCI_DEVICE_ID_QLOGIC_VF_QLE834X),
+	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE844X),
+	ENTRY(PCI_DEVICE_ID_QLOGIC_VF_QLE844X),
 	{0,}
 };
 
@@ -146,6 +148,11 @@ static const u32 qlcnic_reg_tbl[] = {
 
 static const struct qlcnic_board_info qlcnic_boards[] = {
 	{ PCI_VENDOR_ID_QLOGIC,
+	  PCI_DEVICE_ID_QLOGIC_QLE844X,
+	  0x0,
+	  0x0,
+	  "8400 series 10GbE Converged Network Adapter (TCP/IP Networking)" },
+	{ PCI_VENDOR_ID_QLOGIC,
 	  PCI_DEVICE_ID_QLOGIC_QLE834X,
 	  PCI_VENDOR_ID_QLOGIC,
 	  0x24e,
@@ -829,7 +836,9 @@ static void qlcnic_get_bar_length(u32 dev_id, ulong *bar)
 		*bar = QLCNIC_82XX_BAR0_LENGTH;
 		break;
 	case PCI_DEVICE_ID_QLOGIC_QLE834X:
+	case PCI_DEVICE_ID_QLOGIC_QLE844X:
 	case PCI_DEVICE_ID_QLOGIC_VF_QLE834X:
+	case PCI_DEVICE_ID_QLOGIC_VF_QLE844X:
 		*bar = QLCNIC_83XX_BAR0_LENGTH;
 		break;
 	default:
@@ -2048,9 +2057,11 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		ahw->reg_tbl = (u32 *) qlcnic_reg_tbl;
 		break;
 	case PCI_DEVICE_ID_QLOGIC_QLE834X:
+	case PCI_DEVICE_ID_QLOGIC_QLE844X:
 		qlcnic_83xx_register_map(ahw);
 		break;
 	case PCI_DEVICE_ID_QLOGIC_VF_QLE834X:
+	case PCI_DEVICE_ID_QLOGIC_VF_QLE844X:
 		qlcnic_sriov_vf_register_map(ahw);
 		break;
 	default:
-- 
1.8.1.4
