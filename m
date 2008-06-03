From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 19/39] mv643xx_eth: kill ->rx_resource_err
Date: Tue,  3 Jun 2008 13:02:34 +0200
Message-ID: <1212490974-23719-20-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48763 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756119AbYFCMAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:42 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ->rx_resource_err variable doesn't serve a useful purpose --
kill it.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   15 ---------------
 1 files changed, 0 insertions(+), 15 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 16dee87..cce9686 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -311,8 +311,6 @@ struct mv643xx_eth_private {
 	u32 tx_sram_addr;		/* Base address of tx sram area */
 	u32 tx_sram_size;		/* Size of tx sram area		*/
 
-	int rx_resource_err;		/* Rx ring resource error flag */
-
 	/* Tx/Rx rings managment indexes fields. For driver use */
 
 	/* Next available and first returning Rx resource */
@@ -463,9 +461,6 @@ static FUNC_RET_STATUS rx_return_buff(struct mv643xx_eth_private *mep,
 	/* Move the used descriptor pointer to the next descriptor */
 	mep->rx_used_desc_q = (used_rx_desc + 1) % mep->rx_ring_size;
 
-	/* Any Rx return cancels the Rx resource error status */
-	mep->rx_resource_err = 0;
-
 	spin_unlock_irqrestore(&mep->lock, flags);
 
 	return ETH_OK;
@@ -522,10 +517,6 @@ static FUNC_RET_STATUS port_receive(struct mv643xx_eth_private *mep,
 	unsigned int command_status;
 	unsigned long flags;
 
-	/* Do not process Rx ring in case of Rx ring resource error */
-	if (mep->rx_resource_err)
-		return ETH_QUEUE_FULL;
-
 	spin_lock_irqsave(&mep->lock, flags);
 
 	/* Get the Rx Desc ring 'curr and 'used' indexes */
@@ -560,10 +551,6 @@ static FUNC_RET_STATUS port_receive(struct mv643xx_eth_private *mep,
 	rx_next_curr_desc = (rx_curr_desc + 1) % mep->rx_ring_size;
 	mep->rx_curr_desc_q = rx_next_curr_desc;
 
-	/* Rx descriptors exhausted. Set the Rx ring resource error flag */
-	if (rx_next_curr_desc == rx_used_desc)
-		mep->rx_resource_err = 1;
-
 	spin_unlock_irqrestore(&mep->lock, flags);
 
 	return ETH_OK;
@@ -1751,8 +1738,6 @@ static unsigned int set_tx_coal(struct mv643xx_eth_private *mep,
 
 static void port_init(struct mv643xx_eth_private *mep)
 {
-	mep->rx_resource_err = 0;
-
 	port_reset(mep);
 
 	init_mac_tables(mep);
-- 
1.5.3.4

