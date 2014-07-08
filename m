From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 3/6] net/mlx4: Verify port number in __mlx4_unregister_mac
Date: Tue,  8 Jul 2014 11:25:21 +0300
Message-ID: <1404807924-29038-4-git-send-email-amirv@mellanox.com>
References: <1404807924-29038-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Eli Cohen <eli@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:47655 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753322AbaGHI00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2014 04:26:26 -0400
In-Reply-To: <1404807924-29038-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Verify port number to avoid crashes if port number is outside the range.


Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/port.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 5d76a60..9ba0c1c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -244,10 +244,16 @@ EXPORT_SYMBOL_GPL(mlx4_get_base_qpn);
 
 void __mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, u64 mac)
 {
-	struct mlx4_port_info *info = &mlx4_priv(dev)->port[port];
-	struct mlx4_mac_table *table = &info->mac_table;
+	struct mlx4_port_info *info;
+	struct mlx4_mac_table *table;
 	int index;
 
+	if (port < 1 || port > dev->caps.num_ports) {
+		mlx4_warn(dev, "invalid port number (%d), aborting...\n", port);
+		return;
+	}
+	info = &mlx4_priv(dev)->port[port];
+	table = &info->mac_table;
 	mutex_lock(&table->mutex);
 	index = find_index(dev, table, mac);
 
-- 
1.8.3.4
