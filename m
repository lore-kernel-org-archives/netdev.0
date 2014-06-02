From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH v9 7/7] xen-netfront: initialise queue name in xennet_init_queue
Date: Mon, 2 Jun 2014 11:50:12 +0100
Message-ID: <1401706212-8208-8-git-send-email-wei.liu2@citrix.com>
References: <1401706212-8208-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <david.vrabel@citrix.com>,
	<zoltan.kiss@citrix.com>, <paul.durrant@citrix.com>,
	<a.j.bennieston@gmail.com>, Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:26241 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753754AbaFBKuO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2014 06:50:14 -0400
In-Reply-To: <1401706212-8208-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
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
