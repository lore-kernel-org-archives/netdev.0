From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [net-next-2.6 PATCH 1/2] be2net: Add support for next generation
	of BladeEngine device
Date: Wed, 14 Oct 2009 17:54:09 +0530
Message-ID: <20091014122358.GA11905@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:2594 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756516AbZJNMYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 08:24:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new PCI ids to support next generation of BladeEnigne device.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 4b61a91..151e73e 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -35,20 +35,31 @@
 #define DRV_VER			"2.101.205"
 #define DRV_NAME		"be2net"
 #define BE_NAME			"ServerEngines BladeEngine2 10Gbps NIC"
+#define BE3_NAME		"ServerEngines BladeEngine3 10Gbps NIC"
 #define OC_NAME			"Emulex OneConnect 10Gbps NIC"
+#define OC_NAME1		"Emulex OneConnect 10Gbps NIC (be3)"
 #define DRV_DESC		BE_NAME "Driver"
 
 #define BE_VENDOR_ID 		0x19a2
 #define BE_DEVICE_ID1		0x211
+#define BE_DEVICE_ID1		0x221
 #define OC_DEVICE_ID1		0x700
 #define OC_DEVICE_ID2		0x701
+#define OC_DEVICE_ID2		0x710
 
 static inline char *nic_name(struct pci_dev *pdev)
 {
-	if (pdev->device == OC_DEVICE_ID1 || pdev->device == OC_DEVICE_ID2)
+	switch (pdev->device) {
+	case OC_DEVICE_ID1:
+	case OC_DEVICE_ID2:
 		return OC_NAME;
-	else
+	case OC_DEVICE_ID3:
+		return OC_NAME1;
+	case BE_DEVICE_ID2:
+		return BE3_NAME;
+	default:
 		return BE_NAME;
+	}
 }
 
 /* Number of bytes of an RX frame that are copied to skb->data */
-- 
1.6.0.4

