From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net-next v10 7/7] xen-netfront: initialise queue name in xennet_init_queue
Date: Wed, 4 Jun 2014 10:30:47 +0100
Message-ID: <1401874247-3202-8-git-send-email-wei.liu2@citrix.com>
References: <1401874247-3202-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <david.vrabel@citrix.com>,
	<zoltan.kiss@citrix.com>, <paul.durrant@citrix.com>,
	<a.j.bennieston@gmail.com>, <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:22339 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751332AbaFDJat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 05:30:49 -0400
In-Reply-To: <1401874247-3202-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Reviewed-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netfront.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 55bf834..5a7872a 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1665,6 +1665,9 @@ static int xennet_init_queue(struct netfront_queue *queue)
 	queue->rx_refill_timer.data = (unsigned long)queue;
 	queue->rx_refill_timer.function = rx_refill_timeout;
 
+	snprintf(queue->name, sizeof(queue->name), "%s-q%u",
+		 queue->info->netdev->name, queue->id);
+
 	/* Initialise tx_skbs as a free chain containing every entry. */
 	queue->tx_skb_freelist = 0;
 	for (i = 0; i < NET_TX_RING_SIZE; i++) {
-- 
1.7.10.4
