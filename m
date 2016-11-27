From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 2/2] net/mlx4: Fix uninitialized fields in rule when adding promiscuous mode to device managed flow steering
Date: Sun, 27 Nov 2016 19:20:52 +0200
Message-ID: <1480267252-26146-3-git-send-email-tariqt@mellanox.com>
References: <1480267252-26146-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Sebastian Ott <sebott@linux.vnet.ibm.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34731 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751872AbcK0RVN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 12:21:13 -0500
In-Reply-To: <1480267252-26146-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

In procedure mlx4_flow_steer_promisc_add(), several fields
were left uninitialized in the rule structure.
Correctly initialize these fields.

Fixes: 592e49dda812 ("net/mlx4: Implement promiscuous mode with device managed flow-steering")
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mcg.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 94b891c118c1..1a670b681555 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -1457,7 +1457,12 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 int mlx4_flow_steer_promisc_add(struct mlx4_dev *dev, u8 port,
 				u32 qpn, enum mlx4_net_trans_promisc_mode mode)
 {
-	struct mlx4_net_trans_rule rule;
+	struct mlx4_net_trans_rule rule = {
+		.queue_mode = MLX4_NET_TRANS_Q_FIFO,
+		.exclusive = 0,
+		.allow_loopback = 1,
+	};
+
 	u64 *regid_p;
 
 	switch (mode) {
-- 
1.8.3.1
