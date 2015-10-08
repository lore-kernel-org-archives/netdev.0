From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 7/7] net/mlx4_core: Fix resource tracker error flow in add_res_range
Date: Thu,  8 Oct 2015 17:14:03 +0300
Message-ID: <1444313643-15284-8-git-send-email-ogerlitz@mellanox.com>
References: <1444313643-15284-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eli Cohen <eli@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:45255 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932192AbbJHOOb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 10:14:31 -0400
In-Reply-To: <1444313643-15284-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

The 'for' loop when undoing rb-tree insertions and list-adds in the
error flow in add_res_range had errors, fix them.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 731423c..ac4b99a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -1238,8 +1238,10 @@ static int add_res_range(struct mlx4_dev *dev, int slave, u64 base, int count,
 	return 0;
 
 undo:
-	for (--i; i >= base; --i)
+	for (--i; i >= 0; --i) {
 		rb_erase(&res_arr[i]->node, root);
+		list_del_init(&res_arr[i]->list);
+	}
 
 	spin_unlock_irq(mlx4_tlock(dev));
 
-- 
2.3.7
