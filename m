From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V2 1/9] net/mlx4_en: Fix UP limit in ieee_ets->prio_tc
Date: Sun,  2 Mar 2014 10:24:57 +0200
Message-ID: <1393748705-1685-2-git-send-email-amirv@mellanox.com>
References: <1393748705-1685-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:34534 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751623AbaCBIZ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Mar 2014 03:25:29 -0500
In-Reply-To: <1393748705-1685-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

User priority limit has to be less than MLX4_EN_NUM_UP.


Signed-off-by: Amir Vadai <amirv@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index b4881b6..c95ca25 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -62,7 +62,7 @@ static int mlx4_en_ets_validate(struct mlx4_en_priv *priv, struct ieee_ets *ets)
 	int has_ets_tc = 0;
 
 	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
-		if (ets->prio_tc[i] > MLX4_EN_NUM_UP) {
+		if (ets->prio_tc[i] >= MLX4_EN_NUM_UP) {
 			en_err(priv, "Bad priority in UP <=> TC mapping. TC: %d, UP: %d\n",
 					i, ets->prio_tc[i]);
 			return -EINVAL;
-- 
1.8.3.4
