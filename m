From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 11/14] net/mlx4_en: tx_info->ts_requested was not cleared
Date: Mon,  6 Oct 2014 09:16:00 +0300
Message-ID: <1412576163-7224-12-git-send-email-amirv@mellanox.com>
References: <1412576163-7224-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:57214 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751658AbaJFGRE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2014 02:17:04 -0400
In-Reply-To: <1412576163-7224-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Properly clear tx_info->ts_requested

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index e00841a..2c03b55 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -837,6 +837,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * For timestamping add flag to skb_shinfo and
 	 * set flag for further reference
 	 */
+	tx_info->ts_requested = 0;
 	if (unlikely(ring->hwtstamp_tx_type == HWTSTAMP_TX_ON &&
 		     shinfo->tx_flags & SKBTX_HW_TSTAMP)) {
 		shinfo->tx_flags |= SKBTX_IN_PROGRESS;
-- 
1.8.3.1
