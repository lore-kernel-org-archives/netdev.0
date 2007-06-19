From: Veena Parat <Veena.Parat@neterion.com>
Subject: [PATCH 2.6.22 4/4]S2IO: Implementing review comments from old patches
Date: Tue, 19 Jun 2007 06:06:11 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10706190604110.2608-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Leonid.Grossman@neterion.com, ramkrishna.vepa@neterion.com,
	santosh.rastapur@neterion.com, Sivakumar.Subramani@neterion.com,
	sreenivasa.honnur@neterion.com, Alicia.Pena@neterion.com,
	sriram.rapuru@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:48151 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756207AbXFSKGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 06:06:14 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implementation of review comments 
1. Incorporated Jeff Garzik's comments on coding standards.
2. Incorporated Andreas Schwab's comments on redundant condition check.

Signed-off-by: Veena Parat <veena.parat@neterion.com>
---
diff -urpN patch_3/drivers/net/s2io.c patch_4/drivers/net/s2io.c
--- patch_3/drivers/net/s2io.c	2007-06-07 12:11:27.000000000 +0530
+++ patch_4/drivers/net/s2io.c	2007-06-07 12:00:16.000000000 +0530
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.23.1"
+#define DRV_VERSION "2.0.24.1"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -4837,15 +4837,15 @@ static void s2io_ethtool_gringparam(stru
 		ering->rx_max_pending = MAX_RX_DESC_2;
 
 	ering->tx_max_pending = MAX_TX_DESC;
-	for (i = 0 ; i < sp->config.tx_fifo_num ; i++) {
+	for (i = 0 ; i < sp->config.tx_fifo_num ; i++) 
 		tx_desc_count += sp->config.tx_cfg[i].fifo_len;
-	}
+
 	DBG_PRINT(INFO_DBG,"\nmax txds : %d\n",sp->config.max_txds);
 	ering->tx_pending = tx_desc_count;
 	rx_desc_count = 0;
-	for (i = 0 ; i < sp->config.rx_ring_num ; i++) {
+	for (i = 0 ; i < sp->config.rx_ring_num ; i++) 
 		rx_desc_count += sp->config.rx_cfg[i].num_rxd;
-	}
+
 	ering->rx_pending = rx_desc_count;
 
 	ering->rx_mini_max_pending = 0;
@@ -6723,13 +6723,7 @@ static int rx_osm_handler(struct ring_in
 	struct lro *lro;
 
 	skb->dev = dev;
-
-	if (err) {
-		/* Check for parity error */
-		if (err & 0x1) {
-			sp->mac_control.stats_info->sw_stat.parity_err_cnt++;
-		}
-		err >>= 48;
+	if ((err = GET_RXD_T_CODE(rxdp->Control_1))) {
 		switch(err) {
 			case 1:
 				sp->mac_control.stats_info->sw_stat.
diff -urpN patch_3/drivers/net/s2io.h patch_4/drivers/net/s2io.h
--- patch_3/drivers/net/s2io.h	2007-05-21 15:32:26.000000000 +0530
+++ patch_4/drivers/net/s2io.h	2007-06-07 12:07:01.000000000 +0530
@@ -503,6 +503,7 @@ struct RxD_t {
 	u64 Control_1;
 #define RXD_OWN_XENA            BIT(7)
 #define RXD_T_CODE              (BIT(12)|BIT(13)|BIT(14)|BIT(15))
+#define GET_RXD_T_CODE(val)     ((val & RXD_T_CODE) >> 48)
 #define RXD_FRAME_PROTO         vBIT(0xFFFF,24,8)
 #define RXD_FRAME_PROTO_IPV4    BIT(27)
 #define RXD_FRAME_PROTO_IPV6    BIT(28)

