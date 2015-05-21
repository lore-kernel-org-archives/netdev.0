From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 4/6] net/mlx4_core: Adjust the schedule queue port for single ported IB VFs
Date: Thu, 21 May 2015 15:14:08 +0300
Message-ID: <1432210450-23408-5-git-send-email-ogerlitz@mellanox.com>
References: <1432210450-23408-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:56582 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755429AbbEUMOu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 08:14:50 -0400
In-Reply-To: <1432210450-23408-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some VF drivers flow set the schedule queue in the QP context but
without setting none of OPTPAR_SCHED_QUEUE or OPTPAR_PRIMARY_ADDR_PATH.

To allow for such non-modified drivers to function as single ported
IB VFs, we must adjust the schedule queue port whenever being set,
e.g as currently done for single ported Eth VFs.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 92fce1b..5e2ea03 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -3526,8 +3526,8 @@ static int adjust_qp_sched_queue(struct mlx4_dev *dev, int slave,
 	pri_sched_queue = (qpc->pri_path.sched_queue & ~(1 << 6)) |
 			  ((port & 1) << 6);
 
-	if (optpar & MLX4_QP_OPTPAR_PRIMARY_ADDR_PATH ||
-	    mlx4_is_eth(dev, port + 1)) {
+	if (optpar & (MLX4_QP_OPTPAR_PRIMARY_ADDR_PATH | MLX4_QP_OPTPAR_SCHED_QUEUE) ||
+	    qpc->pri_path.sched_queue || mlx4_is_eth(dev, port + 1)) {
 		qpc->pri_path.sched_queue = pri_sched_queue;
 	}
 
-- 
1.7.1
