From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] net/mlx4_en: Don't configure the HW vxlan parser when vxlan offloading isn't set
Date: Wed,  2 Jul 2014 17:36:23 +0300
Message-ID: <1404311783-7963-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:57147 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753499AbaGBOg3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2014 10:36:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The add_vxlan_port ndo driver code was wrongly testing whether HW vxlan offloads
are supported by the device instead of checking if they are currently enabled.

This causes the driver to configure the HW parser to conduct matching for vxlan
packets but since no steering rules were set, vxlan packets are dropped on RX.

Fix that by doing the right test, as done in the del_vxlan_port ndo handler.

Fixes: 1b136de ('net/mlx4: Implement vxlan ndo calls')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---

Hi Dave,

This fixes a bug from 3.15-rc1, can you please push to 3.15.y too?

thanks,

Or.

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 7d4fb7b..e94d96f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2336,7 +2336,7 @@ static void mlx4_en_add_vxlan_port(struct  net_device *dev,
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	__be16 current_port;
 
-	if (!(priv->mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_VXLAN_OFFLOADS))
+	if (priv->mdev->dev->caps.tunnel_offload_mode != MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
 		return;
 
 	if (sa_family == AF_INET6)
-- 
1.7.1
