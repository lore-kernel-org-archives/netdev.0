From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next V2 1/5] net/mlx4_core: Fix QUERY FUNC CAP flags
Date: Mon, 25 Jul 2016 14:15:32 +0300
Message-ID: <1469445336-21952-2-git-send-email-tariqt@mellanox.com>
References: <1469445336-21952-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Moshe Shemesh <moshe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36447 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751139AbcGYLPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 07:15:55 -0400
In-Reply-To: <1469445336-21952-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moshe Shemesh <moshe@mellanox.com>

Separate QUERY_FUNC_CAP flags0 from QUERY_FUNC_CAP flags, as 'flags' is
already used for another set of flags in FUNC CAP, while phv bit should be
part of a different set of flags.
Remove QUERY_FUNC_CAP port_flags field, as it is not in use.

Fixes: 77fc29c4bbbb ('net/mlx4_core: Preparations for 802.1ad VLAN support')
Fixes: 5cc914f10851 ('mlx4_core: Added FW commands and their wrappers for supporting SRIOV')
Signed-off-by: Moshe Shemesh <moshe@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 5 ++---
 drivers/net/ethernet/mellanox/mlx4/fw.h | 2 +-
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index f4497cf4d06d..355f05ec3a2c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -612,8 +612,7 @@ int mlx4_QUERY_FUNC_CAP(struct mlx4_dev *dev, u8 gen_or_port,
 		MLX4_GET(func_cap->phys_port_id, outbox,
 			 QUERY_FUNC_CAP_PHYS_PORT_ID);
 
-	MLX4_GET(field, outbox, QUERY_FUNC_CAP_FLAGS0_OFFSET);
-	func_cap->flags |= (field & QUERY_FUNC_CAP_PHV_BIT);
+	MLX4_GET(func_cap->flags0, outbox, QUERY_FUNC_CAP_FLAGS0_OFFSET);
 
 	/* All other resources are allocated by the master, but we still report
 	 * 'num' and 'reserved' capabilities as follows:
@@ -2874,7 +2873,7 @@ int get_phv_bit(struct mlx4_dev *dev, u8 port, int *phv)
 	memset(&func_cap, 0, sizeof(func_cap));
 	err = mlx4_QUERY_FUNC_CAP(dev, port, &func_cap);
 	if (!err)
-		*phv = func_cap.flags & QUERY_FUNC_CAP_PHV_BIT;
+		*phv = func_cap.flags0 & QUERY_FUNC_CAP_PHV_BIT;
 	return err;
 }
 EXPORT_SYMBOL(get_phv_bit);
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index cdbd76f10ced..f11614f12517 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -152,7 +152,7 @@ struct mlx4_func_cap {
 	u32	qp1_proxy_qpn;
 	u32	reserved_lkey;
 	u8	physical_port;
-	u8	port_flags;
+	u8	flags0;
 	u8	flags1;
 	u64	phys_port_id;
 	u32	extra_flags;
-- 
1.8.3.1
