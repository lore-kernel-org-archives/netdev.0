From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 5/6] net/mlx4_en: Do not count LLC/SNAP in MTU calculation
Date: Tue,  8 Jul 2014 11:25:23 +0300
Message-ID: <1404807924-29038-6-git-send-email-amirv@mellanox.com>
References: <1404807924-29038-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:47659 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752912AbaGHI00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2014 04:26:26 -0400
In-Reply-To: <1404807924-29038-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yishai Hadas <yishaih@mellanox.com>

LLC/SNAP 8 bytes should not be added as part of header calculation.
If used, payload will be decreased accordingly. For MTU of 1500
we'll set 1522 instead of 1523.


Signed-off-by: Yishai Hadas <yishaih@mellanox.com>
Reviewed-by: Liran Liss <liranl@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 2 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h | 2 --
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index d2d4157..b8ec920 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -922,7 +922,7 @@ static const int frag_sizes[] = {
 void mlx4_en_calc_rx_buf(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	int eff_mtu = dev->mtu + ETH_HLEN + VLAN_HLEN + ETH_LLC_SNAP_SIZE;
+	int eff_mtu = dev->mtu + ETH_HLEN + VLAN_HLEN;
 	int buf_size = 0;
 	int i = 0;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 0e15295..01011d4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -152,8 +152,6 @@ enum {
 #define MLX4_EN_TX_POLL_MODER	16
 #define MLX4_EN_TX_POLL_TIMEOUT	(HZ / 4)
 
-#define ETH_LLC_SNAP_SIZE	8
-
 #define SMALL_PACKET_SIZE      (256 - NET_IP_ALIGN)
 #define HEADER_COPY_SIZE       (128 - NET_IP_ALIGN)
 #define MLX4_LOOPBACK_TEST_PAYLOAD (HEADER_COPY_SIZE - ETH_HLEN)
-- 
1.8.3.4
