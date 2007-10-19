From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 7/8] [MV643XX_ETH] Clean up mv643xx_eth.h
Date: Fri, 19 Oct 2007 04:11:38 +0200
Message-ID: <20071019021138.GI16037@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Manas Saksena <msaksena@marvell.com>, netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:44019 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763986AbXJSCLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 22:11:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Apply the following cleanups to drivers/net/mv643xx_eth.h:
* Change "#define<tab>" to "#define<space>".
* Fix comment block style.
* Wrap lines to fit in 80 columns.
* Change "foo<<1" to "foo << 1".
* Align addresses in the same column.
* Parenthesize macro arguments.
* Replace "(1<<24) | (1<<23) | (1<<22)" type constructs with "(7 << 22)".

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Acked-by: Tzachi Perelstein <tzachi@marvell.com>

Index: linux-2.6/drivers/net/mv643xx_eth.h
===================================================================
--- linux-2.6.orig/drivers/net/mv643xx_eth.h
+++ linux-2.6/drivers/net/mv643xx_eth.h
@@ -14,9 +14,9 @@
 /* Checksum offload for Tx works for most packets, but
  * fails if previous packet sent did not use hw csum
  */
-#define	MV643XX_CHECKSUM_OFFLOAD_TX
-#define	MV643XX_NAPI
-#define	MV643XX_TX_FAST_REFILL
+#define MV643XX_CHECKSUM_OFFLOAD_TX
+#define MV643XX_NAPI
+#define MV643XX_TX_FAST_REFILL
 #undef	MV643XX_COAL
 
 /*
@@ -49,230 +49,199 @@
 #define ETH_HW_IP_ALIGN		2		/* hw aligns IP header */
 #define ETH_WRAPPER_LEN		(ETH_HW_IP_ALIGN + ETH_HLEN + \
 					ETH_VLAN_HLEN + ETH_FCS_LEN)
-#define ETH_RX_SKB_SIZE		(dev->mtu + ETH_WRAPPER_LEN + dma_get_cache_alignment())
+#define ETH_RX_SKB_SIZE		(dev->mtu + ETH_WRAPPER_LEN + \
+					dma_get_cache_alignment())
 
