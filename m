From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 8/9] vxge: Printing the function's configured
 mode of operation
Date: Thu, 2 Jul 2009 03:18:06 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10907020317260.13763-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:37666 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753669AbZGBHSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 03:18:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Printing the function's configured mode of operation.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -pNur patch-7-net-next-2.6/drivers/net/vxge/vxge-main.c patch-8-net-next-2.6/drivers/net/vxge/vxge-main.c
--- patch-7-net-next-2.6/drivers/net/vxge/vxge-main.c	2009-06-30 17:18:17.000000000 -0700
+++ patch-8-net-next-2.6/drivers/net/vxge/vxge-main.c	2009-06-30 17:34:52.000000000 -0700
@@ -4325,6 +4325,27 @@ vxge_probe(struct pci_dev *pdev, const s
 		ll_config.device_hw_info.fw_version.version,
 		ll_config.device_hw_info.fw_date.date);
 
+	if (new_device) {
+		switch (ll_config.device_hw_info.function_mode) {
+		case VXGE_HW_FUNCTION_MODE_SINGLE_FUNCTION:
+			vxge_debug_init(VXGE_TRACE,
+			"%s: Single Function Mode Enabled", vdev->ndev->name);
+		break;
+		case VXGE_HW_FUNCTION_MODE_MULTI_FUNCTION:
+			vxge_debug_init(VXGE_TRACE,
+			"%s: Multi Function Mode Enabled", vdev->ndev->name);
+		break;
+		case VXGE_HW_FUNCTION_MODE_SRIOV:
+			vxge_debug_init(VXGE_TRACE,
+			"%s: Single Root IOV Mode Enabled", vdev->ndev->name);
+		break;
+		case VXGE_HW_FUNCTION_MODE_MRIOV:
+			vxge_debug_init(VXGE_TRACE,
+			"%s: Multi Root IOV Mode Enabled", vdev->ndev->name);
+		break;
+		}
+	}
+
 	vxge_print_parm(vdev, vpath_mask);
 
 	/* Store the fw version for ethttool option */

