From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH][net-next] gianfar: Remove unused field grp_id from gfar_priv_grp
Date: Thu, 1 Aug 2013 10:07:05 +0300
Message-ID: <1375340825-6524-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:22528 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751192Ab3HAHHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 03:07:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

grp->grp_id is obsolete. It has no use in the current driver.
Remove it from gfar_priv_grp and put the 'rstat' member
in its place, in the 2nd cache line, as rstat needs fast access.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 1 -
 drivers/net/ethernet/freescale/gianfar.h | 4 +---
 2 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 0f05b96..8bd4e39 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -593,7 +593,6 @@ static int gfar_parse_group(struct device_node *np,
 			return -EINVAL;
 	}
 
-	grp->grp_id = priv->num_grps;
 	grp->priv = priv;
 	spin_lock_init(&grp->grplock);
 	if (priv->mode == MQ_MG_MODE) {
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 04b552c..ee19f2c 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1009,7 +1009,6 @@ struct gfar_irqinfo {
  *	@napi: the napi poll function
  *	@priv: back pointer to the priv structure
  *	@regs: the ioremapped register space for this group
- *	@grp_id: group id for this group
  *	@irqinfo: TX/RX/ER irq data for this group
  */
 
@@ -1018,11 +1017,10 @@ struct gfar_priv_grp {
 	struct	napi_struct napi;
 	struct gfar_private *priv;
 	struct gfar __iomem *regs;
-	unsigned int grp_id;
+	unsigned int rstat;
 	unsigned long num_rx_queues;
 	unsigned long rx_bit_map;
 	/* cacheline 3 */
-	unsigned int rstat;
 	unsigned int tstat;
 	unsigned long num_tx_queues;
 	unsigned long tx_bit_map;
-- 
1.7.11.7