-/****************************************/
-/*        Ethernet Unit Registers  		*/
-/****************************************/
-
-#define PHY_ADDR_REG                                    0x0000
-#define SMI_REG                                         0x0004
-#define UNIT_DEFAULT_ADDR_REG                           0x0008
-#define UNIT_DEFAULTID_REG                              0x000c
-#define UNIT_INTERRUPT_CAUSE_REG                        0x0080
-#define UNIT_INTERRUPT_MASK_REG                         0x0084
-#define UNIT_INTERNAL_USE_REG                           0x04fc
-#define UNIT_ERROR_ADDR_REG                             0x0094
-#define BAR_0                                           0x0200
-#define BAR_1                                           0x0208
-#define BAR_2                                           0x0210
-#define BAR_3                                           0x0218
-#define BAR_4                                           0x0220
-#define BAR_5                                           0x0228
-#define SIZE_REG_0                                      0x0204
-#define SIZE_REG_1                                      0x020c
-#define SIZE_REG_2                                      0x0214
-#define SIZE_REG_3                                      0x021c
-#define SIZE_REG_4                                      0x0224
-#define SIZE_REG_5                                      0x022c
-#define HEADERS_RETARGET_BASE_REG                       0x0230
-#define HEADERS_RETARGET_CONTROL_REG                    0x0234
-#define HIGH_ADDR_REMAP_REG_0                           0x0280
-#define HIGH_ADDR_REMAP_REG_1                           0x0284
-#define HIGH_ADDR_REMAP_REG_2                           0x0288
-#define HIGH_ADDR_REMAP_REG_3                           0x028c
-#define BASE_ADDR_ENABLE_REG                            0x0290
-#define ACCESS_PROTECTION_REG(port)                    (0x0294 + (port<<2))
-#define MIB_COUNTERS_BASE(port)                        (0x1000 + (port<<7))
-#define PORT_CONFIG_REG(port)                          (0x0400 + (port<<10))
-#define PORT_CONFIG_EXTEND_REG(port)                   (0x0404 + (port<<10))
-#define MII_SERIAL_PARAMETRS_REG(port)                 (0x0408 + (port<<10))
-#define GMII_SERIAL_PARAMETRS_REG(port)                (0x040c + (port<<10))
-#define VLAN_ETHERTYPE_REG(port)                       (0x0410 + (port<<10))
-#define MAC_ADDR_LOW(port)                             (0x0414 + (port<<10))
-#define MAC_ADDR_HIGH(port)                            (0x0418 + (port<<10))
-#define SDMA_CONFIG_REG(port)                          (0x041c + (port<<10))
-#define DSCP_0(port)                                   (0x0420 + (port<<10))
-#define DSCP_1(port)                                   (0x0424 + (port<<10))
-#define DSCP_2(port)                                   (0x0428 + (port<<10))
-#define DSCP_3(port)                                   (0x042c + (port<<10))
-#define DSCP_4(port)                                   (0x0430 + (port<<10))
-#define DSCP_5(port)                                   (0x0434 + (port<<10))
-#define DSCP_6(port)                                   (0x0438 + (port<<10))
-#define PORT_SERIAL_CONTROL_REG(port)                  (0x043c + (port<<10))
-#define VLAN_PRIORITY_TAG_TO_PRIORITY(port)            (0x0440 + (port<<10))
-#define PORT_STATUS_REG(port)                          (0x0444 + (port<<10))
-#define TRANSMIT_QUEUE_COMMAND_REG(port)               (0x0448 + (port<<10))
-#define TX_QUEUE_FIXED_PRIORITY(port)                  (0x044c + (port<<10))
-#define PORT_TX_TOKEN_BUCKET_RATE_CONFIG(port)         (0x0450 + (port<<10))
-#define MAXIMUM_TRANSMIT_UNIT(port)                    (0x0458 + (port<<10))
-#define PORT_MAXIMUM_TOKEN_BUCKET_SIZE(port)           (0x045c + (port<<10))
-#define INTERRUPT_CAUSE_REG(port)                      (0x0460 + (port<<10))
-#define INTERRUPT_CAUSE_EXTEND_REG(port)               (0x0464 + (port<<10))
-#define INTERRUPT_MASK_REG(port)                       (0x0468 + (port<<10))
-#define INTERRUPT_EXTEND_MASK_REG(port)                (0x046c + (port<<10))
-#define RX_FIFO_URGENT_THRESHOLD_REG(port)             (0x0470 + (port<<10))
-#define TX_FIFO_URGENT_THRESHOLD_REG(port)             (0x0474 + (port<<10))
-#define RX_MINIMAL_FRAME_SIZE_REG(port)                (0x047c + (port<<10))
-#define RX_DISCARDED_FRAMES_COUNTER(port)              (0x0484 + (port<<10))
-#define PORT_DEBUG_0_REG(port)                         (0x048c + (port<<10))
-#define PORT_DEBUG_1_REG(port)                         (0x0490 + (port<<10))
-#define PORT_INTERNAL_ADDR_ERROR_REG(port)             (0x0494 + (port<<10))
-#define INTERNAL_USE_REG(port)                         (0x04fc + (port<<10))
-#define RECEIVE_QUEUE_COMMAND_REG(port)                (0x0680 + (port<<10))
-#define CURRENT_SERVED_TX_DESC_PTR(port)               (0x0684 + (port<<10))
-#define RX_CURRENT_QUEUE_DESC_PTR_0(port)              (0x060c + (port<<10))     
-#define RX_CURRENT_QUEUE_DESC_PTR_1(port)              (0x061c + (port<<10))     
-#define RX_CURRENT_QUEUE_DESC_PTR_2(port)              (0x062c + (port<<10))     
-#define RX_CURRENT_QUEUE_DESC_PTR_3(port)              (0x063c + (port<<10))     
-#define RX_CURRENT_QUEUE_DESC_PTR_4(port)              (0x064c + (port<<10))     
-#define RX_CURRENT_QUEUE_DESC_PTR_5(port)              (0x065c + (port<<10))     
-#define RX_CURRENT_QUEUE_DESC_PTR_6(port)              (0x066c + (port<<10))     
-#define RX_CURRENT_QUEUE_DESC_PTR_7(port)              (0x067c + (port<<10))     
-#define TX_CURRENT_QUEUE_DESC_PTR_0(port)              (0x06c0 + (port<<10))     
-#define TX_CURRENT_QUEUE_DESC_PTR_1(port)              (0x06c4 + (port<<10))     
-#define TX_CURRENT_QUEUE_DESC_PTR_2(port)              (0x06c8 + (port<<10))     
-#define TX_CURRENT_QUEUE_DESC_PTR_3(port)              (0x06cc + (port<<10))     
-#define TX_CURRENT_QUEUE_DESC_PTR_4(port)              (0x06d0 + (port<<10))     
-#define TX_CURRENT_QUEUE_DESC_PTR_5(port)              (0x06d4 + (port<<10))     
-#define TX_CURRENT_QUEUE_DESC_PTR_6(port)              (0x06d8 + (port<<10))     
-#define TX_CURRENT_QUEUE_DESC_PTR_7(port)              (0x06dc + (port<<10))     
-#define TX_QUEUE_0_TOKEN_BUCKET_COUNT(port)            (0x0700 + (port<<10))
-#define TX_QUEUE_1_TOKEN_BUCKET_COUNT(port)            (0x0710 + (port<<10))
-#define TX_QUEUE_2_TOKEN_BUCKET_COUNT(port)            (0x0720 + (port<<10))
-#define TX_QUEUE_3_TOKEN_BUCKET_COUNT(port)            (0x0730 + (port<<10))
-#define TX_QUEUE_4_TOKEN_BUCKET_COUNT(port)            (0x0740 + (port<<10))
-#define TX_QUEUE_5_TOKEN_BUCKET_COUNT(port)            (0x0750 + (port<<10))
-#define TX_QUEUE_6_TOKEN_BUCKET_COUNT(port)            (0x0760 + (port<<10))
-#define TX_QUEUE_7_TOKEN_BUCKET_COUNT(port)            (0x0770 + (port<<10))
-#define TX_QUEUE_0_TOKEN_BUCKET_CONFIG(port)           (0x0704 + (port<<10))
-#define TX_QUEUE_1_TOKEN_BUCKET_CONFIG(port)           (0x0714 + (port<<10))
-#define TX_QUEUE_2_TOKEN_BUCKET_CONFIG(port)           (0x0724 + (port<<10))
-#define TX_QUEUE_3_TOKEN_BUCKET_CONFIG(port)           (0x0734 + (port<<10))
-#define TX_QUEUE_4_TOKEN_BUCKET_CONFIG(port)           (0x0744 + (port<<10))
-#define TX_QUEUE_5_TOKEN_BUCKET_CONFIG(port)           (0x0754 + (port<<10))
-#define TX_QUEUE_6_TOKEN_BUCKET_CONFIG(port)           (0x0764 + (port<<10))
-#define TX_QUEUE_7_TOKEN_BUCKET_CONFIG(port)           (0x0774 + (port<<10))
-#define TX_QUEUE_0_ARBITER_CONFIG(port)                (0x0708 + (port<<10))
-#define TX_QUEUE_1_ARBITER_CONFIG(port)                (0x0718 + (port<<10))
-#define TX_QUEUE_2_ARBITER_CONFIG(port)                (0x0728 + (port<<10))
-#define TX_QUEUE_3_ARBITER_CONFIG(port)                (0x0738 + (port<<10))
-#define TX_QUEUE_4_ARBITER_CONFIG(port)                (0x0748 + (port<<10))
-#define TX_QUEUE_5_ARBITER_CONFIG(port)                (0x0758 + (port<<10))
-#define TX_QUEUE_6_ARBITER_CONFIG(port)                (0x0768 + (port<<10))
-#define TX_QUEUE_7_ARBITER_CONFIG(port)                (0x0778 + (port<<10))
-#define PORT_TX_TOKEN_BUCKET_COUNT(port)               (0x0780 + (port<<10))
-#define DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port)   (0x1400 + (port<<10))
-#define DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port)     (0x1500 + (port<<10))
-#define DA_FILTER_UNICAST_TABLE_BASE(port)             (0x1600 + (port<<10))
+/*
+ * Registers shared between all ports.
+ */
+#define PHY_ADDR_REG				0x0000
+#define SMI_REG					0x0004
+#define UNIT_DEFAULT_ADDR_REG			0x0008
+#define UNIT_DEFAULTID_REG			0x000c
+#define UNIT_INTERRUPT_CAUSE_REG		0x0080
+#define UNIT_INTERRUPT_MASK_REG			0x0084
+#define UNIT_INTERNAL_USE_REG			0x04fc
+#define UNIT_ERROR_ADDR_REG			0x0094
+#define BAR_0					0x0200
+#define BAR_1					0x0208
+#define BAR_2					0x0210
+#define BAR_3					0x0218
+#define BAR_4					0x0220
+#define BAR_5					0x0228
+#define SIZE_REG_0				0x0204
+#define SIZE_REG_1				0x020c
+#define SIZE_REG_2				0x0214
+#define SIZE_REG_3				0x021c
+#define SIZE_REG_4				0x0224
+#define SIZE_REG_5				0x022c
+#define HEADERS_RETARGET_BASE_REG		0x0230
+#define HEADERS_RETARGET_CONTROL_REG		0x0234
+#define HIGH_ADDR_REMAP_REG_0			0x0280
+#define HIGH_ADDR_REMAP_REG_1			0x0284
+#define HIGH_ADDR_REMAP_REG_2			0x0288
+#define HIGH_ADDR_REMAP_REG_3			0x028c
+#define BASE_ADDR_ENABLE_REG			0x0290
+
+
+/*
+ * Per-port registers.
+ */
+#define ACCESS_PROTECTION_REG(p)			(0x0294 + ((p) << 2))
+#define PORT_CONFIG_REG(p)				(0x0400 + ((p) << 10))
+#define PORT_CONFIG_EXTEND_REG(p)			(0x0404 + ((p) << 10))
+#define MII_SERIAL_PARAMETRS_REG(p)			(0x0408 + ((p) << 10))
+#define GMII_SERIAL_PARAMETRS_REG(p)			(0x040c + ((p) << 10))
+#define VLAN_ETHERTYPE_REG(p)				(0x0410 + ((p) << 10))
+#define MAC_ADDR_LOW(p)					(0x0414 + ((p) << 10))
+#define MAC_ADDR_HIGH(p)				(0x0418 + ((p) << 10))
+#define SDMA_CONFIG_REG(p)				(0x041c + ((p) << 10))
+#define DSCP_0(p)					(0x0420 + ((p) << 10))
+#define DSCP_1(p)					(0x0424 + ((p) << 10))
+#define DSCP_2(p)					(0x0428 + ((p) << 10))
+#define DSCP_3(p)					(0x042c + ((p) << 10))
+#define DSCP_4(p)					(0x0430 + ((p) << 10))
+#define DSCP_5(p)					(0x0434 + ((p) << 10))
+#define DSCP_6(p)					(0x0438 + ((p) << 10))
+#define PORT_SERIAL_CONTROL_REG(p)			(0x043c + ((p) << 10))
+#define VLAN_PRIORITY_TAG_TO_PRIORITY(p)		(0x0440 + ((p) << 10))
+#define PORT_STATUS_REG(p)				(0x0444 + ((p) << 10))
+#define TRANSMIT_QUEUE_COMMAND_REG(p)			(0x0448 + ((p) << 10))
+#define TX_QUEUE_FIXED_PRIORITY(p)			(0x044c + ((p) << 10))
+#define PORT_TX_TOKEN_BUCKET_RATE_CONFIG(p)		(0x0450 + ((p) << 10))
+#define MAXIMUM_TRANSMIT_UNIT(p)			(0x0458 + ((p) << 10))
+#define PORT_MAXIMUM_TOKEN_BUCKET_SIZE(p)		(0x045c + ((p) << 10))
+#define INTERRUPT_CAUSE_REG(p)				(0x0460 + ((p) << 10))
+#define INTERRUPT_CAUSE_EXTEND_REG(p)			(0x0464 + ((p) << 10))
+#define INTERRUPT_MASK_REG(p)				(0x0468 + ((p) << 10))
+#define INTERRUPT_EXTEND_MASK_REG(p)			(0x046c + ((p) << 10))
+#define RX_FIFO_URGENT_THRESHOLD_REG(p)			(0x0470 + ((p) << 10))
+#define TX_FIFO_URGENT_THRESHOLD_REG(p)			(0x0474 + ((p) << 10))
+#define RX_MINIMAL_FRAME_SIZE_REG(p)			(0x047c + ((p) << 10))
+#define RX_DISCARDED_FRAMES_COUNTER(p)			(0x0484 + ((p) << 10))
+#define PORT_DEBUG_0_REG(p)				(0x048c + ((p) << 10))
+#define PORT_DEBUG_1_REG(p)				(0x0490 + ((p) << 10))
+#define PORT_INTERNAL_ADDR_ERROR_REG(p)			(0x0494 + ((p) << 10))
+#define INTERNAL_USE_REG(p)				(0x04fc + ((p) << 10))
+#define RX_CURRENT_QUEUE_DESC_PTR_0(p)			(0x060c + ((p) << 10))
+#define RX_CURRENT_QUEUE_DESC_PTR_1(p)			(0x061c + ((p) << 10))
+#define RX_CURRENT_QUEUE_DESC_PTR_2(p)			(0x062c + ((p) << 10))
+#define RX_CURRENT_QUEUE_DESC_PTR_3(p)			(0x063c + ((p) << 10))
+#define RX_CURRENT_QUEUE_DESC_PTR_4(p)			(0x064c + ((p) << 10))
+#define RX_CURRENT_QUEUE_DESC_PTR_5(p)			(0x065c + ((p) << 10))
+#define RX_CURRENT_QUEUE_DESC_PTR_6(p)			(0x066c + ((p) << 10))
+#define RX_CURRENT_QUEUE_DESC_PTR_7(p)			(0x067c + ((p) << 10))
+#define RECEIVE_QUEUE_COMMAND_REG(p)			(0x0680 + ((p) << 10))
+#define CURRENT_SERVED_TX_DESC_PTR(p)			(0x0684 + ((p) << 10))
+#define TX_CURRENT_QUEUE_DESC_PTR_0(p)			(0x06c0 + ((p) << 10))
+#define TX_CURRENT_QUEUE_DESC_PTR_1(p)			(0x06c4 + ((p) << 10))
+#define TX_CURRENT_QUEUE_DESC_PTR_2(p)			(0x06c8 + ((p) << 10))
+#define TX_CURRENT_QUEUE_DESC_PTR_3(p)			(0x06cc + ((p) << 10))
+#define TX_CURRENT_QUEUE_DESC_PTR_4(p)			(0x06d0 + ((p) << 10))
+#define TX_CURRENT_QUEUE_DESC_PTR_5(p)			(0x06d4 + ((p) << 10))
+#define TX_CURRENT_QUEUE_DESC_PTR_6(p)			(0x06d8 + ((p) << 10))
+#define TX_CURRENT_QUEUE_DESC_PTR_7(p)			(0x06dc + ((p) << 10))
+#define TX_QUEUE_0_TOKEN_BUCKET_COUNT(p)		(0x0700 + ((p) << 10))
+#define TX_QUEUE_0_TOKEN_BUCKET_CONFIG(p)		(0x0704 + ((p) << 10))
+#define TX_QUEUE_0_ARBITER_CONFIG(p)			(0x0708 + ((p) << 10))
+#define TX_QUEUE_1_TOKEN_BUCKET_COUNT(p)		(0x0710 + ((p) << 10))
+#define TX_QUEUE_1_TOKEN_BUCKET_CONFIG(p)		(0x0714 + ((p) << 10))
+#define TX_QUEUE_1_ARBITER_CONFIG(p)			(0x0718 + ((p) << 10))
+#define TX_QUEUE_2_TOKEN_BUCKET_COUNT(p)		(0x0720 + ((p) << 10))
+#define TX_QUEUE_2_TOKEN_BUCKET_CONFIG(p)		(0x0724 + ((p) << 10))
+#define TX_QUEUE_2_ARBITER_CONFIG(p)			(0x0728 + ((p) << 10))
+#define TX_QUEUE_3_TOKEN_BUCKET_COUNT(p)		(0x0730 + ((p) << 10))
+#define TX_QUEUE_3_TOKEN_BUCKET_CONFIG(p)		(0x0734 + ((p) << 10))
+#define TX_QUEUE_3_ARBITER_CONFIG(p)			(0x0738 + ((p) << 10))
+#define TX_QUEUE_4_TOKEN_BUCKET_COUNT(p)		(0x0740 + ((p) << 10))
+#define TX_QUEUE_4_TOKEN_BUCKET_CONFIG(p)		(0x0744 + ((p) << 10))
+#define TX_QUEUE_4_ARBITER_CONFIG(p)			(0x0748 + ((p) << 10))
+#define TX_QUEUE_5_TOKEN_BUCKET_COUNT(p)		(0x0750 + ((p) << 10))
+#define TX_QUEUE_5_TOKEN_BUCKET_CONFIG(p)		(0x0754 + ((p) << 10))
+#define TX_QUEUE_5_ARBITER_CONFIG(p)			(0x0758 + ((p) << 10))
+#define TX_QUEUE_6_TOKEN_BUCKET_COUNT(p)		(0x0760 + ((p) << 10))
+#define TX_QUEUE_6_TOKEN_BUCKET_CONFIG(p)		(0x0764 + ((p) << 10))
+#define TX_QUEUE_6_ARBITER_CONFIG(p)			(0x0768 + ((p) << 10))
+#define TX_QUEUE_7_TOKEN_BUCKET_COUNT(p)		(0x0770 + ((p) << 10))
+#define TX_QUEUE_7_TOKEN_BUCKET_CONFIG(p)		(0x0774 + ((p) << 10))
+#define TX_QUEUE_7_ARBITER_CONFIG(p)			(0x0778 + ((p) << 10))
+#define PORT_TX_TOKEN_BUCKET_COUNT(p)			(0x0780 + ((p) << 10))
+#define MIB_COUNTERS_BASE(p)				(0x1000 + ((p) << 7))
+#define DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(p)	(0x1400 + ((p) << 10))
+#define DA_FILTER_OTHER_MULTICAST_TABLE_BASE(p)		(0x1500 + ((p) << 10))
+#define DA_FILTER_UNICAST_TABLE_BASE(p)			(0x1600 + ((p) << 10))
 
 /* These macros describe Ethernet Port configuration reg (Px_cR) bits */
