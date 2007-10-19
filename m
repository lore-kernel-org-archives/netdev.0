From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 2/8] [MV643XX_ETH] Move ethernet register definitions into private header
Date: Fri, 19 Oct 2007 04:10:10 +0200
Message-ID: <20071019021010.GD16037@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Manas Saksena <msaksena@marvell.com>, netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:43989 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761799AbXJSCKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 22:10:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the mv643xx's ethernet-related register definitions from
include/linux/mv643xx.h into drivers/net/mv643xx_eth.h, since
they aren't of any use outside the ethernet driver.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Acked-by: Tzachi Perelstein <tzachi@marvell.com>

Index: linux-2.6/drivers/net/mv643xx_eth.h
===================================================================
--- linux-2.6.orig/drivers/net/mv643xx_eth.h
+++ linux-2.6/drivers/net/mv643xx_eth.h
@@ -7,7 +7,7 @@
 #include <linux/workqueue.h>
 #include <linux/mii.h>
 
-#include <linux/mv643xx.h>
+#include <linux/mv643xx_eth.h>
 
 #include <asm/dma-mapping.h>
 
@@ -51,6 +51,312 @@
 					ETH_VLAN_HLEN + ETH_FCS_LEN)
 #define ETH_RX_SKB_SIZE		(dev->mtu + ETH_WRAPPER_LEN + dma_get_cache_alignment())
 
