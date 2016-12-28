From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 05/12] net/mlx5: Mask destination mac value in ethtool steering rules
Date: Wed, 28 Dec 2016 14:58:35 +0200
Message-ID: <1482929922-32626-6-git-send-email-saeedm@mellanox.com>
References: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Maor Gottlieb <maorg@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32809 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751627AbcL1M66 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 07:58:58 -0500
In-Reply-To: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

We need to mask the destination mac value with the destination mac
mask when adding steering rule via ethtool.

Fixes: 1174fce8d1410 ('net/mlx5e: Support l3/l4 flow type specs in ethtool flow steering')
Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
index 3691451..d088eff 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
@@ -247,6 +247,7 @@ static int set_flow_attrs(u32 *match_c, u32 *match_v,
 	}
 	if (fs->flow_type & FLOW_MAC_EXT &&
 	    !is_zero_ether_addr(fs->m_ext.h_dest)) {
+		mask_spec(fs->m_ext.h_dest, fs->h_ext.h_dest, ETH_ALEN);
 		ether_addr_copy(MLX5_ADDR_OF(fte_match_set_lyr_2_4,
 					     outer_headers_c, dmac_47_16),
 				fs->m_ext.h_dest);
-- 
2.7.4
