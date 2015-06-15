From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 09/13] IB/mlx4: Set VF to read from QP counters
Date: Mon, 15 Jun 2015 17:59:04 +0300
Message-ID: <1434380348-19005-10-git-send-email-ogerlitz@mellanox.com>
References: <1434380348-19005-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:44982 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755898AbbFOO7r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 10:59:47 -0400
In-Reply-To: <1434380348-19005-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

As IB VFs are not capable to read the port counters through MADs,
move there to read their own QP counters to gather statistics.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/mad.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/mad.c b/drivers/infiniband/hw/mlx4/mad.c
index 74ca13f..bc698b1 100644
--- a/drivers/infiniband/hw/mlx4/mad.c
+++ b/drivers/infiniband/hw/mlx4/mad.c
@@ -869,10 +869,12 @@ int mlx4_ib_process_mad(struct ib_device *ibdev, int mad_flags, u8 port_num,
 			struct ib_wc *in_wc, struct ib_grh *in_grh,
 			struct ib_mad *in_mad, struct ib_mad *out_mad)
 {
+	struct mlx4_ib_dev *dev = to_mdev(ibdev);
 	switch (rdma_port_get_link_layer(ibdev, port_num)) {
 	case IB_LINK_LAYER_INFINIBAND:
-		return ib_process_mad(ibdev, mad_flags, port_num, in_wc,
-				      in_grh, in_mad, out_mad);
+		if (!mlx4_is_slave(dev->dev))
+			return ib_process_mad(ibdev, mad_flags, port_num, in_wc,
+					      in_grh, in_mad, out_mad);
 	case IB_LINK_LAYER_ETHERNET:
 		return iboe_process_mad(ibdev, mad_flags, port_num, in_wc,
 					  in_grh, in_mad, out_mad);
-- 
1.7.1
