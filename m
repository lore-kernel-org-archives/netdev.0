From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 3/9] net/mlx4_core: Set EQ affinity hint to local NUMA CPUs
Date: Mon, 16 Jan 2017 19:29:59 +0200
Message-ID: <1484587805-12666-4-git-send-email-tariqt@mellanox.com>
References: <1484587805-12666-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Daniel Jurgens <danielj@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43779 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751091AbdAPRah (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 12:30:37 -0500
In-Reply-To: <1484587805-12666-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Jurgens <danielj@mellanox.com>

Use CPUs on the close NUMA when setting the EQ affinity hints.

Signed-off-by: Daniel Jurgens <danielj@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 6efd66b0b822..058531bf7947 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2843,7 +2843,8 @@ static int mlx4_init_affinity_hint(struct mlx4_dev *dev, int port, int eqn)
 	if (!zalloc_cpumask_var(&eq->affinity_mask, GFP_KERNEL))
 		return -ENOMEM;
 
-	cpumask_set_cpu(requested_cpu, eq->affinity_mask);
+	cpumask_set_cpu(cpumask_local_spread(requested_cpu, dev->numa_node),
+			eq->affinity_mask);
 
 	return 0;
 }
-- 
1.8.3.1