-#define UNICAST_NORMAL_MODE		0
-#define UNICAST_PROMISCUOUS_MODE	(1<<0)
-#define DEFAULT_RX_QUEUE_0		0
-#define DEFAULT_RX_QUEUE_1		(1<<1)
-#define DEFAULT_RX_QUEUE_2		(1<<2)
-#define DEFAULT_RX_QUEUE_3		((1<<2) | (1<<1))
-#define DEFAULT_RX_QUEUE_4		(1<<3)
-#define DEFAULT_RX_QUEUE_5		((1<<3) | (1<<1))
-#define DEFAULT_RX_QUEUE_6		((1<<3) | (1<<2))
-#define DEFAULT_RX_QUEUE_7		((1<<3) | (1<<2) | (1<<1))
-#define DEFAULT_RX_ARP_QUEUE_0	0
-#define DEFAULT_RX_ARP_QUEUE_1	(1<<4)
-#define DEFAULT_RX_ARP_QUEUE_2	(1<<5)
-#define DEFAULT_RX_ARP_QUEUE_3	((1<<5) | (1<<4))
-#define DEFAULT_RX_ARP_QUEUE_4	(1<<6)
-#define DEFAULT_RX_ARP_QUEUE_5	((1<<6) | (1<<4))
-#define DEFAULT_RX_ARP_QUEUE_6	((1<<6) | (1<<5))
-#define DEFAULT_RX_ARP_QUEUE_7	((1<<6) | (1<<5) | (1<<4))
-#define RECEIVE_BC_IF_NOT_IP_OR_ARP	0
-#define REJECT_BC_IF_NOT_IP_OR_ARP	(1<<7)
-#define RECEIVE_BC_IF_IP		0
-#define REJECT_BC_IF_IP		(1<<8)
-#define RECEIVE_BC_IF_ARP		0
-#define REJECT_BC_IF_ARP		(1<<9)
-#define TX_AM_NO_UPDATE_ERROR_SUMMARY (1<<12)
-#define CAPTURE_TCP_FRAMES_DIS	0
-#define CAPTURE_TCP_FRAMES_EN	(1<<14)
-#define CAPTURE_UDP_FRAMES_DIS	0
-#define CAPTURE_UDP_FRAMES_EN	(1<<15)
-#define DEFAULT_RX_TCP_QUEUE_0	0
-#define DEFAULT_RX_TCP_QUEUE_1	(1<<16)
-#define DEFAULT_RX_TCP_QUEUE_2	(1<<17)
-#define DEFAULT_RX_TCP_QUEUE_3	((1<<17) | (1<<16))
-#define DEFAULT_RX_TCP_QUEUE_4	(1<<18)
-#define DEFAULT_RX_TCP_QUEUE_5	((1<<18) | (1<<16))
-#define DEFAULT_RX_TCP_QUEUE_6	((1<<18) | (1<<17))
-#define DEFAULT_RX_TCP_QUEUE_7	((1<<18) | (1<<17) | (1<<16))
-#define DEFAULT_RX_UDP_QUEUE_0	0
-#define DEFAULT_RX_UDP_QUEUE_1	(1<<19)
-#define DEFAULT_RX_UDP_QUEUE_2	(1<<20)
-#define DEFAULT_RX_UDP_QUEUE_3	((1<<20) | (1<<19))
-#define DEFAULT_RX_UDP_QUEUE_4	(1<<21)
-#define DEFAULT_RX_UDP_QUEUE_5	((1<<21) | (1<<19))
-#define DEFAULT_RX_UDP_QUEUE_6	((1<<21) | (1<<20))
-#define DEFAULT_RX_UDP_QUEUE_7	((1<<21) | (1<<20) | (1<<19))
-#define DEFAULT_RX_BPDU_QUEUE_0	0
-#define DEFAULT_RX_BPDU_QUEUE_1	(1<<22)
-#define DEFAULT_RX_BPDU_QUEUE_2	(1<<23)
-#define DEFAULT_RX_BPDU_QUEUE_3	((1<<23) | (1<<22))
-#define DEFAULT_RX_BPDU_QUEUE_4	(1<<24)
-#define DEFAULT_RX_BPDU_QUEUE_5	((1<<24) | (1<<22))
-#define DEFAULT_RX_BPDU_QUEUE_6	((1<<24) | (1<<23))
-#define DEFAULT_RX_BPDU_QUEUE_7	((1<<24) | (1<<23) | (1<<22))
+#define UNICAST_NORMAL_MODE		(0 << 0)
+#define UNICAST_PROMISCUOUS_MODE	(1 << 0)
+#define DEFAULT_RX_QUEUE(queue)		((queue) << 1)
+#define DEFAULT_RX_ARP_QUEUE(queue)	((queue) << 4)
+#define RECEIVE_BC_IF_NOT_IP_OR_ARP	(0 << 7)
+#define REJECT_BC_IF_NOT_IP_OR_ARP	(1 << 7)
+#define RECEIVE_BC_IF_IP		(0 << 8)
+#define REJECT_BC_IF_IP			(1 << 8)
+#define RECEIVE_BC_IF_ARP		(0 << 9)
+#define REJECT_BC_IF_ARP		(1 << 9)
+#define TX_AM_NO_UPDATE_ERROR_SUMMARY	(1 << 12)
+#define CAPTURE_TCP_FRAMES_DIS		(0 << 14)
+#define CAPTURE_TCP_FRAMES_EN		(1 << 14)
+#define CAPTURE_UDP_FRAMES_DIS		(0 << 15)
+#define CAPTURE_UDP_FRAMES_EN		(1 << 15)
+#define DEFAULT_RX_TCP_QUEUE(queue)	((queue) << 16)
+#define DEFAULT_RX_UDP_QUEUE(queue)	((queue) << 19)
+#define DEFAULT_RX_BPDU_QUEUE(queue)	((queue) << 22)
 
