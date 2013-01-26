From: Joe Perches <joe@perches.com>
Subject: [PATCH] gro: Fix kcalloc argument order
Date: Sat, 26 Jan 2013 11:24:19 -0800
Message-ID: <1359228259.2079.30.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

First number, then size.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/gro_cells.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/gro_cells.h b/include/net/gro_cells.h
index e5062c9..734d9b5 100644
--- a/include/net/gro_cells.h
+++ b/include/net/gro_cells.h
@@ -73,8 +73,8 @@ static inline int gro_cells_init(struct gro_cells *gcells, struct net_device *de
 	int i;
 
 	gcells->gro_cells_mask = roundup_pow_of_two(netif_get_num_default_rss_queues()) - 1;
-	gcells->cells = kcalloc(sizeof(struct gro_cell),
-				gcells->gro_cells_mask + 1,
+	gcells->cells = kcalloc(gcells->gro_cells_mask + 1,
+				sizeof(struct gro_cell),
 				GFP_KERNEL);
 	if (!gcells->cells)
 		return -ENOMEM;
