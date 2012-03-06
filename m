From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next 6/8] net/mlx4: fixing sparse warnings for not declared,
 functions
Date: Tue, 6 Mar 2012 16:04:47 +0200
Message-ID: <4F56197F.1060403@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:55444 "HELO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1030359Ab2CFOEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 09:04:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

The SET_PORT functions are implemented in port.c, which is part
of mlx4_core, these functions are exported. The functions are in use by
the mlx4_en module (were originally part of mlx4_en).
Their declaration remained in mlx4_en module, moving the declaration to the right location.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    4 ----
 include/linux/mlx4/device.h                  |    5 ++++-
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 8f4e655..9e2b911 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -553,10 +553,6 @@ void mlx4_en_rx_irq(struct mlx4_cq *mcq);
 
 int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port, u64 mac, u64 clear, u8 mode);
 int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, struct mlx4_en_priv *priv);
-int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
-			  u8 pptx, u8 pfctx, u8 pprx, u8 pfcrx);
-int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
-			   u8 promisc);
 
 int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset);
 int mlx4_en_QUERY_PORT(struct mlx4_en_dev *mdev, u8 port);
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index aea6190..44d8144 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -622,7 +622,10 @@ int mlx4_replace_mac(struct mlx4_dev *dev, u8 port, int qpn, u64 new_mac);
 int mlx4_get_eth_qp(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn);
 void mlx4_put_eth_qp(struct mlx4_dev *dev, u8 port, u64 mac, int qpn);
 void mlx4_set_stats_bitmap(struct mlx4_dev *dev, u64 *stats_bitmap);
-
+int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
+			  u8 pptx, u8 pfctx, u8 pprx, u8 pfcrx);
+int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
+			   u8 promisc);
 int mlx4_find_cached_vlan(struct mlx4_dev *dev, u8 port, u16 vid, int *idx);
 int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index);
 void mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, int index);
-- 
1.7.7
