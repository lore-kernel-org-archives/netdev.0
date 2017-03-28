From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 1/1] net/mlx5: Avoid dereferencing uninitialized pointer
Date: Tue, 28 Mar 2017 16:13:41 +0300
Message-ID: <20170328131341.11601-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Talat Batheesh <talatb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46366 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753569AbdC1NZd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 09:25:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Talat Batheesh <talatb@mellanox.com>

In NETDEV_CHANGEUPPER event the upper_info field is valid
only when linking is true. Otherwise it should be ignored.

Fixes: 7907f23adc18 (net/mlx5: Implement RoCE LAG feature)
Signed-off-by: Talat Batheesh <talatb@mellanox.com>
Reviewed-by: Aviv Heller <avivh@mellanox.com>
Reviewed-by: Moni Shoua <monis@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---

Hi Dave,

I will appreciate it if you queue up this patch for v4.9-stable.

Thanks in advance,
Saeed.

 drivers/net/ethernet/mellanox/mlx5/core/lag.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/lag.c b/drivers/net/ethernet/mellanox/mlx5/core/lag.c
index 55957246c0e8..b5d5519542e8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/lag.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/lag.c
@@ -294,7 +294,7 @@ static int mlx5_handle_changeupper_event(struct mlx5_lag *ldev,
 					 struct netdev_notifier_changeupper_info *info)
 {
 	struct net_device *upper = info->upper_dev, *ndev_tmp;
-	struct netdev_lag_upper_info *lag_upper_info;
+	struct netdev_lag_upper_info *lag_upper_info = NULL;
 	bool is_bonded;
 	int bond_status = 0;
 	int num_slaves = 0;
@@ -303,7 +303,8 @@ static int mlx5_handle_changeupper_event(struct mlx5_lag *ldev,
 	if (!netif_is_lag_master(upper))
 		return 0;
 
-	lag_upper_info = info->upper_info;
+	if (info->linking)
+		lag_upper_info = info->upper_info;
 
 	/* The event may still be of interest if the slave does not belong to
 	 * us, but is enslaved to a master which has one or more of our netdevs
-- 
2.11.0
