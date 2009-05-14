From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH 1/1] be2net: add two new pci device ids to pci device table
Date: Thu, 14 May 2009 12:21:20 +0530
Message-ID: <20090514065118.GB13053@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Ajit Khaparde <ajitk@serverengines.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:32092 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750900AbZENGvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2009 02:51:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
This patch adds two new PCI Device IDs to the pci device table.
Please apply this patch to the net-2.6 tree.

Thanks
Ajit

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
----
diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index c49ddd0..b4bb06f 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -35,8 +35,22 @@
 #define DRV_VER			"2.0.348"
 #define DRV_NAME		"be2net"
 #define BE_NAME			"ServerEngines BladeEngine2 10Gbps NIC"
+#define OC_NAME			"Emulex OneConnect 10Gbps NIC"
 #define DRV_DESC		BE_NAME "Driver"
 
+#define BE_VENDOR_ID 		0x19a2
+#define BE_DEVICE_ID1		0x211
+#define OC_DEVICE_ID1		0x700
+#define OC_DEVICE_ID2		0x701
+
+static inline char *nic_name(struct pci_dev *pdev)
+{
+	if (pdev->device == OC_DEVICE_ID1 || pdev->device == OC_DEVICE_ID2)
+		return OC_NAME;
+	else
+		return BE_NAME;
+}
+
 /* Number of bytes of an RX frame that are copied to skb->data */
 #define BE_HDR_LEN 		64
 #define BE_MAX_JUMBO_FRAME_SIZE	9018
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 9b75aa6..cf75905 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -28,10 +28,10 @@ static unsigned int rx_frag_size = 2048;
 module_param(rx_frag_size, uint, S_IRUGO);
 MODULE_PARM_DESC(rx_frag_size, "Size of a fragment that holds rcvd data.");
 
-#define BE_VENDOR_ID 		0x19a2
-#define BE2_DEVICE_ID_1 	0x0211
 static DEFINE_PCI_DEVICE_TABLE(be_dev_ids) = {
-	{ PCI_DEVICE(BE_VENDOR_ID, BE2_DEVICE_ID_1) },
+	{ PCI_DEVICE(BE_VENDOR_ID, BE_DEVICE_ID1) },
+	{ PCI_DEVICE(BE_VENDOR_ID, OC_DEVICE_ID1) },
+	{ PCI_DEVICE(BE_VENDOR_ID, OC_DEVICE_ID2) },
 	{ 0 }
 };
 MODULE_DEVICE_TABLE(pci, be_dev_ids);
@@ -1859,7 +1859,7 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	if (status != 0)
 		goto stats_clean;
 
-	dev_info(&pdev->dev, BE_NAME " port %d\n", adapter->port_num);
+	dev_info(&pdev->dev, "%s port %d\n", nic_name(pdev), adapter->port_num);
 	return 0;
 
 stats_clean:
@@ -1873,7 +1873,7 @@ rel_reg:
 disable_dev:
 	pci_disable_device(pdev);
 do_none:
-	dev_warn(&pdev->dev, BE_NAME " initialization failed\n");
+	dev_err(&pdev->dev, "%s initialization failed\n", nic_name(pdev));
 	return status;
 }
 
