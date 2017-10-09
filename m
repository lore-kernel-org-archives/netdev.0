From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 3/3] net/mlx4_en: Use __force to fix a sparse warning in TX datapath
Date: Mon,  9 Oct 2017 16:59:50 +0300
Message-ID: <1507557590-17747-4-git-send-email-tariqt@mellanox.com>
References: <1507557590-17747-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:33680 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755140AbdJIOAE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 10:00:04 -0400
In-Reply-To: <1507557590-17747-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In TX data-path, we intentionally do not byte-swap, as documented
in code and in the cited commit log.
This fixes sparse warning:
en_tx.c:720:23: warning: incorrect type in argument 1 (different base types)
en_tx.c:720:23:    expected unsigned int [unsigned] [usertype] <noident>
en_tx.c:720:23:    got restricted __be32 [usertype] doorbell_qpn

Fixes: 492f5add4be8 ("net/mlx4_en: Doorbell is byteswapped in Little Endian archs")
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 8a32a8f7f9c0..2cc82dc07397 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -718,7 +718,7 @@ void mlx4_en_xmit_doorbell(struct mlx4_en_tx_ring *ring)
 #else
 	iowrite32be(
 #endif
-		  ring->doorbell_qpn,
+		  (__force u32)ring->doorbell_qpn,
 		  ring->bf.uar->map + MLX4_SEND_DOORBELL);
 }
 
-- 
1.8.3.1
