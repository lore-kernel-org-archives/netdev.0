From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 4/4] gianfar: use netif_tx_queue_stopped instead of __netif_subqueue_stopped
Date: Sun, 18 Mar 2012 17:39:21 -0400
Message-ID: <1332106761-18293-5-git-send-email-paul.gortmaker@windriver.com>
References: <1332089787-24086-1-git-send-email-paul.gortmaker@windriver.com>
 <1332106761-18293-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net, eric.dumazet@gmail.com, therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:60891 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754707Ab2CRVjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2012 17:39:46 -0400
In-Reply-To: <1332106761-18293-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The __netif_subqueue_stopped() just does the following:

        struct netdev_queue *txq = netdev_get_tx_queue(dev, queue_index);
        return netif_tx_queue_stopped(txq);

and since we already have the txq in scope, we can just call that
directly in this case.

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/ethernet/freescale/gianfar.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 6e66cc3..d9428f0 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2565,7 +2565,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 	}
 
 	/* If we freed a buffer, we can restart transmission, if necessary */
-	if (__netif_subqueue_stopped(dev, tqi) && tx_queue->num_txbdfree)
+	if (netif_tx_queue_stopped(txq) && tx_queue->num_txbdfree)
 		netif_wake_subqueue(dev, tqi);
 
 	/* Update dirty indicators */
-- 
1.7.9.1
