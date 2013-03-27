From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 1/2] drivers: net: ethernet: cpsw: use netif_wake_queue() while restarting tx queue
Date: Wed, 27 Mar 2013 20:11:59 +0530
Message-ID: <1364395320-14973-2-git-send-email-mugunthanvnm@ti.com>
References: <1364395320-14973-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-omap@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:37403 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752445Ab3C0OmN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 10:42:13 -0400
In-Reply-To: <1364395320-14973-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To restart tx queue use netif_wake_queue() intead of netif_start_queue()
so that net schedule will restart transmission immediately which will
increase network performance while doing huge data transfers.

Reported-by: Dan Franke <dan.franke@schneider-electric.com>
Suggested-by: Sriramakrishnan A G <srk@ti.com>
Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index f4be85b..61ecebf 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -458,7 +458,7 @@ static void cpsw_tx_handler(void *token, int len, int status)
 	 * queue is stopped then start the queue as we have free desc for tx
 	 */
 	if (unlikely(netif_queue_stopped(ndev)))
-		netif_start_queue(ndev);
+		netif_wake_queue(ndev);
 	cpts_tx_timestamp(priv->cpts, skb);
 	priv->stats.tx_packets++;
 	priv->stats.tx_bytes += len;
-- 
1.7.9.5
