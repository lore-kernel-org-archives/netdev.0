From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net V2 2/4] net/mlx4_en: Fix the return value of mlx4_en_dcbnl_set_state()
Date: Sun, 11 Sep 2016 10:56:18 +0300
Message-ID: <1473580580-2323-3-git-send-email-tariqt@mellanox.com>
References: <1473580580-2323-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Kamal Heib <kamalh@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41824 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753891AbcIKH5D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Sep 2016 03:57:03 -0400
In-Reply-To: <1473580580-2323-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamal Heib <kamalh@mellanox.com>

mlx4_en_dcbnl_set_state() returns u8, the return value from
mlx4_en_setup_tc() could be negative in case of failure, so fix that.

Fixes: af7d51852631 ("net/mlx4_en: Add DCB PFC support through CEE netlink commands")
Signed-off-by: Kamal Heib <kamalh@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index 97081e5bafd1..316a70714434 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -239,7 +239,10 @@ static u8 mlx4_en_dcbnl_set_state(struct net_device *dev, u8 state)
 		priv->flags &= ~MLX4_EN_FLAG_DCB_ENABLED;
 	}
 
-	return mlx4_en_setup_tc(dev, num_tcs);
+	if (mlx4_en_setup_tc(dev, num_tcs))
+		return 1;
+
+	return 0;
 }
 
 /* On success returns a non-zero 802.1p user priority bitmap
-- 
1.8.3.1
