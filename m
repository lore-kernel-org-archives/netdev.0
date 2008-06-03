From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 15/39] mv643xx_eth: clean up rx/tx descriptor field defines
Date: Tue,  3 Jun 2008 13:02:30 +0200
Message-ID: <1212490974-23719-16-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48747 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754212AbYFCMA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:27 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the unused rx/tx descriptor field defines, and move the ones
that are actually used to the actual definitions of the rx/tx
descriptor format.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   82 +++++++++++++++-----------------------------
 1 files changed, 28 insertions(+), 54 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 34bfdf6..ea1af64 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -167,57 +167,6 @@ static char mv643xx_driver_version[] = "1.0";
 #define ETH_SMI_OPCODE_WRITE	0		/* Completion of Read	*/
 #define ETH_SMI_OPCODE_READ	0x04000000	/* Operation is in progress */
 
-/* Interrupt Cause Register Bit Definitions */
-
-/* SDMA command status fields macros */
-
-/* Tx & Rx descriptors status */
-#define ETH_ERROR_SUMMARY			0x00000001
-
-/* Tx & Rx descriptors command */
-#define ETH_BUFFER_OWNED_BY_DMA			0x80000000
-
-/* Tx descriptors status */
-#define ETH_LC_ERROR				0
-#define ETH_UR_ERROR				0x00000002
-#define ETH_RL_ERROR				0x00000004
-#define ETH_LLC_SNAP_FORMAT			0x00000200
-
-/* Rx descriptors status */
-#define ETH_OVERRUN_ERROR			0x00000002
-#define ETH_MAX_FRAME_LENGTH_ERROR		0x00000004
-#define ETH_RESOURCE_ERROR			0x00000006
-#define ETH_VLAN_TAGGED				0x00080000
-#define ETH_BPDU_FRAME				0x00100000
-#define ETH_UDP_FRAME_OVER_IP_V_4		0x00200000
-#define ETH_OTHER_FRAME_TYPE			0x00400000
-#define ETH_LAYER_2_IS_ETH_V_2			0x00800000
-#define ETH_FRAME_TYPE_IP_V_4			0x01000000
-#define ETH_FRAME_HEADER_OK			0x02000000
-#define ETH_RX_LAST_DESC			0x04000000
-#define ETH_RX_FIRST_DESC			0x08000000
-#define ETH_UNKNOWN_DESTINATION_ADDR		0x10000000
-#define ETH_RX_ENABLE_INTERRUPT			0x20000000
-#define ETH_LAYER_4_CHECKSUM_OK			0x40000000
-
-/* Rx descriptors byte count */
-#define ETH_FRAME_FRAGMENTED			0x00000004
-
-/* Tx descriptors command */
-#define ETH_LAYER_4_CHECKSUM_FIRST_DESC		0x00000400
-#define ETH_FRAME_SET_TO_VLAN			0x00008000
-#define ETH_UDP_FRAME				0x00010000
-#define ETH_GEN_TCP_UDP_CHECKSUM		0x00020000
-#define ETH_GEN_IP_V_4_CHECKSUM			0x00040000
-#define ETH_ZERO_PADDING			0x00080000
-#define ETH_TX_LAST_DESC			0x00100000
-#define ETH_TX_FIRST_DESC			0x00200000
-#define ETH_GEN_CRC				0x00400000
-#define ETH_TX_ENABLE_INTERRUPT			0x00800000
-#define ETH_AUTO_MODE				0x40000000
-
-#define ETH_TX_IHL_SHIFT			11
-
 /* typedefs */
 
 typedef enum _eth_func_ret_status {
@@ -229,8 +178,8 @@ typedef enum _eth_func_ret_status {
 	ETH_QUEUE_LAST_RESOURCE	/* Ring resources about to exhaust.	*/
 } ETH_FUNC_RET_STATUS;
 
-/* These are for big-endian machines.  Little endian needs different
- * definitions.
+/*
+ * RX/TX descriptors.
  */
 #if defined(__BIG_ENDIAN)
 struct eth_rx_desc {
@@ -268,6 +217,31 @@ struct eth_tx_desc {
 #error One of __BIG_ENDIAN or __LITTLE_ENDIAN must be defined
 #endif
 
+/* RX & TX descriptor command */
+#define ETH_BUFFER_OWNED_BY_DMA			0x80000000
+
+/* RX & TX descriptor status */
+#define ETH_ERROR_SUMMARY			0x00000001
+
+/* RX descriptor status */
+#define ETH_LAYER_4_CHECKSUM_OK			0x40000000
+#define ETH_RX_ENABLE_INTERRUPT			0x20000000
+#define ETH_RX_FIRST_DESC			0x08000000
+#define ETH_RX_LAST_DESC			0x04000000
+
+/* TX descriptor command */
+#define ETH_TX_ENABLE_INTERRUPT			0x00800000
+#define ETH_GEN_CRC				0x00400000
+#define ETH_TX_FIRST_DESC			0x00200000
+#define ETH_TX_LAST_DESC			0x00100000
+#define ETH_ZERO_PADDING			0x00080000
+#define ETH_GEN_IP_V4_CHECKSUM			0x00040000
+#define ETH_GEN_TCP_UDP_CHECKSUM		0x00020000
+#define ETH_UDP_FRAME				0x00010000
+
+#define ETH_TX_IHL_SHIFT			11
+
+
 /* Unified struct for Rx and Tx operations. The user is not required to	*/
 /* be familier with neither Tx nor Rx descriptors.			*/
 struct pkt_info {
@@ -896,7 +870,7 @@ static void eth_tx_submit_descs_for_skb(struct mv643xx_private *mp,
 		BUG_ON(skb->protocol != htons(ETH_P_IP));
 
 		cmd_sts |= ETH_GEN_TCP_UDP_CHECKSUM |
-			   ETH_GEN_IP_V_4_CHECKSUM  |
+			   ETH_GEN_IP_V4_CHECKSUM   |
 			   ip_hdr(skb)->ihl << ETH_TX_IHL_SHIFT;
 
 		switch (ip_hdr(skb)->protocol) {
-- 
1.5.3.4

