From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 4/5] mlx4_en: use NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM for
 tx csum at initialization
Date: Mon, 20 Apr 2009 17:33:15 +0300
Message-ID: <49EC87AB.1070009@mellanox.co.il>
References: <49EC859C.700@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:39854 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755652AbZDTOeS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 10:34:18 -0400
In-Reply-To: <49EC859C.700@mellanox.co.il>
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
index 09fb7cf..438678a 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -1057,7 +1057,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	 * Set driver features
 	 */
 	dev->features |= NETIF_F_SG;
-	dev->features |= NETIF_F_HW_CSUM;
+	dev->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 	dev->features |= NETIF_F_HIGHDMA;
 	dev->features |= NETIF_F_HW_VLAN_TX |
 			 NETIF_F_HW_VLAN_RX |
-- 
1.5.4


