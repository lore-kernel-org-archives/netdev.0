From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 5/8] qlge: Fix tx byte counter.
Date: Thu,  2 Jul 2009 09:06:10 -0700
Message-ID: <1246550773-18417-5-git-send-email-ron.mercer@qlogic.com>
References: <1246550773-18417-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:26904 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752731AbZGBQLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 12:11:33 -0400
In-Reply-To: <1246550773-18417-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 1b75f6e..74ed84a 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1629,7 +1629,7 @@ static void ql_process_mac_tx_intr(struct ql_adapter *qdev,
 	tx_ring = &qdev->tx_ring[mac_rsp->txq_idx];
 	tx_ring_desc = &tx_ring->q[mac_rsp->tid];
 	ql_unmap_send(qdev, tx_ring_desc, tx_ring_desc->map_cnt);
-	qdev->stats.tx_bytes += tx_ring_desc->map_cnt;
+	qdev->stats.tx_bytes += (tx_ring_desc->skb)->len;
 	qdev->stats.tx_packets++;
 	dev_kfree_skb(tx_ring_desc->skb);
 	tx_ring_desc->skb = NULL;
-- 
1.6.0.2

