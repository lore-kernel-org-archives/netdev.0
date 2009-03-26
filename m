From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 6/6] mlx4_en: use NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM for
 tx csum at initialization
Date: Thu, 26 Mar 2009 15:59:51 +0200
Message-ID: <49CB8A57.8050507@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:53479 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757303AbZCZOAy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 10:00:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The former usage was to set the NETIF_F_HW_CSUM flag which is not used
in get_tx_csum. It caused Ethtool to show tx checksum as "on" even
though it was turned off in previous operation.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index f52e897..0909a0c 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -1056,7 +1056,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	 * Set driver features
 	 */
 	dev->features |= NETIF_F_SG;
-	dev->features |= NETIF_F_HW_CSUM;
+	dev->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 	dev->features |= NETIF_F_HIGHDMA;
 	dev->features |= NETIF_F_HW_VLAN_TX |
 			 NETIF_F_HW_VLAN_RX |
-- 
1.6.1.3

