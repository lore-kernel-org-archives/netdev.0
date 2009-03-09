From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 11/12] qlge: bugfix: Pad outbound frames smaller than 60 bytes.
Date: Mon,  9 Mar 2009 13:59:27 -0700
Message-ID: <1236632368-22079-12-git-send-email-ron.mercer@qlogic.com>
References: <1236632368-22079-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:18643 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753683AbZCIVDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 17:03:10 -0400
In-Reply-To: <1236632368-22079-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With some asic configurations xmit of frames smaller than 60 bytes may
fail.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index ce826da..1895846 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2057,6 +2057,9 @@ static int qlge_send(struct sk_buff *skb, struct net_device *ndev)
 
 	tx_ring = &qdev->tx_ring[tx_ring_idx];
 
+	if (skb_padto(skb, ETH_ZLEN))
+		return NETDEV_TX_OK;
+
 	if (unlikely(atomic_read(&tx_ring->tx_count) < 2)) {
 		QPRINTK(qdev, TX_QUEUED, INFO,
 			"%s: shutting down tx queue %d du to lack of resources.\n",
-- 
1.6.0.2

