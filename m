From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 7/7] net/mlx5e: Initialize CEE's getpermhwaddr address buffer to 0xff
Date: Sun,  9 Jul 2017 15:49:17 +0300
Message-ID: <20170709124917.12852-8-saeedm@mellanox.com>
References: <20170709124917.12852-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Huy Nguyen <huyn@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36241 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752156AbdGIMuH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2017 08:50:07 -0400
In-Reply-To: <20170709124917.12852-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

Latest change in open-lldp code uses bytes 6-11 of perm_addr buffer
as the Ethernet source address for the host TLV packet.
Since our driver does not fill these bytes, they stay at zero and
the open-lldp code ends up sending the TLV packet with zero source
address and the switch drops this packet.

The fix is to initialize these bytes to 0xff. The open-lldp code
considers 0xff:ff:ff:ff:ff:ff as the invalid address and falls back to
use the host's mac address as the Ethernet source address.

Fixes: 3a6a931dfb8e ("net/mlx5e: Support DCBX CEE API")
Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Reviewed-by: Daniel Jurgens <danielj@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
index 8fa23f6a1f67..2eb54d36e16e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
@@ -464,6 +464,8 @@ static void mlx5e_dcbnl_getpermhwaddr(struct net_device *netdev,
 	if (!perm_addr)
 		return;
 
+	memset(perm_addr, 0xff, MAX_ADDR_LEN);
+
 	mlx5_query_nic_vport_mac_address(priv->mdev, 0, perm_addr);
 }
 
-- 
2.11.0
