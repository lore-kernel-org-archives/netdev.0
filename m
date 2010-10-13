From: Dan Carpenter <error27@gmail.com>
Subject: [patch] gianfar: fix double lock typo
Date: Wed, 13 Oct 2010 21:19:55 +0200
Message-ID: <20101013191954.GE6060@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58064 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370Ab0JMTUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 15:20:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This should be a _restore() instead of a _save().

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index ae8e5d3..5c566eb 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -538,7 +538,7 @@ static int gfar_set_rx_csum(struct net_device *dev, uint32_t data)
 
 		unlock_tx_qs(priv);
 		unlock_rx_qs(priv);
-		local_irq_save(flags);
+		local_irq_restore(flags);
 
 		for (i = 0; i < priv->num_rx_queues; i++)
 			gfar_clean_rx_ring(priv->rx_queue[i],
