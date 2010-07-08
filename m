From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 2/6 net-next-2.6] vxge: Use fifo based trans_start time
Date: Thu, 8 Jul 2010 14:21:26 -0500
Message-ID: <20100708192125.GB15167@exar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ramkrishna Vepa <ram.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:43051 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755887Ab0GHTUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 15:20:47 -0400
Received: by pvc7 with SMTP id 7so448144pvc.19
        for <netdev@vger.kernel.org>; Thu, 08 Jul 2010 12:20:47 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the fifo based netdev_queue->trans_start time in vxge_xmit, instead
of the device based netdev->trans_start time.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@exar.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@exar.com>
---
 drivers/net/vxge/vxge-main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index e78703d..b8eed71 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -802,6 +802,7 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags = 0;
 	int vpath_no = 0;
 	int do_spin_tx_lock = 1;
+	struct netdev_queue *txq;
 
 	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d",
 			dev->name, __func__, __LINE__);
@@ -968,8 +969,10 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 					VXGE_HW_FIFO_TXD_TX_CKO_UDP_EN);
 
 	vxge_hw_fifo_txdl_post(fifo_hw, dtr);
+
 #ifdef NETIF_F_LLTX
-	dev->trans_start = jiffies; /* NETIF_F_LLTX driver :( */
+	txq = netdev_get_tx_queue(dev, vpath_no);
+	txq->trans_start = jiffies;
 #endif
 	spin_unlock_irqrestore(&fifo->tx_lock, flags);
 
