From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: net-next-2.6 PATCH 1/4] vxge: Fix a possible memory leak in
 vxge_hw_device_initialize().
Date: Thu, 8 Apr 2010 04:42:02 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.11004080441240.365-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:38515 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243Ab0DHImV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 04:42:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Fix a possible memory leak in vxge_hw_device_initialize(). Free hldev if
vxge_hw_device_reg_addr_get() fails.
 
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@exar.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@exar.com>
---
diff -urpN orig/drivers/net/vxge/vxge-config.c patch1/drivers/net/vxge/vxge-config.c
--- orig/drivers/net/vxge/vxge-config.c	2010-04-01 12:03:33.000000000 +0530
+++ patch1/drivers/net/vxge/vxge-config.c	2010-04-01 12:05:55.000000000 +0530
@@ -634,8 +634,10 @@ vxge_hw_device_initialize(
 	__vxge_hw_device_pci_e_init(hldev);
 
 	status = __vxge_hw_device_reg_addr_get(hldev);
-	if (status != VXGE_HW_OK)
+	if (status != VXGE_HW_OK) {
+		vfree(hldev);
 		goto exit;
+	}
 	__vxge_hw_device_id_get(hldev);
 
 	__vxge_hw_device_host_info_get(hldev);

