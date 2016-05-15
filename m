From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net] net/mlx4_core: Fix access to uninitialized index
Date: Sun, 15 May 2016 10:21:26 +0300
Message-ID: <1463296886-4364-1-git-send-email-tariqt@mellanox.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36001 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752082AbcEOHWX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 03:22:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prevent using uninitialized or negative index when handling
steering entries.

Fixes: b12d93d63c32 ('mlx4: Add support for promiscuous mode in the new steering model.')
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 drivers/net/ethernet/mellanox/mlx4/mcg.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 6aa7397..f2d0920 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -1102,7 +1102,7 @@ int mlx4_qp_attach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	struct mlx4_cmd_mailbox *mailbox;
 	struct mlx4_mgm *mgm;
 	u32 members_count;
-	int index, prev;
+	int index = -1, prev;
 	int link = 0;
 	int i;
 	int err;
@@ -1181,7 +1181,7 @@ int mlx4_qp_attach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 		goto out;
 
 out:
-	if (prot == MLX4_PROT_ETH) {
+	if (prot == MLX4_PROT_ETH && index != -1) {
 		/* manage the steering entry for promisc mode */
 		if (new_entry)
 			err = new_steering_entry(dev, port, steer,
-- 
1.8.3.1
