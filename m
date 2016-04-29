From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 7/9] mlx5e: Add support for UDP tunnel
 segmentation with outer checksum offload
Date: Fri, 29 Apr 2016 15:43:46 -0700
Message-ID: <20160429224345.12418.88876.stgit@ahduyck-xeon-server>
References: <20160429222735.12418.61229.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: talal@mellanox.com, netdev@vger.kernel.org,
	michael.chan@broadcom.com, davem@davemloft.net, galp@mellanox.com,
	ogerlitz@mellanox.com, eranbe@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36387 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752470AbcD2Wnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 18:43:47 -0400
Received: by mail-pf0-f179.google.com with SMTP id c189so54623650pfb.3
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 15:43:47 -0700 (PDT)
In-Reply-To: <20160429222735.12418.61229.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch assumes that the mlx5 hardware will ignore existing IPv4/v6
header fields for length and checksum as well as the length and checksum
fields for outer UDP headers.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 4ccfc1ac62c5..2d6aaad77d62 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2803,13 +2803,18 @@ static void mlx5e_build_netdev(struct net_device *netdev)
 	netdev->hw_features      |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	if (mlx5e_vxlan_allowed(mdev)) {
-		netdev->hw_features     |= NETIF_F_GSO_UDP_TUNNEL;
+		netdev->hw_features     |= NETIF_F_GSO_UDP_TUNNEL |
+					   NETIF_F_GSO_UDP_TUNNEL_CSUM |
+					   NETIF_F_GSO_PARTIAL;
 		netdev->hw_enc_features |= NETIF_F_IP_CSUM;
 		netdev->hw_enc_features |= NETIF_F_RXCSUM;
 		netdev->hw_enc_features |= NETIF_F_TSO;
 		netdev->hw_enc_features |= NETIF_F_TSO6;
 		netdev->hw_enc_features |= NETIF_F_RXHASH;
 		netdev->hw_enc_features |= NETIF_F_GSO_UDP_TUNNEL;
+		netdev->hw_enc_features |= NETIF_F_GSO_UDP_TUNNEL_CSUM |
+					   NETIF_F_GSO_PARTIAL;
+		netdev->gso_partial_features = NETIF_F_GSO_UDP_TUNNEL_CSUM;
 	}
 
 	mlx5_query_port_fcs(mdev, &fcs_supported, &fcs_enabled);
