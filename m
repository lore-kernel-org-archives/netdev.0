From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 7/8] mlx5e: Add support for UDP tunnel segmentation
 with outer checksum offload
Date: Mon, 25 Apr 2016 11:31:39 -0700
Message-ID: <20160425183139.11331.75627.stgit@ahduyck-xeon-server>
References: <20160425182442.11331.88349.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: talal@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
	galp@mellanox.com, ogerlitz@mellanox.com, eranbe@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36506 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933271AbcDYSbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 14:31:46 -0400
Received: by mail-pa0-f51.google.com with SMTP id bt5so14110193pac.3
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 11:31:40 -0700 (PDT)
In-Reply-To: <20160425182442.11331.88349.stgit@ahduyck-xeon-server>
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
index d485d1e4e100..a687d6624c8e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2580,13 +2580,18 @@ static void mlx5e_build_netdev(struct net_device *netdev)
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
 
 	netdev->features          = netdev->hw_features;
