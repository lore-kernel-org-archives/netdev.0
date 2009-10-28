From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH] vxge: Configure the number of transmit descriptors
 per packet to MAX_SKB_FRAGS + 1.
Date: Wed, 28 Oct 2009 01:49:41 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10910280147520.23102-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:49993 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753087AbZJ1FvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 01:51:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Configure the number of transmit descriptors per packet to MAX_SKB_FRAGS + 1.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN orig/drivers/net/vxge/vxge-main.c patch1/drivers/net/vxge/vxge-main.c
--- orig/drivers/net/vxge/vxge-main.c	2009-10-26 23:28:15.000000000 -0700
+++ patch1/drivers/net/vxge/vxge-main.c	2009-10-26 23:32:07.000000000 -0700
@@ -3612,11 +3612,12 @@ static int __devinit vxge_config_vpaths(
 		device_config->vp_config[i].fifo.enable =
 						VXGE_HW_FIFO_ENABLE;
 		device_config->vp_config[i].fifo.max_frags =
-				MAX_SKB_FRAGS;
+				MAX_SKB_FRAGS + 1;
 		device_config->vp_config[i].fifo.memblock_size =
 			VXGE_HW_MIN_FIFO_MEMBLOCK_SIZE;
 
-		txdl_size = MAX_SKB_FRAGS * sizeof(struct vxge_hw_fifo_txd);
+		txdl_size = device_config->vp_config[i].fifo.max_frags *
+				sizeof(struct vxge_hw_fifo_txd);
 		txdl_per_memblock = VXGE_HW_MIN_FIFO_MEMBLOCK_SIZE / txdl_size;
 
 		device_config->vp_config[i].fifo.fifo_blocks =
diff -urpN orig/drivers/net/vxge/vxge-version.h patch1/drivers/net/vxge/vxge-version.h
--- orig/drivers/net/vxge/vxge-version.h	2009-10-26 23:28:15.000000000 -0700
+++ patch1/drivers/net/vxge/vxge-version.h	2009-10-27 02:19:18.000000000 -0700
@@ -18,6 +18,6 @@
 #define VXGE_VERSION_MAJOR	"2"
 #define VXGE_VERSION_MINOR	"0"
 #define VXGE_VERSION_FIX	"6"
-#define VXGE_VERSION_BUILD	"18707"
+#define VXGE_VERSION_BUILD	"18937"
 #define VXGE_VERSION_FOR	"k"
 #endif

