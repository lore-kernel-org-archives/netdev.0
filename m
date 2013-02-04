From: Amir Vadai <amirv@mellanox.com>
Subject: [PATH net-next v1 2/2] net/mlx4_en: Fix compilation error when CONFIG_INET isn't defined
Date: Mon,  4 Feb 2013 15:01:21 +0200
Message-ID: <1359982881-10139-3-git-send-email-amirv@mellanox.com>
References: <1359982881-10139-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:47059 "HELO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754478Ab3BDNBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 08:01:43 -0500
In-Reply-To: <1359982881-10139-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

ip_eth_mc_map function can't be used when CONFIG_INET isn't defined.
Fixed compilation error by adding CONFIG_INET define check before using the
function.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 3e993d5..f523f02 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -711,6 +711,7 @@ static int mlx4_en_ethtool_add_mac_rule_by_ipv4(struct mlx4_en_priv *priv,
 						struct mlx4_spec_list *spec_l2,
 						__be32 ipv4_dst)
 {
+#ifdef CONFIG_INET
 	__be64 be_mac = 0;
 	unsigned char mac[ETH_ALEN];
 
@@ -726,6 +727,9 @@ static int mlx4_en_ethtool_add_mac_rule_by_ipv4(struct mlx4_en_priv *priv,
 	}
 
 	return mlx4_en_ethtool_add_mac_rule(cmd, rule_list_h, spec_l2, &mac[0]);
+#else
+	return -EINVAL;
+#endif
 }
 
 static int add_ip_rule(struct mlx4_en_priv *priv,
-- 
1.7.8.2