-#define	PORT_CONFIG_DEFAULT_VALUE			\
+#define PORT_CONFIG_DEFAULT_VALUE			\
 		UNICAST_NORMAL_MODE		|	\
-		DEFAULT_RX_QUEUE_0		|	\
-		DEFAULT_RX_ARP_QUEUE_0	|	\
+		DEFAULT_RX_QUEUE(0)		|	\
+		DEFAULT_RX_ARP_QUEUE(0)		|	\
 		RECEIVE_BC_IF_NOT_IP_OR_ARP	|	\
 		RECEIVE_BC_IF_IP		|	\
 		RECEIVE_BC_IF_ARP		|	\
-		CAPTURE_TCP_FRAMES_DIS	|	\
-		CAPTURE_UDP_FRAMES_DIS	|	\
-		DEFAULT_RX_TCP_QUEUE_0	|	\
-		DEFAULT_RX_UDP_QUEUE_0	|	\
-		DEFAULT_RX_BPDU_QUEUE_0
+		CAPTURE_TCP_FRAMES_DIS		|	\
+		CAPTURE_UDP_FRAMES_DIS		|	\
+		DEFAULT_RX_TCP_QUEUE(0)		|	\
+		DEFAULT_RX_UDP_QUEUE(0)		|	\
+		DEFAULT_RX_BPDU_QUEUE(0)
 
 /* These macros describe Ethernet Port configuration extend reg (Px_cXR) bits*/
