From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net V2 2/5] net/mlx5e: Fix ethtool pause support and advertise reporting
Date: Sun, 14 May 2017 13:43:08 +0300
Message-ID: <20170514104311.2081-3-saeedm@mellanox.com>
References: <20170514104311.2081-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        kernel-team@fb.com, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48616 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750877AbdENKnZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 14 May 2017 06:43:25 -0400
In-Reply-To: <20170514104311.2081-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Pause bit should set when RX pause is on, not TX pause.
Also, setting Asym_Pause is incorrect, and should be turned off.

Fixes: 665bc53969d7 ("net/mlx5e: Use new ethtool get/set link ksettings API")
Signed-off-by: Gal Pressman <galp@mellanox.com>
Cc: kernel-team@fb.com
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index d60e681b443e..8209affa75c3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -794,7 +794,6 @@ static void get_supported(u32 eth_proto_cap,
 	ptys2ethtool_supported_port(link_ksettings, eth_proto_cap);
 	ptys2ethtool_supported_link(supported, eth_proto_cap);
 	ethtool_link_ksettings_add_link_mode(link_ksettings, supported, Pause);
-	ethtool_link_ksettings_add_link_mode(link_ksettings, supported, Asym_Pause);
 }
 
 static void get_advertising(u32 eth_proto_cap, u8 tx_pause,
@@ -804,7 +803,7 @@ static void get_advertising(u32 eth_proto_cap, u8 tx_pause,
 	unsigned long *advertising = link_ksettings->link_modes.advertising;
 
 	ptys2ethtool_adver_link(advertising, eth_proto_cap);
-	if (tx_pause)
+	if (rx_pause)
 		ethtool_link_ksettings_add_link_mode(link_ksettings, advertising, Pause);
 	if (tx_pause ^ rx_pause)
 		ethtool_link_ksettings_add_link_mode(link_ksettings, advertising, Asym_Pause);
-- 
2.11.0
