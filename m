From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 2/4] net/mlx4_core: Make explicit conversion to 64bit value
Date: Mon, 28 Aug 2017 16:38:21 +0300
Message-ID: <1503927503-29065-3-git-send-email-tariqt@mellanox.com>
References: <1503927503-29065-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38594 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751189AbdH1NjM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 09:39:12 -0400
In-Reply-To: <1503927503-29065-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

The "lg" variable is declared as int so in all places where this variable
is used as a shift operand, the output will be int too.

This produces the following smatch warning:
drivers/net/ethernet/mellanox/mlx4/fw.c:1532 mlx4_map_cmd() warn:
	should '1 << lg' be a 64 bit type?

Simple declaration of "1" to be "1ULL" will fix the issue.

Fixes: 225c7b1feef1 ("IB/mlx4: Add a driver Mellanox ConnectX InfiniBand adapters")
Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index f76cac01d564..10cfb058a9de 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -1534,7 +1534,7 @@ int mlx4_map_cmd(struct mlx4_dev *dev, u16 op, struct mlx4_icm *icm, u64 virt)
 		for (i = 0; i < mlx4_icm_size(&iter) >> lg; ++i) {
 			if (virt != -1) {
 				pages[nent * 2] = cpu_to_be64(virt);
-				virt += 1 << lg;
+				virt += 1ULL << lg;
 			}
 
 			pages[nent * 2 + 1] =
-- 
1.8.3.1