-#define CLASSIFY_EN				(1<<0)
-#define SPAN_BPDU_PACKETS_AS_NORMAL		0
-#define SPAN_BPDU_PACKETS_TO_RX_QUEUE_7	(1<<1)
-#define PARTITION_DISABLE			0
-#define PARTITION_ENABLE			(1<<2)
+#define CLASSIFY_EN				(1 << 0)
+#define SPAN_BPDU_PACKETS_AS_NORMAL		(0 << 1)
+#define SPAN_BPDU_PACKETS_TO_RX_QUEUE_7		(1 << 1)
+#define PARTITION_DISABLE			(0 << 2)
+#define PARTITION_ENABLE			(1 << 2)
 
-#define	PORT_CONFIG_EXTEND_DEFAULT_VALUE		\
+#define PORT_CONFIG_EXTEND_DEFAULT_VALUE		\
 		SPAN_BPDU_PACKETS_AS_NORMAL	|	\
 		PARTITION_DISABLE
 
 /* These macros describe Ethernet Port Sdma configuration reg (SDCR) bits */
-#define RIFB			(1<<0)
-#define RX_BURST_SIZE_1_64BIT		0
-#define RX_BURST_SIZE_2_64BIT		(1<<1)
-#define RX_BURST_SIZE_4_64BIT		(1<<2)
-#define RX_BURST_SIZE_8_64BIT		((1<<2) | (1<<1))
-#define RX_BURST_SIZE_16_64BIT		(1<<3)
-#define BLM_RX_NO_SWAP			(1<<4)
-#define BLM_RX_BYTE_SWAP			0
-#define BLM_TX_NO_SWAP			(1<<5)
-#define BLM_TX_BYTE_SWAP			0
-#define DESCRIPTORS_BYTE_SWAP		(1<<6)
-#define DESCRIPTORS_NO_SWAP			0
-#define TX_BURST_SIZE_1_64BIT		0
-#define TX_BURST_SIZE_2_64BIT		(1<<22)
-#define TX_BURST_SIZE_4_64BIT		(1<<23)
-#define TX_BURST_SIZE_8_64BIT		((1<<23) | (1<<22))
-#define TX_BURST_SIZE_16_64BIT		(1<<24)
-
-#define	IPG_INT_RX(value) ((value & 0x3fff) << 8)
+#define RIFB				(1 << 0)
+#define RX_BURST_SIZE_1_64BIT		(0 << 1)
+#define RX_BURST_SIZE_2_64BIT		(1 << 1)
+#define RX_BURST_SIZE_4_64BIT		(2 << 1)
+#define RX_BURST_SIZE_8_64BIT		(3 << 1)
+#define RX_BURST_SIZE_16_64BIT		(4 << 1)
+#define BLM_RX_NO_SWAP			(1 << 4)
+#define BLM_RX_BYTE_SWAP		(0 << 4)
+#define BLM_TX_NO_SWAP			(1 << 5)
+#define BLM_TX_BYTE_SWAP		(0 << 5)
+#define DESCRIPTORS_BYTE_SWAP		(1 << 6)
+#define DESCRIPTORS_NO_SWAP		(0 << 6)
+#define IPG_INT_RX(value)		(((value) & 0x3fff) << 8)
+#define TX_BURST_SIZE_1_64BIT		(0 << 22)
+#define TX_BURST_SIZE_2_64BIT		(1 << 22)
+#define TX_BURST_SIZE_4_64BIT		(2 << 22)
+#define TX_BURST_SIZE_8_64BIT		(3 << 22)
+#define TX_BURST_SIZE_16_64BIT		(4 << 22)
 
 #if defined(__BIG_ENDIAN)
