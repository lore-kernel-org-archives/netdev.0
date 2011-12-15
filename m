From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next] be2net: Add support for Skyhawk cards
Date: Thu, 15 Dec 2011 10:31:38 -0600
Message-ID: <20111215163138.GA5786@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:48337 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756267Ab1LOQcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 11:32:01 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    4 ++++
 drivers/net/ethernet/emulex/benet/be_main.c |    2 ++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index a3588fb..995198d 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -40,6 +40,7 @@
 #define OC_NAME			"Emulex OneConnect 10Gbps NIC"
 #define OC_NAME_BE		OC_NAME	"(be3)"
 #define OC_NAME_LANCER		OC_NAME "(Lancer)"
+#define OC_NAME_SH		OC_NAME "(Skyhawk)"
 #define DRV_DESC		"ServerEngines BladeEngine 10Gbps NIC Driver"
 
 #define BE_VENDOR_ID 		0x19a2
@@ -50,6 +51,7 @@
 #define OC_DEVICE_ID2		0x710	/* Device Id for BE3 cards */
 #define OC_DEVICE_ID3		0xe220	/* Device id for Lancer cards */
 #define OC_DEVICE_ID4           0xe228   /* Device id for VF in Lancer */
+#define OC_DEVICE_ID5		0x720	/* Device Id for Skyhawk cards */
 
 static inline char *nic_name(struct pci_dev *pdev)
 {
@@ -63,6 +65,8 @@ static inline char *nic_name(struct pci_dev *pdev)
 		return OC_NAME_LANCER;
 	case BE_DEVICE_ID2:
 		return BE3_NAME;
+	case OC_DEVICE_ID5:
+		return OC_NAME_SH;
 	default:
 		return BE_NAME;
 	}
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 9b5304a..b145a49 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -42,6 +42,7 @@ static DEFINE_PCI_DEVICE_TABLE(be_dev_ids) = {
 	{ PCI_DEVICE(BE_VENDOR_ID, OC_DEVICE_ID2) },
 	{ PCI_DEVICE(EMULEX_VENDOR_ID, OC_DEVICE_ID3)},
 	{ PCI_DEVICE(EMULEX_VENDOR_ID, OC_DEVICE_ID4)},
+	{ PCI_DEVICE(EMULEX_VENDOR_ID, OC_DEVICE_ID5)},
 	{ 0 }
 };
 MODULE_DEVICE_TABLE(pci, be_dev_ids);
@@ -3312,6 +3313,7 @@ static int be_dev_family_check(struct be_adapter *adapter)
 		break;
 	case BE_DEVICE_ID2:
 	case OC_DEVICE_ID2:
+	case OC_DEVICE_ID5:
 		adapter->generation = BE_GEN3;
 		break;
 	case OC_DEVICE_ID3:
-- 
1.7.5.4
