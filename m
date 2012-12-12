From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH V1 net-next 2/3] net/mlx4_en: Use generic etherdevice.h functions.
Date: Wed, 12 Dec 2012 14:13:18 +0200
Message-ID: <1355314400-14909-3-git-send-email-amirv@mellanox.com>
References: <1355314400-14909-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Yan Burman <yanb@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:35750 "HELO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751561Ab2LLMNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 07:13:37 -0500
In-Reply-To: <1355314400-14909-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yan Burman <yanb@mellanox.com>

Get rid of full_mac, zero_mac in favour of
is_zero_ether_addr and is_broadcast_ether_addr.

Signed-off-by: Yan Burman <yanb@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 4aaa7c3..cc7bb25 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -613,8 +613,6 @@ static int mlx4_en_validate_flow(struct net_device *dev,
 	struct ethtool_usrip4_spec *l3_mask;
 	struct ethtool_tcpip4_spec *l4_mask;
 	struct ethhdr *eth_mask;
-	u64 full_mac = ~0ull;
-	u64 zero_mac = 0;
 
 	if (cmd->fs.location >= MAX_NUM_OF_FS_RULES)
 		return -EINVAL;
@@ -644,11 +642,11 @@ static int mlx4_en_validate_flow(struct net_device *dev,
 	case ETHER_FLOW:
 		eth_mask = &cmd->fs.m_u.ether_spec;
 		/* source mac mask must not be set */
-		if (memcmp(eth_mask->h_source, &zero_mac, ETH_ALEN))
+		if (!is_zero_ether_addr(eth_mask->h_source))
 			return -EINVAL;
 
 		/* dest mac mask must be ff:ff:ff:ff:ff:ff */
-		if (memcmp(eth_mask->h_dest, &full_mac, ETH_ALEN))
+		if (!is_broadcast_ether_addr(eth_mask->h_dest))
 			return -EINVAL;
 
 		if (!all_zeros_or_all_ones(eth_mask->h_proto))
-- 
1.7.11.3