-#define	PORT_SDMA_CONFIG_DEFAULT_VALUE		\
+#define PORT_SDMA_CONFIG_DEFAULT_VALUE		\
 		RX_BURST_SIZE_4_64BIT	|	\
 		IPG_INT_RX(0)		|	\
 		TX_BURST_SIZE_4_64BIT
 #elif defined(__LITTLE_ENDIAN)
-#define	PORT_SDMA_CONFIG_DEFAULT_VALUE		\
+#define PORT_SDMA_CONFIG_DEFAULT_VALUE		\
 		RX_BURST_SIZE_4_64BIT	|	\
 		BLM_RX_NO_SWAP		|	\
 		BLM_TX_NO_SWAP		|	\
@@ -283,88 +252,87 @@
 #endif
 
 /* These macros describe Ethernet Port serial control reg (PSCR) bits */
-#define SERIAL_PORT_DISABLE			0
-#define SERIAL_PORT_ENABLE			(1<<0)
-#define FORCE_LINK_PASS			(1<<1)
-#define DO_NOT_FORCE_LINK_PASS		0
-#define ENABLE_AUTO_NEG_FOR_DUPLX		0
-#define DISABLE_AUTO_NEG_FOR_DUPLX		(1<<2)
-#define ENABLE_AUTO_NEG_FOR_FLOW_CTRL	0
-#define DISABLE_AUTO_NEG_FOR_FLOW_CTRL	(1<<3)
-#define ADV_NO_FLOW_CTRL			0
-#define ADV_SYMMETRIC_FLOW_CTRL		(1<<4)
-#define FORCE_FC_MODE_NO_PAUSE_DIS_TX	0
-#define FORCE_FC_MODE_TX_PAUSE_DIS		(1<<5)
-#define FORCE_BP_MODE_NO_JAM		0
-#define FORCE_BP_MODE_JAM_TX		(1<<7)
-#define FORCE_BP_MODE_JAM_TX_ON_RX_ERR	(1<<8)
-#define SERIAL_PORT_CONTROL_RESERVED	(1<<9)
-#define FORCE_LINK_FAIL			0
-#define DO_NOT_FORCE_LINK_FAIL		(1<<10)
-#define RETRANSMIT_16_ATTEMPTS		0
-#define RETRANSMIT_FOREVER			(1<<11)
-#define DISABLE_AUTO_NEG_SPEED_GMII		(1<<13)
-#define ENABLE_AUTO_NEG_SPEED_GMII		0
-#define DTE_ADV_0				0
-#define DTE_ADV_1				(1<<14)
-#define DISABLE_AUTO_NEG_BYPASS		0
-#define ENABLE_AUTO_NEG_BYPASS		(1<<15)
-#define AUTO_NEG_NO_CHANGE			0
-#define RESTART_AUTO_NEG			(1<<16)
-#define MAX_RX_PACKET_1518BYTE		0
-#define MAX_RX_PACKET_1522BYTE		(1<<17)
-#define MAX_RX_PACKET_1552BYTE		(1<<18)
-#define MAX_RX_PACKET_9022BYTE		((1<<18) | (1<<17))
-#define MAX_RX_PACKET_9192BYTE		(1<<19)
-#define MAX_RX_PACKET_9700BYTE		((1<<19) | (1<<17))
-#define SET_EXT_LOOPBACK			(1<<20)
-#define CLR_EXT_LOOPBACK			0
-#define SET_FULL_DUPLEX_MODE		(1<<21)
-#define SET_HALF_DUPLEX_MODE		0
-#define ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX (1<<22)
-#define DISABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX 0
-#define SET_GMII_SPEED_TO_10_100		0
-#define SET_GMII_SPEED_TO_1000		(1<<23)
-#define SET_MII_SPEED_TO_10			0
-#define SET_MII_SPEED_TO_100		(1<<24)
-
-#define MAX_RX_PACKET_MASK			(0x7<<17)
+#define SERIAL_PORT_DISABLE			(0 << 0)
+#define SERIAL_PORT_ENABLE			(1 << 0)
+#define DO_NOT_FORCE_LINK_PASS			(0 << 1)
+#define FORCE_LINK_PASS				(1 << 1)
+#define ENABLE_AUTO_NEG_FOR_DUPLX		(0 << 2)
+#define DISABLE_AUTO_NEG_FOR_DUPLX		(1 << 2)
+#define ENABLE_AUTO_NEG_FOR_FLOW_CTRL		(0 << 3)
+#define DISABLE_AUTO_NEG_FOR_FLOW_CTRL		(1 << 3)
+#define ADV_NO_FLOW_CTRL			(0 << 4)
+#define ADV_SYMMETRIC_FLOW_CTRL			(1 << 4)
+#define FORCE_FC_MODE_NO_PAUSE_DIS_TX		(0 << 5)
+#define FORCE_FC_MODE_TX_PAUSE_DIS		(1 << 5)
+#define FORCE_BP_MODE_NO_JAM			(0 << 7)
+#define FORCE_BP_MODE_JAM_TX			(1 << 7)
+#define FORCE_BP_MODE_JAM_TX_ON_RX_ERR		(2 << 7)
+#define SERIAL_PORT_CONTROL_RESERVED		(1 << 9)
+#define FORCE_LINK_FAIL				(0 << 10)
+#define DO_NOT_FORCE_LINK_FAIL			(1 << 10)
+#define RETRANSMIT_16_ATTEMPTS			(0 << 11)
+#define RETRANSMIT_FOREVER			(1 << 11)
+#define ENABLE_AUTO_NEG_SPEED_GMII		(0 << 13)
+#define DISABLE_AUTO_NEG_SPEED_GMII		(1 << 13)
+#define DTE_ADV_0				(0 << 14)
+#define DTE_ADV_1				(1 << 14)
+#define DISABLE_AUTO_NEG_BYPASS			(0 << 15)
+#define ENABLE_AUTO_NEG_BYPASS			(1 << 15)
+#define AUTO_NEG_NO_CHANGE			(0 << 16)
+#define RESTART_AUTO_NEG			(1 << 16)
+#define MAX_RX_PACKET_1518BYTE			(0 << 17)
+#define MAX_RX_PACKET_1522BYTE			(1 << 17)
+#define MAX_RX_PACKET_1552BYTE			(2 << 17)
+#define MAX_RX_PACKET_9022BYTE			(3 << 17)
+#define MAX_RX_PACKET_9192BYTE			(4 << 17)
+#define MAX_RX_PACKET_9700BYTE			(5 << 17)
+#define MAX_RX_PACKET_MASK			(7 << 17)
+#define CLR_EXT_LOOPBACK			(0 << 20)
+#define SET_EXT_LOOPBACK			(1 << 20)
+#define SET_HALF_DUPLEX_MODE			(0 << 21)
+#define SET_FULL_DUPLEX_MODE			(1 << 21)
+#define DISABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX	(0 << 22)
+#define ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX	(1 << 22)
+#define SET_GMII_SPEED_TO_10_100		(0 << 23)
+#define SET_GMII_SPEED_TO_1000			(1 << 23)
+#define SET_MII_SPEED_TO_10			(0 << 24)
+#define SET_MII_SPEED_TO_100			(1 << 24)
 
