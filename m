From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH] mlx4_en: Start port error flow bug fix
Date: Wed, 05 Nov 2008 16:53:50 +0200
Message-ID: <4911B37E.3020900@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	yevgenyp@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:43962 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751881AbYKEOzD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 09:55:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tried to deactivate rx ring that wasn't activated,
used wrong index.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 12d736a..96e709d 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -706,7 +706,7 @@ tx_err:
 	mlx4_en_release_rss_steer(priv);
 rx_err:
 	for (i = 0; i < priv->rx_ring_num; i++)
-		mlx4_en_deactivate_rx_ring(priv, &priv->rx_ring[rx_index]);
+		mlx4_en_deactivate_rx_ring(priv, &priv->rx_ring[i]);
 cq_err:
 	while (rx_index--)
 		mlx4_en_deactivate_cq(priv, &priv->rx_cq[rx_index]);
-- 
1.5.4




