From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 3/9] vxge: Removed accessing non-supported
 registers.
Date: Mon, 5 Oct 2009 07:53:38 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10910050752560.9377-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:42025 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758627AbZJEL7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 07:59:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 - Removed accessing GENDMA_INT register
 - This allowed the firmware to perform a generic DMA write to host memory.
   This feature is not supported by the ASIC, this patch removes access to
   GENDMA_INT register.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
---
diff -urpN patch2/drivers/net/vxge/vxge-config.c patch3/drivers/net/vxge/vxge-config.c
--- patch2/drivers/net/vxge/vxge-config.c	2009-09-04 01:17:22.000000000 -0700
+++ patch3/drivers/net/vxge/vxge-config.c	2009-09-04 01:19:53.000000000 -0700
@@ -4106,8 +4106,6 @@ __vxge_hw_vpath_initialize(struct __vxge
 	if (status != VXGE_HW_OK)
 		goto exit;
 
-	writeq(0, &vp_reg->gendma_int);
-
 	val64 = readq(&vp_reg->rtdma_rd_optimization_ctrl);
 
 	/* Get MRRS value from device control */
diff -urpN patch2/drivers/net/vxge/vxge-reg.h patch3/drivers/net/vxge/vxge-reg.h
--- patch2/drivers/net/vxge/vxge-reg.h	2009-09-04 01:17:22.000000000 -0700
+++ patch3/drivers/net/vxge/vxge-reg.h	2009-09-04 01:20:26.000000000 -0700
@@ -4326,10 +4326,6 @@ struct vxge_hw_vpath_reg {
 /*0x011e0*/	u64	umq_bwr_init_byte;
 #define VXGE_HW_UMQ_BWR_INIT_BYTE_COUNT(val) vxge_vBIT(val, 0, 32)
 /*0x011e8*/	u64	gendma_int;
-#define	VXGE_HW_GENDMA_INT_IMMED_ENABLE	vxge_mBIT(6)
-#define	VXGE_HW_GENDMA_INT_EVENT_ENABLE	vxge_mBIT(7)
-#define VXGE_HW_GENDMA_INT_NUMBER(val) vxge_vBIT(val, 9, 7)
-#define VXGE_HW_GENDMA_INT_BITMAP(val) vxge_vBIT(val, 16, 16)
 /*0x011f0*/	u64	umqdmq_ir_init_notify;
 #define	VXGE_HW_UMQDMQ_IR_INIT_NOTIFY_PULSE	vxge_mBIT(3)
 /*0x011f8*/	u64	dmq_init_notify;