-#define	PORT_SERIAL_CONTROL_DEFAULT_VALUE		\
-		DO_NOT_FORCE_LINK_PASS	|	\
+#define PORT_SERIAL_CONTROL_DEFAULT_VALUE		\
+		DO_NOT_FORCE_LINK_PASS		|	\
 		ENABLE_AUTO_NEG_FOR_DUPLX	|	\
-		DISABLE_AUTO_NEG_FOR_FLOW_CTRL |	\
-		ADV_SYMMETRIC_FLOW_CTRL	|	\
-		FORCE_FC_MODE_NO_PAUSE_DIS_TX |	\
-		FORCE_BP_MODE_NO_JAM	|	\
-		(1<<9)	/* reserved */			|	\
-		DO_NOT_FORCE_LINK_FAIL	|	\
-		RETRANSMIT_16_ATTEMPTS	|	\
+		DISABLE_AUTO_NEG_FOR_FLOW_CTRL	|	\
+		ADV_SYMMETRIC_FLOW_CTRL		|	\
+		FORCE_FC_MODE_NO_PAUSE_DIS_TX	|	\
+		FORCE_BP_MODE_NO_JAM		|	\
+		(1 << 9) /* reserved */		|	\
+		DO_NOT_FORCE_LINK_FAIL		|	\
+		RETRANSMIT_16_ATTEMPTS		|	\
 		ENABLE_AUTO_NEG_SPEED_GMII	|	\
 		DTE_ADV_0			|	\
