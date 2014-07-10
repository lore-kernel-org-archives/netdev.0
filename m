From: varkabhadram@gmail.com
Subject: [PATCH net 2/7] net: cpmac: fix comments
Date: Thu, 10 Jul 2014 10:17:55 +0530
Message-ID: <1404967680-13206-3-git-send-email-varkabhadram@gmail.com>
References: <1404967680-13206-1-git-send-email-varkabhadram@gmail.com>
Cc: mugunthanvnm@ti.com, linux@rainbow-software.org, balbi@ti.com,
	george.cherian@ti.com, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:58686 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbaGJEt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 00:49:27 -0400
Received: by mail-pa0-f53.google.com with SMTP id ey11so10370599pad.40
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2014 21:49:27 -0700 (PDT)
In-Reply-To: <1404967680-13206-1-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkab@cdac.in>

This patch convert the normal comments to networking subsystem
style comments.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/ti/cpmac.c |   40 ++++++++++++++++++++-------------------
 1 file changed, 21 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 61eb691..1d8ef39 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -118,8 +118,8 @@ MODULE_PARM_DESC(dumb_switch, "Assume switch is not connected to MDIO bus");
 #define CPMAC_TX_ACK(channel)		(0x0640 + (channel) * 4)
 #define CPMAC_RX_ACK(channel)		(0x0660 + (channel) * 4)
 #define CPMAC_REG_END			0x0680
-/*
- * Rx/Tx statistics
+
+/* Rx/Tx statistics
  * TODO: use some of them to fill stats in cpmac_stats()
  */
 #define CPMAC_STATS_RX_GOOD		0x0200
@@ -331,8 +331,7 @@ static void cpmac_set_multicast_list(struct net_device *dev)
 			cpmac_write(priv->regs, CPMAC_MAC_HASH_LO, 0xffffffff);
 			cpmac_write(priv->regs, CPMAC_MAC_HASH_HI, 0xffffffff);
 		} else {
-			/*
-			 * cpmac uses some strange mac address hashing
+			/* cpmac uses some strange mac address hashing
 			 * (not crc32)
 			 */
 			netdev_for_each_mc_addr(ha, dev) {
@@ -432,10 +431,10 @@ static int cpmac_poll(struct napi_struct *napi, int budget)
 
 		if ((desc->dataflags & CPMAC_EOQ) != 0) {
 			/* The last update to eoq->hw_next didn't happen
-			* soon enough, and the receiver stopped here.
-			*Remember this descriptor so we can restart
-			* the receiver after freeing some space.
-			*/
+			 * soon enough, and the receiver stopped here.
+			 * Remember this descriptor so we can restart
+			 * the receiver after freeing some space.
+			 */
 			if (unlikely(restart)) {
 				if (netif_msg_rx_err(priv))
 					printk(KERN_ERR "%s: poll found a"
@@ -457,25 +456,27 @@ static int cpmac_poll(struct napi_struct *napi, int budget)
 
 	if (desc != priv->rx_head) {
 		/* We freed some buffers, but not the whole ring,
-		 * add what we did free to the rx list */
+		 * add what we did free to the rx list
+		 */
 		desc->prev->hw_next = (u32)0;
 		priv->rx_head->prev->hw_next = priv->rx_head->mapping;
 	}
 
 	/* Optimization: If we did not actually process an EOQ (perhaps because
 	 * of quota limits), check to see if the tail of the queue has EOQ set.
-	* We should immediately restart in that case so that the receiver can
-	* restart and run in parallel with more packet processing.
-	* This lets us handle slightly larger bursts before running
-	* out of ring space (assuming dev->weight < ring_size) */
+	 * We should immediately restart in that case so that the receiver can
+	 * restart and run in parallel with more packet processing.
+	 * This lets us handle slightly larger bursts before running
+	 * out of ring space (assuming dev->weight < ring_size)
+	 */
 
 	if (!restart &&
 	     (priv->rx_head->prev->dataflags & (CPMAC_OWN|CPMAC_EOQ))
 		    == CPMAC_EOQ &&
 	     (priv->rx_head->dataflags & CPMAC_OWN) != 0) {
 		/* reset EOQ so the poll loop (above) doesn't try to
-		* restart this when it eventually gets to this descriptor.
-		*/
+		 * restart this when it eventually gets to this descriptor.
+		 */
 		priv->rx_head->prev->dataflags &= ~CPMAC_EOQ;
 		restart = priv->rx_head;
 	}
@@ -506,7 +507,8 @@ static int cpmac_poll(struct napi_struct *napi, int budget)
 		       priv->dev->name, received);
 	if (processed == 0) {
 		/* we ran out of packets to read,
-		 * revert to interrupt-driven mode */
+		 * revert to interrupt-driven mode
+		 */
 		napi_complete(napi);
 		cpmac_write(priv->regs, CPMAC_RX_INT_ENABLE, 1);
 		return 0;
@@ -516,8 +518,8 @@ static int cpmac_poll(struct napi_struct *napi, int budget)
 
 fatal_error:
 	/* Something went horribly wrong.
-	 * Reset hardware to try to recover rather than wedging. */
-
+	 * Reset hardware to try to recover rather than wedging.
+	 */
 	if (netif_msg_drv(priv)) {
 		printk(KERN_ERR "%s: cpmac_poll is confused. "
 				"Resetting hardware\n", priv->dev->name);
@@ -751,7 +753,7 @@ static void cpmac_check_status(struct net_device *dev)
 	if (rx_code || tx_code) {
 		if (netif_msg_drv(priv) && net_ratelimit()) {
 			/* Can't find any documentation on what these
-			 *error codes actually are. So just log them and hope..
+			 * error codes actually are. So just log them and hope..
 			 */
 			if (rx_code)
 				printk(KERN_WARNING "%s: host error %d on rx "
-- 
1.7.9.5
