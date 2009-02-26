From: Rini van Zetten <rini@arvoo.nl>
Subject: [PATCH net] gianfar : Do right check on num_txbdfree
Date: Thu, 26 Feb 2009 09:56:58 +0100
Message-ID: <49A6595A.9000405@arvoo.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp0.euronet.nl ([194.134.35.141]:61217 "EHLO smtp0.euronet.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752109AbZBZI5K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 03:57:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a wrong check on num_txbdfree. It could lead to num_txbdfree become nagative.
Result was that the gianfar stops sending data.


Signed-off-by: Rini van Zetten <rini at arvoo dot nl>
---
  drivers/net/gianfar.c |    2 +-
  1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 7ef1ffd..2dc3bd3 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1284,9 +1284,8 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
  	spin_lock_irqsave(&priv->txlock, flags);

  	/* check if there is space to queue this packet */
-	if (nr_frags > priv->num_txbdfree) {
+	if ( (nr_frags+1) > priv->num_txbdfree) {
  		/* no space, stop the queue */
  		netif_stop_queue(dev);
  		dev->stats.tx_fifo_errors++;
  		spin_unlock_irqrestore(&priv->txlock, flags);
-- 


