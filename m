From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH] net/mlx4_en: allocate non 0-order pages for RX ring with
 __GFP_NOMEMALLOC
Date: Mon, 18 Apr 2016 14:33:54 +0300
Message-ID: <146097923460.15114.8965134124148581055.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, Yishai Hadas <yishaih@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

High order pages are optional here since commit 51151a16a60f ("mlx4: allow
order-0 memory allocations in RX path"), so here is no reason for depleting
reserves. Generic __netdev_alloc_frag() implements the same logic.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 86bcfe510e4e..56d070d9cf01 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -61,7 +61,7 @@ static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
 		gfp_t gfp = _gfp;
 
 		if (order)
-			gfp |= __GFP_COMP | __GFP_NOWARN;
+			gfp |= __GFP_COMP | __GFP_NOWARN | __GFP_NOMEMALLOC;
 		page = alloc_pages(gfp, order);
 		if (likely(page))
 			break;
