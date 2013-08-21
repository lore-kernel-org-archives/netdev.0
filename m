From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V2 2/5] net/mlx4_en: Disable global flow control when PFC enabled
Date: Wed, 21 Aug 2013 10:08:56 +0300
Message-ID: <1377068939-17561-3-git-send-email-amirv@mellanox.com>
References: <1377068939-17561-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40004 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752526Ab3HUHJQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Aug 2013 03:09:16 -0400
In-Reply-To: <1377068939-17561-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Fix a bug when FC and PFC are enabled/disabled at the same time.
According to ConnectX-3 Programmer Manual these two features are mutial
exclusive.  So make sure when enabling PFC to turn off global FC and
vise versa.  Otherwise it hurts the performance.


Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index f71fba9..b4881b6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -170,8 +170,8 @@ static int mlx4_en_dcbnl_ieee_setpfc(struct net_device *dev,
 			pfc->mbc,
 			pfc->delay);
 
-	prof->rx_pause = !!pfc->pfc_en;
-	prof->tx_pause = !!pfc->pfc_en;
+	prof->rx_pause = !pfc->pfc_en;
+	prof->tx_pause = !pfc->pfc_en;
 	prof->rx_ppp = pfc->pfc_en;
 	prof->tx_ppp = pfc->pfc_en;
 
-- 
1.8.3.4
