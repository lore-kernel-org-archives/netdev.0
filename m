From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 6/8] vxge: Set function-0 as the privilaged
 function for normal function.
Date: Mon, 29 Mar 2010 04:12:33 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.11003290411440.4435-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:48125 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484Ab0C2IXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 04:23:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-  For Normal function (MR-IOV disabled, SR-IOV disabled) Function-0 is the
   privilaged function.
 
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN patch5/drivers/net/vxge/vxge-config.c patch6/drivers/net/vxge/vxge-config.c
--- patch5/drivers/net/vxge/vxge-config.c	2010-03-19 16:23:57.000000000 +0530
+++ patch6/drivers/net/vxge/vxge-config.c	2010-03-22 14:42:04.000000000 +0530
@@ -356,8 +356,10 @@ __vxge_hw_device_access_rights_get(u32 h
 
 	switch (host_type) {
 	case VXGE_HW_NO_MR_NO_SR_NORMAL_FUNCTION:
-		access_rights |= VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM |
-				VXGE_HW_DEVICE_ACCESS_RIGHT_SRPCIM;
+		if (func_id == 0) {
+			access_rights |= VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM |
+					VXGE_HW_DEVICE_ACCESS_RIGHT_SRPCIM;
+		}
 		break;
 	case VXGE_HW_MR_NO_SR_VH0_BASE_FUNCTION:
 		access_rights |= VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM |

