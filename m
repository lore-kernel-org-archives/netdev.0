From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/4] net/mlx4_en: Fix adaptive moderation cq update
Date: Tue,  4 Jun 2013 18:13:26 +0300
Message-ID: <1370358809-7484-2-git-send-email-ogerlitz@mellanox.com>
References: <1370358809-7484-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Sagi Grimberg <sagig@mellanox.co.il>,
	Sagi Grimberg <sagig@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:59252 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751802Ab3FDPTG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jun 2013 11:19:06 -0400
In-Reply-To: <1370358809-7484-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sagi Grimberg <sagig@mellanox.co.il>

When turning on adaptive_rx under adaptive moderation, the CQ's moderation
count wasn't updated according to rx_frames which resulted in too many
interrupts and bandwidth drop.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index b35f947..810aab0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1323,6 +1323,7 @@ static void mlx4_en_auto_moderation(struct mlx4_en_priv *priv)
 			priv->last_moder_time[ring] = moder_time;
 			cq = &priv->rx_cq[ring];
 			cq->moder_time = moder_time;
+			cq->moder_cnt = priv->rx_frames;
 			err = mlx4_en_set_cq_moder(priv, cq);
 			if (err)
 				en_err(priv, "Failed modifying moderation for cq:%d\n",
-- 
1.7.1
