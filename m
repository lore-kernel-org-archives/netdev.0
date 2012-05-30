From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: [PATCH net 1/6] net/mlx4_core: Fix the slave_id out-of-range test in mlx4_eq_int
Date: Wed, 30 May 2012 22:19:56 +0300
Message-ID: <1338405596-16012-1-git-send-email-yevgenyp@mellanox.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:42166 "HELO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750931Ab2E3TUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 15:20:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Ths fixes the comparison in the FLR (Function Level Reset) event case.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/eq.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 3b6f8ef..bce98d9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -426,7 +426,7 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 
 			mlx4_dbg(dev, "FLR event for slave: %d\n", flr_slave);
 
-			if (flr_slave > dev->num_slaves) {
+			if (flr_slave >= dev->num_slaves) {
 				mlx4_warn(dev,
 					  "Got FLR for unknown function: %d\n",
 					  flr_slave);
-- 
1.7.1
