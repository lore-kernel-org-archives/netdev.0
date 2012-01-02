From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next 1/2] mlx4_core: fix mtt range deallocation
Date: Mon, 2 Jan 2012 16:07:39 +0200
Message-ID: <4F01BA2B.1060605@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<marcela@dev.mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:43592 "HELO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752791Ab2ABQTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 11:19:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Apfelbaum <marcela@mellanox.co.il>

The mtt range was allocated in mtt units but deallocated
in segments. Among the rest, this caused crash during hotplug removal

Reported-by: Yinghai Lu <yinghai@kernel.org> 
Signed-off-by: Marcel Apfelbaum <marcela@mellanox.co.il>
Reviewed-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/mr.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
index f7243b2..01df556 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
@@ -239,8 +239,8 @@ void __mlx4_free_mtt_range(struct mlx4_dev *dev, u32 offset, int order)
 	first_seg = offset / (1 << log_mtts_per_seg);
 
 	mlx4_buddy_free(&mr_table->mtt_buddy, first_seg, seg_order);
-	mlx4_table_put_range(dev, &mr_table->mtt_table, first_seg,
-			     first_seg + (1 << seg_order) - 1);
+	mlx4_table_put_range(dev, &mr_table->mtt_table, offset,
+			     offset + (1 << order) - 1);
 }
 
 static void mlx4_free_mtt_range(struct mlx4_dev *dev, u32 offset, int order)
-- 
1.7.7
