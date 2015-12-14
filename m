From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH] net/mlx4_core: fix handling return value of
 mlx4_slave_convert_port
Date: Mon, 14 Dec 2015 11:05:58 +0100
Message-ID: <1450087564-28441-1-git-send-email-a.hajda@samsung.com>
Cc: Andrzej Hajda <a.hajda@samsung.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function can return negative values, so its result should
be assigned to signed variable.

The problem has been detected using proposed semantic patch
scripts/coccinelle/tests/assign_signed_to_unsigned.cocci [1].

[1]: http://permalink.gmane.org/gmane.linux.kernel/2046107

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index da7f578..b46dbe2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -4331,9 +4331,10 @@ int mlx4_QP_FLOW_STEERING_ATTACH_wrapper(struct mlx4_dev *dev, int slave,
 		return -EOPNOTSUPP;
 
 	ctrl = (struct mlx4_net_trans_rule_hw_ctrl *)inbox->buf;
-	ctrl->port = mlx4_slave_convert_port(dev, slave, ctrl->port);
-	if (ctrl->port <= 0)
+	err = mlx4_slave_convert_port(dev, slave, ctrl->port);
+	if (err <= 0)
 		return -EINVAL;
+	ctrl->port = err;
 	qpn = be32_to_cpu(ctrl->qpn) & 0xffffff;
 	err = get_res(dev, slave, qpn, RES_QP, &rqp);
 	if (err) {
-- 
1.9.1
