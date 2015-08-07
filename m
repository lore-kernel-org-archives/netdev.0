From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 4/6] qlcnic: Add new VF device ID 0x8C30
Date: Fri, 7 Aug 2015 07:17:05 -0400
Message-ID: <1438946227-11426-5-git-send-email-shahed.shaikh@qlogic.com>
References: <1438946227-11426-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:39421 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752958AbbHGMCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 08:02:55 -0400
In-Reply-To: <1438946227-11426-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

This is a 83xx series based VF device

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |   12 ++++++++----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    5 ++++-
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index a861592..17f37b7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -2290,8 +2290,9 @@ extern const struct ethtool_ops qlcnic_ethtool_failed_ops;
 
 #define PCI_DEVICE_ID_QLOGIC_QLE824X		0x8020
 #define PCI_DEVICE_ID_QLOGIC_QLE834X		0x8030
-#define PCI_DEVICE_ID_QLOGIC_QLE8830		0x8830
 #define PCI_DEVICE_ID_QLOGIC_VF_QLE834X	0x8430
+#define PCI_DEVICE_ID_QLOGIC_QLE8830		0x8830
+#define PCI_DEVICE_ID_QLOGIC_VF_QLE8C30		0x8C30
 #define PCI_DEVICE_ID_QLOGIC_QLE844X		0x8040
 #define PCI_DEVICE_ID_QLOGIC_VF_QLE844X	0x8440
 
@@ -2318,7 +2319,8 @@ static inline bool qlcnic_83xx_check(struct qlcnic_adapter *adapter)
 		  (device == PCI_DEVICE_ID_QLOGIC_QLE8830) ||
 		  (device == PCI_DEVICE_ID_QLOGIC_QLE844X) ||
 		  (device == PCI_DEVICE_ID_QLOGIC_VF_QLE844X) ||
-		  (device == PCI_DEVICE_ID_QLOGIC_VF_QLE834X)) ? true : false;
+		  (device == PCI_DEVICE_ID_QLOGIC_VF_QLE834X) ||
+		  (device == PCI_DEVICE_ID_QLOGIC_VF_QLE8C30)) ? true : false;
 
 	return status;
 }
@@ -2334,7 +2336,8 @@ static inline bool qlcnic_sriov_vf_check(struct qlcnic_adapter *adapter)
 	bool status;
 
 	status = ((device == PCI_DEVICE_ID_QLOGIC_VF_QLE834X) ||
-		  (device == PCI_DEVICE_ID_QLOGIC_VF_QLE844X)) ? true : false;
+		  (device == PCI_DEVICE_ID_QLOGIC_VF_QLE844X) ||
+		  (device == PCI_DEVICE_ID_QLOGIC_VF_QLE8C30)) ? true : false;
 
 	return status;
 }
@@ -2350,7 +2353,8 @@ static inline bool qlcnic_83xx_vf_check(struct qlcnic_adapter *adapter)
 {
 	unsigned short device = adapter->pdev->device;
 
-	return (device == PCI_DEVICE_ID_QLOGIC_VF_QLE834X) ? true : false;
+	return ((device == PCI_DEVICE_ID_QLOGIC_VF_QLE834X) ||
+		(device == PCI_DEVICE_ID_QLOGIC_VF_QLE8C30)) ? true : false;
 }
 
 static inline bool qlcnic_sriov_check(struct qlcnic_adapter *adapter)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index b714cee..8b08b20 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -110,8 +110,9 @@ static u32 qlcnic_vlan_tx_check(struct qlcnic_adapter *adapter)
 static const struct pci_device_id qlcnic_pci_tbl[] = {
 	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE824X),
 	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE834X),
-	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE8830),
 	ENTRY(PCI_DEVICE_ID_QLOGIC_VF_QLE834X),
+	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE8830),
+	ENTRY(PCI_DEVICE_ID_QLOGIC_VF_QLE8C30),
 	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE844X),
 	ENTRY(PCI_DEVICE_ID_QLOGIC_VF_QLE844X),
 	{0,}
@@ -1148,6 +1149,7 @@ static void qlcnic_get_bar_length(u32 dev_id, ulong *bar)
 	case PCI_DEVICE_ID_QLOGIC_QLE844X:
 	case PCI_DEVICE_ID_QLOGIC_VF_QLE834X:
 	case PCI_DEVICE_ID_QLOGIC_VF_QLE844X:
+	case PCI_DEVICE_ID_QLOGIC_VF_QLE8C30:
 		*bar = QLCNIC_83XX_BAR0_LENGTH;
 		break;
 	default:
@@ -2490,6 +2492,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		qlcnic_83xx_register_map(ahw);
 		break;
 	case PCI_DEVICE_ID_QLOGIC_VF_QLE834X:
+	case PCI_DEVICE_ID_QLOGIC_VF_QLE8C30:
 	case PCI_DEVICE_ID_QLOGIC_VF_QLE844X:
 		qlcnic_sriov_vf_register_map(ahw);
 		break;
-- 
1.5.6