-		DISABLE_AUTO_NEG_BYPASS	|	\
+		DISABLE_AUTO_NEG_BYPASS		|	\
 		AUTO_NEG_NO_CHANGE		|	\
-		MAX_RX_PACKET_9700BYTE	|	\
+		MAX_RX_PACKET_9700BYTE		|	\
 		CLR_EXT_LOOPBACK		|	\
-		SET_FULL_DUPLEX_MODE	|	\
+		SET_FULL_DUPLEX_MODE		|	\
 		ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX
 
 /* These macros describe Ethernet Serial Status reg (PSR) bits */
-#define PORT_STATUS_MODE_10_BIT		(1<<0)
-#define PORT_STATUS_LINK_UP			(1<<1)
-#define PORT_STATUS_FULL_DUPLEX		(1<<2)
-#define PORT_STATUS_FLOW_CONTROL		(1<<3)
-#define PORT_STATUS_GMII_1000		(1<<4)
-#define PORT_STATUS_MII_100			(1<<5)
+#define PORT_STATUS_MODE_10_BIT		(1 << 0)
+#define PORT_STATUS_LINK_UP		(1 << 1)
+#define PORT_STATUS_FULL_DUPLEX		(1 << 2)
+#define PORT_STATUS_FLOW_CONTROL	(1 << 3)
+#define PORT_STATUS_GMII_1000		(1 << 4)
+#define PORT_STATUS_MII_100		(1 << 5)
 /* PSR bit 6 is undocumented */
-#define PORT_STATUS_TX_IN_PROGRESS		(1<<7)
-#define PORT_STATUS_AUTONEG_BYPASSED	(1<<8)
-#define PORT_STATUS_PARTITION		(1<<9)
-#define PORT_STATUS_TX_FIFO_EMPTY		(1<<10)
+#define PORT_STATUS_TX_IN_PROGRESS	(1 << 7)
+#define PORT_STATUS_AUTONEG_BYPASSED	(1 << 8)
+#define PORT_STATUS_PARTITION		(1 << 9)
+#define PORT_STATUS_TX_FIFO_EMPTY	(1 << 10)
 /* PSR bits 11-31 are reserved */
 
-#define	PORT_DEFAULT_TRANSMIT_QUEUE_SIZE	800
-#define	PORT_DEFAULT_RECEIVE_QUEUE_SIZE	400
+#define PORT_DEFAULT_TRANSMIT_QUEUE_SIZE	800
+#define PORT_DEFAULT_RECEIVE_QUEUE_SIZE		400
 
 #define DESC_SIZE				64
 
@@ -446,7 +414,7 @@
 #define ETH_SMI_BUSY		0x10000000	/* 0 - Write, 1 - Read	*/
 #define ETH_SMI_READ_VALID	0x08000000	/* 0 - Write, 1 - Read	*/
 #define ETH_SMI_OPCODE_WRITE	0		/* Completion of Read	*/
-#define ETH_SMI_OPCODE_READ 	0x04000000	/* Operation is in progress */
+#define ETH_SMI_OPCODE_READ	0x04000000	/* Operation is in progress */
 
 /* Interrupt Cause Register Bit Definitions */
 
@@ -537,7 +505,6 @@ struct eth_tx_desc {
 	u32 next_desc_ptr;	/* Pointer to next descriptor		*/
 	u32 buf_ptr;		/* pointer to buffer for this descriptor*/
 };
-
 #elif defined(__LITTLE_ENDIAN)
 struct eth_rx_desc {
 	u32 cmd_sts;		/* Descriptor command status		*/
@@ -569,7 +536,6 @@ struct pkt_info {
 };
 
 /* Ethernet port specific information */
-
 struct mv643xx_mib_counters {
 	u64 good_octets_received;
 	u32 bad_octets_received;
@@ -684,4 +650,5 @@ static ETH_FUNC_RET_STATUS eth_port_rece
 static ETH_FUNC_RET_STATUS eth_rx_return_buff(struct mv643xx_private *mp,
 					      struct pkt_info *p_pkt_info);
 
-#endif				/* __MV643XX_ETH_H__ */
+
+#endif
