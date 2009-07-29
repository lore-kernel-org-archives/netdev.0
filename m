From: Li Yang <leoli@freescale.com>
Subject: [PATCH] gianfar: fix coalescing setup in ethtool support
Date: Wed, 29 Jul 2009 16:51:57 +0800
Message-ID: <1248857517-8270-1-git-send-email-leoli@freescale.com>
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Jiajun Wu <b06378@freescale.com>, Li Yang <leoli@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:42072 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbZG2ITv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 04:19:51 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n6T8JYr0014269
	for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 01:19:45 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id n6T8JkMZ003494
	for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 03:19:47 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiajun Wu <b06378@freescale.com>

Parameter order for using mk_ic_value(count, time) was reversed,
the patch fixes this.

Signed-off-by: Jiajun Wu <b06378@freescale.com>
Signed-off-by: Li Yang <leoli@freescale.com>
---
 drivers/net/gianfar_ethtool.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index 2a7edfa..3109f4b 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -373,9 +373,8 @@ static int gfar_scoalesce(struct net_device *dev, struct ethtool_coalesce *cvals
 		return -EINVAL;
 	}
 
-	priv->rxic = mk_ic_value(
-		gfar_usecs2ticks(priv, cvals->rx_coalesce_usecs),
-		cvals->rx_max_coalesced_frames);
+	priv->rxic = mk_ic_value(cvals->rx_max_coalesced_frames,
+		gfar_usecs2ticks(priv, cvals->rx_coalesce_usecs));
 
 	/* Set up tx coalescing */
 	if ((cvals->tx_coalesce_usecs == 0) ||
@@ -397,9 +396,8 @@ static int gfar_scoalesce(struct net_device *dev, struct ethtool_coalesce *cvals
 		return -EINVAL;
 	}
 
-	priv->txic = mk_ic_value(
-		gfar_usecs2ticks(priv, cvals->tx_coalesce_usecs),
-		cvals->tx_max_coalesced_frames);
+	priv->txic = mk_ic_value(cvals->tx_max_coalesced_frames,
+		gfar_usecs2ticks(priv, cvals->tx_coalesce_usecs));
 
 	gfar_write(&priv->regs->rxic, 0);
 	if (priv->rxcoalescing)
-- 
1.5.6.3

