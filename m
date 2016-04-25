From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 8/8] mlx5e: Fix IPv6 tunnel checksum offload
Date: Mon, 25 Apr 2016 11:31:45 -0700
Message-ID: <20160425183145.11331.26545.stgit@ahduyck-xeon-server>
References: <20160425182442.11331.88349.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: talal@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
	galp@mellanox.com, ogerlitz@mellanox.com, eranbe@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35617 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933389AbcDYSbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 14:31:47 -0400
Received: by mail-pf0-f178.google.com with SMTP id n1so71835840pfn.2
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 11:31:46 -0700 (PDT)
In-Reply-To: <20160425182442.11331.88349.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mlx5 driver exposes support for TSO6 but not IPv6 csum for hardware
encapsulated tunnels.  This leads to issues as it triggers warnings in
skb_checksum_help as it ends up being called as we report supporting the
segmentation but not the checksumming for IPv6 frames.

This patch corrects that and drops 2 features that don't actually need to
be supported in hw_enc_features since they are Rx features and don't
actually impact anything by being present in hw_enc_features.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index a687d6624c8e..4728abd46cb2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2584,10 +2584,9 @@ static void mlx5e_build_netdev(struct net_device *netdev)
 					   NETIF_F_GSO_UDP_TUNNEL_CSUM |
 					   NETIF_F_GSO_PARTIAL;
 		netdev->hw_enc_features |= NETIF_F_IP_CSUM;
-		netdev->hw_enc_features |= NETIF_F_RXCSUM;
+		netdev->hw_enc_features |= NETIF_F_IPV6_CSUM;
 		netdev->hw_enc_features |= NETIF_F_TSO;
 		netdev->hw_enc_features |= NETIF_F_TSO6;
-		netdev->hw_enc_features |= NETIF_F_RXHASH;
 		netdev->hw_enc_features |= NETIF_F_GSO_UDP_TUNNEL;
 		netdev->hw_enc_features |= NETIF_F_GSO_UDP_TUNNEL_CSUM |
 					   NETIF_F_GSO_PARTIAL;
