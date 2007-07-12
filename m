From: Veena Parat <Veena.Parat@neterion.com>
Subject: [PATCH 2.6.22 4/4]S2IO: Implementing review comments from old patches
Date: Thu, 12 Jul 2007 06:23:37 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10707120620210.16507-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:44779 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757914AbXGLKXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 06:23:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implementation of review comments
 - Incorporated Jeff Garzik's comments on coding standards
 - Incorporated Andreas Schwab's comments on redundant condition check

Signed-off-by: Veena Parat <veena.parat@neterion.com>
---
diff -Nurp 2.0.23.1P3/drivers/net/s2io.c 2.0.23.1P4/drivers/net/s2io.c
--- 2.0.23.1P3/drivers/net/s2io.c	2007-07-04 01:36:55.000000000 -0700
+++ 2.0.23.1P4/drivers/net/s2io.c	2007-07-04 02:54:29.000000000 -0700
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.23.1"
+#define DRV_VERSION "2.0.24.1"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -4836,15 +4836,13 @@ static void s2io_ethtool_gringparam(stru
 		ering->rx_max_pending = MAX_RX_DESC_2;
 
 	ering->tx_max_pending = MAX_TX_DESC;
-	for (i = 0 ; i < sp->config.tx_fifo_num ; i++) {
+	for (i = 0 ; i < sp->config.tx_fifo_num ; i++) 
 		tx_desc_count += sp->config.tx_cfg[i].fifo_len;
-	}
 	DBG_PRINT(INFO_DBG,"\nmax txds : %d\n",sp->config.max_txds);
 	ering->tx_pending = tx_desc_count;
 	rx_desc_count = 0;
-	for (i = 0 ; i < sp->config.rx_ring_num ; i++) {
+	for (i = 0 ; i < sp->config.rx_ring_num ; i++) 
 		rx_desc_count += sp->config.rx_cfg[i].num_rxd;
-	}
 	ering->rx_pending = rx_desc_count;
 
 	ering->rx_mini_max_pending = 0;
diff -Nurp 2.0.23.1P3/drivers/net/s2io.h 2.0.23.1P4/drivers/net/s2io.h
--- 2.0.23.1P3/drivers/net/s2io.h	2007-07-03 23:58:40.000000000 -0700
+++ 2.0.23.1P4/drivers/net/s2io.h	2007-07-04 02:54:29.000000000 -0700
@@ -464,7 +464,7 @@ struct TxD {
 #define TXD_LIST_OWN_XENA       BIT(7)
 #define TXD_T_CODE              (BIT(12)|BIT(13)|BIT(14)|BIT(15))
 #define TXD_T_CODE_OK(val)      (|(val & TXD_T_CODE))
-#define GET_TXD_T_CODE(val)     ((val & TXD_T_CODE)<<12)
+#define GET_TXD_T_CODE(val)     ((val & TXD_T_CODE)>> 48)
 #define TXD_GATHER_CODE         (BIT(22) | BIT(23))
 #define TXD_GATHER_CODE_FIRST   BIT(22)
 #define TXD_GATHER_CODE_LAST    BIT(23)
@@ -503,6 +503,7 @@ struct RxD_t {
 	u64 Control_1;
 #define RXD_OWN_XENA            BIT(7)
 #define RXD_T_CODE              (BIT(12)|BIT(13)|BIT(14)|BIT(15))
+#define GET_RXD_T_CODE(val)     ((val & RXD_T_CODE) >> 48)
 #define RXD_FRAME_PROTO         vBIT(0xFFFF,24,8)
 #define RXD_FRAME_PROTO_IPV4    BIT(27)
 #define RXD_FRAME_PROTO_IPV6    BIT(28)

