From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net 1/7] qlge: Fixed packet transmit errors due to potential driver errors.
Date: Mon,  2 Jul 2012 19:41:48 -0400
Message-ID: <1341272514-5156-2-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1341272514-5156-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:16498 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1750944Ab2GBX6h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2012 19:58:37 -0400
In-Reply-To: <1341272514-5156-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

qlge driver was acting wrongly when considering TX ring full
as a TX error. TX ring full is expected behavior when NIC is
overwhelmed and is expected to happen, as far as packets are
not lost.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 09d8d33..cdbc860 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -2562,7 +2562,6 @@ static netdev_tx_t qlge_send(struct sk_buff *skb, struct net_device *ndev)
 			   __func__, tx_ring_idx);
 		netif_stop_subqueue(ndev, tx_ring->wq_id);
 		atomic_inc(&tx_ring->queue_stopped);
-		tx_ring->tx_errors++;
 		return NETDEV_TX_BUSY;
 	}
 	tx_ring_desc = &tx_ring->q[tx_ring->prod_idx];
-- 
1.7.1
