From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 5/9] vxge: Removed the code to bounds check the
 mss value
Date: Thu, 2 Jul 2009 03:15:41 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10907020314590.13763-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:37771 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993AbZGBH0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 03:26:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Removed the code to bounds check the mss value. The hardware does bounds checking and 
will not allow an oversized mss to lockup the transmit path.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN patch_4/drivers/net/vxge/vxge-main.c patch_5/drivers/net/vxge/vxge-main.c
--- patch_4/drivers/net/vxge/vxge-main.c	2009-06-21 23:53:43.000000000 -0700
+++ patch_5/drivers/net/vxge/vxge-main.c	2009-06-22 00:52:43.000000000 -0700
@@ -817,7 +817,6 @@ vxge_xmit(struct sk_buff *skb, struct ne
 	u64 dma_pointer;
 	struct vxge_tx_priv *txdl_priv = NULL;
 	struct __vxge_hw_fifo *fifo_hw;
-	u32 max_mss = 0x0;
 	int offload_type;
 	unsigned long flags = 0;
 	int vpath_no = 0;
@@ -969,10 +968,6 @@ vxge_xmit(struct sk_buff *skb, struct ne
 
 		int mss = vxge_tcp_mss(skb);
 		if (mss) {
-			max_mss = dev->mtu + ETH_HLEN -
-				VXGE_HW_TCPIP_HEADER_MAX_SIZE;
-			if (mss > max_mss)
-				mss = max_mss;
 			vxge_debug_tx(VXGE_TRACE,
 				"%s: %s:%d mss = %d",
 				dev->name, __func__, __LINE__, mss);
diff -urpN patch_4/drivers/net/vxge/vxge-traffic.h patch_5/drivers/net/vxge/vxge-traffic.h
--- patch_4/drivers/net/vxge/vxge-traffic.h	2009-06-21 23:53:43.000000000 -0700
+++ patch_5/drivers/net/vxge/vxge-traffic.h	2009-06-22 00:53:09.000000000 -0700
@@ -35,8 +35,6 @@
 			VXGE_HW_HEADER_VLAN_SIZE + \
 			VXGE_HW_HEADER_SNAP_SIZE)
 
-#define VXGE_HW_TCPIP_HEADER_MAX_SIZE	(64 + 64)
-
 /* 32bit alignments */
 #define VXGE_HW_HEADER_ETHERNET_II_802_3_ALIGN		2
 #define VXGE_HW_HEADER_802_2_SNAP_ALIGN			2

