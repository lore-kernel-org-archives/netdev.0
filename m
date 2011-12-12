From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next V1 13/21] mlx4_ib: disable SRIOV mode for IB ports
 (not yet supported)
Date: Mon, 12 Dec 2011 16:45:17 +0200
Message-ID: <4EE6137D.4090800@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<roland@purestorage.com>, <yevgenyp@mellanox.co.il>,
	<liranl@mellanox.co.il>, <jackm@dev.mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:37234 "HELO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753468Ab1LLQul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 11:50:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
---
 drivers/infiniband/hw/mlx4/main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 34f8a5d..b8279de 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1075,6 +1075,11 @@ static void *mlx4_ib_add(struct mlx4_dev *dev)
 
 	printk_once(KERN_INFO "%s", mlx4_ib_version);
 
+	if (mlx4_is_mfunc(dev)) {
+		printk(KERN_WARNING "IB not yet supported in SRIOV\n");
+		return NULL;
+	}
+
 	mlx4_foreach_ib_transport_port(i, dev)
 		num_ports++;
 
-- 
1.7.7