+/****************************************/
+/*        Ethernet Unit Registers  		*/
+/****************************************/
+
+#define MV643XX_ETH_PHY_ADDR_REG                                    0x2000
+#define MV643XX_ETH_SMI_REG                                         0x2004
+#define MV643XX_ETH_UNIT_DEFAULT_ADDR_REG                           0x2008
+#define MV643XX_ETH_UNIT_DEFAULTID_REG                              0x200c
+#define MV643XX_ETH_UNIT_INTERRUPT_CAUSE_REG                        0x2080
+#define MV643XX_ETH_UNIT_INTERRUPT_MASK_REG                         0x2084
+#define MV643XX_ETH_UNIT_INTERNAL_USE_REG                           0x24fc
+#define MV643XX_ETH_UNIT_ERROR_ADDR_REG                             0x2094
+#define MV643XX_ETH_BAR_0                                           0x2200
+#define MV643XX_ETH_BAR_1                                           0x2208
+#define MV643XX_ETH_BAR_2                                           0x2210
+#define MV643XX_ETH_BAR_3                                           0x2218
+#define MV643XX_ETH_BAR_4                                           0x2220
+#define MV643XX_ETH_BAR_5                                           0x2228
+#define MV643XX_ETH_SIZE_REG_0                                      0x2204
+#define MV643XX_ETH_SIZE_REG_1                                      0x220c
+#define MV643XX_ETH_SIZE_REG_2                                      0x2214
+#define MV643XX_ETH_SIZE_REG_3                                      0x221c
+#define MV643XX_ETH_SIZE_REG_4                                      0x2224
+#define MV643XX_ETH_SIZE_REG_5                                      0x222c
+#define MV643XX_ETH_HEADERS_RETARGET_BASE_REG                       0x2230
+#define MV643XX_ETH_HEADERS_RETARGET_CONTROL_REG                    0x2234
+#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_0                           0x2280
+#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_1                           0x2284
+#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_2                           0x2288
+#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_3                           0x228c
+#define MV643XX_ETH_BASE_ADDR_ENABLE_REG                            0x2290
+#define MV643XX_ETH_ACCESS_PROTECTION_REG(port)                    (0x2294 + (port<<2))
+#define MV643XX_ETH_MIB_COUNTERS_BASE(port)                        (0x3000 + (port<<7))
+#define MV643XX_ETH_PORT_CONFIG_REG(port)                          (0x2400 + (port<<10))
+#define MV643XX_ETH_PORT_CONFIG_EXTEND_REG(port)                   (0x2404 + (port<<10))
+#define MV643XX_ETH_MII_SERIAL_PARAMETRS_REG(port)                 (0x2408 + (port<<10))
+#define MV643XX_ETH_GMII_SERIAL_PARAMETRS_REG(port)                (0x240c + (port<<10))
+#define MV643XX_ETH_VLAN_ETHERTYPE_REG(port)                       (0x2410 + (port<<10))
+#define MV643XX_ETH_MAC_ADDR_LOW(port)                             (0x2414 + (port<<10))
+#define MV643XX_ETH_MAC_ADDR_HIGH(port)                            (0x2418 + (port<<10))
+#define MV643XX_ETH_SDMA_CONFIG_REG(port)                          (0x241c + (port<<10))
+#define MV643XX_ETH_DSCP_0(port)                                   (0x2420 + (port<<10))
+#define MV643XX_ETH_DSCP_1(port)                                   (0x2424 + (port<<10))
+#define MV643XX_ETH_DSCP_2(port)                                   (0x2428 + (port<<10))
+#define MV643XX_ETH_DSCP_3(port)                                   (0x242c + (port<<10))
+#define MV643XX_ETH_DSCP_4(port)                                   (0x2430 + (port<<10))
+#define MV643XX_ETH_DSCP_5(port)                                   (0x2434 + (port<<10))
+#define MV643XX_ETH_DSCP_6(port)                                   (0x2438 + (port<<10))
+#define MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port)                  (0x243c + (port<<10))
+#define MV643XX_ETH_VLAN_PRIORITY_TAG_TO_PRIORITY(port)            (0x2440 + (port<<10))
+#define MV643XX_ETH_PORT_STATUS_REG(port)                          (0x2444 + (port<<10))
+#define MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port)               (0x2448 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_FIXED_PRIORITY(port)                  (0x244c + (port<<10))
+#define MV643XX_ETH_PORT_TX_TOKEN_BUCKET_RATE_CONFIG(port)         (0x2450 + (port<<10))
+#define MV643XX_ETH_MAXIMUM_TRANSMIT_UNIT(port)                    (0x2458 + (port<<10))
+#define MV643XX_ETH_PORT_MAXIMUM_TOKEN_BUCKET_SIZE(port)           (0x245c + (port<<10))
+#define MV643XX_ETH_INTERRUPT_CAUSE_REG(port)                      (0x2460 + (port<<10))
+#define MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port)               (0x2464 + (port<<10))
+#define MV643XX_ETH_INTERRUPT_MASK_REG(port)                       (0x2468 + (port<<10))
+#define MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port)                (0x246c + (port<<10))
+#define MV643XX_ETH_RX_FIFO_URGENT_THRESHOLD_REG(port)             (0x2470 + (port<<10))
+#define MV643XX_ETH_TX_FIFO_URGENT_THRESHOLD_REG(port)             (0x2474 + (port<<10))
+#define MV643XX_ETH_RX_MINIMAL_FRAME_SIZE_REG(port)                (0x247c + (port<<10))
+#define MV643XX_ETH_RX_DISCARDED_FRAMES_COUNTER(port)              (0x2484 + (port<<10))
+#define MV643XX_ETH_PORT_DEBUG_0_REG(port)                         (0x248c + (port<<10))
+#define MV643XX_ETH_PORT_DEBUG_1_REG(port)                         (0x2490 + (port<<10))
+#define MV643XX_ETH_PORT_INTERNAL_ADDR_ERROR_REG(port)             (0x2494 + (port<<10))
+#define MV643XX_ETH_INTERNAL_USE_REG(port)                         (0x24fc + (port<<10))
+#define MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port)                (0x2680 + (port<<10))
+#define MV643XX_ETH_CURRENT_SERVED_TX_DESC_PTR(port)               (0x2684 + (port<<10))
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port)              (0x260c + (port<<10))     
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_1(port)              (0x261c + (port<<10))     
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_2(port)              (0x262c + (port<<10))     
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_3(port)              (0x263c + (port<<10))     
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_4(port)              (0x264c + (port<<10))     
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_5(port)              (0x265c + (port<<10))     
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_6(port)              (0x266c + (port<<10))     
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_7(port)              (0x267c + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_0(port)              (0x26c0 + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_1(port)              (0x26c4 + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_2(port)              (0x26c8 + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_3(port)              (0x26cc + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_4(port)              (0x26d0 + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_5(port)              (0x26d4 + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_6(port)              (0x26d8 + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_7(port)              (0x26dc + (port<<10))     
+#define MV643XX_ETH_TX_QUEUE_0_TOKEN_BUCKET_COUNT(port)            (0x2700 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_1_TOKEN_BUCKET_COUNT(port)            (0x2710 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_2_TOKEN_BUCKET_COUNT(port)            (0x2720 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_3_TOKEN_BUCKET_COUNT(port)            (0x2730 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_4_TOKEN_BUCKET_COUNT(port)            (0x2740 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_5_TOKEN_BUCKET_COUNT(port)            (0x2750 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_6_TOKEN_BUCKET_COUNT(port)            (0x2760 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_7_TOKEN_BUCKET_COUNT(port)            (0x2770 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_0_TOKEN_BUCKET_CONFIG(port)           (0x2704 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_1_TOKEN_BUCKET_CONFIG(port)           (0x2714 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_2_TOKEN_BUCKET_CONFIG(port)           (0x2724 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_3_TOKEN_BUCKET_CONFIG(port)           (0x2734 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_4_TOKEN_BUCKET_CONFIG(port)           (0x2744 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_5_TOKEN_BUCKET_CONFIG(port)           (0x2754 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_6_TOKEN_BUCKET_CONFIG(port)           (0x2764 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_7_TOKEN_BUCKET_CONFIG(port)           (0x2774 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_0_ARBITER_CONFIG(port)                (0x2708 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_1_ARBITER_CONFIG(port)                (0x2718 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_2_ARBITER_CONFIG(port)                (0x2728 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_3_ARBITER_CONFIG(port)                (0x2738 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_4_ARBITER_CONFIG(port)                (0x2748 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_5_ARBITER_CONFIG(port)                (0x2758 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_6_ARBITER_CONFIG(port)                (0x2768 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_7_ARBITER_CONFIG(port)                (0x2778 + (port<<10))
+#define MV643XX_ETH_PORT_TX_TOKEN_BUCKET_COUNT(port)               (0x2780 + (port<<10))
+#define MV643XX_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port)   (0x3400 + (port<<10))
+#define MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port)     (0x3500 + (port<<10))
+#define MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE(port)             (0x3600 + (port<<10))
+
+/* These macros describe Ethernet Port configuration reg (Px_cR) bits */
+#define MV643XX_ETH_UNICAST_NORMAL_MODE		0
+#define MV643XX_ETH_UNICAST_PROMISCUOUS_MODE	(1<<0)
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_0		0
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_1		(1<<1)
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_2		(1<<2)
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_3		((1<<2) | (1<<1))
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_4		(1<<3)
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_5		((1<<3) | (1<<1))
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_6		((1<<3) | (1<<2))
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_7		((1<<3) | (1<<2) | (1<<1))
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_0	0
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_1	(1<<4)
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_2	(1<<5)
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_3	((1<<5) | (1<<4))
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_4	(1<<6)
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_5	((1<<6) | (1<<4))
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_6	((1<<6) | (1<<5))
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_7	((1<<6) | (1<<5) | (1<<4))
+#define MV643XX_ETH_RECEIVE_BC_IF_NOT_IP_OR_ARP	0
+#define MV643XX_ETH_REJECT_BC_IF_NOT_IP_OR_ARP	(1<<7)
+#define MV643XX_ETH_RECEIVE_BC_IF_IP		0
+#define MV643XX_ETH_REJECT_BC_IF_IP		(1<<8)
+#define MV643XX_ETH_RECEIVE_BC_IF_ARP		0
+#define MV643XX_ETH_REJECT_BC_IF_ARP		(1<<9)
+#define MV643XX_ETH_TX_AM_NO_UPDATE_ERROR_SUMMARY (1<<12)
+#define MV643XX_ETH_CAPTURE_TCP_FRAMES_DIS	0
+#define MV643XX_ETH_CAPTURE_TCP_FRAMES_EN	(1<<14)
+#define MV643XX_ETH_CAPTURE_UDP_FRAMES_DIS	0
+#define MV643XX_ETH_CAPTURE_UDP_FRAMES_EN	(1<<15)
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_0	0
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_1	(1<<16)
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_2	(1<<17)
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_3	((1<<17) | (1<<16))
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_4	(1<<18)
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_5	((1<<18) | (1<<16))
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_6	((1<<18) | (1<<17))
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_7	((1<<18) | (1<<17) | (1<<16))
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_0	0
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_1	(1<<19)
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_2	(1<<20)
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_3	((1<<20) | (1<<19))
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_4	(1<<21)
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_5	((1<<21) | (1<<19))
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_6	((1<<21) | (1<<20))
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_7	((1<<21) | (1<<20) | (1<<19))
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_0	0
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_1	(1<<22)
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_2	(1<<23)
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_3	((1<<23) | (1<<22))
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_4	(1<<24)
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_5	((1<<24) | (1<<22))
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_6	((1<<24) | (1<<23))
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_7	((1<<24) | (1<<23) | (1<<22))
+
+#define	MV643XX_ETH_PORT_CONFIG_DEFAULT_VALUE			\
+		MV643XX_ETH_UNICAST_NORMAL_MODE		|	\
+		MV643XX_ETH_DEFAULT_RX_QUEUE_0		|	\
+		MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_0	|	\
+		MV643XX_ETH_RECEIVE_BC_IF_NOT_IP_OR_ARP	|	\
+		MV643XX_ETH_RECEIVE_BC_IF_IP		|	\
+		MV643XX_ETH_RECEIVE_BC_IF_ARP		|	\
+		MV643XX_ETH_CAPTURE_TCP_FRAMES_DIS	|	\
+		MV643XX_ETH_CAPTURE_UDP_FRAMES_DIS	|	\
+		MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_0	|	\
+		MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_0	|	\
+		MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_0
+
+/* These macros describe Ethernet Port configuration extend reg (Px_cXR) bits*/
+#define MV643XX_ETH_CLASSIFY_EN				(1<<0)
+#define MV643XX_ETH_SPAN_BPDU_PACKETS_AS_NORMAL		0
+#define MV643XX_ETH_SPAN_BPDU_PACKETS_TO_RX_QUEUE_7	(1<<1)
+#define MV643XX_ETH_PARTITION_DISABLE			0
+#define MV643XX_ETH_PARTITION_ENABLE			(1<<2)
+
+#define	MV643XX_ETH_PORT_CONFIG_EXTEND_DEFAULT_VALUE		\
+		MV643XX_ETH_SPAN_BPDU_PACKETS_AS_NORMAL	|	\
+		MV643XX_ETH_PARTITION_DISABLE
+
+/* These macros describe Ethernet Port Sdma configuration reg (SDCR) bits */
+#define MV643XX_ETH_RIFB			(1<<0)
+#define MV643XX_ETH_RX_BURST_SIZE_1_64BIT		0
+#define MV643XX_ETH_RX_BURST_SIZE_2_64BIT		(1<<1)
+#define MV643XX_ETH_RX_BURST_SIZE_4_64BIT		(1<<2)
+#define MV643XX_ETH_RX_BURST_SIZE_8_64BIT		((1<<2) | (1<<1))
+#define MV643XX_ETH_RX_BURST_SIZE_16_64BIT		(1<<3)
+#define MV643XX_ETH_BLM_RX_NO_SWAP			(1<<4)
+#define MV643XX_ETH_BLM_RX_BYTE_SWAP			0
+#define MV643XX_ETH_BLM_TX_NO_SWAP			(1<<5)
+#define MV643XX_ETH_BLM_TX_BYTE_SWAP			0
+#define MV643XX_ETH_DESCRIPTORS_BYTE_SWAP		(1<<6)
+#define MV643XX_ETH_DESCRIPTORS_NO_SWAP			0
+#define MV643XX_ETH_TX_BURST_SIZE_1_64BIT		0
+#define MV643XX_ETH_TX_BURST_SIZE_2_64BIT		(1<<22)
+#define MV643XX_ETH_TX_BURST_SIZE_4_64BIT		(1<<23)
+#define MV643XX_ETH_TX_BURST_SIZE_8_64BIT		((1<<23) | (1<<22))
+#define MV643XX_ETH_TX_BURST_SIZE_16_64BIT		(1<<24)
+
+#define	MV643XX_ETH_IPG_INT_RX(value) ((value & 0x3fff) << 8)
+
+#define	MV643XX_ETH_PORT_SDMA_CONFIG_DEFAULT_VALUE		\
+		MV643XX_ETH_RX_BURST_SIZE_4_64BIT	|	\
+		MV643XX_ETH_IPG_INT_RX(0)		|	\
+		MV643XX_ETH_TX_BURST_SIZE_4_64BIT
+
+/* These macros describe Ethernet Port serial control reg (PSCR) bits */
+#define MV643XX_ETH_SERIAL_PORT_DISABLE			0
+#define MV643XX_ETH_SERIAL_PORT_ENABLE			(1<<0)
+#define MV643XX_ETH_FORCE_LINK_PASS			(1<<1)
+#define MV643XX_ETH_DO_NOT_FORCE_LINK_PASS		0
+#define MV643XX_ETH_ENABLE_AUTO_NEG_FOR_DUPLX		0
+#define MV643XX_ETH_DISABLE_AUTO_NEG_FOR_DUPLX		(1<<2)
+#define MV643XX_ETH_ENABLE_AUTO_NEG_FOR_FLOW_CTRL	0
+#define MV643XX_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL	(1<<3)
+#define MV643XX_ETH_ADV_NO_FLOW_CTRL			0
+#define MV643XX_ETH_ADV_SYMMETRIC_FLOW_CTRL		(1<<4)
+#define MV643XX_ETH_FORCE_FC_MODE_NO_PAUSE_DIS_TX	0
+#define MV643XX_ETH_FORCE_FC_MODE_TX_PAUSE_DIS		(1<<5)
+#define MV643XX_ETH_FORCE_BP_MODE_NO_JAM		0
+#define MV643XX_ETH_FORCE_BP_MODE_JAM_TX		(1<<7)
+#define MV643XX_ETH_FORCE_BP_MODE_JAM_TX_ON_RX_ERR	(1<<8)
+#define MV643XX_ETH_SERIAL_PORT_CONTROL_RESERVED	(1<<9)
+#define MV643XX_ETH_FORCE_LINK_FAIL			0
+#define MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL		(1<<10)
+#define MV643XX_ETH_RETRANSMIT_16_ATTEMPTS		0
+#define MV643XX_ETH_RETRANSMIT_FOREVER			(1<<11)
+#define MV643XX_ETH_DISABLE_AUTO_NEG_SPEED_GMII		(1<<13)
+#define MV643XX_ETH_ENABLE_AUTO_NEG_SPEED_GMII		0
+#define MV643XX_ETH_DTE_ADV_0				0
+#define MV643XX_ETH_DTE_ADV_1				(1<<14)
+#define MV643XX_ETH_DISABLE_AUTO_NEG_BYPASS		0
+#define MV643XX_ETH_ENABLE_AUTO_NEG_BYPASS		(1<<15)
+#define MV643XX_ETH_AUTO_NEG_NO_CHANGE			0
+#define MV643XX_ETH_RESTART_AUTO_NEG			(1<<16)
+#define MV643XX_ETH_MAX_RX_PACKET_1518BYTE		0
+#define MV643XX_ETH_MAX_RX_PACKET_1522BYTE		(1<<17)
+#define MV643XX_ETH_MAX_RX_PACKET_1552BYTE		(1<<18)
+#define MV643XX_ETH_MAX_RX_PACKET_9022BYTE		((1<<18) | (1<<17))
+#define MV643XX_ETH_MAX_RX_PACKET_9192BYTE		(1<<19)
+#define MV643XX_ETH_MAX_RX_PACKET_9700BYTE		((1<<19) | (1<<17))
+#define MV643XX_ETH_SET_EXT_LOOPBACK			(1<<20)
+#define MV643XX_ETH_CLR_EXT_LOOPBACK			0
+#define MV643XX_ETH_SET_FULL_DUPLEX_MODE		(1<<21)
+#define MV643XX_ETH_SET_HALF_DUPLEX_MODE		0
+#define MV643XX_ETH_ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX (1<<22)
+#define MV643XX_ETH_DISABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX 0
+#define MV643XX_ETH_SET_GMII_SPEED_TO_10_100		0
+#define MV643XX_ETH_SET_GMII_SPEED_TO_1000		(1<<23)
+#define MV643XX_ETH_SET_MII_SPEED_TO_10			0
+#define MV643XX_ETH_SET_MII_SPEED_TO_100		(1<<24)
+
+#define MV643XX_ETH_MAX_RX_PACKET_MASK			(0x7<<17)
+
+#define	MV643XX_ETH_PORT_SERIAL_CONTROL_DEFAULT_VALUE		\
+		MV643XX_ETH_DO_NOT_FORCE_LINK_PASS	|	\
+		MV643XX_ETH_ENABLE_AUTO_NEG_FOR_DUPLX	|	\
+		MV643XX_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL |	\
+		MV643XX_ETH_ADV_SYMMETRIC_FLOW_CTRL	|	\
+		MV643XX_ETH_FORCE_FC_MODE_NO_PAUSE_DIS_TX |	\
+		MV643XX_ETH_FORCE_BP_MODE_NO_JAM	|	\
+		(1<<9)	/* reserved */			|	\
+		MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL	|	\
+		MV643XX_ETH_RETRANSMIT_16_ATTEMPTS	|	\
+		MV643XX_ETH_ENABLE_AUTO_NEG_SPEED_GMII	|	\
+		MV643XX_ETH_DTE_ADV_0			|	\
+		MV643XX_ETH_DISABLE_AUTO_NEG_BYPASS	|	\
+		MV643XX_ETH_AUTO_NEG_NO_CHANGE		|	\
+		MV643XX_ETH_MAX_RX_PACKET_9700BYTE	|	\
+		MV643XX_ETH_CLR_EXT_LOOPBACK		|	\
+		MV643XX_ETH_SET_FULL_DUPLEX_MODE	|	\
+		MV643XX_ETH_ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX
+
+/* These macros describe Ethernet Serial Status reg (PSR) bits */
+#define MV643XX_ETH_PORT_STATUS_MODE_10_BIT		(1<<0)
+#define MV643XX_ETH_PORT_STATUS_LINK_UP			(1<<1)
+#define MV643XX_ETH_PORT_STATUS_FULL_DUPLEX		(1<<2)
+#define MV643XX_ETH_PORT_STATUS_FLOW_CONTROL		(1<<3)
+#define MV643XX_ETH_PORT_STATUS_GMII_1000		(1<<4)
+#define MV643XX_ETH_PORT_STATUS_MII_100			(1<<5)
+/* PSR bit 6 is undocumented */
+#define MV643XX_ETH_PORT_STATUS_TX_IN_PROGRESS		(1<<7)
+#define MV643XX_ETH_PORT_STATUS_AUTONEG_BYPASSED	(1<<8)
+#define MV643XX_ETH_PORT_STATUS_PARTITION		(1<<9)
+#define MV643XX_ETH_PORT_STATUS_TX_FIFO_EMPTY		(1<<10)
+/* PSR bits 11-31 are reserved */
+
+#define	MV643XX_ETH_PORT_DEFAULT_TRANSMIT_QUEUE_SIZE	800
+#define	MV643XX_ETH_PORT_DEFAULT_RECEIVE_QUEUE_SIZE	400
+
+#define MV643XX_ETH_DESC_SIZE				64
+
 #define ETH_RX_QUEUES_ENABLED	(1 << 0)	/* use only Q0 for receive */
 #define ETH_TX_QUEUES_ENABLED	(1 << 0)	/* use only Q0 for transmit */
 
Index: linux-2.6/include/linux/mv643xx.h
===================================================================
--- linux-2.6.orig/include/linux/mv643xx.h
+++ linux-2.6/include/linux/mv643xx.h
@@ -659,117 +659,6 @@
 /*        Ethernet Unit Registers  		*/
 /****************************************/
 
-#define MV643XX_ETH_PHY_ADDR_REG                                    0x2000
-#define MV643XX_ETH_SMI_REG                                         0x2004
-#define MV643XX_ETH_UNIT_DEFAULT_ADDR_REG                           0x2008
-#define MV643XX_ETH_UNIT_DEFAULTID_REG                              0x200c
-#define MV643XX_ETH_UNIT_INTERRUPT_CAUSE_REG                        0x2080
-#define MV643XX_ETH_UNIT_INTERRUPT_MASK_REG                         0x2084
-#define MV643XX_ETH_UNIT_INTERNAL_USE_REG                           0x24fc
-#define MV643XX_ETH_UNIT_ERROR_ADDR_REG                             0x2094
-#define MV643XX_ETH_BAR_0                                           0x2200
-#define MV643XX_ETH_BAR_1                                           0x2208
-#define MV643XX_ETH_BAR_2                                           0x2210
-#define MV643XX_ETH_BAR_3                                           0x2218
-#define MV643XX_ETH_BAR_4                                           0x2220
-#define MV643XX_ETH_BAR_5                                           0x2228
-#define MV643XX_ETH_SIZE_REG_0                                      0x2204
-#define MV643XX_ETH_SIZE_REG_1                                      0x220c
-#define MV643XX_ETH_SIZE_REG_2                                      0x2214
-#define MV643XX_ETH_SIZE_REG_3                                      0x221c
-#define MV643XX_ETH_SIZE_REG_4                                      0x2224
-#define MV643XX_ETH_SIZE_REG_5                                      0x222c
-#define MV643XX_ETH_HEADERS_RETARGET_BASE_REG                       0x2230
-#define MV643XX_ETH_HEADERS_RETARGET_CONTROL_REG                    0x2234
-#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_0                           0x2280
-#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_1                           0x2284
-#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_2                           0x2288
-#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_3                           0x228c
-#define MV643XX_ETH_BASE_ADDR_ENABLE_REG                            0x2290
-#define MV643XX_ETH_ACCESS_PROTECTION_REG(port)                    (0x2294 + (port<<2))
-#define MV643XX_ETH_MIB_COUNTERS_BASE(port)                        (0x3000 + (port<<7))
-#define MV643XX_ETH_PORT_CONFIG_REG(port)                          (0x2400 + (port<<10))
-#define MV643XX_ETH_PORT_CONFIG_EXTEND_REG(port)                   (0x2404 + (port<<10))
-#define MV643XX_ETH_MII_SERIAL_PARAMETRS_REG(port)                 (0x2408 + (port<<10))
-#define MV643XX_ETH_GMII_SERIAL_PARAMETRS_REG(port)                (0x240c + (port<<10))
-#define MV643XX_ETH_VLAN_ETHERTYPE_REG(port)                       (0x2410 + (port<<10))
-#define MV643XX_ETH_MAC_ADDR_LOW(port)                             (0x2414 + (port<<10))
-#define MV643XX_ETH_MAC_ADDR_HIGH(port)                            (0x2418 + (port<<10))
-#define MV643XX_ETH_SDMA_CONFIG_REG(port)                          (0x241c + (port<<10))
-#define MV643XX_ETH_DSCP_0(port)                                   (0x2420 + (port<<10))
-#define MV643XX_ETH_DSCP_1(port)                                   (0x2424 + (port<<10))
-#define MV643XX_ETH_DSCP_2(port)                                   (0x2428 + (port<<10))
-#define MV643XX_ETH_DSCP_3(port)                                   (0x242c + (port<<10))
-#define MV643XX_ETH_DSCP_4(port)                                   (0x2430 + (port<<10))
-#define MV643XX_ETH_DSCP_5(port)                                   (0x2434 + (port<<10))
-#define MV643XX_ETH_DSCP_6(port)                                   (0x2438 + (port<<10))
-#define MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port)                  (0x243c + (port<<10))
-#define MV643XX_ETH_VLAN_PRIORITY_TAG_TO_PRIORITY(port)            (0x2440 + (port<<10))
-#define MV643XX_ETH_PORT_STATUS_REG(port)                          (0x2444 + (port<<10))
-#define MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port)               (0x2448 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_FIXED_PRIORITY(port)                  (0x244c + (port<<10))
-#define MV643XX_ETH_PORT_TX_TOKEN_BUCKET_RATE_CONFIG(port)         (0x2450 + (port<<10))
-#define MV643XX_ETH_MAXIMUM_TRANSMIT_UNIT(port)                    (0x2458 + (port<<10))
-#define MV643XX_ETH_PORT_MAXIMUM_TOKEN_BUCKET_SIZE(port)           (0x245c + (port<<10))
-#define MV643XX_ETH_INTERRUPT_CAUSE_REG(port)                      (0x2460 + (port<<10))
-#define MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port)               (0x2464 + (port<<10))
-#define MV643XX_ETH_INTERRUPT_MASK_REG(port)                       (0x2468 + (port<<10))
-#define MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port)                (0x246c + (port<<10))
-#define MV643XX_ETH_RX_FIFO_URGENT_THRESHOLD_REG(port)             (0x2470 + (port<<10))
-#define MV643XX_ETH_TX_FIFO_URGENT_THRESHOLD_REG(port)             (0x2474 + (port<<10))
-#define MV643XX_ETH_RX_MINIMAL_FRAME_SIZE_REG(port)                (0x247c + (port<<10))
-#define MV643XX_ETH_RX_DISCARDED_FRAMES_COUNTER(port)              (0x2484 + (port<<10))
-#define MV643XX_ETH_PORT_DEBUG_0_REG(port)                         (0x248c + (port<<10))
-#define MV643XX_ETH_PORT_DEBUG_1_REG(port)                         (0x2490 + (port<<10))
-#define MV643XX_ETH_PORT_INTERNAL_ADDR_ERROR_REG(port)             (0x2494 + (port<<10))
-#define MV643XX_ETH_INTERNAL_USE_REG(port)                         (0x24fc + (port<<10))
-#define MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port)                (0x2680 + (port<<10))
-#define MV643XX_ETH_CURRENT_SERVED_TX_DESC_PTR(port)               (0x2684 + (port<<10))      
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port)              (0x260c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_1(port)              (0x261c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_2(port)              (0x262c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_3(port)              (0x263c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_4(port)              (0x264c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_5(port)              (0x265c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_6(port)              (0x266c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_7(port)              (0x267c + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_0(port)              (0x26c0 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_1(port)              (0x26c4 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_2(port)              (0x26c8 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_3(port)              (0x26cc + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_4(port)              (0x26d0 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_5(port)              (0x26d4 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_6(port)              (0x26d8 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_7(port)              (0x26dc + (port<<10))     
-#define MV643XX_ETH_TX_QUEUE_0_TOKEN_BUCKET_COUNT(port)            (0x2700 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_1_TOKEN_BUCKET_COUNT(port)            (0x2710 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_2_TOKEN_BUCKET_COUNT(port)            (0x2720 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_3_TOKEN_BUCKET_COUNT(port)            (0x2730 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_4_TOKEN_BUCKET_COUNT(port)            (0x2740 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_5_TOKEN_BUCKET_COUNT(port)            (0x2750 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_6_TOKEN_BUCKET_COUNT(port)            (0x2760 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_7_TOKEN_BUCKET_COUNT(port)            (0x2770 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_0_TOKEN_BUCKET_CONFIG(port)           (0x2704 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_1_TOKEN_BUCKET_CONFIG(port)           (0x2714 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_2_TOKEN_BUCKET_CONFIG(port)           (0x2724 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_3_TOKEN_BUCKET_CONFIG(port)           (0x2734 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_4_TOKEN_BUCKET_CONFIG(port)           (0x2744 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_5_TOKEN_BUCKET_CONFIG(port)           (0x2754 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_6_TOKEN_BUCKET_CONFIG(port)           (0x2764 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_7_TOKEN_BUCKET_CONFIG(port)           (0x2774 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_0_ARBITER_CONFIG(port)                (0x2708 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_1_ARBITER_CONFIG(port)                (0x2718 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_2_ARBITER_CONFIG(port)                (0x2728 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_3_ARBITER_CONFIG(port)                (0x2738 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_4_ARBITER_CONFIG(port)                (0x2748 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_5_ARBITER_CONFIG(port)                (0x2758 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_6_ARBITER_CONFIG(port)                (0x2768 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_7_ARBITER_CONFIG(port)                (0x2778 + (port<<10))
-#define MV643XX_ETH_PORT_TX_TOKEN_BUCKET_COUNT(port)               (0x2780 + (port<<10))
-#define MV643XX_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port)   (0x3400 + (port<<10))
-#define MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port)     (0x3500 + (port<<10))
-#define MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE(port)             (0x3600 + (port<<10))
-
 /*******************************************/
 /*          CUNIT  Registers               */
 /*******************************************/
@@ -1087,197 +976,6 @@ struct mv64xxx_i2c_pdata {
 	u32	retries;
 };
 
-/* These macros describe Ethernet Port configuration reg (Px_cR) bits */
-#define MV643XX_ETH_UNICAST_NORMAL_MODE		0
-#define MV643XX_ETH_UNICAST_PROMISCUOUS_MODE	(1<<0)
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_0		0
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_1		(1<<1)
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_2		(1<<2)
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_3		((1<<2) | (1<<1))
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_4		(1<<3)
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_5		((1<<3) | (1<<1))
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_6		((1<<3) | (1<<2))
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_7		((1<<3) | (1<<2) | (1<<1))
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_0	0
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_1	(1<<4)
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_2	(1<<5)
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_3	((1<<5) | (1<<4))
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_4	(1<<6)
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_5	((1<<6) | (1<<4))
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_6	((1<<6) | (1<<5))
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_7	((1<<6) | (1<<5) | (1<<4))
-#define MV643XX_ETH_RECEIVE_BC_IF_NOT_IP_OR_ARP	0
-#define MV643XX_ETH_REJECT_BC_IF_NOT_IP_OR_ARP	(1<<7)
-#define MV643XX_ETH_RECEIVE_BC_IF_IP		0
-#define MV643XX_ETH_REJECT_BC_IF_IP		(1<<8)
-#define MV643XX_ETH_RECEIVE_BC_IF_ARP		0
-#define MV643XX_ETH_REJECT_BC_IF_ARP		(1<<9)
-#define MV643XX_ETH_TX_AM_NO_UPDATE_ERROR_SUMMARY (1<<12)
-#define MV643XX_ETH_CAPTURE_TCP_FRAMES_DIS	0
-#define MV643XX_ETH_CAPTURE_TCP_FRAMES_EN	(1<<14)
-#define MV643XX_ETH_CAPTURE_UDP_FRAMES_DIS	0
-#define MV643XX_ETH_CAPTURE_UDP_FRAMES_EN	(1<<15)
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_0	0
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_1	(1<<16)
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_2	(1<<17)
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_3	((1<<17) | (1<<16))
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_4	(1<<18)
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_5	((1<<18) | (1<<16))
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_6	((1<<18) | (1<<17))
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_7	((1<<18) | (1<<17) | (1<<16))
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_0	0
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_1	(1<<19)
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_2	(1<<20)
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_3	((1<<20) | (1<<19))
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_4	(1<<21)
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_5	((1<<21) | (1<<19))
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_6	((1<<21) | (1<<20))
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_7	((1<<21) | (1<<20) | (1<<19))
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_0	0
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_1	(1<<22)
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_2	(1<<23)
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_3	((1<<23) | (1<<22))
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_4	(1<<24)
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_5	((1<<24) | (1<<22))
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_6	((1<<24) | (1<<23))
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_7	((1<<24) | (1<<23) | (1<<22))
-
-#define	MV643XX_ETH_PORT_CONFIG_DEFAULT_VALUE			\
-		MV643XX_ETH_UNICAST_NORMAL_MODE		|	\
-		MV643XX_ETH_DEFAULT_RX_QUEUE_0		|	\
-		MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_0	|	\
-		MV643XX_ETH_RECEIVE_BC_IF_NOT_IP_OR_ARP	|	\
-		MV643XX_ETH_RECEIVE_BC_IF_IP		|	\
-		MV643XX_ETH_RECEIVE_BC_IF_ARP		|	\
-		MV643XX_ETH_CAPTURE_TCP_FRAMES_DIS	|	\
-		MV643XX_ETH_CAPTURE_UDP_FRAMES_DIS	|	\
-		MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_0	|	\
-		MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_0	|	\
-		MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_0
-
-/* These macros describe Ethernet Port configuration extend reg (Px_cXR) bits*/
-#define MV643XX_ETH_CLASSIFY_EN				(1<<0)
-#define MV643XX_ETH_SPAN_BPDU_PACKETS_AS_NORMAL		0
-#define MV643XX_ETH_SPAN_BPDU_PACKETS_TO_RX_QUEUE_7	(1<<1)
-#define MV643XX_ETH_PARTITION_DISABLE			0
-#define MV643XX_ETH_PARTITION_ENABLE			(1<<2)
-
-#define	MV643XX_ETH_PORT_CONFIG_EXTEND_DEFAULT_VALUE		\
-		MV643XX_ETH_SPAN_BPDU_PACKETS_AS_NORMAL	|	\
-		MV643XX_ETH_PARTITION_DISABLE
-
-/* These macros describe Ethernet Port Sdma configuration reg (SDCR) bits */
-#define MV643XX_ETH_RIFB			(1<<0)
-#define MV643XX_ETH_RX_BURST_SIZE_1_64BIT		0
-#define MV643XX_ETH_RX_BURST_SIZE_2_64BIT		(1<<1)
-#define MV643XX_ETH_RX_BURST_SIZE_4_64BIT		(1<<2)
-#define MV643XX_ETH_RX_BURST_SIZE_8_64BIT		((1<<2) | (1<<1))
-#define MV643XX_ETH_RX_BURST_SIZE_16_64BIT		(1<<3)
-#define MV643XX_ETH_BLM_RX_NO_SWAP			(1<<4)
-#define MV643XX_ETH_BLM_RX_BYTE_SWAP			0
-#define MV643XX_ETH_BLM_TX_NO_SWAP			(1<<5)
-#define MV643XX_ETH_BLM_TX_BYTE_SWAP			0
-#define MV643XX_ETH_DESCRIPTORS_BYTE_SWAP		(1<<6)
-#define MV643XX_ETH_DESCRIPTORS_NO_SWAP			0
-#define MV643XX_ETH_TX_BURST_SIZE_1_64BIT		0
-#define MV643XX_ETH_TX_BURST_SIZE_2_64BIT		(1<<22)
-#define MV643XX_ETH_TX_BURST_SIZE_4_64BIT		(1<<23)
-#define MV643XX_ETH_TX_BURST_SIZE_8_64BIT		((1<<23) | (1<<22))
-#define MV643XX_ETH_TX_BURST_SIZE_16_64BIT		(1<<24)
-
-#define	MV643XX_ETH_IPG_INT_RX(value) ((value & 0x3fff) << 8)
-
-#define	MV643XX_ETH_PORT_SDMA_CONFIG_DEFAULT_VALUE		\
-		MV643XX_ETH_RX_BURST_SIZE_4_64BIT	|	\
-		MV643XX_ETH_IPG_INT_RX(0)		|	\
-		MV643XX_ETH_TX_BURST_SIZE_4_64BIT
-
-/* These macros describe Ethernet Port serial control reg (PSCR) bits */
-#define MV643XX_ETH_SERIAL_PORT_DISABLE			0
-#define MV643XX_ETH_SERIAL_PORT_ENABLE			(1<<0)
-#define MV643XX_ETH_FORCE_LINK_PASS			(1<<1)
-#define MV643XX_ETH_DO_NOT_FORCE_LINK_PASS		0
-#define MV643XX_ETH_ENABLE_AUTO_NEG_FOR_DUPLX		0
-#define MV643XX_ETH_DISABLE_AUTO_NEG_FOR_DUPLX		(1<<2)
-#define MV643XX_ETH_ENABLE_AUTO_NEG_FOR_FLOW_CTRL	0
-#define MV643XX_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL	(1<<3)
-#define MV643XX_ETH_ADV_NO_FLOW_CTRL			0
-#define MV643XX_ETH_ADV_SYMMETRIC_FLOW_CTRL		(1<<4)
-#define MV643XX_ETH_FORCE_FC_MODE_NO_PAUSE_DIS_TX	0
-#define MV643XX_ETH_FORCE_FC_MODE_TX_PAUSE_DIS		(1<<5)
-#define MV643XX_ETH_FORCE_BP_MODE_NO_JAM		0
-#define MV643XX_ETH_FORCE_BP_MODE_JAM_TX		(1<<7)
-#define MV643XX_ETH_FORCE_BP_MODE_JAM_TX_ON_RX_ERR	(1<<8)
-#define MV643XX_ETH_SERIAL_PORT_CONTROL_RESERVED	(1<<9)
-#define MV643XX_ETH_FORCE_LINK_FAIL			0
-#define MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL		(1<<10)
-#define MV643XX_ETH_RETRANSMIT_16_ATTEMPTS		0
-#define MV643XX_ETH_RETRANSMIT_FOREVER			(1<<11)
-#define MV643XX_ETH_DISABLE_AUTO_NEG_SPEED_GMII		(1<<13)
-#define MV643XX_ETH_ENABLE_AUTO_NEG_SPEED_GMII		0
-#define MV643XX_ETH_DTE_ADV_0				0
-#define MV643XX_ETH_DTE_ADV_1				(1<<14)
-#define MV643XX_ETH_DISABLE_AUTO_NEG_BYPASS		0
-#define MV643XX_ETH_ENABLE_AUTO_NEG_BYPASS		(1<<15)
-#define MV643XX_ETH_AUTO_NEG_NO_CHANGE			0
-#define MV643XX_ETH_RESTART_AUTO_NEG			(1<<16)
-#define MV643XX_ETH_MAX_RX_PACKET_1518BYTE		0
-#define MV643XX_ETH_MAX_RX_PACKET_1522BYTE		(1<<17)
-#define MV643XX_ETH_MAX_RX_PACKET_1552BYTE		(1<<18)
-#define MV643XX_ETH_MAX_RX_PACKET_9022BYTE		((1<<18) | (1<<17))
-#define MV643XX_ETH_MAX_RX_PACKET_9192BYTE		(1<<19)
-#define MV643XX_ETH_MAX_RX_PACKET_9700BYTE		((1<<19) | (1<<17))
-#define MV643XX_ETH_SET_EXT_LOOPBACK			(1<<20)
-#define MV643XX_ETH_CLR_EXT_LOOPBACK			0
-#define MV643XX_ETH_SET_FULL_DUPLEX_MODE		(1<<21)
-#define MV643XX_ETH_SET_HALF_DUPLEX_MODE		0
-#define MV643XX_ETH_ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX (1<<22)
-#define MV643XX_ETH_DISABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX 0
-#define MV643XX_ETH_SET_GMII_SPEED_TO_10_100		0
-#define MV643XX_ETH_SET_GMII_SPEED_TO_1000		(1<<23)
-#define MV643XX_ETH_SET_MII_SPEED_TO_10			0
-#define MV643XX_ETH_SET_MII_SPEED_TO_100		(1<<24)
-
-#define MV643XX_ETH_MAX_RX_PACKET_MASK			(0x7<<17)
-
-#define	MV643XX_ETH_PORT_SERIAL_CONTROL_DEFAULT_VALUE		\
-		MV643XX_ETH_DO_NOT_FORCE_LINK_PASS	|	\
-		MV643XX_ETH_ENABLE_AUTO_NEG_FOR_DUPLX	|	\
-		MV643XX_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL |	\
-		MV643XX_ETH_ADV_SYMMETRIC_FLOW_CTRL	|	\
-		MV643XX_ETH_FORCE_FC_MODE_NO_PAUSE_DIS_TX |	\
-		MV643XX_ETH_FORCE_BP_MODE_NO_JAM	|	\
-		(1<<9)	/* reserved */			|	\
-		MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL	|	\
-		MV643XX_ETH_RETRANSMIT_16_ATTEMPTS	|	\
-		MV643XX_ETH_ENABLE_AUTO_NEG_SPEED_GMII	|	\
-		MV643XX_ETH_DTE_ADV_0			|	\
-		MV643XX_ETH_DISABLE_AUTO_NEG_BYPASS	|	\
-		MV643XX_ETH_AUTO_NEG_NO_CHANGE		|	\
-		MV643XX_ETH_MAX_RX_PACKET_9700BYTE	|	\
-		MV643XX_ETH_CLR_EXT_LOOPBACK		|	\
-		MV643XX_ETH_SET_FULL_DUPLEX_MODE	|	\
-		MV643XX_ETH_ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX
-
-/* These macros describe Ethernet Serial Status reg (PSR) bits */
-#define MV643XX_ETH_PORT_STATUS_MODE_10_BIT		(1<<0)
-#define MV643XX_ETH_PORT_STATUS_LINK_UP			(1<<1)
-#define MV643XX_ETH_PORT_STATUS_FULL_DUPLEX		(1<<2)
-#define MV643XX_ETH_PORT_STATUS_FLOW_CONTROL		(1<<3)
-#define MV643XX_ETH_PORT_STATUS_GMII_1000		(1<<4)
-#define MV643XX_ETH_PORT_STATUS_MII_100			(1<<5)
-/* PSR bit 6 is undocumented */
-#define MV643XX_ETH_PORT_STATUS_TX_IN_PROGRESS		(1<<7)
-#define MV643XX_ETH_PORT_STATUS_AUTONEG_BYPASSED	(1<<8)
-#define MV643XX_ETH_PORT_STATUS_PARTITION		(1<<9)
-#define MV643XX_ETH_PORT_STATUS_TX_FIFO_EMPTY		(1<<10)
-/* PSR bits 11-31 are reserved */
-
-#define	MV643XX_ETH_PORT_DEFAULT_TRANSMIT_QUEUE_SIZE	800
-#define	MV643XX_ETH_PORT_DEFAULT_RECEIVE_QUEUE_SIZE	400
-
-#define MV643XX_ETH_DESC_SIZE				64
-
 /* Watchdog Platform Device, Driver Data */
 #define	MV64x60_WDT_NAME			"mv64x60_wdt"
