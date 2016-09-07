From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 3/5] net/mlx5e: Prevent casting overflow
Date: Wed,  7 Sep 2016 19:07:59 +0300
Message-ID: <1473264481-20392-4-git-send-email-saeedm@mellanox.com>
References: <1473264481-20392-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:58431 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752752AbcIGQIg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 12:08:36 -0400
In-Reply-To: <1473264481-20392-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

On 64 bits architectures unsigned long is longer than u32,
casting to unsigned long will result in overflow.
We need to first allocate an unsigned long variable, then assign the
wanted value.

Fixes: 665bc53969d7 ('net/mlx5e: Use new ethtool get/set link ksettings API')
Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index d0cf8fa..98e1a4a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -659,9 +659,10 @@ out:
 static void ptys2ethtool_supported_link(unsigned long *supported_modes,
 					u32 eth_proto_cap)
 {
+	unsigned long proto_cap = eth_proto_cap;
 	int proto;
 
-	for_each_set_bit(proto, (unsigned long *)&eth_proto_cap, MLX5E_LINK_MODES_NUMBER)
+	for_each_set_bit(proto, &proto_cap, MLX5E_LINK_MODES_NUMBER)
 		bitmap_or(supported_modes, supported_modes,
 			  ptys2ethtool_table[proto].supported,
 			  __ETHTOOL_LINK_MODE_MASK_NBITS);
@@ -670,9 +671,10 @@ static void ptys2ethtool_supported_link(unsigned long *supported_modes,
 static void ptys2ethtool_adver_link(unsigned long *advertising_modes,
 				    u32 eth_proto_cap)
 {
+	unsigned long proto_cap = eth_proto_cap;
 	int proto;
 
-	for_each_set_bit(proto, (unsigned long *)&eth_proto_cap, MLX5E_LINK_MODES_NUMBER)
+	for_each_set_bit(proto, &proto_cap, MLX5E_LINK_MODES_NUMBER)
 		bitmap_or(advertising_modes, advertising_modes,
 			  ptys2ethtool_table[proto].advertised,
 			  __ETHTOOL_LINK_MODE_MASK_NBITS);
-- 
2.7.4
