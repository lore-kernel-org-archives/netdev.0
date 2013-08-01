From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/2] net/mlx4_core: VFs must ignore the enable_64b_cqe_eqe module param
Date: Thu,  1 Aug 2013 19:55:01 +0300
Message-ID: <1375376101-20435-3-git-send-email-ogerlitz@mellanox.com>
References: <1375376101-20435-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:54551 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755792Ab3HAQyb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 12:54:31 -0400
In-Reply-To: <1375376101-20435-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Slaves get the 64B CQE/EQE state from QUERY_HCA, not from the module parameter.

If the parameter is set to zero, the slave outputs an incorrect/irrelevant
warning message that 64B CQEs/EQEs are supported but not enabled (even if the
hypervisor has enabled 64B CQEs/EQEs).

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index e85af92..36be320 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -371,7 +371,7 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 
 	dev->caps.sqp_demux = (mlx4_is_master(dev)) ? MLX4_MAX_NUM_SLAVES : 0;
 
-	if (!enable_64b_cqe_eqe) {
+	if (!enable_64b_cqe_eqe && !mlx4_is_slave(dev)) {
 		if (dev_cap->flags &
 		    (MLX4_DEV_CAP_FLAG_64B_CQE | MLX4_DEV_CAP_FLAG_64B_EQE)) {
 			mlx4_warn(dev, "64B EQEs/CQEs supported by the device but not enabled\n");
-- 
1.7.1
