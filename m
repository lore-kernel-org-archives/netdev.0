From: Zhiyi Sun <zhiyisun@gmail.com>
Subject: [PATCH] net/mlx4_en: Fix bpf_prog_add ref_cnt in mlx4
Date: Wed, 9 Nov 2016 15:35:44 +0800
Message-ID: <20161109073544.jbufjqn7y7oa6ptg@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zhiyisun@gmail.com
To: bblanco@plumgrid.com, Tariq Toukan <tariqt@mellanox.com>,
        Yishai Hadas <yishaih@mellanox.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are rx_ring_num queues. Each queue will load xdp prog. So
bpf_prog_add() should add rx_ring_num to ref_cnt.

Signed-off-by: Zhiyi Sun <zhiyisun@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 12c99a2..d25e150 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2650,7 +2650,7 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	 */
 	if (priv->xdp_ring_num == xdp_ring_num) {
 		if (prog) {
-			prog = bpf_prog_add(prog, priv->rx_ring_num - 1);
+			prog = bpf_prog_add(prog, priv->rx_ring_num);
 			if (IS_ERR(prog))
 				return PTR_ERR(prog);
 		}
@@ -2680,7 +2680,7 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	}
 
 	if (prog) {
-		prog = bpf_prog_add(prog, priv->rx_ring_num - 1);
+		prog = bpf_prog_add(prog, priv->rx_ring_num);
 		if (IS_ERR(prog))
 			return PTR_ERR(prog);
 	}
-- 
2.9.3
