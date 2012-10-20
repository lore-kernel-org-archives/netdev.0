From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 13/14] be2net: Fix skyhawk VF PCI Device ID
Date: Sat, 20 Oct 2012 21:34:40 +0530
Message-ID: <b8c00300-1bf1-4f77-a2c7-98d402cccdb0@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:40039 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593Ab2JTQFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 12:05:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    5 ++++-
 drivers/net/ethernet/emulex/benet/be_main.c |    2 ++
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index d95825f..3b66c63 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -53,6 +53,7 @@
 #define OC_DEVICE_ID3		0xe220	/* Device id for Lancer cards */
 #define OC_DEVICE_ID4           0xe228   /* Device id for VF in Lancer */
 #define OC_DEVICE_ID5		0x720	/* Device Id for Skyhawk cards */
+#define OC_DEVICE_ID6		0x728   /* Device id for VF in SkyHawk */
 #define OC_SUBSYS_DEVICE_ID1	0xE602
 #define OC_SUBSYS_DEVICE_ID2	0xE642
 #define OC_SUBSYS_DEVICE_ID3	0xE612
@@ -71,6 +72,7 @@ static inline char *nic_name(struct pci_dev *pdev)
 	case BE_DEVICE_ID2:
 		return BE3_NAME;
 	case OC_DEVICE_ID5:
+	case OC_DEVICE_ID6:
 		return OC_NAME_SH;
 	default:
 		return BE_NAME;
@@ -466,7 +468,8 @@ struct be_adapter {
 #define lancer_chip(adapter)	((adapter->pdev->device == OC_DEVICE_ID3) || \
 				 (adapter->pdev->device == OC_DEVICE_ID4))
 
-#define skyhawk_chip(adapter)	(adapter->pdev->device == OC_DEVICE_ID5)
+#define skyhawk_chip(adapter)	(adapter->pdev->device == OC_DEVICE_ID5 || \
+				 adapter->pdev->device == OC_DEVICE_ID6)
 
 
 #define be_roce_supported(adapter) ((adapter->if_type == SLI_INTF_TYPE_3 || \
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2143e06..68665da 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -44,6 +44,7 @@ static DEFINE_PCI_DEVICE_TABLE(be_dev_ids) = {
 	{ PCI_DEVICE(EMULEX_VENDOR_ID, OC_DEVICE_ID3)},
 	{ PCI_DEVICE(EMULEX_VENDOR_ID, OC_DEVICE_ID4)},
 	{ PCI_DEVICE(EMULEX_VENDOR_ID, OC_DEVICE_ID5)},
+	{ PCI_DEVICE(EMULEX_VENDOR_ID, OC_DEVICE_ID6)},
 	{ 0 }
 };
 MODULE_DEVICE_TABLE(pci, be_dev_ids);
@@ -3910,6 +3911,7 @@ static int be_dev_type_check(struct be_adapter *adapter)
 		adapter->generation = BE_GEN3;
 		break;
 	case OC_DEVICE_ID5:
+	case OC_DEVICE_ID6:
 		pci_read_config_dword(pdev, SLI_INTF_REG_OFFSET, &sli_intf);
 		if ((sli_intf & SLI_INTF_VALID_MASK) != SLI_INTF_VALID) {
 			dev_err(&pdev->dev, "SLI_INTF reg val is not valid\n");
-- 
1.6.0.2
