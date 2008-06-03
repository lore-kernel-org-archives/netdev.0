From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 23/39] mv643xx_eth: kill FUNC_RET_STATUS/pkt_info
Date: Tue,  3 Jun 2008 13:02:38 +0200
Message-ID: <1212490974-23719-24-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48755 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754765AbYFCMA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:29 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since they are no longer used, kill enum FUNC_RET_STATUS and
struct pkt_info (which were a rather roundabout way of communicating
RX/TX status within the same driver).

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   21 ---------------------
 1 files changed, 0 insertions(+), 21 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index a54c342..d68780a 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -167,16 +167,6 @@ static char mv643xx_eth_driver_version[] = "1.0";
 #define SMI_OPCODE_WRITE	0		/* Completion of Read	*/
 #define SMI_OPCODE_READ		0x04000000	/* Operation is in progress */
 
-/* typedefs */
-
-typedef enum _func_ret_status {
-	ETH_OK,			/* Returned as expected.		*/
-	ETH_ERROR,		/* Fundamental error.			*/
-	ETH_RETRY,		/* Could not process request. Try later.*/
-	ETH_END_OF_JOB,		/* Ring has nothing to process.		*/
-	ETH_QUEUE_FULL,		/* Ring resource error.			*/
-	ETH_QUEUE_LAST_RESOURCE	/* Ring resources about to exhaust.	*/
-} FUNC_RET_STATUS;
 
 /*
  * RX/TX descriptors.
@@ -242,17 +232,6 @@ struct tx_desc {
 #define TX_IHL_SHIFT			11
 
 
-/* Unified struct for Rx and Tx operations. The user is not required to	*/
-/* be familier with neither Tx nor Rx descriptors.			*/
-struct pkt_info {
-	unsigned short byte_cnt;	/* Descriptor buffer byte count	*/
-	unsigned short l4i_chk;		/* Tx CPU provided TCP Checksum	*/
-	unsigned int cmd_sts;		/* Descriptor command status	*/
-	dma_addr_t buf_ptr;		/* Descriptor buffer pointer	*/
-	struct sk_buff *return_info;	/* User resource return information */
-};
-
-
 /* global *******************************************************************/
 struct mv643xx_eth_shared_private {
 	void __iomem *base;
-- 
1.5.3.4

