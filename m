From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next 1/3] net/mlx5e: use %pad format string for dma_addr_t
Date: Thu,  8 Dec 2016 22:57:03 +0100
Message-ID: <20161208215727.44841-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Jurgens <danielj@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 32-bit ARM with 64-bit dma_addr_t I get this warning about an
incorrect format string:

In file included from /git/arm-soc/drivers/net/ethernet/mellanox/mlx5/core/alloc.c:42:0:
drivers/net/ethernet/mellanox/mlx5/core/alloc.c: In function ‘mlx5_frag_buf_alloc_node’:
drivers/net/ethernet/mellanox/mlx5/core/alloc.c:134:12: error: cast to pointer from integer of different size [-Werror=int-to-pointer-cast]

We have the special %pad format for printing dma_addr_t, so use that
to print the correct address and avoid the warning.

Fixes: 1c1b522808a1 ("net/mlx5e: Implement Fragmented Work Queue (WQ)")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/mellanox/mlx5/core/alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
index 44791de5afe6..66bd213f35ce 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
@@ -130,8 +130,8 @@ int mlx5_frag_buf_alloc_node(struct mlx5_core_dev *dev, int size,
 		if (frag->map & ((1 << buf->page_shift) - 1)) {
 			dma_free_coherent(&dev->pdev->dev, frag_sz,
 					  buf->frags[i].buf, buf->frags[i].map);
-			mlx5_core_warn(dev, "unexpected map alignment: 0x%p, page_shift=%d\n",
-				       (void *)frag->map, buf->page_shift);
+			mlx5_core_warn(dev, "unexpected map alignment: %pad, page_shift=%d\n",
+				       &frag->map, buf->page_shift);
 			goto err_free_buf;
 		}
 		size -= frag_sz;
-- 
2.9.0
