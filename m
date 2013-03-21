From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 4/5] net/mlx4_core: Always use 64 bit resource ID when doing lookup
Date: Thu, 21 Mar 2013 17:55:54 +0200
Message-ID: <1363881355-21137-5-git-send-email-ogerlitz@mellanox.com>
References: <1363881355-21137-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	jackm@dev.mellanox.co.il, hadarh@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:55039 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755953Ab3CUP4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 11:56:05 -0400
In-Reply-To: <1363881355-21137-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

One of the resource tracker code paths was wrongly using int and not u64
for resource tracking IDs, fix it.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 0d1d967..b0ccdb5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -355,7 +355,7 @@ static int mpt_mask(struct mlx4_dev *dev)
 	return dev->caps.num_mpts - 1;
 }
 
-static void *find_res(struct mlx4_dev *dev, int res_id,
+static void *find_res(struct mlx4_dev *dev, u64 res_id,
 		      enum mlx4_resource type)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
-- 
1.7.1
