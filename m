From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 2/2] gianfar: Remove unused field grp_id in gfar_priv_grp
Date: Wed, 24 Jul 2013 17:43:35 +0300
Message-ID: <1374677015-23127-2-git-send-email-claudiu.manoil@freescale.com>
References: <1374677015-23127-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:2459 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751904Ab3GXOo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 10:44:29 -0400
In-Reply-To: <1374677015-23127-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

grp_id is obsolete. It has not been used for a long time
now as it has no relevant meaning in the current driver.
Remove it from gfar_priv_grp and put the 'rstat' member
in its place, as rstat needs fast access (and to preserve
consistency of cache line layout according to comments).

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 1 -
 drivers/net/ethernet/freescale/gianfar.h | 3 +--
 2 files changed, 1 insertion(+), 3 deletions(-)

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
index 655951d..978fc28 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1002,11 +1002,10 @@ struct gfar_priv_grp {
 	struct gfar_private *priv;
 	/* register space for this group */
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
1.7.11.4
