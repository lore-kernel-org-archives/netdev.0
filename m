From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] net/mlx4_en: Deregister multicast vxlan steering rules when going down
Date: Thu, 13 Mar 2014 14:52:15 +0200
Message-ID: <1394715135-18791-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:42400 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750994AbaCMMwU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Mar 2014 08:52:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When mlx4_en_stop_port() is called, we need to deregister also the
tunnel steering rules that relate to multicast.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---

Dave - this is a small fix which is addition to yesterday's set. 

While on that, I noted that there are places where we do check for the 
return value of mlx4_flow_detach() and print something, while in other places
we don't. I will work on net-next patch that makes it consistent all across 
the place by setting that to void, as we should be OK with the warning 
which exists within mlx4_flow_detach()

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index ba21261..84a96f7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1800,6 +1800,8 @@ void mlx4_en_stop_port(struct net_device *dev, int detach)
 		mc_list[5] = priv->port;
 		mlx4_multicast_detach(mdev->dev, &priv->rss_map.indir_qp,
 				      mc_list, MLX4_PROT_ETH, mclist->reg_id);
+		if (mclist->tunnel_reg_id)
+			mlx4_flow_detach(mdev->dev, mclist->tunnel_reg_id);
 	}
 	mlx4_en_clear_list(dev);
 	list_for_each_entry_safe(mclist, tmp, &priv->curr_list, list) {
-- 
1.7.1
