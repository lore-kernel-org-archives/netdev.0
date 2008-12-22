From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [ofa-general] [PATCH 6/9] mlx4_en: Remove pauses module parameters
Date: Mon, 22 Dec 2008 12:01:13 +0200
Message-ID: <494F6569.3080105@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org
To: jeff@garzik.org
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

>From 8bd9271caddadecb6310d7306dc50075c371f8c7 Mon Sep 17 00:00:00 2001
From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Sun, 14 Dec 2008 11:37:01 +0200
Subject: [PATCH] mlx4_en: Remove pauses module parameters.

They are controlled through Ethtool interface.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_params.c |   10 ++--------
 1 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/mlx4/en_params.c b/drivers/net/mlx4/en_params.c
index 86f4031..047b37f 100644
--- a/drivers/net/mlx4/en_params.c
+++ b/drivers/net/mlx4/en_params.c
@@ -60,12 +60,6 @@ MLX4_EN_PARM_INT(num_lro, MLX4_EN_MAX_LRO_DESCRIPTORS,
 		 "Number of LRO sessions per ring or disabled (0)");

 /* Priority pausing */
-MLX4_EN_PARM_INT(pptx, MLX4_EN_DEF_TX_PAUSE,
-		 "Pause policy on TX: 0 never generate pause frames "
-		 "1 generate pause frames according to RX buffer threshold");
-MLX4_EN_PARM_INT(pprx, MLX4_EN_DEF_RX_PAUSE,
-		 "Pause policy on RX: 0 ignore received pause frames "
-		 "1 respect received pause frames");
 MLX4_EN_PARM_INT(pfctx, 0, "Priority based Flow Control policy on TX[7:0]."
 			   " Per priority bit mask");
 MLX4_EN_PARM_INT(pfcrx, 0, "Priority based Flow Control policy on RX[7:0]."
@@ -89,9 +83,9 @@ int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 	params->rss_mask = rss_mask & 0x1f;
 	params->num_lro = min_t(int, num_lro , MLX4_EN_MAX_LRO_DESCRIPTORS);
 	for (i = 1; i <= MLX4_MAX_PORTS; i++) {
-		params->prof[i].rx_pause = pprx;
+		params->prof[i].rx_pause = 1;
 		params->prof[i].rx_ppp = pfcrx;
-		params->prof[i].tx_pause = pptx;
+		params->prof[i].tx_pause = 1;
 		params->prof[i].tx_ppp = pfctx;
 	}
 	if (pfcrx || pfctx) {
-- 
1.5.4
